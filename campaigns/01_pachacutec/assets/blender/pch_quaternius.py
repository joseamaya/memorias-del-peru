"""Genera el prototipo de personajes Quaternius de la campaña 01.

Los cuerpos, ojos y peinados son de Universal Base Characters (Quaternius,
CC0). La ropa, trenzas, cintas y sandalias son autoría propia. El esqueleto
de 65 huesos es el mismo de UAL1/UAL2, así que los clips de UAL1 se añaden en
el juego con `QuaterniusClips` sin retargeting.

Uso (desde la raíz del repositorio):

    blender --background --factory-startup \
        --python campaigns/01_pachacutec/assets/blender/pch_quaternius.py -- \
        [--only pch_npc_mensajero_q] [--out DIR] [--preview DIR]

El GLB sale sin animaciones: el AnimationPlayer y los clips se crean en
Godot. Así el mismo cuerpo se reutiliza con distintos clips y no se duplican
animaciones por personaje.

Convenciones:
- 1 unidad = 1 metro, pies en el suelo, frente hacia -Z de Godot.
- La ropa lleva clase de superficie y coordenadas de tejido para el shader
  `pch_cloth`, igual que `pch_people.py`.
- Los materiales se llaman `pch.body_<tono>_<m|f>`, `pch.hair_<color>_<m|f>`,
  `pch.eye` y `pch_cloth`. `SurfaceMaterials` carga las texturas compartidas de
  `shared_assets/characters/quaternius/base/`: el GLB no las embebe.
"""

import argparse
import math
import os
import sys

import bpy
from mathutils import Matrix, Vector

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_DIR = os.path.normpath(os.path.join(SCRIPT_DIR, "..", "..", "..", ".."))
DEFAULT_OUT = os.path.normpath(os.path.join(SCRIPT_DIR, "..", "models"))
DEFAULT_PREVIEW = "/tmp/opencode/quaternius_preview"
QUATERNIUS_DIR = os.path.join(REPO_DIR, "shared_assets", "characters", "quaternius")
BASE_DIR = os.path.join(QUATERNIUS_DIR, "base")
HAIR_DIR = os.path.join(QUATERNIUS_DIR, "hair")

# Reutiliza las clases de ropa y la paleta de `pch_dressed.py`/`pch_people.py`.
sys.path.insert(0, SCRIPT_DIR)
import pch_dressed as kit  # noqa: E402
from pch_dressed import (  # noqa: E402
	BodyInfo,
	Garment,
	TEXTILE_PIECES,
	_linear,
	add_cloth_ellipsoid,
	add_weights,
	box,
	clear_scene,
	ellipsoid,
	make_material,
	parent_to_armature,
	ring_points,
	setup_cloth_material,
	smooth,
	srgb,
)

# Altura de la cabeza de UBC: 1,60 m; la coronilla, 1,81 m.
HEAD_Z = 1.66
HEAD_TOP = 1.84
WAIST_Z = 0.98
SHOULDER_Z = 1.47

# Especificaciones del prototipo. Los colores son de la paleta de PCH-018;
# la combinación concreta es reconstrucción (R), no un hecho documentado.
SPECS = {
	"pch_npc_mensajero_q": dict(
		gender="male", hair="Hair_SimpleParted", beard=False,
		garment="unku", body="wool_brown", band="wool_dark",
		manto="wool_cream", head_cloth="wool_brown", chuspa="wool_cream",
		headband=None, width=0.90, head_scale=(0.96, 1.00, 1.02),
		skin="pch.body_mid", face=(0.98, 1.00, 1.00),
		notes="mensajero de viaje, sin insignias",
	),
	"pch_npc_sisa_q": dict(
		gender="female", hair="Hair_Long", beard=False,
		garment="anacu", body="wool_brown", band="wool_ochre",
		lliclla="wool_cream", lliclla_stripe="wool_red", belt="wool_red",
		headband="wool_red", braids=True, width=0.98, head_scale=(0.97, 0.99, 1.00),
		skin="pch.body_light", face=(0.94, 0.98, 0.98),
		notes="joven de la llacta, anacu y lliclla con trenzas",
	),
	"pch_npc_curaca_q": dict(
		gender="male", hair="Hair_SimpleParted", beard=True, hair_grey=True,
		garment="unku", body="wool_cream", band="wool_red",
		band_style="tocapu", band_alt="wool_dark",
		manto="wool_red", headband="wool_ochre", chuspa="wool_blue",
		width=0.88, head_scale=(1.03, 1.00, 0.98),
		skin="pch.body_dark", face=(1.04, 1.02, 1.02),
		notes="autoridad local, franja de t'oqapu y manto teñido",
	),
	"pch_npc_chanca_q": dict(
		gender="male", hair="Hair_SimpleParted", beard=False,
		garment="unku", body="wool_dark", band="wool_blue",
		manto="wool_grey", headband="wool_blue", chuspa="wool_red",
		width=1.02, head_scale=(1.05, 1.02, 1.03), dark_clothes=True,
		skin="pch.body_dark", face=(1.06, 1.04, 1.04),
		notes="explorador chanca, sin metal",
	),
}

# Huesos de UBC usados por la ropa.
TORSO_BONES = ("spine_01", "spine_02", "spine_03", "pelvis")


def upper_body_weights(point: Vector) -> dict:
	if point.z >= 1.22:
		return {"spine_03": 1.0}
	if point.z >= 1.05:
		t = (point.z - 1.05) / 0.17
		return {"spine_03": t, "spine_02": 1.0 - t}
	return {"spine_02": 1.0}


def skirt_weights(point: Vector) -> dict:
	# La falda cuelga de la cadera; los muslos solo acompañan el vuelo.
	t = max(0.0, min(1.0, (WAIST_Z - point.z) / 0.85)) * 0.38
	side = max(-1.0, min(1.0, point.x / 0.13))
	return {
		"pelvis": 1.0 - t,
		"thigh_l": t * (0.5 + 0.5 * side),
		"thigh_r": t * (0.5 - 0.5 * side),
	}


def mantle_weights(point: Vector) -> dict:
	if point.z >= 1.30:
		return {"spine_03": 1.0}
	if point.z >= 1.10:
		t = (point.z - 1.10) / 0.20
		return {"spine_03": t, "spine_02": 1.0 - t}
	if point.z >= 0.88:
		t = (point.z - 0.88) / 0.22
		return {"spine_02": t, "pelvis": 1.0 - t}
	return {"pelvis": 1.0}


def color(name: str) -> tuple:
	return _linear(name)


def band_color(spec: dict, point: Vector) -> tuple:
	"""Color de la túnica con una franja de cintura y un bajo oscuro."""
	base = color(spec["body"])
	if point.z < 1.04 and point.z > 0.94:
		return color(spec.get("band", "wool_dark"))
	if point.z < 0.72:
		return color(spec.get("band", "wool_dark"))
	if spec.get("band_style") == "tocapu" and 1.04 <= point.z <= 1.14:
		# Franja ajedrezada: dos colores alternos por columnas.
		return color(spec.get("band_alt", "wool_dark")) if int(abs(point.x) * 80.0) % 2 == 0 else color(spec["band"])
	return base


def tunic_face(body: BodyInfo, verts: tuple) -> bool:
	for index in verts:
		point = body.points[index]
		if point.z < 0.94 or point.z > 1.52:
			return False
		if abs(point.x) > 0.74:
			return False
	return True


def import_ubc(gender: str):
	file_name = "Superhero_Male_FullBody.gltf" if gender == "male" else "Superhero_Female_FullBody.gltf"
	path = os.path.join(BASE_DIR, file_name)
	if not os.path.exists(path):
		raise SystemExit("Falta el cuerpo UBC: %s" % path)
	bpy.ops.import_scene.gltf(filepath=path)
	armature = None
	body = None
	for obj in bpy.data.objects:
		if obj.type == "ARMATURE":
			armature = obj
		elif obj.type == "MESH" and obj.name.startswith("Super"):
			body = obj
	# La esfera de relleno no es parte del personaje.
	for obj in list(bpy.data.objects):
		if obj.type == "MESH" and obj.name.startswith("Icosphere"):
			bpy.data.objects.remove(obj, do_unlink=True)
	if armature is None or body is None:
		raise SystemExit("No se encontró el cuerpo o el esqueleto UBC")
	# Nombres de material que el juego reconoce. El sufijo _m/_f elige la
	# textura compartida en `SurfaceMaterials`.
	suffix = "_m" if gender == "male" else "_f"
	for material in bpy.data.materials:
		if material.name.startswith("MI_Superhero"):
			material.name = "pch.body" + suffix
		elif material.name == "MI_Eyes":
			material.name = "pch.eye"
		elif material.name.startswith("MI_Hair"):
			material.name = "pch.hair_dark" + suffix
	armature.name = "Armature"
	body.name = "Body"
	return armature, body


def import_hair(armature, hair_name: str, material_name: str = "pch.hair", grey: bool = False):
	path = os.path.join(HAIR_DIR, hair_name + ".gltf")
	if not os.path.exists(path):
		raise SystemExit("Falta el peinado: %s" % path)
	before = set(bpy.data.objects)
	bpy.ops.import_scene.gltf(filepath=path)
	hair = None
	for obj in [item for item in bpy.data.objects if item not in before]:
		if obj.type == "MESH" and obj.name.startswith("Hair"):
			hair = obj
		elif obj.type == "MESH" and obj.name.startswith("Icosphere"):
			bpy.data.objects.remove(obj, do_unlink=True)
	if hair is None:
		return None
	hair_material = bpy.data.materials.get(material_name)
	if hair_material is None and grey:
		var_base = bpy.data.materials.get("pch.hair")
		hair_material = var_base.copy() if var_base is not None else bpy.data.materials.new(material_name)
		hair_material.name = material_name
	elif hair_material is None:
		hair_material = bpy.data.materials.new(material_name)
		hair_material.use_nodes = True
	hair.data.materials.clear()
	hair.data.materials.append(hair_material)
	add_weights(hair, {"Head": 1.0})
	parent_to_armature(hair, armature)
	smooth(hair)
	return hair


def add_sleeve(garment: Garment, armature, side: str, color_name: str, short: bool = False):
	"""Manga taperada a lo largo del brazo, con pesos hombro/codo."""
	upper = armature.pose.bones["upperarm_%s" % side]
	lower = armature.pose.bones["lowerarm_%s" % side]
	hand = armature.pose.bones["hand_%s" % side]
	start = upper.head.copy()
	elbow = lower.head.copy()
	end = hand.head.copy() if short else lower.tail.copy()
	if short:
		end = start.lerp(elbow, 0.82)
	# Puntos a lo largo del brazo y radios decrecientes.
	points = [start.lerp(elbow, t) for t in (0.0, 0.35, 0.7, 1.0)]
	if not short:
		points += [elbow.lerp(end, t) for t in (0.35, 0.7, 1.0)]
	radii = [0.080, 0.072, 0.064, 0.056, 0.050, 0.045, 0.041]
	radii = radii[:len(points)]
	angles = [2.0 * math.pi * s / 16.0 for s in range(16)]
	rings = []
	for point_index, (point, radius) in enumerate(zip(points, radii)):
		# Plano perpendicular a la dirección del brazo.
		idx = min(len(points) - 1, point_index + 1)
		direction = (points[idx] - point).normalized() if idx != point_index else (point - start).normalized()
		if direction.length < 0.01:
			direction = Vector((1.0, 0.0, 0.0))
		across = direction.cross(Vector((0.0, 0.0, 1.0)))
		if across.length < 0.01:
			across = direction.cross(Vector((0.0, 1.0, 0.0)))
		across.normalize()
		up = across.cross(direction).normalized()
		ring = [point + across * math.cos(a) * radius + up * math.sin(a) * radius for a in angles]
		rings.append(ring)

	def weights(point: Vector) -> dict:
		along = (point - start).length
		elbow_distance = (elbow - start).length
		if along <= elbow_distance * 0.92:
			return {"upperarm_%s" % side: 1.0}
		if along <= elbow_distance * 1.08:
			t = (along - elbow_distance * 0.92) / (elbow_distance * 0.16)
			return {"upperarm_%s" % side: 1.0 - t, "lowerarm_%s" % side: t}
		return {"lowerarm_%s" % side: 1.0}

	def sleeve_color(_s: int, row: int) -> tuple:
		if row >= len(points) - 2:
			return color("wool_dark")
		return color(color_name)

	garment.tube(rings, sleeve_color, weights)


def build_clothes(body: bpy.types.Object, armature, spec: dict, hair_material_name: str):
	body_info = BodyInfo(body)
	garment = Garment()
	segments = 24
	female = spec["garment"] == "anacu"

	# Túnica o vestido: copia de la superficie del torso y los hombros.
	garment.piece = TEXTILE_PIECES["garment"]
	garment.add_body_surface(
		body_info,
		lambda verts: tunic_face(body_info, verts),
		0.048,
		lambda index: band_color(spec, body_info.points[index]),
	)
	# Cuello.
	garment.tube(
		[
			ring_points(1.46, 0.115, 0.095, 0.0, segments),
			ring_points(1.50, 0.100, 0.082, 0.0, segments),
		],
		lambda _s, _r: color(spec.get("band", "wool_dark")),
		lambda _p: {"spine_03": 0.5, "neck_01": 0.5},
	)
	# Mangas.
	for side in ("l", "r"):
		add_sleeve(garment, armature, side, spec["body"], short=female)

	# Falda: unku hasta media pierna; anacu hasta el tobillo.
	garment.piece = TEXTILE_PIECES["garment"]
	if female:
		rings = [
			ring_points(0.98, 0.205, 0.160, 0.0, segments, fold=0.014),
			ring_points(0.80, 0.235, 0.185, 0.0, segments, fold=0.018),
			ring_points(0.60, 0.275, 0.220, 0.0, segments, fold=0.022),
			ring_points(0.40, 0.320, 0.260, 0.0, segments, fold=0.028),
			ring_points(0.22, 0.360, 0.295, 0.0, segments, fold=0.032),
			ring_points(0.12, 0.380, 0.310, 0.0, segments, fold=0.034),
		]
	else:
		rings = [
			ring_points(0.98, 0.205, 0.160, 0.0, segments, fold=0.012),
			ring_points(0.82, 0.230, 0.180, 0.0, segments, fold=0.016),
			ring_points(0.68, 0.255, 0.198, 0.0, segments, fold=0.020),
			ring_points(0.56, 0.275, 0.215, 0.0, segments, fold=0.022),
		]

	def skirt_color(_s: int, row: int) -> tuple:
		if row == len(rings) - 1:
			return color(spec.get("band", "wool_dark"))
		if row == 0:
			return color(spec.get("belt", spec.get("band", "wool_dark")))
		return color(spec["body"])

	garment.tube(rings, skirt_color, skirt_weights)

	# Faja.
	garment.piece = TEXTILE_PIECES["belt"]
	garment.tube(
		[
			ring_points(0.96, 0.215, 0.165, 0.0, segments),
			ring_points(1.03, 0.210, 0.160, 0.0, segments),
		],
		lambda _s, _r: color(spec.get("belt", spec.get("band", "wool_dark"))),
		lambda _p: {"pelvis": 1.0},
	)

	# Manto o lliclla: capa abierta por delante, echada sobre los hombros.
	garment.piece = TEXTILE_PIECES["lliclla"]
	cloth_name = spec.get("lliclla", spec.get("manto", "wool_cream"))
	stripe_name = spec.get("lliclla_stripe", spec.get("band", "wool_dark"))
	top = 1.45
	bottom = 0.52 if female else 0.78
	rows, cols = 5, 12
	ids = []
	for row in range(rows + 1):
		t = float(row) / float(rows)
		z = top - (top - bottom) * t
		rx = 0.215 + 0.105 * t
		ry = 0.135 + 0.075 * t
		line = []
		for col in range(cols + 1):
			u = float(col) / float(cols)
			# Abierto por delante: recorre los lados y la espalda.
			angle = math.radians(62.0 + 236.0 * u)
			x = math.sin(angle) * rx
			y = -math.cos(angle) * ry + 0.010
			point = Vector((x, y, z))
			line.append(garment.add_vertex(point, mantle_weights(point)))
		ids.append(line)
	for row in range(rows):
		for col in range(cols):
			border = col == 0 or col == cols - 1 or row == rows - 1
			if border:
				base = color("wool_cream") if female else color(stripe_name)
			else:
				base = color(cloth_name)
			garment.add_face(
				[ids[row][col], ids[row][col + 1], ids[row + 1][col + 1], ids[row + 1][col]],
				base,
				[(col, row), (col + 1, row), (col + 1, row + 1), (col, row + 1)],
			)

	# Delantero de la lliclla femenina: el paño se ve sobre el pecho.
	if female:
		garment.piece = TEXTILE_PIECES["lliclla"]
		front_cols, front_rows = 6, 3
		front_ids = []
		for row in range(front_rows + 1):
			t = float(row) / float(front_rows)
			line = []
			for col in range(front_cols + 1):
				u = float(col) / float(front_cols)
				x = (u - 0.5) * 0.34
				z = 1.42 - 0.30 * t
				y = -0.205 - 0.010 * math.sin(math.pi * u)
				point = Vector((x, y, z))
				line.append(garment.add_vertex(point, mantle_weights(point)))
			front_ids.append(line)
		for row in range(front_rows):
			for col in range(front_cols):
				border = row == 0 or row == front_rows - 1
				base = color(stripe_name) if border else color(cloth_name)
				garment.add_face(
					[front_ids[row][col], front_ids[row][col + 1], front_ids[row + 1][col + 1], front_ids[row + 1][col]],
					base,
					[(col, row), (col + 1, row), (col + 1, row + 1), (col, row + 1)],
				)
		# Tupu: alfiler de cobre que prende la lliclla al pecho.
		garment.piece = TEXTILE_PIECES["belt"]
		garment.box(
			Vector((0.0, -0.240, 1.30)), (0.075, 0.018, 0.075),
			Matrix.Identity(3), color("copper"), {"spine_03": 1.0},
		)

	# Chuspa en la cadera derecha.
	if spec.get("chuspa"):
		garment.piece = TEXTILE_PIECES["bag"]
		garment.box(
			Vector((0.235, -0.04, 0.88)), (0.12, 0.07, 0.17),
			Matrix.Identity(3), color(spec["chuspa"]),
			{"pelvis": 1.0},
		)

	# Sandalias: suela y dos tiras por pie.
	garment.piece = TEXTILE_PIECES["garment"]
	for side, suffix in ((1.0, "l"), (-1.0, "r")):
		x = 0.095 * side
		garment.box(Vector((x, -0.055, 0.020)), (0.115, 0.28, 0.030),
			Matrix.Identity(3), color("sole"), {"foot_%s" % suffix: 1.0})
		garment.box(Vector((x, -0.08, 0.060)), (0.105, 0.025, 0.020),
			Matrix.Identity(3), color("rope"), {"foot_%s" % suffix: 1.0})
		garment.box(Vector((x, 0.02, 0.065)), (0.10, 0.022, 0.020),
			Matrix.Identity(3), color("rope"), {"foot_%s" % suffix: 1.0})

	# Cinta o paño de cabeza.
	if spec.get("headband") or spec.get("head_cloth"):
		head_color = spec.get("headband") or spec.get("head_cloth")
		garment.piece = TEXTILE_PIECES["headwear"]
		garment.tube(
			[
				ring_points(HEAD_Z + 0.055, 0.082, 0.086, 0.0, 28),
				ring_points(HEAD_Z + 0.085, 0.084, 0.088, 0.0, 28),
			],
			lambda _s, _r: color(head_color),
			lambda _p: {"Head": 1.0},
		)

	# Trenzas: dos series de cuentas que caen por la espalda.
	if spec.get("braids"):
		garment.piece = TEXTILE_PIECES["garment"]
		for side in (-1.0, 1.0):
			for index in range(7):
				t = float(index) / 6.0
				center = Vector((0.072 * side + 0.020 * side * t, 0.055 + 0.035 * t, HEAD_Z + 0.02 - 0.36 * t))
				ellipsoid(
					"Braid%s%d" % ("L" if side > 0 else "R", index),
					center, (0.020 - 0.003 * t, 0.020 - 0.003 * t, 0.032),
					bpy.data.materials[hair_material_name], armature,
					{"Head": 1.0}, segments=10, rings=6,
				)

	clothes = garment.to_object("Clothes", bpy.context.scene.collection, armature)
	setup_cloth_material()
	# Solo suavizado: la copia del cuerpo ya trae detalle y no queremos
	# duplicar triángulos con subdivisión.
	smooth_mod = clothes.modifiers.new("Smooth", "SMOOTH")
	smooth_mod.factor = 0.35
	smooth_mod.iterations = 1
	bpy.context.view_layer.objects.active = clothes
	clothes.select_set(True)
	bpy.ops.object.modifier_apply(modifier="Smooth")
	clothes.select_set(False)
	return clothes


def prepare_body_materials(body: bpy.types.Object, skin_name: str = "pch.body_mid",
		gender: str = "male"):
	suffix = "_m" if gender == "male" else "_f"
	for slot in body.material_slots:
		if slot.material is not None:
			slot.material.name = skin_name + suffix


def apply_width(armature, width: float) -> None:
	"""Estrecha o ensancha el cuerpo entero y hornea la escala.

	Se aplica a la armadura y a todas las mallas: así el GLB no lleva nodos con
	escala (lo exige `AssetValidation`) y las animaciones siguen funcionando
	sobre el mismo rig.
	"""
	if abs(width - 1.0) < 0.001:
		return
	armature.scale = (width, 1.0, 1.0)
	bpy.ops.object.select_all(action="DESELECT")
	armature.select_set(True)
	for obj in bpy.data.objects:
		if obj.type == "MESH" and not obj.name.startswith("Icosphere"):
			obj.select_set(True)
	bpy.context.view_layer.objects.active = armature
	bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)


def shape_head(spec: dict) -> None:
	"""Da una proporción de cabeza distinta a cada papel.

	No sustituye una cara esculpida: es una variación de silueta para que los
	cuatro personajes no compartan exactamente el mismo cráneo. Se aplica a
	 cuerpo, ojos, cejas, pelo, barba y tocado.
	"""
	scale = spec.get("head_scale", (1.0, 1.0, 1.0))
	if not isinstance(scale, (tuple, list)) or len(scale) != 3:
		return
	hx, hy, hz = float(scale[0]), float(scale[1]), float(scale[2])
	if abs(hx - 1.0) < 0.001 and abs(hy - 1.0) < 0.001 and abs(hz - 1.0) < 0.001:
		return
	center = Vector((0.0, 0.0, 1.70))
	for obj in bpy.data.objects:
		if obj.type != "MESH" or obj.name.startswith("Icosphere"):
			continue
		for vertex in obj.data.vertices:
			if vertex.co.z <= 1.60:
				continue
			vertex.co.x *= hx
			vertex.co.y *= hy
			vertex.co.z = center.z + (vertex.co.z - center.z) * hz
		obj.data.update()


def shape_face(spec: dict) -> None:
	"""Variación suave de mandíbula, pómulos y profundidad de nariz.

	No es una cara esculpida: es una licencia artística (R) para que los cuatro
	papeles no compartan el mismo cráneo. Mantiene los ojos y el pelo alineados.
	"""
	face = spec.get("face", (1.0, 1.0, 1.0))
	if not isinstance(face, (tuple, list)) or len(face) != 3:
		return
	jaw, cheek, nose = float(face[0]), float(face[1]), float(face[2])
	if abs(jaw - 1.0) < 0.001 and abs(cheek - 1.0) < 0.001 and abs(nose - 1.0) < 0.001:
		return
	for obj in bpy.data.objects:
		if obj.type != "MESH" or obj.name.startswith("Icosphere"):
			continue
		is_body = obj.name == "Body"
		for vertex in obj.data.vertices:
			z = vertex.co.z
			if 1.58 < z < 1.70:
				t = math.sin(math.pi * (z - 1.58) / 0.12)
				vertex.co.x *= 1.0 + (jaw - 1.0) * t
			if 1.66 < z < 1.76:
				t = math.sin(math.pi * (z - 1.66) / 0.10)
				vertex.co.x *= 1.0 + (cheek - 1.0) * t
				if is_body and vertex.co.y < -0.02:
					vertex.co.y *= 1.0 + (nose - 1.0) * t
		obj.data.update()


def strip_textures() -> None:
	"""Quita las texturas del GLB: el juego las comparte desde `base/`."""
	for material in bpy.data.materials:
		if not material.use_nodes:
			continue
		for node in list(material.node_tree.nodes):
			if node.type == "TEX_IMAGE":
				material.node_tree.nodes.remove(node)


def build_character(spec: dict, name: str, out_dir: str):
	clear_scene()
	armature, body = import_ubc(spec["gender"])
	prepare_body_materials(body, str(spec.get("skin", "pch.body_mid")), str(spec["gender"]))
	# Peinado y barba.
	grey = bool(spec.get("hair_grey", False))
	gender_suffix = "_m" if str(spec["gender"]) == "male" else "_f"
	hair_name = "pch.hair_grey" + gender_suffix if grey else "pch.hair_dark" + gender_suffix
	hair = import_hair(armature, spec["hair"], hair_name, grey)
	if spec.get("beard"):
		beard = import_hair(armature, "Hair_Beard", hair_name, grey)
		if beard is not None:
			# Barba canosa para la autoridad; el material se comparte con el pelo.
			beard.name = "Beard"
	if grey:
		grey_material = bpy.data.materials.get("pch.hair_grey" + gender_suffix)
		for obj in bpy.data.objects:
			if obj.type == "MESH" and obj.name.startswith("Eyebrow") and grey_material is not None:
				obj.data.materials.clear()
				obj.data.materials.append(grey_material)
	# Ropa.
	clothes = build_clothes(body, armature, spec, hair_name)
	# Las trenzas se unen al pelo para no añadir una malla por cuenta.
	braids = [obj for obj in bpy.data.objects if obj.type == "MESH" and obj.name.startswith("Braid")]
	if hair is not None and braids:
		bpy.ops.object.select_all(action="DESELECT")
		hair.select_set(True)
		for braid in braids:
			braid.select_set(True)
		bpy.context.view_layer.objects.active = hair
		bpy.ops.object.join()
		hair.name = "Hair"
	apply_width(armature, float(spec.get("width", 1.0)))
	shape_head(spec)
	shape_face(spec)
	# Orientación del proyecto: el frente mira a -Z de Godot. El importador
	# deja la armadura en modo cuaternión; hay que cambiarlo para que el giro
	# se exporte.
	armature.rotation_mode = "XYZ"
	armature.rotation_euler[2] = math.pi
	# Metadatos que el juego lee: rig y ritmo de zancada.
	armature["pch_rig"] = "quaternius"
	armature["pch_note"] = spec.get("notes", "")
	armature["pch_walk_cycle_speed"] = 1.05
	armature["pch_run_cycle_speed"] = 2.45
	armature["pch_work_beat"] = 1.4
	body["pch_rig"] = "quaternius"
	# Nombres finales.
	body.name = "Body"
	clothes.name = "Clothes"
	armature.name = "Armature"
	strip_textures()
	# Exporta solo la jerarquía del personaje.
	os.makedirs(out_dir, exist_ok=True)
	path = os.path.join(out_dir, name + ".glb")
	bpy.ops.export_scene.gltf(
		filepath=path,
		export_format="GLB",
		export_yup=True,
		export_apply=True,
		export_animations=False,
		export_skins=True,
		export_cameras=False,
		export_lights=False,
		export_extras=True,
		export_vertex_color="ACTIVE",
		export_image_format="NONE",
	)
	print("EXPORTED", path)
	return path


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("--out", default=DEFAULT_OUT)
	parser.add_argument("--preview", default=DEFAULT_PREVIEW)
	parser.add_argument("--only", default="")
	args = parser.parse_args(sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else [])
	names = [args.only] if args.only else list(SPECS.keys())
	for name in names:
		if name not in SPECS:
			raise SystemExit("Personaje desconocido: %s" % name)
		build_character(SPECS[name], name, args.out)
	print("PERSONAJES_OK", len(names))


if __name__ == "__main__":
	main()
