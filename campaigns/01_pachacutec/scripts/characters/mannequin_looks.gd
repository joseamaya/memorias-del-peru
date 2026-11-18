class_name MannequinLooks
extends RefCounted
## Looks de prototipo para los maniquíes UAL1 de la campaña 01.
##
## Siguen la idea del proyecto de referencia: cuerpo de dos colores y piezas
## primitivas sobre huesos reales (spine_02, pelvis, Head). Los colores y las
## piezas se ajustan aquí mientras se aprueba el estilo; después se pueden
## serializar a recursos .tres.

const CREAM: Color = Color(0.78, 0.70, 0.55, 1.0)
const RED: Color = Color(0.62, 0.10, 0.08, 1.0)
const OCHRE: Color = Color(0.86, 0.66, 0.16, 1.0)
const BROWN: Color = Color(0.42, 0.30, 0.20, 1.0)
const DARK: Color = Color(0.16, 0.12, 0.10, 1.0)
const TEAL: Color = Color(0.16, 0.35, 0.42, 1.0)
const COPPER: Color = Color(0.72, 0.36, 0.16, 1.0)


## Autoridad local: unku crema, faja y manto rojos, llauto y orejeras.
static func curaca() -> CharacterLook:
	var look: CharacterLook = CharacterLook.new()
	look.skin = Color(0.55, 0.36, 0.24)
	look.joints = Color(0.16, 0.10, 0.08)
	var parts: Array[LookPart] = []
	parts.append(_part("UnkuTop", &"spine_02", LookPart.Shape.CYLINDER,
		Vector3(0.245, 0.46, 0.0), Vector3(0.0, 0.08, 0.0), CREAM))
	parts.append(_part("UnkuSkirt", &"pelvis", LookPart.Shape.CYLINDER,
		Vector3(0.255, 0.32, 0.0), Vector3(0.0, -0.09, 0.0), CREAM))
	parts.append(_part("Faja", &"pelvis", LookPart.Shape.CYLINDER,
		Vector3(0.25, 0.07, 0.0), Vector3(0.0, 0.05, 0.0), RED))
	parts.append(_part("Manto", &"spine_02", LookPart.Shape.BOX,
		Vector3(0.48, 0.50, 0.04), Vector3(0.0, 0.02, -0.27), RED))
	parts.append(_part("Llauto", &"Head", LookPart.Shape.RING,
		Vector3(0.095, 0.115, 0.0), Vector3(0.0, 0.10, 0.01), OCHRE))
	parts.append(_part("OrejeraL", &"Head", LookPart.Shape.DISC,
		Vector3(0.035, 0.015, 0.0), Vector3(0.085, 0.05, 0.0), OCHRE, Vector3(0.0, 0.0, 90.0)))
	parts.append(_part("OrejeraR", &"Head", LookPart.Shape.DISC,
		Vector3(0.035, 0.015, 0.0), Vector3(-0.085, 0.05, 0.0), OCHRE, Vector3(0.0, 0.0, 90.0)))
	parts.append(_part("Chuspa", &"spine_02", LookPart.Shape.BOX,
		Vector3(0.12, 0.18, 0.08), Vector3(0.28, -0.02, 0.08), Color(0.20, 0.30, 0.48, 1.0)))
	look.parts = parts
	return look


## Mujer de la comunidad: anacu largo, lliclla, faja y tupu.
static func sisa() -> CharacterLook:
	var look: CharacterLook = CharacterLook.new()
	look.skin = Color(0.63, 0.46, 0.35)
	look.joints = Color(0.30, 0.20, 0.15)
	var parts: Array[LookPart] = []
	parts.append(_part("AnacuTop", &"spine_02", LookPart.Shape.CYLINDER,
		Vector3(0.235, 0.38, 0.0), Vector3(0.0, 0.08, 0.0), BROWN))
	parts.append(_part("AnacuSkirt", &"pelvis", LookPart.Shape.CYLINDER,
		Vector3(0.265, 0.58, 0.0), Vector3(0.0, -0.23, 0.0), BROWN))
	parts.append(_part("AnacuHem", &"pelvis", LookPart.Shape.CYLINDER,
		Vector3(0.27, 0.06, 0.0), Vector3(0.0, -0.50, 0.0), RED))
	parts.append(_part("Lliclla", &"spine_02", LookPart.Shape.BOX,
		Vector3(0.48, 0.44, 0.04), Vector3(0.0, 0.04, -0.27), CREAM))
	parts.append(_part("Faja", &"pelvis", LookPart.Shape.CYLINDER,
		Vector3(0.255, 0.06, 0.0), Vector3(0.0, 0.05, 0.0), RED))
	parts.append(_part("Cinta", &"Head", LookPart.Shape.RING,
		Vector3(0.09, 0.11, 0.0), Vector3(0.0, 0.10, 0.01), RED))
	parts.append(_part("Tupu", &"spine_02", LookPart.Shape.DISC,
		Vector3(0.025, 0.008, 0.0), Vector3(0.0, 0.0, 0.26), COPPER, Vector3(90.0, 0.0, 0.0)))
	look.parts = parts
	return look


## Guerrero chanca: túnica corta teal y cinta oscura.
static func chanca() -> CharacterLook:
	var look: CharacterLook = CharacterLook.new()
	look.skin = Color(0.48, 0.32, 0.22)
	look.joints = Color(0.14, 0.14, 0.16)
	var parts: Array[LookPart] = []
	parts.append(_part("Tunica", &"spine_02", LookPart.Shape.CYLINDER,
		Vector3(0.24, 0.44, 0.0), Vector3(0.0, 0.07, 0.0), TEAL))
	parts.append(_part("Faldon", &"pelvis", LookPart.Shape.CYLINDER,
		Vector3(0.25, 0.30, 0.0), Vector3(0.0, -0.09, 0.0), Color(0.10, 0.24, 0.30, 1.0)))
	parts.append(_part("Faja", &"pelvis", LookPart.Shape.CYLINDER,
		Vector3(0.255, 0.06, 0.0), Vector3(0.0, 0.05, 0.0), DARK))
	parts.append(_part("Cinta", &"Head", LookPart.Shape.RING,
		Vector3(0.09, 0.11, 0.0), Vector3(0.0, 0.10, 0.01), DARK))
	look.parts = parts
	return look


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
