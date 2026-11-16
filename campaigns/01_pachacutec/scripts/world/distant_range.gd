class_name DistantRange
extends RefCounted
## Banda de montaña lejana con volumen.
##
## Genera una rejilla polar entre dos radios: sube desde un pie oculto hasta la
## cresta y baja por detrás. La altura sale de un ruido de crestas en 2D, así
## que hay picos, collados y laderas en vez de una silueta recortada. El
## sombreado direccional y la bruma los pone `range_shade.gdshader`.
##
## Es geometría de fondo: no proyecta sombra, no entra en el GI y no conoce la
## campaña. La usan la llacta y el Cusco con sus propias paletas.

const SEGMENTS: int = 192
const RADIAL_STEPS: int = 6
const BOTTOM: float = -12.0
const SHADER_PATH: String = "res://shared_assets/materials/range_shade.gdshader"


## Construye la banda bajo [param parent] y devuelve el nodo creado.
static func build(parent: Node3D, node_name: String, inner: float, outer: float,
		amplitude: float, seed_value: float, color: Color,
		sun_direction: Vector3) -> MeshInstance3D:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for ri: int in range(RADIAL_STEPS):
		var t0: float = float(ri) / float(RADIAL_STEPS)
		var t1: float = float(ri + 1) / float(RADIAL_STEPS)
		var radius0: float = lerpf(inner, outer, t0)
		var radius1: float = lerpf(inner, outer, t1)
		for ai: int in range(SEGMENTS):
			var angle0: float = TAU * float(ai) / float(SEGMENTS)
			var angle1: float = TAU * float(ai + 1) / float(SEGMENTS)
			_add_vertex(surface, angle0, radius0, t0, amplitude, seed_value)
			_add_vertex(surface, angle1, radius0, t0, amplitude, seed_value)
			_add_vertex(surface, angle1, radius1, t1, amplitude, seed_value)
			_add_vertex(surface, angle0, radius0, t0, amplitude, seed_value)
			_add_vertex(surface, angle1, radius1, t1, amplitude, seed_value)
			_add_vertex(surface, angle0, radius1, t1, amplitude, seed_value)
	surface.index()
	surface.generate_normals()
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = load(SHADER_PATH) as Shader
	material.set_shader_parameter("sun_direction", sun_direction.normalized())
	material.set_shader_parameter("rock_color", color)
	var node: MeshInstance3D = MeshInstance3D.new()
	node.name = node_name
	node.mesh = surface.commit()
	node.material_override = material
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	node.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	parent.add_child(node)
	return node


static func _add_vertex(surface: SurfaceTool, angle: float, radius: float, t: float,
		amplitude: float, seed_value: float) -> void:
	var x: float = cos(angle) * radius
	var z: float = sin(angle) * radius
	# Envolvente: la banda sube desde el pie y vuelve a bajar por detrás.
	var envelope: float = pow(sin(PI * t), 0.8)
	var height: float = BOTTOM + amplitude * envelope * _ridge_noise(x, z, seed_value)
	surface.add_vertex(Vector3(x, height, z))


## Ruido de crestas: valor en [0, 1] con picos estrechos y valles anchos.
static func _ridge_noise(x: float, z: float, seed_value: float) -> float:
	var value: float = 0.0
	var total: float = 0.0
	var amplitude: float = 0.55
	var frequency: float = 0.0072
	for octave: int in range(4):
		var sample: float = _value_noise(
			x * frequency + seed_value * 13.0, z * frequency - seed_value * 7.0)
		var ridge: float = 1.0 - absf(sample * 2.0 - 1.0)
		value += ridge * ridge * amplitude
		total += amplitude
		amplitude *= 0.50
		frequency *= 2.1
	return clampf(value / total, 0.0, 1.0)


static func _value_noise(x: float, z: float) -> float:
	var ix: float = floorf(x)
	var iz: float = floorf(z)
	var fx: float = x - ix
	var fz: float = z - iz
	fx = fx * fx * (3.0 - 2.0 * fx)
	fz = fz * fz * (3.0 - 2.0 * fz)
	var a: float = _hash2(ix, iz)
	var b: float = _hash2(ix + 1.0, iz)
	var c: float = _hash2(ix, iz + 1.0)
	var d: float = _hash2(ix + 1.0, iz + 1.0)
	return lerpf(lerpf(a, b, fx), lerpf(c, d, fx), fz)


static func _hash2(x: float, z: float) -> float:
	var value: float = sin(x * 127.1 + z * 311.7) * 43758.5453
	return value - floorf(value)
