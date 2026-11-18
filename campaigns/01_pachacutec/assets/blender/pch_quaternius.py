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
- Los materiales se llaman `pch.body_<personaje>`, `pch.hair_<color>_<m|f>`,
  `pch.eye`, `pch_cloth` y `pch_tupu`. El GLB **sí** embebe el atlas textil de
  la ropa (`pch_cloth`); las texturas de cuerpo, cara, pelo y ojos se cargan
  compartidas desde `shared_assets/characters/quaternius/base/` y `faces/`.
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
	paint_textile,
	ring_points,
	set_cloth_texture,
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
		skin="pch.body_mid", face=(0.98, 1.00, 1.00), brow=(0.96, 0.82), brow_drop=-0.001, brow_angle=2.5, age=0.3,
		vstripes=True, nose_width=1.10, lip_volume=1.10,
		notes="mensajero de viaje, sin insignias",
	),
	"pch_npc_sisa_q": dict(
		gender="female", hair="Hair_Long", beard=False,
		garment="anacu", body="wool_brown", band="wool_ochre",
		lliclla="wool_cream", lliclla_stripe="wool_red", belt="wool_red",
		headband="wool_red", braids=True, width=0.98, head_scale=(0.97, 0.99, 1.00),
		skin="pch.body_light", face=(0.94, 0.98, 0.98), brow=(0.88, 0.48), brow_drop=-0.005, brow_angle=3.0, age=0.0,
		vstripes=True, nose_width=1.10, lip_volume=1.15,
		notes="joven de la llacta, anacu y lliclla con trenzas",
	),
	"pch_npc_curaca_q": dict(
		gender="male", hair="Hair_SimpleParted", beard=True, hair_grey=True,
		garment="unku", body="wool_cream", band="wool_red",
		band_style="tocapu", band_alt="wool_dark",
		manto="wool_red", headband="wool_ochre", chuspa="wool_blue",
		width=0.88, head_scale=(1.03, 1.00, 0.98),
		skin="pch.body_dark", face=(1.04, 1.02, 1.02), brow=(1.00, 1.00), age=0.9,
		vstripes=True, nose_width=1.12, lip_volume=1.10,
		notes="autoridad local, franja de t'oqapu y manto teñido",
	),
	"pch_npc_chanca_q": dict(
		gender="male", hair="Hair_SimpleParted", beard=False,
		garment="unku", body="wool_dark", band="wool_blue",
		manto="wool_grey", headband="wool_blue", chuspa="wool_red",
		width=1.02, head_scale=(1.05, 1.02, 1.03), dark_clothes=True,
		skin="pch.body_dark", face=(1.06, 1.04, 1.04), brow=(1.06, 1.08), brow_drop=-0.001, brow_angle=-2.0, age=0.4,
		vstripes=True, nose_width=1.12, lip_volume=1.10,
		notes="explorador chanca, sin metal",
	),
	# Arquetipos de multitud. La identidad andina se construye con pómulos
	# anchos, nariz recta, labios llenos, pelo negro liso y piel media/oscura;
	# no son retratos ni una reconstrucción antropológica.
	"pch_npc_anciana_q": dict(
		gender="female", hair="Hair_Long", beard=False, hair_grey=True,
		garment="anacu", body="wool_grey", band="wool_dark",
		lliclla="wool_brown", lliclla_stripe="wool_cream", belt="wool_dark",
		braids=True, width=1.02, head_scale=(1.02, 1.00, 0.98),
		skin="pch.body_dark", face=(1.04, 1.05, 1.06), brow=(0.95, 0.90), age=1.0,
		vstripes=True, nose_width=1.12, lip_volume=1.10,
		notes="mujer mayor de la comunidad, trenzas canosas y lliclla",
	),
	"pch_npc_joven_q": dict(
		gender="male", hair="Hair_SimpleParted", beard=False,
		garment="unku", body="wool_brown", band="wool_red",
		manto="wool_cream", chuspa="wool_ochre",
		width=0.94, head_scale=(1.00, 1.02, 1.00),
		skin="pch.body_mid", face=(1.03, 1.04, 1.07), brow=(0.98, 0.95), age=0.0,
		vstripes=True, nose_width=1.10, lip_volume=1.10,
		notes="joven de la comunidad, unku sencillo y chuspa",
	),
	# Familia de Rumi. Rasgos y ropa son reconstrucción (R); los personajes
	# concretos son ficción (N). La madre y el hermano comparten la llacta;
	# Puma y Anca aparecen en la asamblea y la posguerra.
	"pch_npc_madre_q": dict(
		gender="female", hair="Hair_Long", beard=False,
		garment="anacu", body="wool_brown", band="wool_dark",
		lliclla="wool_cream", lliclla_stripe="wool_red", belt="wool_red",
		headband="wool_cream", braids=True, width=1.00, head_scale=(1.01, 1.00, 0.99),
		skin="pch.body_mid", face=(1.03, 1.04, 1.05), brow=(0.95, 0.75), age=0.55,
		vstripes=True, nose_width=1.12, lip_volume=1.15,
		notes="madre de Rumi y Sisa, anacu y lliclla",
	),
	"pch_npc_hermano_q": dict(
		gender="male", hair="Hair_SimpleParted", beard=False,
		garment="unku", body="wool_brown", band="wool_ochre",
		manto="wool_grey", chuspa="wool_cream",
		width=0.93, head_scale=(1.00, 1.01, 1.00),
		skin="pch.body_mid", face=(1.02, 1.03, 1.05), brow=(0.98, 0.92), age=0.0,
		vstripes=True, nose_width=1.10, lip_volume=1.10,
		notes="hermano de Rumi, unku sencillo y chuspa",
	),
	"pch_npc_puma_q": dict(
		gender="male", hair="Hair_SimpleParted", beard=False,
		garment="unku", body="wool_cream", band="wool_red",
		manto="wool_brown", headband="wool_dark", chuspa="wool_blue",
		width=0.99, head_scale=(1.03, 1.02, 1.01),
		skin="pch.body_dark", face=(1.04, 1.04, 1.06), brow=(1.02, 1.00), age=0.4,
		vstripes=True, nose_width=1.12, lip_volume=1.10,
		notes="autoridad comunal aliada, sin insignias del curaca",
	),
	"pch_npc_anca_q": dict(
		gender="female", hair="Hair_Long", beard=False,
		garment="anacu", body="wool_brown", band="wool_dark",
		lliclla="wool_red", lliclla_stripe="wool_cream", belt="wool_dark",
		headband="wool_red", braids=True, width=0.98, head_scale=(1.01, 1.00, 0.99),
		skin="pch.body_mid", face=(1.03, 1.04, 1.04), brow=(0.94, 0.78), age=0.3,
		vstripes=True, nose_width=1.10, lip_volume=1.15,
		notes="mujer de la comunidad, anacu, lliclla y tupu",
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
	"""Peso del manto: arriba sigue la espalda; abajo cuelga de tres cadenas
	(L/C/R) que el juego simula con muelles. Así el paño se mece sin mover la
	lliclla del pecho ni la correa de la chuspa."""
	if point.z >= 1.30:
		return {"spine_03": 1.0}
	side = max(-1.0, min(1.0, point.x / 0.17))
	left = max(0.0, -side)
	right = max(0.0, side)
	center = 1.0 - abs(side)
	cape = min(1.0, (1.30 - point.z) / 0.25)
	spine = 1.0 - cape
	hang = min(1.0, max(0.0, (1.05 - point.z) / 0.33))
	weights = {"spine_03": spine}
	for name, share in (("L", left), ("C", center), ("R", right)):
		if share <= 0.0:
			continue
		weights["Cape_%s_1" % name] = cape * share * (1.0 - hang)
		weights["Cape_%s_2" % name] = cape * share * hang
	return weights


## Cadenas de manto: dos huesos por lado, colgando de la espalda alta. El
## juego las lee en `Cape_<lado>_1/2` y las mueve con `SpringBoneSimulator3D`.
CAPE_CHAINS = (("L", -1.0), ("C", 0.0), ("R", 1.0))


def add_cape_bones(armature):
	"""Añade las cadenas del manto al esqueleto UBC antes de construir la ropa.
	Los huesos son autoría propia; el cuerpo y los clips siguen siendo UBC."""
	parent = armature.data.bones.get("spine_03")
	if parent is None:
		return
	bpy.context.view_layer.objects.active = armature
	armature.select_set(True)
	bpy.ops.object.mode_set(mode="EDIT")
	bones = armature.data.edit_bones
	for name, side in CAPE_CHAINS:
		head = Vector((0.12 * side, 0.10, 1.32))
		mid = Vector((0.15 * side, 0.15, 1.02))
		tail = Vector((0.17 * side, 0.19, 0.72))
		first = bones.new("Cape_%s_1" % name)
		first.head = head
		first.tail = mid
		first.parent = bones.get("spine_03")
		first.use_connect = False
		second = bones.new("Cape_%s_2" % name)
		second.head = mid
		second.tail = tail
		second.parent = first
		second.use_connect = True
	bpy.ops.object.mode_set(mode="OBJECT")


def add_jaw_bone(armature):
	"""Hueso de mandíbula para abrir/cerrar la boca al hablar. La cara UBC no
	trae mandíbula ni blendshapes; este hueso mueve el labio inferior y el
	mentón sin tocar el resto de la cabeza."""
	parent = armature.data.bones.get("Head")
	if parent is None:
		return
	bpy.context.view_layer.objects.active = armature
	armature.select_set(True)
	bpy.ops.object.mode_set(mode="EDIT")
	bones = armature.data.edit_bones
	jaw = bones.new("Jaw")
	jaw.head = Vector((0.0, -0.020, 1.650))
	jaw.tail = Vector((0.0, -0.075, 1.585))
	jaw.parent = bones.get("Head")
	jaw.use_connect = False
	bpy.ops.object.mode_set(mode="OBJECT")


def weight_jaw(body, armature):
	"""Reparte el labio inferior, el mentón y la barba entre `Head` y `Jaw`
	para que la mandíbula los mueva sin arrastrar la nariz ni los ojos."""
	if armature.data.bones.get("Jaw") is None:
		return
	targets = [body]
	beard = bpy.data.objects.get("Beard")
	if beard is not None:
		targets.append(beard)
	for target in targets:
		head_group = target.vertex_groups.get("Head")
		if head_group is None:
			continue
		jaw_group = target.vertex_groups.get("Jaw") or target.vertex_groups.new(name="Jaw")
		for vertex in target.data.vertices:
			z = vertex.co.z
			if not (1.575 < z < 1.665):
				continue
			if vertex.co.y > -0.060 or abs(vertex.co.x) > 0.060:
				continue
			falloff = max(0.0, min(1.0, math.sin(math.pi * (z - 1.575) / 0.090)))
			weight = falloff * 0.85
			if weight <= 0.01:
				continue
			head_weight = 1.0
			for membership in vertex.groups:
				if membership.group == head_group.index:
					head_weight = membership.weight
					break
			jaw_group.add([vertex.index], head_weight * weight, "REPLACE")
			head_group.add([vertex.index], head_weight * (1.0 - weight), "REPLACE")


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
	"""Túnica con cuello alto y abertura frontal estrecha.

	La copia del cuerpo sube hasta 1,56 m para cubrir los hombros; se recorta
	un hueco alrededor del cuello y una abertura vertical en el pecho. Así
	desaparece el escote ancho que dejaba ver el hombro y la manga separada.
	"""
	for index in verts:
		point = body.points[index]
		if point.z < 0.94 or point.z > 1.56:
			return False
		if abs(point.x) > 0.74:
			return False
		if point.z > 1.51 and abs(point.x) < 0.075 and abs(point.y) < 0.075:
			return False
		if point.z > 1.48 and abs(point.x) < 0.012 and point.y < -0.07:
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
	# Las cejas comparten malla con el pelo, pero no deben ser tan oscuras:
	# un material propio les da un tono más suave y las separa del cabello.
	eyebrows = bpy.data.objects.get("Eyebrows")
	if eyebrows is not None and eyebrows.data.materials:
		brow = eyebrows.data.materials[0].copy()
		brow.name = "pch.brow_dark" + suffix
		eyebrows.data.materials.clear()
		eyebrows.data.materials.append(brow)
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
				line.append(garment.add_vertex(point, upper_body_weights(point)))
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

	# Chuspa en la cadera derecha.
	if spec.get("chuspa"):
		garment.piece = TEXTILE_PIECES["bag"]
		garment.box(
			Vector((0.235, -0.04, 0.88)), (0.12, 0.05, 0.17),
			Matrix.Identity(3), color(spec["chuspa"]),
			{"pelvis": 1.0},
		)
		# Correa de la chuspa, cruzada al pecho.
		strap_points = [
			Vector((-0.10, -0.145, 1.42)),
			Vector((0.02, -0.185, 1.24)),
			Vector((0.14, -0.145, 1.06)),
			Vector((0.235, -0.045, 0.98)),
		]
		strap_rings = []
		for index, point in enumerate(strap_points):
			ahead = strap_points[min(index + 1, len(strap_points) - 1)]
			behind = strap_points[max(index - 1, 0)]
			direction = (ahead - behind).normalized()
			across = direction.cross(Vector((0.0, 0.0, 1.0)))
			if across.length < 0.01:
				across = direction.cross(Vector((0.0, 1.0, 0.0)))
			across.normalize()
			up = across.cross(direction).normalized()
			radius = 0.012
			strap_rings.append([
				point + across * math.cos(angle) * radius + up * math.sin(angle) * radius
				for angle in [2.0 * math.pi * k / 8.0 for k in range(8)]
			])
		garment.tube(
			strap_rings,
			lambda _segment, _row: color(spec["chuspa"]),
			upper_body_weights,
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
	# El tupu es metal, no tela: disco y alfiler con material propio.
	if female and spec.get("lliclla"):
		tupu_material = bpy.data.materials.get("pch_tupu")
		if tupu_material is None:
			tupu_material = make_material("pch_tupu", color("copper"), 0.28, 0.85)
		ellipsoid("TupuDisc", Vector((0.0, -0.245, 1.30)), (0.040, 0.012, 0.040),
			tupu_material, armature, {"spine_03": 1.0}, segments=16, rings=6)
		box("TupuPin", Vector((0.0, -0.258, 1.30)), (0.010, 0.018, 0.075),
			tupu_material, armature, {"spine_03": 1.0})
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


def prepare_body_materials(body: bpy.types.Object, material_name: str) -> None:
	for slot in body.material_slots:
		if slot.material is not None:
			slot.material.name = material_name


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


def shape_age(spec: dict) -> None:
	"""Envejece la cara con volumen, no solo con textura.

	Hunde un poco las mejillas y adelanta la papada. Las arrugas finas van en
	la textura (`tools/build_face_textures.py`); aquí solo se busca la silueta
	del hombre mayor. Es reconstrucción (R), no un retrato.
	"""
	age = float(spec.get("age", 0.0))
	if age < 0.05:
		return
	body = bpy.data.objects.get("Body")
	if body is None:
		return
	for vertex in body.data.vertices:
		x = vertex.co.x
		y = vertex.co.y
		z = vertex.co.z
		# Mejillas hundidas: solo la cara frontal, sin tocar orejas ni cuello.
		if 1.640 < z < 1.688 and 0.030 < abs(x) < 0.068 and y < -0.045:
			vertex.co.y += 0.0032 * age
		# Papada: la mandíbula cede hacia fuera y hacia abajo.
		if 1.600 < z < 1.646 and 0.018 < abs(x) < 0.058 and y < -0.075:
			vertex.co.x *= 1.0 + 0.040 * age
			vertex.co.z -= 0.0028 * age
	body.data.update()


def shape_brows(spec: dict) -> None:
	"""Afina o engrosa las cejas sin tocar el resto de la cara.

	Las cejas son mallas independientes de UBC. La escala se aplica alrededor
	de su centro para que Sisa no comparta la ceja ancha del Curaca.
	"""
	scale = spec.get("brow", (1.0, 1.0))
	if not isinstance(scale, (tuple, list)) or len(scale) != 2:
		return
	sx, sz = float(scale[0]), float(scale[1])
	drop = float(spec.get("brow_drop", 0.0))
	angle = math.radians(float(spec.get("brow_angle", 0.0)))
	if (abs(sx - 1.0) < 0.001 and abs(sz - 1.0) < 0.001
			and abs(drop) < 0.001 and abs(angle) < 0.0001):
		return
	for obj in bpy.data.objects:
		if obj.type != "MESH" or not obj.name.startswith("Eyebrow"):
			continue
		# Cada ceja se escala alrededor de su propio centro: escalar las dos
		# juntas las junta y convierte a Sisa en un ceño fruncido.
		for side in (-1.0, 1.0):
			group = [vertex for vertex in obj.data.vertices
				if (vertex.co.x < 0.0) == (side < 0.0)]
			if not group:
				continue
			xs = [vertex.co.x for vertex in group]
			zs = [vertex.co.z for vertex in group]
			center_x = (min(xs) + max(xs)) * 0.5
			center_z = (min(zs) + max(zs)) * 0.5
			# La ceja base de UBC cae hacia la nariz. Un giro pequeño sube el
			# extremo interior y abre la expresión sin cambiar la malla.
			theta = angle if side < 0.0 else -angle
			cos_a = math.cos(theta)
			sin_a = math.sin(theta)
			for vertex in group:
				local_x = (vertex.co.x - center_x) * sx
				local_z = (vertex.co.z - center_z) * sz
				vertex.co.x = center_x + local_x * cos_a - local_z * sin_a
				vertex.co.z = center_z + local_x * sin_a + local_z * cos_a + drop
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
	nose_width = float(spec.get("nose_width", 1.0))
	lip_volume = float(spec.get("lip_volume", 1.0))
	for obj in bpy.data.objects:
		if obj.type != "MESH" or obj.name.startswith("Icosphere"):
			continue
		is_body = obj.name == "Body"
		for vertex in obj.data.vertices:
			x = vertex.co.x
			y = vertex.co.y
			z = vertex.co.z
			if 1.58 < z < 1.70:
				t = math.sin(math.pi * (z - 1.58) / 0.12)
				vertex.co.x *= 1.0 + (jaw - 1.0) * t
			if 1.66 < z < 1.76:
				t = math.sin(math.pi * (z - 1.66) / 0.10)
				vertex.co.x *= 1.0 + (cheek - 1.0) * t
				if is_body and y < -0.02:
					vertex.co.y *= 1.0 + (nose - 1.0) * t
			# Nariz más ancha: solo el caballete y la punta frontal.
			if is_body and 1.65 < z < 1.72 and abs(x) < 0.028 and y < -0.075:
				t = math.sin(math.pi * (z - 1.65) / 0.07)
				vertex.co.x *= 1.0 + (nose_width - 1.0) * t
			# Labios más llenos: se empujan hacia fuera en la boca frontal.
			if 1.625 < z < 1.665 and abs(x) < 0.040 and y < -0.095:
				t = math.sin(math.pi * (z - 1.625) / 0.040)
				vertex.co.y -= (lip_volume - 1.0) * 0.006 * t
		obj.data.update()


def strip_textures() -> None:
	"""Quita las texturas de cuerpo, pelo y ojos. El textil de la ropa se
	conserva: es un atlas por personaje y el juego lo necesita en el GLB."""
	for material in bpy.data.materials:
		if not material.use_nodes:
			continue
		if material.name.startswith("pch_cloth"):
			continue
		for node in list(material.node_tree.nodes):
			if node.type == "TEX_IMAGE":
				material.node_tree.nodes.remove(node)


def build_character(spec: dict, name: str, out_dir: str):
	clear_scene()
	armature, body = import_ubc(spec["gender"])
	# La textura de rostro es propia de cada papel: el nombre del material la
	# elige en `SurfaceMaterials` (`pch.body_sisa`, `pch.body_curaca`...).
	body_material = str(spec.get("body_material",
		"pch.body_" + name.replace("pch_npc_", "").replace("_q", "")))
	prepare_body_materials(body, body_material)
	# Cadenas del manto, antes de construir la ropa para que las costuras
	# encuentren sus grupos de vértices.
	add_cape_bones(armature)
	add_jaw_bone(armature)
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
		grey_material = bpy.data.materials.get("pch.brow_grey" + gender_suffix)
		if grey_material is None:
			grey_material = bpy.data.materials.new("pch.brow_grey" + gender_suffix)
		for obj in bpy.data.objects:
			if obj.type == "MESH" and obj.name.startswith("Eyebrow"):
				obj.data.materials.clear()
				obj.data.materials.append(grey_material)
	# Ropa y textil pintado. El textil va embebido en el GLB; las texturas de
	# cuerpo, pelo y ojos siguen compartidas desde `base/` y `faces/`.
	clothes = build_clothes(body, armature, spec, hair_name)
	dims = {
		"waist": WAIST_Z,
		"shoulder": SHOULDER_Z,
		"bottom": 0.12 if spec["garment"] == "anacu" else 0.56,
		"knee": 0.50,
	}
	set_cloth_texture(paint_textile(spec, dims, seed=sum(ord(c) for c in name)))
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
	shape_brows(spec)
	apply_width(armature, float(spec.get("width", 1.0)))
	shape_head(spec)
	shape_face(spec)
	shape_age(spec)
	weight_jaw(body, armature)
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
		export_image_format="AUTO",
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
