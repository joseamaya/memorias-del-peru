class_name CapeSprings
extends RefCounted
## Muelles del manto de los personajes Quaternius.
##
## El generador añade seis huesos `Cape_<L|C|R>_1/2` colgando de `spine_03`.
## Este helper monta un [SpringBoneSimulator3D] sobre ellos y cápsulas de
## colisión en el pelvis y la cintura. No conoce escenas ni campañas: devuelve
## el simulador o `null` si el modelo no trae cadenas de manto.

const CHAINS: Array[String] = ["L", "C", "R"]
const STIFFNESS: float = 2.6
const DRAG: float = 0.6
const GRAVITY: float = 0.9
const RADIUS: float = 0.03
## Huesos del rig UBC que el manto no debe atravesar.
const COLLIDERS: Dictionary[String, Vector2] = {
	"pelvis": Vector2(0.17, 0.42),
	"spine_01": Vector2(0.17, 0.4),
}


## Crea el simulador bajo [param skeleton]. Devuelve `null` si no hay cadenas
## completas o si el esqueleto es nulo.
static func setup(skeleton: Skeleton3D) -> SpringBoneSimulator3D:
	if skeleton == null:
		return null
	var chains: Array[String] = []
	for chain: String in CHAINS:
		if (skeleton.find_bone("Cape_%s_1" % chain) >= 0
			and skeleton.find_bone("Cape_%s_2" % chain) >= 0):
			chains.append(chain)
	if chains.is_empty():
		return null
	var springs: SpringBoneSimulator3D = SpringBoneSimulator3D.new()
	springs.name = "CapeSprings"
	skeleton.add_child(springs)
	springs.setting_count = chains.size()
	for index: int in range(chains.size()):
		var chain: String = chains[index]
		springs.set_root_bone_name(index, "Cape_%s_1" % chain)
		springs.set_end_bone_name(index, "Cape_%s_2" % chain)
		springs.set_extend_end_bone(index, true)
		springs.set_end_bone_length(index, 0.12)
		springs.set_stiffness(index, STIFFNESS)
		springs.set_drag(index, DRAG)
		springs.set_gravity(index, GRAVITY)
		springs.set_radius(index, RADIUS)
		springs.set_enable_all_child_collisions(index, true)
	for bone: String in COLLIDERS:
		if skeleton.find_bone(bone) < 0:
			continue
		var capsule: SpringBoneCollisionCapsule3D = SpringBoneCollisionCapsule3D.new()
		capsule.name = "Collider%s" % bone.capitalize()
		capsule.bone_name = bone
		capsule.radius = COLLIDERS[bone].x
		capsule.height = COLLIDERS[bone].y
		springs.add_child(capsule)
	return springs
