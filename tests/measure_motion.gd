extends SceneTree
## Mide el movimiento de los personajes en el juego (ADR-0019): deslizamiento
## del pie de apoyo en la marcha estable, giros por fotograma, aceleración y
## cambios de animación. No es una prueba: imprime líneas «MED» para comparar.
##
##     godot --headless --path . --fixed-fps 30 --script res://tests/measure_motion.gd

var world: Node
func _initialize() -> void:
	world = (load("res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn") as PackedScene).instantiate()
	root.add_child(world)
	_run.call_deferred()

func _bone(sk: Skeleton3D, name: String) -> Vector3:
	return (sk.global_transform * sk.get_bone_global_pose(sk.find_bone(name))).origin

## Recorre [frames] fotogramas y, en los tramos de marcha estable (la misma
## animación de locomoción desde hace 0,5 s), mide cuánto se desliza el pie
## que está más bajo (el de apoyo).
func _measure(actor: NpcActor, label: String, frames: int) -> void:
	var sk: Skeleton3D = actor.find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D
	var prev_l: Vector3 = Vector3.ZERO
	var prev_r: Vector3 = Vector3.ZERO
	var steady: int = 0
	var slides: PackedFloat32Array = []
	var heights: PackedFloat32Array = []
	var raw: PackedFloat32Array = []
	var turns: PackedFloat32Array = []
	var prev_yaw: float = actor.global_rotation.y
	var prev_speed: float = 0.0
	var prev_pos: Vector3 = actor.global_position
	var accel_max: float = 0.0
	var transitions: int = 0
	var last_anim: StringName = actor.current_animation()
	for f: int in range(frames):
		await process_frame
		sk.force_update_all_bone_transforms()
		var anim: StringName = actor.current_animation()
		if anim != last_anim:
			transitions += 1
			steady = 0
			last_anim = anim
		var l: Vector3 = _bone(sk, "LeftToeBase")
		var r: Vector3 = _bone(sk, "RightToeBase")
		if (anim == &"walk" or anim == &"run") and actor.moving:
			steady += 1
			if steady > 15:
				var plant: Vector3 = l if l.y < r.y else r
				var before: Vector3 = prev_l if l.y < r.y else prev_r
				# Se guarda con su altura; el contacto se decide al final, respecto
				# a la altura mínima del pie (al correr hay fases de vuelo).
				heights.append(minf(plant.y, before.y) - actor.global_position.y)
				raw.append(Vector2(plant.x - before.x, plant.z - before.z).length() * 30.0)
		else:
			steady = 0
		prev_l = l
		prev_r = r
		var yaw: float = actor.global_rotation.y
		turns.append(absf(rad_to_deg(wrapf(yaw - prev_yaw, -PI, PI))))
		prev_yaw = yaw
		var speed: float = Vector2(actor.global_position.x - prev_pos.x, actor.global_position.z - prev_pos.z).length() * 30.0
		accel_max = maxf(accel_max, absf(speed - prev_speed) * 30.0)
		prev_speed = speed
		prev_pos = actor.global_position
	var floor_h: float = 99.0
	for h: float in heights:
		floor_h = minf(floor_h, h)
	for i: int in range(raw.size()):
		if heights[i] < floor_h + 0.012:
			slides.append(raw[i])
	var sorted: PackedFloat32Array = slides.duplicate()
	sorted.sort()
	var med: float = sorted[sorted.size() / 2] if sorted.size() > 0 else 0.0
	var p90: float = sorted[int(sorted.size() * 0.9)] if sorted.size() > 0 else 0.0
	var big_turns: int = 0
	var turn_max: float = 0.0
	for t: float in turns:
		turn_max = maxf(turn_max, t)
		if t > 20.0:
			big_turns += 1
	print("MED %s | muestras %d | desliz pie apoyo mediana %.2f p90 %.2f m/s | giro max %.0f°/fot (%d giros bruscos) | acel max %.1f m/s² | cambios anim %d" % [label, sorted.size(), med, p90, turn_max, big_turns, accel_max, transitions])

func _run() -> void:
	for i: int in range(20):
		await process_frame
	var player: Node3D = world.get_node("PlayerFPS") as Node3D
	player.process_mode = Node.PROCESS_MODE_DISABLED
	player.global_position = Vector3(40, 0, 40)
	var n1: NpcActor = world.get_node("Llacta/NPCs/Habitante1") as NpcActor
	await _measure(n1, "vecina paseando 20 s", 600)
	var event: MessengerEvent = world.get_node("EventController") as MessengerEvent
	event.start()
	var m: NpcActor = world.get_node("Llacta/NPCs/Mensajero") as NpcActor
	var cur: NpcActor = world.get_node("Llacta/NPCs/Curaca") as NpcActor
	await _measure(m, "mensajero corre y llega", 450)
	await _measure(cur, "curaca hacia la reunión", 300)
	quit()
