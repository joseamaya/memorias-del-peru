"""Genera la tejedora vestida sobre el maniquí UAL1 (ADR-0042).

Uso (desde la raíz del repositorio):

    blender --background --factory-startup \
        --python campaigns/01_pachacutec/assets/blender/pch_dressed.py -- \
        [--out DIR] [--preview DIR]

El cuerpo y el esqueleto son los de UAL1 (Quaternius, CC0). La cabeza, el pelo
y la ropa son mallas nuevas: la túnica se copia de la superficie del cuerpo para
heredar sus pesos, y la falda, el cinturón, la chuspa, la lliclla y las sandalias
se construyen con pesos asignados por altura y lado. El resultado es un único
GLB con el cuerpo, las capas y las animaciones recortadas.

El pipeline sigue ADR-0010: script versionado, sin addons ni MCP.
"""

import argparse
import math
import os
import sys

import bmesh
import bpy
from mathutils import Matrix, Vector

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_DIR = os.path.normpath(os.path.join(SCRIPT_DIR, "..", "..", "..", ".."))
DEFAULT_OUT = os.path.normpath(os.path.join(SCRIPT_DIR, "..", "models"))
DEFAULT_PREVIEW = "/tmp/opencode/weaver_preview"
UAL1_PATH = os.path.join(REPO_DIR, "shared_assets", "characters", "mannequin", "ual1_standard.glb")

def load_people_library():
	"""Carga las clases de `pch_people.py` sin ejecutar su `main()`.

	El generador de personajes de MakeHuman llama a `main()` al final del
	archivo y exige argumentos de CMU/Rocketbox; aquí solo se reutilizan
	`Garment`, `BodyInfo` y la paleta de telas.
	"""
	path = os.path.join(SCRIPT_DIR, "pch_people.py")
	with open(path, "r", encoding="utf-8") as handle:
		source = handle.read()
	if source.rstrip().endswith("main()"):
		source = source.rstrip()[:-len("main()")]
	namespace = {"__name__": "pch_people_library", "__file__": path}
	exec(compile(source, path, "exec"), namespace)
	return namespace


_PEOPLE = load_people_library()
BodyInfo = _PEOPLE["BodyInfo"]
Garment = _PEOPLE["Garment"]
TEXTILE_PIECES = _PEOPLE["TEXTILE_PIECES"]
_linear = _PEOPLE["_linear"]
paint_textile = _PEOPLE["paint_textile"]
set_cloth_texture = _PEOPLE["set_cloth_texture"]

# Altura del cuello y de la cabeza. UAL1 mide 1,83 m; la cabeza empieza en
# 1,57 y termina en 1,84. La cara mira hacia -Y en Blender (frente de UAL1).
HEAD_BASE = 1.575
HEAD_TOP = 1.840
NECK_TOP = 1.605
BODY_HEAD_CUT = 1.555

SKIN_SRGB = (0.72, 0.52, 0.40)
HAIR_SRGB = (0.055, 0.045, 0.040)
LIP_SRGB = (0.36, 0.14, 0.12)
EYE_WHITE_SRGB = (0.86, 0.83, 0.76)
IRIS_SRGB = (0.10, 0.065, 0.040)
PUPIL_SRGB = (0.02, 0.015, 0.012)

KEEP_TRACKS = {
	"Idle_Loop",
	"Walk_Loop",
	"Jog_Fwd_Loop",
	"Sprint_Loop",
	"Idle_Talking_Loop",
	"Crouch_Idle_Loop",
	"Fixing_Kneeling",
	"Hit_Chest",
	"Sword_Attack",
}


def srgb(color):
	"""Color sRGB a lineal para el Base Color de Blender."""
	def channel(c):
		return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
	return (channel(color[0]), channel(color[1]), channel(color[2]), 1.0)


def clear_scene():
	for obj in list(bpy.data.objects):
		bpy.data.objects.remove(obj, do_unlink=True)
	for mesh in list(bpy.data.meshes):
		bpy.data.meshes.remove(mesh)
	for material in list(bpy.data.materials):
		bpy.data.materials.remove(material)


def make_material(name, color, roughness=0.8, metallic=0.0):
	material = bpy.data.materials.new(name)
	material.use_nodes = True
	nodes = material.node_tree.nodes
	bsdf = nodes.get("Principled BSDF")
	bsdf.inputs["Base Color"].default_value = color
	bsdf.inputs["Roughness"].default_value = roughness
	bsdf.inputs["Metallic"].default_value = metallic
	return material


def import_ual1():
	bpy.ops.import_scene.gltf(filepath=UAL1_PATH)
	armature = None
	body = None
	for obj in bpy.data.objects:
		if obj.type == "ARMATURE":
			armature = obj
		elif obj.type == "MESH" and obj.name == "Mannequin":
			body = obj
	if armature is None or body is None:
		raise SystemExit("No se encontró el cuerpo o el esqueleto de UAL1")
	# El GLB trae una esfera de relleno sin materiales; no se usa.
	for obj in list(bpy.data.objects):
		if obj.type == "MESH" and obj not in (body,):
			bpy.data.objects.remove(obj, do_unlink=True)
	return armature, body


def delete_body_head(body):
	"""Quita la cabeza del cuerpo UAL1; la cabeza nueva la sustituye."""
	bm = bmesh.new()
	bm.from_mesh(body.data)
	doomed = [v for v in bm.verts if v.co.z > BODY_HEAD_CUT]
	bmesh.ops.delete(bm, geom=doomed, context="VERTS")
	bm.to_mesh(body.data)
	bm.free()
	body.data.update()


def delete_hidden_body(body):
	"""Quita el torso, los brazos y las piernas que quedan bajo la ropa.

	La ropa se construyó antes a partir de la superficie completa; una vez
	hecha, el cuerpo interior solo sirve para asomar por las costuras. Se
	conservan manos, pies y cuello, que sí se ven.
	"""
	bm = bmesh.new()
	bm.from_mesh(body.data)
	doomed = []
	for vertex in bm.verts:
		point = vertex.co
		if 0.90 <= point.z <= 1.50 and abs(point.x) < 0.30:
			doomed.append(vertex)
		elif 1.30 <= point.z <= 1.50 and 0.30 <= abs(point.x) <= 0.72:
			doomed.append(vertex)
		elif 0.25 <= point.z <= 0.90 and abs(point.x) < 0.25:
			doomed.append(vertex)
	bmesh.ops.delete(bm, geom=doomed, context="VERTS")
	bm.to_mesh(body.data)
	bm.free()
	body.data.update()


def assign_body_skin(body, skin):
	body.data.materials.clear()
	body.data.materials.append(skin)
	for polygon in body.data.polygons:
		polygon.material_index = 0


def add_weights(obj, weights):
	if callable(weights):
		for index, vertex in enumerate(obj.data.vertices):
			value = weights(vertex.co)
			for bone, weight in value.items():
				group = obj.vertex_groups.get(bone) or obj.vertex_groups.new(name=bone)
				group.add([index], weight, "REPLACE")
		return
	for bone, weight in weights.items():
		group = obj.vertex_groups.get(bone) or obj.vertex_groups.new(name=bone)
		group.add(list(range(len(obj.data.vertices))), weight, "REPLACE")


def parent_to_armature(obj, armature):
	obj.parent = armature
	modifier = obj.modifiers.new("Armature", "ARMATURE")
	modifier.object = armature


def smooth(obj):
	for polygon in obj.data.polygons:
		polygon.use_smooth = True


def ellipsoid(name, center, scale, material, armature, weights, segments=20, rings=12, rotation=(0.0, 0.0, 0.0)):
	bpy.ops.mesh.primitive_uv_sphere_add(segments=segments, ring_count=rings, radius=1.0, location=center)
	obj = bpy.context.active_object
	obj.name = name
	obj.scale = scale
	obj.rotation_euler = rotation
	bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
	obj.data.materials.append(material)
	smooth(obj)
	add_weights(obj, weights)
	parent_to_armature(obj, armature)
	return obj


def box(name, center, size, material, armature, weights, rotation=(0.0, 0.0, 0.0)):
	bpy.ops.mesh.primitive_cube_add(size=1.0, location=center)
	obj = bpy.context.active_object
	obj.name = name
	obj.scale = size
	obj.rotation_euler = rotation
	bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
	obj.data.materials.append(material)
	add_weights(obj, weights)
	parent_to_armature(obj, armature)
	return obj


def ring_points(z, rx, ry, cy, segments, fold=0.0):
	points = []
	for s in range(segments):
		angle = 2.0 * math.pi * s / segments
		scale = 1.0 + fold * math.cos(6.0 * angle)
		points.append(Vector((math.cos(angle) * rx * scale,
			math.sin(angle) * ry * scale + cy, z)))
	return points


def head_weights(point):
	if point.z <= 1.56:
		return {"neck_01": 1.0}
	if point.z >= 1.62:
		return {"Head": 1.0}
	t = (point.z - 1.56) / 0.06
	return {"neck_01": 1.0 - t, "Head": t}


def build_head(armature, skin, hair, eye_white, iris, pupil, lips, band):
	# Cráneo por anillos: mentón, mandíbula, boca, nariz, pómulos, frente y
	# coronilla. La cara mira hacia -Y.
	rings = [
		(1.575, 0.028, 0.030, -0.048),
		(1.598, 0.052, 0.058, -0.032),
		(1.625, 0.072, 0.074, -0.016),
		(1.655, 0.082, 0.086, -0.006),
		(1.685, 0.086, 0.093, 0.000),
		(1.715, 0.087, 0.097, 0.005),
		(1.745, 0.088, 0.099, 0.008),
		(1.775, 0.086, 0.095, 0.010),
		(1.805, 0.073, 0.083, 0.010),
		(1.830, 0.044, 0.052, 0.010),
	]
	segments = 28
	verts = []
	for z, rx, ry, cy in rings:
		verts.extend(ring_points(z, rx, ry, cy, segments))
	faces = []
	for row in range(len(rings) - 1):
		for s in range(segments):
			a = row * segments + s
			b = row * segments + (s + 1) % segments
			c = (row + 1) * segments + (s + 1) % segments
			d = (row + 1) * segments + s
			faces.append((a, b, c, d))
	top_center = len(verts)
	verts.append(Vector((0.0, rings[-1][3], rings[-1][0])))
	for s in range(segments):
		a = (len(rings) - 1) * segments + s
		b = (len(rings) - 1) * segments + (s + 1) % segments
		faces.append((a, b, top_center))
	mesh = bpy.data.meshes.new("HeadSkin")
	mesh.from_pydata([tuple(v) for v in verts], [], faces)
	mesh.validate()
	mesh.update()
	head = bpy.data.objects.new("HeadSkin", mesh)
	bpy.context.scene.collection.objects.link(head)
	head.data.materials.append(skin)
	smooth(head)
	add_weights(head, head_weights)
	parent_to_armature(head, armature)

	# Cuello: cilindro que tapa el hueco del cuerpo y enlaza con la cabeza.
	bpy.ops.mesh.primitive_cylinder_add(vertices=18, radius=0.066, depth=0.15, location=(0.0, 0.005, 1.535))
	neck = bpy.context.active_object
	neck.name = "Neck"
	neck.data.materials.append(skin)
	smooth(neck)
	add_weights(neck, {"neck_01": 1.0})
	parent_to_armature(neck, armature)

	# Nariz: puente, punta y aletas. Tres elipsoides bastan para leer un perfil.
	ellipsoid("NoseBridge", (0.0, -0.098, 1.710), (0.010, 0.016, 0.036), skin, armature,
		{"Head": 1.0}, segments=12, rings=8, rotation=(math.radians(-8.0), 0.0, 0.0))
	ellipsoid("NoseTip", (0.0, -0.110, 1.686), (0.016, 0.013, 0.013), skin, armature,
		{"Head": 1.0}, segments=12, rings=8)
	for side in (-1.0, 1.0):
		ellipsoid("Nostril%s" % ("L" if side > 0.0 else "R"),
			(0.015 * side, -0.098, 1.677), (0.008, 0.008, 0.006), skin, armature,
			{"Head": 1.0}, segments=10, rings=6)
		ellipsoid("Ear%s" % ("L" if side > 0.0 else "R"),
			(0.090 * side, 0.004, 1.700), (0.014, 0.026, 0.042), skin, armature,
			{"Head": 1.0}, segments=12, rings=8)

	# Ojos: esclerótica, iris y pupila. Las cejas y la línea de pestañas
	# oscurecen el borde y evitan el aspecto de bolas blancas.
	for side in (-1.0, 1.0):
		x = 0.036 * side
		ellipsoid("EyeWhite%s" % ("L" if side > 0.0 else "R"),
			(x, -0.089, 1.716), (0.022, 0.009, 0.012), eye_white, armature,
			{"Head": 1.0}, segments=16, rings=10)
		ellipsoid("Iris%s" % ("L" if side > 0.0 else "R"),
			(x, -0.097, 1.716), (0.008, 0.004, 0.008), iris, armature,
			{"Head": 1.0}, segments=12, rings=8)
		ellipsoid("Pupil%s" % ("L" if side > 0.0 else "R"),
			(x, -0.101, 1.716), (0.0035, 0.0018, 0.0035), pupil, armature,
			{"Head": 1.0}, segments=10, rings=6)
		ellipsoid("UpperLid%s" % ("L" if side > 0.0 else "R"),
			(x, -0.096, 1.724), (0.026, 0.010, 0.008), skin, armature,
			{"Head": 1.0}, segments=12, rings=6)
		box("Brow%s" % ("L" if side > 0.0 else "R"),
			(x, -0.098, 1.750), (0.040, 0.005, 0.004), hair, armature,
			{"Head": 1.0})
		box("Lash%s" % ("L" if side > 0.0 else "R"),
			(x, -0.100, 1.730), (0.042, 0.003, 0.003), hair, armature,
			{"Head": 1.0})

	# Boca: labio superior, inferior y línea oscura.
	ellipsoid("UpperLip", (0.0, -0.098, 1.647), (0.030, 0.007, 0.005), lips, armature,
		{"Head": 1.0}, segments=16, rings=8)
	ellipsoid("LowerLip", (0.0, -0.098, 1.635), (0.026, 0.007, 0.005), lips, armature,
		{"Head": 1.0}, segments=16, rings=8)
	box("MouthLine", (0.0, -0.103, 1.641), (0.032, 0.0025, 0.002), pupil, armature,
		{"Head": 1.0})
	for side in (-1.0, 1.0):
		ellipsoid("LipCorner%s" % ("L" if side > 0.0 else "R"),
			(0.025 * side, -0.098, 1.644), (0.006, 0.005, 0.003),
			lips, armature, {"Head": 1.0}, segments=8, rings=4)

	# Pelo: casquete sobre el cráneo, con la cara recortada. La cinta tapa la
	# línea del flequillo y la trenza cae por la espalda.
	bpy.ops.mesh.primitive_uv_sphere_add(segments=28, ring_count=18, radius=1.0, location=(0.0, 0.010, 1.755))
	hair_cap = bpy.context.active_object
	hair_cap.name = "HairCap"
	hair_cap.scale = (0.100, 0.106, 0.105)
	bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
	bm = bmesh.new()
	bm.from_mesh(hair_cap.data)
	world = hair_cap.matrix_world
	remove = []
	for face in bm.faces:
		center = world @ face.calc_center_median()
		if center.y < -0.030 and center.z < 1.785:
			remove.append(face)
	bmesh.ops.delete(bm, geom=remove, context="FACES")
	bm.to_mesh(hair_cap.data)
	bm.free()
	hair_cap.data.materials.append(hair)
	smooth(hair_cap)
	add_weights(hair_cap, {"Head": 1.0})
	parent_to_armature(hair_cap, armature)

	for index in range(6):
		t = float(index) / 5.0
		ellipsoid("Braid%d" % index,
			(0.078 + 0.028 * t, -0.020 - 0.075 * t, 1.720 - 0.240 * t),
			(0.018 - 0.003 * t, 0.018 - 0.003 * t, 0.030),
			hair, armature, {"Head": 1.0}, segments=10, rings=6)
	ellipsoid("BraidTie", (0.108, -0.095, 1.472), (0.021, 0.021, 0.011),
		band, armature, {"Head": 1.0}, segments=10, rings=6)

	bpy.ops.mesh.primitive_torus_add(major_radius=0.092, minor_radius=0.007,
		major_segments=32, minor_segments=8, location=(0.0, 0.010, 1.778))
	headband = bpy.context.active_object
	headband.name = "Headband"
	headband.scale = (1.0, 1.05, 1.0)
	bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
	headband.data.materials.append(band)
	smooth(headband)
	add_weights(headband, {"Head": 1.0})
	parent_to_armature(headband, armature)


def tunic_face(body_info, verts):
	for index in verts:
		point = body_info.points[index]
		# Torso y brazos completos: una sola superficie continua evita los
		# huecos del hombro y la axila. El bajo y la falda van aparte.
		if point.z < 0.93 or point.z > 1.52:
			return False
		if abs(point.x) > 0.72:
			return False
	return True


def build_sleeve(garment, side, upper, lower):
	"""Manga taperada a lo largo del brazo, con pesos de hombro y codo."""
	angles = [2.0 * math.pi * s / 18.0 for s in range(18)]
	xs = [0.14, 0.22, 0.30, 0.38, 0.466, 0.54, 0.62, 0.70, 0.735]
	radii = [0.145, 0.135, 0.120, 0.095, 0.075, 0.065, 0.058, 0.050, 0.043]
	rings = []
	for x, radius in zip(xs, radii):
		rings.append([Vector((x * side, 0.065 + math.cos(a) * radius,
			1.441 + math.sin(a) * radius)) for a in angles])

	def weights(point):
		along = abs(point.x)
		if along <= 0.466:
			return {upper: 1.0}
		if along >= 0.50:
			return {lower: 1.0}
		t = (along - 0.466) / 0.034
		return {upper: 1.0 - t, lower: t}

	def color(_s, row):
		return _linear("wool_red") if row >= len(xs) - 2 else _linear("wool_cream")

	garment.tube(rings, color, weights)


def tunic_color(body_info, index):
	point = body_info.points[index]
	if abs(point.x) > 0.68:
		return _linear("wool_red")
	return _linear("wool_cream")


def torso_weights(point):
	if point.z >= 1.10:
		t = max(0.0, min(1.0, (point.z - 1.10) / 0.10))
		return {"spine_02": t, "spine_01": 1.0 - t}
	if point.z >= 0.95:
		t = max(0.0, min(1.0, (point.z - 0.95) / 0.15))
		return {"spine_01": t, "pelvis": 1.0 - t}
	return {"pelvis": 1.0}


def skirt_weights(point):
	# La falda cuelga sobre todo de la cadera: si sigue demasiado a los muslos,
	# al arrodillarse se abre en dos y deja ver las piernas.
	t = max(0.0, min(1.0, (0.95 - point.z) / 0.77)) * 0.35
	side = max(-1.0, min(1.0, point.x / 0.12))
	return {
		"pelvis": 1.0 - t,
		"thigh_l": t * (0.5 + 0.5 * side),
		"thigh_r": t * (0.5 - 0.5 * side),
	}


def lliclla_weights(point):
	if point.z >= 1.30:
		return {"spine_03": 1.0}
	if point.z >= 1.10:
		t = (point.z - 1.10) / 0.20
		return {"spine_03": t, "spine_02": 1.0 - t}
	if point.z >= 0.90:
		t = (point.z - 0.90) / 0.20
		return {"spine_02": t, "pelvis": 1.0 - t}
	return {"pelvis": 1.0}


def setup_cloth_material():
	"""Hace que el material de tela use el color por vértice también en los
	renders de Blender; el juego lo sustituye por su shader de tejido."""
	material = bpy.data.materials.get("pch_cloth")
	if material is None:
		return
	material.use_nodes = True
	nodes = material.node_tree.nodes
	bsdf = nodes.get("Principled BSDF")
	if bsdf is None:
		return
	vertex_color = nodes.new("ShaderNodeVertexColor")
	vertex_color.layer_name = "Color"
	material.node_tree.links.new(vertex_color.outputs["Color"], bsdf.inputs["Base Color"])
	bsdf.inputs["Roughness"].default_value = 0.92


def add_cloth_ellipsoid(garment, center, scale, color, weight_fn, segments=16, rings=8):
	"""Elipsoide de tela con color por cara, para hombros y refuerzos."""
	top = garment.add_vertex(center + Vector((0.0, 0.0, scale[2])),
		weight_fn(center + Vector((0.0, 0.0, scale[2]))))
	bottom = garment.add_vertex(center - Vector((0.0, 0.0, scale[2])),
		weight_fn(center - Vector((0.0, 0.0, scale[2]))))
	rows = []
	for row in range(1, rings):
		phi = math.pi * float(row) / float(rings)
		z = math.cos(phi) * scale[2]
		radius = math.sin(phi)
		line = []
		for segment in range(segments):
			theta = 2.0 * math.pi * float(segment) / float(segments)
			point = center + Vector((math.cos(theta) * radius * scale[0],
				math.sin(theta) * radius * scale[1], z))
			line.append(garment.add_vertex(point, weight_fn(point)))
		rows.append(line)
	for segment in range(segments):
		a = rows[0][segment]
		b = rows[0][(segment + 1) % segments]
		garment.add_face([top, a, b], color, [(0.5, 1.0), (0.0, 0.8), (1.0, 0.8)])
	for row in range(len(rows) - 1):
		for segment in range(segments):
			a = rows[row][segment]
			b = rows[row][(segment + 1) % segments]
			c = rows[row + 1][(segment + 1) % segments]
			d = rows[row + 1][segment]
			garment.add_face([a, b, c, d], color,
				[(0.0, row), (1.0, row), (1.0, row + 1), (0.0, row + 1)])
	last = rows[-1]
	for segment in range(segments):
		a = last[segment]
		b = last[(segment + 1) % segments]
		garment.add_face([bottom, b, a], color, [(0.5, 0.0), (1.0, 0.2), (0.0, 0.2)])


def build_clothes(body, armature):
	body_info = BodyInfo(body)
	garment = Garment()

	# Túnica: copia de la superficie del torso y los brazos, con sus pesos.
	# Túnica: copia continua del torso y los brazos. Al heredar los pesos del
	# cuerpo, se deforma con él y no deja huecos en hombros ni axilas.
	garment.piece = TEXTILE_PIECES["garment"]
	segments = 24
	garment.add_body_surface(body_info, lambda verts: tunic_face(body_info, verts), 0.035,
		lambda index: tunic_color(body_info, index))
	# Cuello de la túnica: banda que tapa el borde superior del tubo.
	collar_rings = [
		ring_points(1.500, 0.105, 0.085, 0.0, segments),
		ring_points(1.525, 0.095, 0.078, 0.0, segments),
	]
	garment.tube(collar_rings, lambda _s, _r: _linear("wool_red"),
		lambda _p: {"spine_03": 0.5, "neck_01": 0.5})

	# Falda larga acampanada, de la cintura a media pierna.
	rings = [
		ring_points(0.95, 0.195, 0.145, 0.0, segments, fold=0.018),
		ring_points(0.78, 0.235, 0.180, 0.0, segments, fold=0.022),
		ring_points(0.60, 0.280, 0.220, 0.0, segments, fold=0.026),
		ring_points(0.42, 0.340, 0.270, 0.0, segments, fold=0.030),
		ring_points(0.25, 0.380, 0.300, 0.0, segments, fold=0.034),
	]
	def skirt_color(_s, row):
		return _linear("wool_red") if row >= 4 else _linear("wool_brown")
	garment.tube(rings, skirt_color, skirt_weights)

	# Cinturón ancho sobre la cintura.
	garment.piece = TEXTILE_PIECES["belt"]
	belt_rings = [
		ring_points(0.935, 0.205, 0.155, 0.0, segments),
		ring_points(1.015, 0.205, 0.155, 0.0, segments),
	]
	garment.tube(belt_rings, lambda _s, _r: _linear("wool_dark"), lambda _p: {"pelvis": 1.0})

	# Chuspa en la cadera derecha.
	garment.piece = TEXTILE_PIECES["bag"]
	garment.box(Vector((0.245, -0.050, 0.875)), (0.12, 0.07, 0.17), Matrix.Identity(3),
		_linear("wool_brown"), {"pelvis": 1.0})

	# Lliclla: paño largo sobre la espalda, con borde claro.
	garment.piece = TEXTILE_PIECES["lliclla"]
	cols, rows = 10, 8
	ids = []
	for row in range(rows + 1):
		t = float(row) / float(rows)
		line = []
		for col in range(cols + 1):
			u = float(col) / float(cols)
			x = (u - 0.5) * 0.44
			# El centro cuelga un poco más que los lados: el borde inferior
			# deja de ser una tabla recta.
			z = 1.46 - 0.81 * t - 0.040 * (1.0 - (2.0 * u - 1.0) ** 2) * t
			y = 0.185 - 0.015 * t + 0.018 * (1.0 - (2.0 * u - 1.0) ** 2)
			y += 0.006 * math.sin(6.0 * math.pi * u)
			line.append(garment.add_vertex(Vector((x, y, z)), lliclla_weights(Vector((x, y, z)))))
		ids.append(line)
	for row in range(rows):
		for col in range(cols):
			border = col == 0 or col == cols - 1 or row == 0 or row == rows - 1
			color = _linear("wool_cream") if border else _linear("wool_red")
			garment.add_face([ids[row][col], ids[row][col + 1], ids[row + 1][col + 1], ids[row + 1][col]],
				color, [(col, row), (col + 1, row), (col + 1, row + 1), (col, row + 1)])

	# Sandalias: suela y dos tiras por pie.
	garment.piece = TEXTILE_PIECES["garment"]
	for side, suffix in ((1.0, "l"), (-1.0, "r")):
		x = 0.089 * side
		garment.box(Vector((x, -0.080, 0.020)), (0.115, 0.280, 0.030), Matrix.Identity(3),
			_linear("sole"), {"foot_%s" % suffix: 1.0})
		garment.box(Vector((x, -0.105, 0.060)), (0.105, 0.025, 0.020), Matrix.Identity(3),
			_linear("rope"), {"foot_%s" % suffix: 1.0})
		garment.box(Vector((x, -0.015, 0.065)), (0.100, 0.022, 0.020), Matrix.Identity(3),
			_linear("rope"), {"foot_%s" % suffix: 1.0})

	clothes = garment.to_object("Clothes", bpy.context.scene.collection, armature)
	setup_cloth_material()
	# La copia del cuerpo hereda los bultos del abdomen y del pecho. Una
	# subdivisión y un suavizado convierten esa piel en una tela con caída.
	# Sin Solidify, que borraba el color por vértice al aplicarse.
	subdivision = clothes.modifiers.new("Subdivision", "SUBSURF")
	subdivision.levels = 1
	subdivision.render_levels = 1
	smooth = clothes.modifiers.new("Smooth", "SMOOTH")
	smooth.factor = 0.5
	smooth.iterations = 1
	bpy.context.view_layer.objects.active = clothes
	clothes.select_set(True)
	bpy.ops.object.modifier_move_to_index(modifier="Smooth", index=0)
	bpy.ops.object.modifier_move_to_index(modifier="Subdivision", index=0)
	bpy.ops.object.modifier_apply(modifier="Subdivision")
	bpy.ops.object.modifier_apply(modifier="Smooth")
	clothes.select_set(False)
	return clothes


def join_head(head_objects):
	"""Une solo las piezas de la cabeza; cuerpo y ropa van aparte para que el
	atributo de color de la tela no se mezcle con el del cuerpo."""
	if not head_objects:
		return None
	for obj in bpy.context.scene.objects:
		obj.select_set(obj in head_objects)
	bpy.context.view_layer.objects.active = head_objects[0]
	bpy.ops.object.join()
	joined = bpy.context.view_layer.objects.active
	joined.name = "WeaverHead"
	joined.data.name = "WeaverHead"
	return joined


def trim_animations(armature):
	animation = armature.animation_data
	if animation is None:
		return
	for track in list(animation.nla_tracks):
		if track.name not in KEEP_TRACKS:
			animation.nla_tracks.remove(track)
	animation.action = None


def export(out_dir):
	os.makedirs(out_dir, exist_ok=True)
	path = os.path.join(out_dir, "pch_weaver_dressed.glb")
	bpy.ops.export_scene.gltf(
		filepath=path,
		export_format="GLB",
		export_yup=True,
		export_apply=True,
		export_animations=True,
		export_animation_mode="NLA_TRACKS",
		export_skins=True,
		export_cameras=False,
		export_lights=False,
		export_extras=False,
		export_vertex_color="ACTIVE",
	)
	print("EXPORTED", path)
	return path


def look_at(obj, target):
	direction = target - obj.location
	obj.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()


def add_light(name, location, energy, size):
	data = bpy.data.lights.new(name, "AREA")
	data.energy = energy
	data.shape = "DISK"
	data.size = size
	obj = bpy.data.objects.new(name, data)
	bpy.context.scene.collection.objects.link(obj)
	obj.location = location
	look_at(obj, Vector((0.0, 0.0, 1.0)))
	return obj


def render_previews(preview_dir):
	os.makedirs(preview_dir, exist_ok=True)
	scene = bpy.context.scene
	scene.render.engine = "BLENDER_EEVEE"
	scene.render.resolution_x = 700
	scene.render.resolution_y = 900
	scene.render.resolution_percentage = 100
	scene.render.film_transparent = False
	world = bpy.data.worlds.new("PreviewWorld")
	world.use_nodes = True
	world.node_tree.nodes["Background"].inputs["Color"].default_value = (0.08, 0.08, 0.09, 1.0)
	world.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.6
	scene.world = world
	add_light("Key", Vector((2.4, -3.2, 3.2)), 500.0, 4.0)
	add_light("Fill", Vector((-2.6, -1.8, 2.0)), 220.0, 4.0)
	add_light("Rim", Vector((0.0, 3.4, 3.0)), 380.0, 3.0)
	camera_data = bpy.data.cameras.new("PreviewCamera")
	camera = bpy.data.objects.new("PreviewCamera", camera_data)
	bpy.context.scene.collection.objects.link(camera)
	scene.camera = camera
	camera_data.lens = 65.0
	shots = [
		("01_frontal", Vector((0.0, -3.4, 1.15)), Vector((0.0, 0.0, 0.95))),
		("02_tres_cuartos", Vector((2.2, -2.4, 1.25)), Vector((0.0, 0.0, 0.95))),
		("03_lateral", Vector((3.4, 0.0, 1.15)), Vector((0.0, 0.0, 0.95))),
		("04_espalda", Vector((0.0, 3.4, 1.15)), Vector((0.0, 0.0, 0.95))),
		("05_rostro", Vector((0.0, -1.25, 1.72)), Vector((0.0, 0.0, 1.70))),
	]
	for name, location, target in shots:
		camera.location = location
		look_at(camera, target)
		scene.render.filepath = os.path.join(preview_dir, name + ".png")
		bpy.ops.render.render(write_still=True)
		print("PREVIEW", scene.render.filepath)


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("--out", default=DEFAULT_OUT)
	parser.add_argument("--preview", default=DEFAULT_PREVIEW)
	args = parser.parse_args(sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else [])

	clear_scene()
	armature, body = import_ual1()
	delete_body_head(body)
	skin = make_material("PCH_Skin", srgb(SKIN_SRGB), 0.72)
	hair = make_material("PCH_Hair", srgb(HAIR_SRGB), 0.85)
	eye_white = make_material("PCH_EyeWhite", srgb(EYE_WHITE_SRGB), 0.28)
	iris = make_material("PCH_Iris", srgb(IRIS_SRGB), 0.30)
	pupil = make_material("PCH_Pupil", srgb(PUPIL_SRGB), 0.30)
	lips = make_material("PCH_Lips", srgb(LIP_SRGB), 0.65)
	band = make_material("PCH_Headband", srgb((0.45, 0.12, 0.10)), 0.85)
	assign_body_skin(body, skin)

	build_head(armature, skin, hair, eye_white, iris, pupil, lips, band)
	head_objects = [obj for obj in bpy.context.scene.objects
		if obj.type == "MESH" and obj is not body and obj.name != "Clothes"]
	clothes = build_clothes(body, armature)
	delete_hidden_body(body)
	join_head(head_objects)
	body.name = "WeaverBody"
	clothes.name = "WeaverClothes"
	trim_animations(armature)
	export(args.out)
	render_previews(args.preview)


if __name__ == "__main__":
	main()
