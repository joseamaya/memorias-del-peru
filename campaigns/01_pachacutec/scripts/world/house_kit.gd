class_name HouseKit
extends RefCounted
## Medidas y variantes de las viviendas de la campaña.
##
## La malla, la colisión y los props salen de la misma tabla. Antes cada
## variante usaba una base de 6 × 5 m, así que la casa pequeña tenía una
## colisión mayor que su muro y la grande una menor. La llacta y el Cusco
## comparten estas medidas para que una casa se vea y se choque igual en los
## dos mundos.

const FILES: Array[String] = [
	"pch_house_a.glb", "pch_house_b.glb", "pch_house_c.glb",
	"pch_house_d.glb", "pch_house_e.glb",
]
## Ancho, fondo y altura de muro de cada variante, en metros.
const WIDTHS: Array[float] = [6.0, 5.6, 4.8, 7.0, 4.4]
const DEPTHS: Array[float] = [5.0, 4.6, 4.0, 5.4, 3.8]
const WALL_HEIGHTS: Array[float] = [2.4, 2.2, 2.0, 2.5, 2.0]
## Altura del bloqueo de techo; el modelo final lo oculta.
const ROOF_HEIGHT: float = 1.5
const ROOF_OVERHANG: float = 0.3
## Variación de tamaño y tinte para romper la repetición sin geometría nueva.
const SCALES: Array[float] = [1.0, 0.94, 1.06, 0.97, 1.03]
const TINTS: Array[Color] = [
	Color(1.0, 1.0, 1.0),
	Color(0.96, 0.94, 0.90),
	Color(1.0, 0.98, 0.93),
	Color(0.94, 0.95, 0.98),
	Color(1.0, 0.97, 0.91),
]
const LEFT_PROP_X: Array[float] = [-2.1, -2.4, -1.7, -2.5, -1.5]
const YAW_JITTER: Array[float] = [7.0, -11.0, 4.0, -6.0, 10.0, -8.0, 5.0, -4.0]
const FRONT_GAP: float = 0.45


static func variant(index: int) -> int:
	return posmod(index, FILES.size())


static func model_file(index: int) -> String:
	return FILES[variant(index)]


## Tamaño del cuerpo de colisión: muro completo, sin alero.
static func wall_size(index: int) -> Vector3:
	var v: int = variant(index)
	return Vector3(WIDTHS[v], WALL_HEIGHTS[v], DEPTHS[v])


static func roof_size(index: int) -> Vector3:
	var v: int = variant(index)
	return Vector3(WIDTHS[v] + ROOF_OVERHANG * 2.0, ROOF_HEIGHT, DEPTHS[v] + ROOF_OVERHANG * 2.0)


static func scale(index: int) -> float:
	return SCALES[variant(index)]


static func tint(index: int) -> Color:
	return TINTS[variant(index)]


static func left_prop_x(index: int) -> float:
	return LEFT_PROP_X[variant(index)]


static func yaw_jitter(index: int) -> float:
	return YAW_JITTER[index % YAW_JITTER.size()]


## Frente de la casa en Z local (el modelo mira a −Z).
static func front_z(index: int) -> float:
	return -DEPTHS[variant(index)] * 0.5 - FRONT_GAP


## Aplica el tinte de la variante a todas las mallas del modelo. Duplica el
## material para no teñir las demás casas que comparten el shader.
static func tint_model(root: Node3D, tint_value: Color) -> void:
	if root == null or tint_value == Color(1.0, 1.0, 1.0):
		return
	for node: Node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		var base: ShaderMaterial = mesh_instance.material_override as ShaderMaterial
		if base == null:
			continue
		var material: ShaderMaterial = base.duplicate() as ShaderMaterial
		material.set_shader_parameter("tint", tint_value)
		mesh_instance.material_override = material
