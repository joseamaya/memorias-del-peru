class_name MannequinLooks
extends RefCounted
## Looks de los diez papeles del elenco sobre el maniquí UAL1 de la campaña 01.
##
## Cuerpo de dos colores y piezas primitivas sobre huesos reales. La ropa es
## reconstrucción (R) sobre PCH-017/018/024: unku, anacu, lliclla, manto, faja,
## chuspa, tupu, cinta y paño. No hay caras, telas esculpidas ni metales; las
## autoridades locales no llevan orejeras ni oro (guía visual).

const CREAM: Color = Color(0.78, 0.70, 0.55, 1.0)
const RED: Color = Color(0.62, 0.10, 0.08, 1.0)
const OCHRE: Color = Color(0.86, 0.66, 0.16, 1.0)
const BROWN: Color = Color(0.42, 0.30, 0.20, 1.0)
const DARK: Color = Color(0.16, 0.12, 0.10, 1.0)
const TEAL: Color = Color(0.16, 0.35, 0.42, 1.0)
const COPPER: Color = Color(0.72, 0.36, 0.16, 1.0)
const GRAY: Color = Color(0.46, 0.43, 0.39, 1.0)
const CHARCOAL: Color = Color(0.20, 0.18, 0.17, 1.0)
const SLATE: Color = Color(0.24, 0.26, 0.28, 1.0)
const BLUE: Color = Color(0.20, 0.30, 0.48, 1.0)
const SAND: Color = Color(0.62, 0.52, 0.38, 1.0)
const PALE: Color = Color(0.82, 0.76, 0.64, 1.0)
const OLIVE: Color = Color(0.35, 0.33, 0.22, 1.0)
const SILVER: Color = Color(0.62, 0.60, 0.56, 1.0)
const TRAVEL: Color = Color(0.30, 0.22, 0.15, 1.0)
const HAIR: Color = Color(0.19, 0.13, 0.10, 1.0)

const TOP_SIZE: Vector3 = Vector3(0.245, 0.46, 0.0)
const TOP_AT: Vector3 = Vector3(0.0, 0.08, 0.0)
const SKIRT_SIZE: Vector3 = Vector3(0.255, 0.32, 0.0)
const SKIRT_AT: Vector3 = Vector3(0.0, -0.09, 0.0)
const LONG_SKIRT_SIZE: Vector3 = Vector3(0.265, 0.58, 0.0)
const LONG_SKIRT_AT: Vector3 = Vector3(0.0, -0.23, 0.0)
const BELT_SIZE: Vector3 = Vector3(0.252, 0.06, 0.0)
const BELT_AT: Vector3 = Vector3(0.0, 0.05, 0.0)
const MANTO_SIZE: Vector3 = Vector3(0.48, 0.50, 0.04)
const MANTO_AT: Vector3 = Vector3(0.0, 0.02, -0.27)
const HEAVY_MANTO_SIZE: Vector3 = Vector3(0.50, 0.52, 0.06)
const CINTA_SIZE: Vector3 = Vector3(0.09, 0.11, 0.0)
const CINTA_AT: Vector3 = Vector3(0.0, 0.10, 0.01)
const TUPU_AT: Vector3 = Vector3(0.0, 0.22, 0.264)

## Orden de la captura de contacto y del catálogo.
const ROLE_NAMES: Array[String] = [
	"Curaca", "Sisa", "Chanca", "Anca", "Puma",
	"Madre", "Hermano", "Joven", "Anciana", "Mensajero",
]
## Alturas de la tabla de la llacta; la anciana es arquetipo de multitud.
const ROLE_HEIGHTS: Array[float] = [
	1.65, 1.50, 1.60, 1.58, 1.63,
	1.53, 1.56, 1.57, 1.48, 1.60,
]


## Los diez looks en el orden de [constant ROLE_NAMES].
static func all() -> Array[CharacterLook]:
	var looks: Array[CharacterLook] = []
	for role: String in ROLE_NAMES:
		looks.append(for_role(role))
	return looks


## Papeles que pueden aparecer en la multitud: la comunidad y el viajero, sin
## las autoridades ni el enemigo, para no confundir a un vecino con el curaca.
const CROWD_ROLES: Array[String] = [
	"Sisa", "Anca", "Madre", "Anciana", "Joven", "Hermano", "Mensajero",
]


## Piezas que conserva la multitud: silueta, color y cabeza, sin tupu,
## chuspa, bulto ni el panel trasero del manto.
const CROWD_KEEP: Array[String] = [
	"UnkuTop", "AnacuTop", "UnkuSkirt", "AnacuSkirt", "AnacuHem",
	"Faja", "Cinta", "LlicllaFront", "HairBack", "Pano",
]


## Papel de multitud para un índice estable, sin depender de la escena.
static func crowd_role(variant: int) -> String:
	return CROWD_ROLES[posmod(variant, CROWD_ROLES.size())]


## Reduce un look para la multitud conservando la identidad de frente.
static func crowd_from(look: CharacterLook) -> CharacterLook:
	var crowd: CharacterLook = CharacterLook.new()
	crowd.skin = look.skin
	crowd.joints = look.joints
	for part: LookPart in look.parts:
		if CROWD_KEEP.has(part.name):
			crowd.parts.append(part)
	return crowd


## Look del papel. Los papeles sin modelo propio reutilizan un arquetipo.
static func for_role(role: String) -> CharacterLook:
	match role:
		"Anca", "Tejedora", "weaver":
			return anca()
		"Puma", "Principal2", "principal":
			return puma()
		"Madre", "Habitante1", "Herido2", "Comitiva1":
			return madre()
		"Hermano", "Habitante2", "Herido1", "Comitiva2":
			return hermano()
		"Joven", "Agricultor", "HijoPuma", "farmer", "joven", "Comitiva3":
			return joven()
		"Anciana", "anciana":
			return anciana()
		"Mensajero", "messenger":
			return mensajero()
		"Sisa", "Habitante3":
			return sisa()
		"Chanca", "chanca":
			return chanca()
		"Curaca", "CuracaVecino", "curaca":
			return curaca()
	return joven()


## Autoridad local: unku crema con franja de t'oqapu, manto rojo, cinta y
## chuspa. Sin orejeras, vara, oro ni metales.
static func curaca() -> CharacterLook:
	var look: CharacterLook = _look(Color(0.56, 0.38, 0.26), Color(0.16, 0.10, 0.08))
	_top(look, CREAM)
	_skirt(look, false, CREAM)
	_belt(look, RED)
	_add(look, "Toqapu", &"spine_02", LookPart.Shape.BOX,
		Vector3(0.26, 0.10, 0.02), Vector3(0.0, 0.16, 0.25), RED)
	_add(look, "ToqapuStripe", &"spine_02", LookPart.Shape.BOX,
		Vector3(0.26, 0.028, 0.012), Vector3(0.0, 0.16, 0.256), OCHRE)
	_back_cloth(look, RED, "Manto", false)
	_cinta(look, OCHRE)
	_chuspa(look, BLUE, 1.0)
	return look


## Mujer joven de la comunidad: anacu pardo con ruedo rojo, lliclla crema,
## faja, cinta, tupu y trenzas.
static func sisa() -> CharacterLook:
	var look: CharacterLook = _look(Color(0.63, 0.46, 0.35), Color(0.30, 0.20, 0.15))
	_top(look, BROWN, "AnacuTop")
	_skirt(look, true, BROWN)
	_add(look, "AnacuHem", &"pelvis", LookPart.Shape.CYLINDER,
		Vector3(0.27, 0.06, 0.0), Vector3(0.0, -0.50, 0.0), RED)
	_back_cloth(look, CREAM, "Lliclla", false)
	_lliclla_front(look, CREAM)
	_belt(look, RED)
	_cinta(look, RED)
	_tupu(look)
	_hair_back(look, HAIR)
	return look


## Explorador chanca: unku oscuro, manto pesado y acento teal. Las armas van
## aparte, en el actor de combate.
static func chanca() -> CharacterLook:
	var look: CharacterLook = _look(Color(0.45, 0.30, 0.21), Color(0.14, 0.14, 0.16))
	_top(look, CHARCOAL)
	_skirt(look, false, SLATE)
	_belt(look, TEAL)
	_back_cloth(look, CHARCOAL, "Manto", true)
	_cinta(look, TEAL)
	return look


## Mujer de la comitiva: anacu pardo, lliclla ocre, faja roja, tupu y trenzas.
## Es también el look de la Tejedora.
static func anca() -> CharacterLook:
	var look: CharacterLook = _look(Color(0.60, 0.43, 0.31), Color(0.28, 0.18, 0.13))
	_top(look, SAND, "AnacuTop")
	_skirt(look, true, BROWN)
	_add(look, "AnacuHem", &"pelvis", LookPart.Shape.CYLINDER,
		Vector3(0.27, 0.06, 0.0), Vector3(0.0, -0.50, 0.0), OCHRE)
	_back_cloth(look, OCHRE, "Lliclla", false)
	_lliclla_front(look, OCHRE)
	_belt(look, RED)
	_cinta(look, RED)
	_tupu(look)
	_hair_back(look, HAIR)
	return look


## Principal de la comunidad: autoridad sin t'oqapu, manto ocre y chuspa.
static func puma() -> CharacterLook:
	var look: CharacterLook = _look(Color(0.52, 0.36, 0.26), Color(0.20, 0.14, 0.10))
	_top(look, OLIVE)
	_skirt(look, false, BROWN)
	_belt(look, OCHRE)
	_back_cloth(look, OCHRE, "Manto", false)
	_cinta(look, OCHRE)
	_chuspa(look, DARK, 1.0)
	return look


## Madre de Rumi: anacu y lliclla apagados, paño en la cabeza, tupu y trenzas.
static func madre() -> CharacterLook:
	var look: CharacterLook = _look(Color(0.58, 0.41, 0.30), Color(0.24, 0.16, 0.12))
	_top(look, GRAY, "AnacuTop")
	_skirt(look, true, GRAY)
	_add(look, "AnacuHem", &"pelvis", LookPart.Shape.CYLINDER,
		Vector3(0.27, 0.06, 0.0), Vector3(0.0, -0.50, 0.0), PALE)
	_back_cloth(look, PALE, "Lliclla", false)
	_lliclla_front(look, PALE)
	_belt(look, DARK)
	_tupu(look)
	_head_cloth(look, DARK)
	return look


## Hermano menor: unku corto, manto pequeño, faja roja y chuspa.
static func hermano() -> CharacterLook:
	var look: CharacterLook = _look(Color(0.60, 0.43, 0.31), Color(0.26, 0.18, 0.13))
	_top(look, CREAM)
	_skirt(look, false, SAND)
	_belt(look, RED)
	_back_cloth(look, BROWN, "Manto", false)
	_cinta(look, DARK)
	_chuspa(look, BROWN, 0.8)
	return look


## Hombre joven de la comunidad: unku sencillo y chuspa. Es el Agricultor,
## el HijoPuma y el arquetipo de multitud.
static func joven() -> CharacterLook:
	var look: CharacterLook = _look(Color(0.56, 0.39, 0.27), Color(0.24, 0.16, 0.11))
	_top(look, SAND)
	_skirt(look, false, SAND)
	_belt(look, BROWN)
	_cinta(look, DARK)
	_chuspa(look, CREAM, 1.0)
	return look


## Mujer mayor: anacu y lliclla grises, paño, trenzas canas y tupu.
static func anciana() -> CharacterLook:
	var look: CharacterLook = _look(Color(0.60, 0.45, 0.34), Color(0.28, 0.20, 0.15))
	_top(look, GRAY, "AnacuTop")
	_skirt(look, true, GRAY)
	_add(look, "AnacuHem", &"pelvis", LookPart.Shape.CYLINDER,
		Vector3(0.27, 0.06, 0.0), Vector3(0.0, -0.50, 0.0), PALE)
	_back_cloth(look, SILVER, "Lliclla", false)
	_lliclla_front(look, SILVER)
	_belt(look, DARK)
	_tupu(look)
	_head_cloth(look, GRAY)
	return look


## Mensajero: ropa de viaje sin insignias, paño, chuspa, correa y bulto.
static func mensajero() -> CharacterLook:
	var look: CharacterLook = _look(Color(0.50, 0.34, 0.24), Color(0.18, 0.12, 0.09))
	_top(look, TRAVEL)
	_skirt(look, false, TRAVEL)
	_belt(look, OCHRE)
	_back_cloth(look, TRAVEL, "Manto", false)
	_head_cloth(look, DARK)
	_chuspa(look, OCHRE, 1.0)
	_add(look, "Bulto", &"spine_02", LookPart.Shape.BOX,
		Vector3(0.24, 0.28, 0.16), Vector3(0.0, 0.0, -0.38), TRAVEL)
	_add(look, "Correa", &"spine_02", LookPart.Shape.BOX,
		Vector3(0.04, 0.50, 0.02), Vector3(0.06, 0.04, 0.25), DARK, Vector3(0.0, 0.0, -18.0))
	return look


static func _look(skin_color: Color, joint_color: Color) -> CharacterLook:
	var look: CharacterLook = CharacterLook.new()
	look.skin = skin_color
	look.joints = joint_color
	return look


static func _top(look: CharacterLook, color: Color, part_name: String = "UnkuTop") -> void:
	_add(look, part_name, &"spine_02", LookPart.Shape.CYLINDER,
		TOP_SIZE, TOP_AT, color)


static func _skirt(look: CharacterLook, long: bool, color: Color) -> void:
	var part_name: String = "AnacuSkirt" if long else "UnkuSkirt"
	var size: Vector3 = LONG_SKIRT_SIZE if long else SKIRT_SIZE
	var at: Vector3 = LONG_SKIRT_AT if long else SKIRT_AT
	_add(look, part_name, &"pelvis", LookPart.Shape.CYLINDER, size, at, color)


static func _belt(look: CharacterLook, color: Color) -> void:
	_add(look, "Faja", &"pelvis", LookPart.Shape.CYLINDER,
		BELT_SIZE, BELT_AT, color)


static func _back_cloth(look: CharacterLook, color: Color, part_name: String,
		heavy: bool) -> void:
	_add(look, part_name, &"spine_02", LookPart.Shape.BOX,
		HEAVY_MANTO_SIZE if heavy else MANTO_SIZE, MANTO_AT, color)


static func _cinta(look: CharacterLook, color: Color) -> void:
	_add(look, "Cinta", &"Head", LookPart.Shape.RING, CINTA_SIZE, CINTA_AT, color)


## Melena posterior: una placa oscura detrás de la cabeza que asoma a los
## lados y por detrás. El maniquí no tiene cara ni pelo esculpido; esta pieza
## distingue a las mujeres de los hombres sin inventar un peinado moderno.
static func _hair_back(look: CharacterLook, color: Color) -> void:
	_add(look, "HairBack", &"Head", LookPart.Shape.BOX,
		Vector3(0.24, 0.24, 0.03), Vector3(0.0, -0.03, -0.08), color)


## Paño en la cabeza: cinta ancha y caída en la nuca.
static func _head_cloth(look: CharacterLook, color: Color) -> void:
	_add(look, "Pano", &"Head", LookPart.Shape.RING,
		Vector3(0.10, 0.12, 0.0), CINTA_AT, color)
	_add(look, "PanoBack", &"Head", LookPart.Shape.BOX,
		Vector3(0.26, 0.22, 0.025), Vector3(0.0, -0.02, -0.08), color,
		Vector3(8.0, 0.0, 0.0))


## Lliclla delantera: el paño que se prende con el tupu y que, a diferencia del
## manto, se ve de frente.
static func _lliclla_front(look: CharacterLook, color: Color) -> void:
	_add(look, "LlicllaFront", &"spine_02", LookPart.Shape.BOX,
		Vector3(0.34, 0.14, 0.03), Vector3(0.0, 0.24, 0.24), color)


static func _tupu(look: CharacterLook) -> void:
	_add(look, "Tupu", &"spine_02", LookPart.Shape.DISC,
		Vector3(0.025, 0.008, 0.0), TUPU_AT, COPPER, Vector3(90.0, 0.0, 0.0))


static func _chuspa(look: CharacterLook, color: Color, scale: float) -> void:
	_add(look, "Chuspa", &"spine_02", LookPart.Shape.BOX,
		Vector3(0.12, 0.18, 0.08) * scale, Vector3(0.28, -0.02, 0.08), color)


static func _add(look: CharacterLook, part_name: String, bone: StringName,
		shape: LookPart.Shape, size: Vector3, offset: Vector3, color: Color,
		rotation_deg: Vector3 = Vector3.ZERO) -> void:
	look.parts.append(_part(part_name, bone, shape, size, offset, color, rotation_deg))


static func _part(part_name: String, bone: StringName, shape: LookPart.Shape,
		size: Vector3, offset: Vector3, color: Color,
		rotation_deg: Vector3 = Vector3.ZERO) -> LookPart:
	var part: LookPart = LookPart.new()
	part.name = part_name
	part.bone = bone
	part.shape = shape
	part.size = size
	part.offset = offset
	part.color = color
	part.rotation_deg = rotation_deg
	return part
