class_name AmbushEnemy
extends CharacterBody3D
## Explorador chanca del acto II.
##
## Maniquí UAL1 teñido como chanca; la ropa y la cara llegan como capas encima
## (ADR-0042). La lógica de combate vive en [EnemyCombatant]; este nodo la mueve,
## orienta al enemigo hacia el jugador y aplica el daño.

const SPEED: float = 2.4
## Velocidad de desplazamiento del ciclo de carrera del modelo (m/s). El clip
## se reproduce a SPEED / RUN_CYCLE_SPEED para que los pies acompañen al cuerpo.
const RUN_CYCLE_SPEED: float = 3.0
## Grados por segundo a los que el cuerpo encara al objetivo.
const TURN_RATE: float = 220.0
## Distancia a la que se detiene aunque el golpe esté en recarga: sin esto se
## seguía acercando durante la espera y acababa dentro de la cámara.
const STANDOFF_DISTANCE: float = 1.9
## Anticipación del golpe: la porra sube y el daño llega al final del gesto.
const ATTACK_WINDUP: float = 0.45
const ATTACK_REACH: float = 2.9
const MORALE_LOSS: float = 15.0
const MODEL_PATH: String = "res://campaigns/01_pachacutec/assets/models/pch_npc_commoner.glb"
## Duración de la caída del enemigo derribado.
const FALL_SECONDS: float = 0.85

var player: Node3D = null
var paso: Node = null
var character: CharacterState = null
var brain: EnemyCombatant = null
## Director del encuentro; si es null, el enemigo ataca por su cuenta.
var director: EncounterDirector = null

var _resolved: bool = false
var _visual: CharacterModelVisual = null
var _current_clip: StringName = &""
var _winding_up: bool = false
var _windup_left: float = 0.0
var _has_token: bool = false
var _telegraph: MeshInstance3D = null
var _strafe_sign: int = 1
var _strafe_elapsed: float = 0.0


func _ready() -> void:
	collision_layer = 8
	# Choca con el mundo (1) y con los otros chancas (8): así se separan al
	# rodear al jugador en lugar de apilarse en el mismo punto.
	collision_mask = 9
	_visual = CharacterModelVisual.new()
	_visual.name = "Visual"
	_visual.model_path = MODEL_PATH
	_visual.dark_clothes = true
	_visual.porra = true
	# El chanca es el único que corre hacia el jugador: algo más alto que la
	# aldea y sin variación, para que los cuatro se lean como un grupo.
	_visual.target_height = 1.67
	_visual.height_variation = 0.0

	add_child(_visual)
	var shape: CollisionShape3D = CollisionShape3D.new()
	var capsule_shape: CapsuleShape3D = CapsuleShape3D.new()
	capsule_shape.radius = 0.35
	capsule_shape.height = 1.75
	shape.shape = capsule_shape
	shape.position = Vector3(0.0, 0.875, 0.0)
	add_child(shape)
	character = CharacterState.new()
	character.name = "CharacterState"
	character.max_health = 60.0
	character.health = 60.0
	character.max_morale = 80.0
	character.morale = 80.0
	add_child(character)
	brain = EnemyCombatant.new()
	brain.character = character
	brain.weapon = _make_weapon()
	brain.team = &"chanca"
	brain.alert_radius = 30.0
	brain.flee_morale = 25.0
	add_child(brain)
	_build_telegraph()


## Asigna el objetivo y la escena que recibe el daño del jugador.
func setup(target: Node3D, scene: Node) -> void:
	player = target
	paso = scene


func _physics_process(delta: float) -> void:
	if _resolved or player == null or paso == null or brain == null:
		return
	if paso.call("is_ambush_active") != true:
		return
	if not character.is_alive():
		_resolve()
		return
	var distance: float = global_position.distance_to(player.global_position)
	var intent: EnemyCombatant.Intent = brain.think(delta, distance, true)
	if intent != EnemyCombatant.Intent.IDLE:
		_face(player.global_position, delta)
	match intent:
		EnemyCombatant.Intent.APPROACH:
			_cancel_windup()
			if distance > STANDOFF_DISTANCE:
				_play_visual(&"Walk")
				_move_towards(player.global_position)
			else:
				_play_visual(&"Idle")
				velocity = Vector3.ZERO
		EnemyCombatant.Intent.FLEE:
			_cancel_windup()
			_play_visual(&"Walk")
			var away: Vector3 = global_position + (global_position - player.global_position).normalized() * 10.0
			_move_towards(away)
			if distance > 30.0:
				_resolve()
		EnemyCombatant.Intent.ATTACK:
			if not _winding_up:
				# Sin ficha del director, el enemigo rodea en vez de atacar.
				if director != null and not director.has_token(self):
					if not director.request_token(self):
						_strafe(delta, distance)
						return
					_has_token = true
				_winding_up = true
				_windup_left = ATTACK_WINDUP
				_set_telegraph(true)
				CampaignAudio.play_sfx(CampaignAudio.PORRA_PATH, -18.0)
				_play_visual(&"attack")
			else:
				_windup_left -= delta
				if _windup_left <= 0.0:
					_winding_up = false
					_set_telegraph(false)
					if distance <= ATTACK_REACH:
						var damage: float = brain.attack(1.0)
						if damage > 0.0:
							CampaignAudio.play_sfx(CampaignAudio.PORRA_PATH, -10.0)
							paso.call("apply_player_damage", damage, self)
					_release_token()
		EnemyCombatant.Intent.IDLE:
			_cancel_windup()
			_play_visual(&"Idle")
			velocity = Vector3.ZERO


## Aplica un golpe del jugador. Al perder la moral, el cerebro ordena huir.
func take_hit(amount: float) -> void:
	if _resolved or brain == null:
		return
	_cancel_windup()
	brain.take_damage(amount, MORALE_LOSS)
	if _visual != null:
		_visual.flash_hit()
	_play_visual(&"hit")
	if not character.is_alive():
		_resolve()


## Interrumpe el golpe en curso (por un parry o un empujón).
func stagger() -> void:
	if _resolved:
		return
	_cancel_windup()
	_play_visual(&"hit")


## Indica si ya no cuenta para la emboscada (derribado o huido).
func is_resolved() -> bool:
	return _resolved or not character.is_alive() or brain.is_fleeing()


## Indica si sigue en pie y en el combate.
func is_alive() -> bool:
	return not _resolved and character.is_alive() and not brain.is_fleeing()


## Reproduce un clip. Los de un solo disparo (`attack`, `hit`) se repiten
## aunque sean el mismo que el anterior: si no, dos golpes seguidos se verían
## como uno solo.
func _play_visual(clip: StringName) -> void:
	if _visual == null:
		return
	if _current_clip == clip and clip != &"attack" and clip != &"hit" and clip != &"death":
		return
	_current_clip = clip
	if clip == &"Walk":
		# El chanca trota: el ciclo se ajusta a la velocidad real. Antes se
		# reproducía a 1.0 con un clip de 3 m/s y el cuerpo iba a 2,4: los pies
		# patinaban.
		_visual.play_locomotion(SPEED)
		return
	_visual.play(clip)


## Gira el cuerpo hacia el objetivo; el modelo mira hacia -Z. El giro es
## progresivo: un `look_at` instantáneo cada fotograma convertía al chanca en
## una peonza que encaraba al jugador de golpe.
func _face(target: Vector3, delta: float) -> void:
	var flat: Vector3 = Vector3(target.x, global_position.y, target.z)
	var to: Vector3 = flat - global_position
	if to.length() <= 0.05:
		return
	var desired: float = atan2(-to.x, -to.z)
	rotation.y = move_toward(rotation.y, desired, deg_to_rad(TURN_RATE) * delta)


## Visual del enemigo, para las pruebas.
func visual() -> CharacterModelVisual:
	return _visual


func _move_towards(target: Vector3) -> void:
	var direction: Vector3 = target - global_position
	direction.y = 0.0
	if direction.length() < 0.05:
		velocity = Vector3.ZERO
		return
	direction = direction.normalized()
	if director != null:
		direction = (direction + director.separation(self)).normalized()
	velocity = direction * SPEED
	move_and_slide()


## Rodea al jugador cuando no tiene ficha de ataque: así el grupo espera su
## turno en vez de quedarse quieto o apilarse.
func _strafe(delta: float, distance: float) -> void:
	_strafe_elapsed += delta
	if _strafe_elapsed >= 1.8:
		_strafe_elapsed = 0.0
		_strafe_sign = -_strafe_sign
	var to_player: Vector3 = player.global_position - global_position
	to_player.y = 0.0
	if to_player.length() <= 0.05:
		return
	var radial: Vector3 = to_player.normalized()
	var tangent: Vector3 = radial.cross(Vector3.UP) * float(_strafe_sign)
	var correction: float = clampf(distance - STANDOFF_DISTANCE, -1.0, 1.0)
	var direction: Vector3 = (tangent + radial * correction).normalized()
	if director != null:
		direction = (direction + director.separation(self)).normalized()
	velocity = direction * SPEED * 0.7
	move_and_slide()
	_play_visual(&"Walk")


func _build_telegraph() -> void:
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.075
	mesh.height = 0.15
	mesh.radial_segments = 6
	mesh.rings = 3
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.58, 0.16, 1.0)
	material.emission_enabled = true
	material.emission = Color(1.0, 0.38, 0.08, 1.0)
	material.emission_energy_multiplier = 2.2
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_telegraph = MeshInstance3D.new()
	_telegraph.name = "AttackTelegraph"
	_telegraph.mesh = mesh
	_telegraph.material_override = material
	_telegraph.position = Vector3(0.0, 2.08, 0.0)
	_telegraph.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_telegraph.visible = false
	add_child(_telegraph)


func _set_telegraph(value: bool) -> void:
	if _telegraph != null:
		_telegraph.visible = value


func _cancel_windup() -> void:
	if not _winding_up and not _has_token:
		return
	_winding_up = false
	_windup_left = 0.0
	_set_telegraph(false)
	_release_token()


func _release_token() -> void:
	if director != null and _has_token:
		director.release_token(self)
	_has_token = false


func _resolve() -> void:
	if _resolved:
		return
	_resolved = true
	_cancel_windup()
	if director != null:
		director.unregister(self)
	# Un cuerpo derribado no debe seguir bloqueando los ataques ni el paso: si
	# conserva la colisión, el rayo del jugador sigue golpeando el cadáver y los
	# compañeros quedan detrás. Se difiere porque estamos en el tick de física.
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	set_physics_process(false)
	if paso != null:
		paso.call("on_enemy_resolved")
	if character != null and not character.is_alive() and _visual != null:
		_fall()
		return
	visible = false


## Caída del enemigo derribado: reproduce el clip `death` y se oculta cuando
## termina. Si el clip faltara, cae con un giro del nodo como respaldo.
func _fall() -> void:
	var seconds: float = _visual.clip_length(&"death")
	if seconds > 0.0:
		_play_visual(&"death")
		await get_tree().create_timer(seconds).timeout
		if is_inside_tree():
			visible = false
		return
	_play_visual(&"hit")
	var fall: Tween = create_tween()
	fall.set_parallel(true)
	fall.set_trans(Tween.TRANS_QUAD)
	fall.set_ease(Tween.EASE_IN)
	fall.tween_property(_visual, "rotation:x", deg_to_rad(-82.0), FALL_SECONDS)
	fall.tween_property(_visual, "position:y", _visual.position.y - 0.18, FALL_SECONDS)
	fall.chain().tween_callback(func() -> void:
		if is_inside_tree():
			visible = false)


static func _make_weapon() -> CombatWeapon:
	var weapon: CombatWeapon = CombatWeapon.new()
	# Porra, no honda: el chanca lleva una maza en la mano y golpea de cerca.
	# Antes el arma era una honda con 22 m de alcance, así que golpeaba desde
	# lejos con una animación de maza y se pegaba a la cámara sin atacar.
	weapon.kind = CombatWeapon.Kind.CLUB
	weapon.damage_min = 8.0
	weapon.damage_max = 14.0
	weapon.range_min = 1.0
	weapon.range_max = 2.6
	weapon.charge_full_seconds = 1.0
	weapon.stamina_cost = 0.0
	weapon.cooldown_seconds = 2.0
	weapon.windup_seconds = ATTACK_WINDUP
	weapon.active_seconds = 0.12
	weapon.recovery_seconds = 0.40
	weapon.lunge_distance = 0.0
	return weapon
