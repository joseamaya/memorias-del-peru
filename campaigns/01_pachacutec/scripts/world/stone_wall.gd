class_name StoneWall
extends RefCounted
## Cara de muro de piedra de campo generada en Godot para los muros de
## contención de las terrazas (alcance §6.1: malla
## procedural; ficha PCH-008, reconstrucción R).
##
## Cada cara se llena de hiladas de piedras irregulares que sobresalen un poco
## del bloque de colisión; el bloque asoma entre ellas como junta (oscura,
## de piedra seca, en las terrazas). Una sola malla con color por vértice por terraza: una llamada de
## dibujo. El reparto es determinista para una semilla dada.

const COURSE_MIN: float = 0.2
const COURSE_MAX: float = 0.3
const STONE_MIN: float = 0.3
const STONE_MAX: float = 0.6
const GAP: float = 0.025
const DEPTH: float = 0.12
const BULGE_MAX: float = 0.035
const STONE_COLORS: Array[Color] = [
	Color(0.5, 0.47, 0.42, 1.0),
	Color(0.42, 0.4, 0.36, 1.0),
	Color(0.58, 0.54, 0.47, 1.0),
	Color(0.55, 0.46, 0.37, 1.0),
]
## Variación de brillo de cada piedra.
const SHADE_JITTER: float = 0.06


## Cara rectangular de muro: esquina inferior de partida, dirección a lo largo
## de la cara, normal hacia fuera, largo y alto.
class Face:
	var origin: Vector3
	var along: Vector3
	var normal: Vector3
	var length: float
	var height: float

	func _init(face_origin: Vector3, face_along: Vector3, face_normal: Vector3, face_length: float, face_height: float) -> void:
		origin = face_origin
		along = face_along.normalized()
		normal = face_normal.normalized()
		length = face_length
		height = face_height


## Malla de piedras para todas las [param faces], con la semilla [param wall_seed].
## Devuelve también, en [param stats], el número de piedras (clave "stones").
static func build(faces: Array[Face], wall_seed: int, stats: Dictionary = {}) -> ArrayMesh:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = wall_seed
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var stones: int = 0
	for face: Face in faces:
		stones += _fill_face(surface, rng, face)
	stats["stones"] = stones
	surface.generate_normals()
	return surface.commit()


static func _fill_face(surface: SurfaceTool, rng: RandomNumberGenerator, face: Face) -> int:
	var up: Vector3 = Vector3.UP
	var count: int = 0
	var v: float = 0.0
	while v < face.height - 0.06:
		var course: float = minf(rng.randf_range(COURSE_MIN, COURSE_MAX), face.height - v)
		var u: float = -rng.randf_range(0.0, 0.25)
		while u < face.length:
			var stone_len: float = rng.randf_range(STONE_MIN, STONE_MAX)
			var u0: float = maxf(u, 0.0)
			var u1: float = minf(u + stone_len, face.length)
			u += stone_len
			var bulge: float = rng.randf_range(0.0, BULGE_MAX)
			var color: Color = STONE_COLORS[rng.randi_range(0, STONE_COLORS.size() - 1)]
			var shade: float = rng.randf_range(-SHADE_JITTER, SHADE_JITTER)
			if u1 - u0 < 0.1:
				continue
			color = Color(clampf(color.r + shade, 0.0, 1.0), clampf(color.g + shade, 0.0, 1.0), clampf(color.b + shade, 0.0, 1.0), 1.0)
			var a: Vector3 = face.origin + face.along * (u0 + GAP * 0.5) + up * (v + GAP * 0.5)
			var size_u: float = (u1 - u0) - GAP
			var size_v: float = course - GAP
			_add_stone(surface, a, face.along * size_u, up * size_v, face.normal, bulge, color)
			count += 1
		v += course
	return count


## Piedra como caja con cinco caras visibles (la trasera queda dentro del
## bloque): desde [param corner], con lados [param side_u] y [param side_v] en
## el plano del muro, y saliente [param bulge] hacia [param normal].
static func _add_stone(surface: SurfaceTool, corner: Vector3, side_u: Vector3, side_v: Vector3, normal: Vector3, bulge: float, color: Color) -> void:
	var back: Vector3 = -normal * (DEPTH - bulge)
	var front: Vector3 = normal * bulge
	var b0: Vector3 = corner + back
	var f0: Vector3 = corner + front
	var quads: Array[PackedVector3Array] = [
		# Frente.
		PackedVector3Array([f0, f0 + side_u, f0 + side_u + side_v, f0 + side_v]),
		# Arriba y abajo.
		PackedVector3Array([f0 + side_v, f0 + side_u + side_v, b0 + side_u + side_v, b0 + side_v]),
		PackedVector3Array([b0, b0 + side_u, f0 + side_u, f0]),
		# Lados.
		PackedVector3Array([b0, f0, f0 + side_v, b0 + side_v]),
		PackedVector3Array([f0 + side_u, b0 + side_u, b0 + side_u + side_v, f0 + side_u + side_v]),
	]
	surface.set_color(color)
	for quad: PackedVector3Array in quads:
		# Orden de vértices para que la cara mire hacia fuera.
		var n: Vector3 = (quad[1] - quad[0]).cross(quad[2] - quad[0])
		var center: Vector3 = (quad[0] + quad[2]) * 0.5
		var stone_center: Vector3 = corner + (side_u + side_v) * 0.5 + normal * (bulge - (DEPTH - bulge)) * 0.5
		if n.dot(center - stone_center) > 0.0:
			for index: int in [0, 2, 1, 0, 3, 2]:
				surface.add_vertex(quad[index])
		else:
			for index: int in [0, 1, 2, 0, 2, 3]:
				surface.add_vertex(quad[index])
