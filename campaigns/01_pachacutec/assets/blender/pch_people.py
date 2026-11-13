"""Generador de los personajes realistas de la campaña 01 (ADR-0016).

Crea cada personaje con MPFB2 (MakeHuman para Blender), le pone ropa andina
generada aquí mismo (las prendas grandes, cortadas como paños de telar y caídas
con la simulación de tela de Blender, ADR-0020), traslada la captura de
movimiento de CMU a su esqueleto y lo exporta a glTF binario en
`assets/models/pch_npc_<papel>.glb`.

Requisitos (no se versionan; ver ADR-0016):

1. MPFB2 2.0.18 instalado en un directorio de usuario de Blender aparte:

       export BLENDER_USER_RESOURCES=<dir>
       blender --factory-startup --command extension install-file \\
           -r user_default -e add-on-mpfb-v2.0.18.zip

2. Los recursos CC0 de MakeHuman (`makehuman_system_assets_cc0.zip`)
   descomprimidos en `<dir>/extensions/.user/user_default/mpfb/data/`.
3. Las tomas ASF/AMC de CMU en un directorio, indicado con `--cmu`.
4. Las cabezas de Rocketbox (ADR-0017): por cada avatar de `PEOPLE[...]["head"]`,
   una carpeta con su FBX (`Export/<avatar>.fbx`) y sus texturas
   `*_head_color.tga`, `*_head_normal.tga` y `*_opacity_color.tga`, todo bajo
   el directorio indicado con `--rocketbox`.

Uso (desde la raíz del repositorio):

    BLENDER_USER_RESOURCES=<dir> blender --background --factory-startup \\
        --python campaigns/01_pachacutec/assets/blender/pch_people.py -- \\
        --cmu <dir_cmu> --rocketbox <dir_rocketbox> [--out DIR] [--preview DIR] [nombre ...]

Convenciones:
- 1 unidad = 1 metro, pies en el suelo y frente hacia +Y de Blender (−Z de
  Godot), como el resto de modelos. MakeHuman mira hacia −Y, así que el
  esqueleto se gira 180° al exportar.
- Las animaciones se llaman como en ADR-0015 y se exportan como pistas NLA.
- Tras exportar, ejecutar `postprocess_capes.py` sobre cada `pch_npc_*.glb`
  para ajustar la apertura de mantos y llicllas (alcance v4.15). Ese paso no
  toca huesos, pesos, UV ni animaciones.
- La ropa lleva la clase de superficie en UV0 (tejido) y coordenadas de tejido
  en UV1, con el material «pch_cloth» que el juego sustituye por el suyo.

Los personajes son reconstrucciones (R) según PCH-011, PCH-017 y PCH-018.
"""

import argparse
import math
import os
import sys

import bmesh
import bpy
from mathutils import Matrix, Quaternion, Vector, bvhtree, kdtree

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DEFAULT_OUT = os.path.normpath(os.path.join(SCRIPT_DIR, "..", "models"))

ANIM_FPS = 30
# Clase de superficie del tejido (SurfaceMaterials.Layer.FABRIC + 1).
FABRIC_CLASS = 5.0
CLOTH_MATERIAL = "pch_cloth"
TEXTURE_SIZE = 1024

# Paleta de tejidos (sRGB), la misma que la de pch_models.py.
WOOL = {
	"wool_cream": (0.80, 0.74, 0.62),
	"wool_brown": (0.42, 0.29, 0.19),
	"wool_dark": (0.22, 0.17, 0.13),
	"wool_grey": (0.52, 0.49, 0.45),
	"wool_red": (0.62, 0.16, 0.12),
	"wool_ochre": (0.74, 0.54, 0.22),
	"wool_green": (0.30, 0.40, 0.22),
	"wool_blue": (0.18, 0.24, 0.40),
	"rope": (0.62, 0.52, 0.34),
	"copper": (0.66, 0.40, 0.22),
	"sole": (0.36, 0.27, 0.18),
	"wood": (0.42, 0.26, 0.14),
	"wood_light": (0.60, 0.43, 0.26),
}

# Tono de piel buscado (sRGB medio) y de pelo. Interpretación declarada
# (PCH-018): moreno de la sierra, pelo negro.
SKIN_TARGET = (0.56, 0.39, 0.28)
HAIR_TARGET = (0.05, 0.045, 0.04)

# Huesos de CMU (ASF) y su equivalente en el esqueleto cmu_mb de MPFB2.
CMU_TO_RIG = {
	"root": "Hips", "lowerback": "LowerBack", "upperback": "Spine", "thorax": "Spine1",
	"lowerneck": "Neck", "upperneck": "Neck1", "head": "Head",
	"lhipjoint": "LHipJoint", "lfemur": "LeftUpLeg", "ltibia": "LeftLeg", "lfoot": "LeftFoot", "ltoes": "LeftToeBase",
	"rhipjoint": "RHipJoint", "rfemur": "RightUpLeg", "rtibia": "RightLeg", "rfoot": "RightFoot", "rtoes": "RightToeBase",
	"lclavicle": "LeftShoulder", "lhumerus": "LeftArm", "lradius": "LeftForeArm", "lwrist": "LeftHand",
	"lhand": "LeftFingerBase", "lfingers": "LeftHandFinger1", "lthumb": "LThumb",
	"rclavicle": "RightShoulder", "rhumerus": "RightArm", "rradius": "RightForeArm", "rwrist": "RightHand",
	"rhand": "RightFingerBase", "rfingers": "RightHandFinger1", "rthumb": "RThumb",
}
LOWER_BODY = {"root", "lhipjoint", "lfemur", "ltibia", "lfoot", "ltoes", "rhipjoint", "rfemur", "rtibia", "rfoot", "rtoes"}
ARM_BONES = ("Arm", "ForeArm", "Hand", "Thumb", "FingerBase", "HandFinger1")
LEG_BONES = ("UpLeg", "Leg", "Foot", "ToeBase")


# Ajustes de la boca (objetivos de MakeHuman) para cerrarla.
MOUTH_TARGETS = (
	("mouth-lowerlip-middle-up", 1.0),
	("mouth-upperlip-middle-down", 0.7),
	("mouth-lowerlip-ext-up", 0.6),
	("mouth-upperlip-ext-down", 0.4),
	("mouth-scale-vert-decr", 0.45),
)


# --- MPFB2 ------------------------------------------------------------------

def mpfb():
	"""Activa MPFB2 y devuelve sus servicios (falla con un mensaje claro)."""
	try:
		bpy.ops.preferences.addon_enable(module="bl_ext.user_default.mpfb")
		from bl_ext.user_default.mpfb.services.humanservice import HumanService
		from bl_ext.user_default.mpfb.services.targetservice import TargetService
	except Exception as error:  # noqa: BLE001 - se informa y se sale
		raise SystemExit("MPFB2 no está instalado en BLENDER_USER_RESOURCES (ADR-0016): %s" % error)
	data = os.path.join(bpy.utils.extension_path_user("bl_ext.user_default.mpfb"), "data")
	if not os.path.isdir(os.path.join(data, "proxymeshes")):
		raise SystemExit("Faltan los recursos de MakeHuman en %s (ADR-0016)" % data)
	return HumanService, TargetService, data


def build_body(spec):
	HumanService, TargetService, data = mpfb()
	macro = TargetService.get_default_macro_info_dict()
	macro.update(spec["macro"])
	macro["race"] = {"asian": 0.72, "caucasian": 0.08, "african": 0.2}
	base = HumanService.create_human(macro_detail_dict=macro)
	# Boca cerrada y relajada: la cara neutra de MakeHuman tiene los labios
	# separados, y con los dientes a la vista parece una mueca.
	for target, weight in MOUTH_TARGETS:
		TargetService.load_target(base, TargetService.target_full_path(target), weight=weight)
	rig = HumanService.add_builtin_rig(base, "cmu_mb")
	female = spec["garment"] == "anacu"
	proxy_name = "female1605" if female else "male1591"
	proxy = HumanService.add_mhclo_asset(os.path.join(data, "proxymeshes", proxy_name, proxy_name + ".proxy"),
		base, asset_type="Proxymeshes", subdiv_levels=0)
	HumanService.set_character_skin(os.path.join(data, "skins", spec["skin"], spec["skin"] + ".mhmat"),
		base, bodyproxy=proxy, skin_type="GAMEENGINE")
	# Pestañas: ojos con vida. Sin dientes ni lengua: con la boca cerrada
	# (MOUTH_TARGETS) asomarían a través de los labios.
	parts = [("eyes/low-poly", "low-poly", "Eyes"), ("eyebrows/eyebrow001", "eyebrow001", "Eyebrows"),
		("eyelashes/eyelashes01", "eyelashes01", "Eyelashes"), ("hair/" + spec["hair"], spec["hair"], "Hair")]
	extra = []
	for folder, name, kind in parts:
		extra.append(HumanService.add_mhclo_asset(os.path.join(data, folder, name + ".mhclo"), base,
			asset_type=kind, subdiv_levels=0, material_type="MAKESKIN"))
	bpy.data.objects.remove(base)
	proxy.name = "body"
	return rig, proxy, extra


def _image_nodes(obj):
	nodes = []
	for material in obj.data.materials:
		if material and material.node_tree:
			nodes.extend(n for n in material.node_tree.nodes if n.type == "TEX_IMAGE" and n.image)
	return nodes


def _tint_image(image, target, keep_alpha=True, strength=1.0, name_suffix="_pch"):
	"""Copia reducida de [image] con su color medio llevado a [target]
	(sRGB), conservando el detalle. Determinista."""
	import numpy as np
	width, height = image.size
	pixels = np.empty(width * height * 4, dtype=np.float32)
	image.pixels.foreach_get(pixels)
	pixels = pixels.reshape(height, width, 4)
	mask = pixels[..., 3] > 0.5
	if not mask.any():
		mask = np.ones(pixels.shape[:2], dtype=bool)
	rgb = pixels[..., :3]
	mean = rgb[mask].mean(axis=0)
	gain = np.array(target, dtype=np.float32) / np.maximum(mean, 1e-3)
	tinted = rgb * (1.0 + (gain - 1.0) * strength)
	pixels[..., :3] = np.clip(tinted, 0.0, 1.0)
	copy = bpy.data.images.new(image.name + name_suffix, width, height, alpha=True)
	copy.pixels.foreach_set(pixels.ravel())
	if width > TEXTURE_SIZE:
		copy.scale(TEXTURE_SIZE, TEXTURE_SIZE)
	copy.pack()
	return copy


def _make_opaque(obj):
	"""La piel y los ojos son opacos: sin el alfa enlazado, el exportador los
	marca como OPAQUE y Godot no los ordena como transparentes."""
	for material in obj.data.materials:
		if not material or not material.node_tree:
			continue
		for node in material.node_tree.nodes:
			if node.type == "BSDF_PRINCIPLED":
				alpha = node.inputs["Alpha"]
				for link in list(alpha.links):
					material.node_tree.links.remove(link)
				alpha.default_value = 1.0


def _darken_iris(image):
	"""Ojos castaño oscuro: el iris marrón de MakeHuman es rojizo y a
	distancia parece rojo; el blanco del ojo se aclara un poco."""
	import numpy as np
	width, height = image.size
	pixels = np.empty(width * height * 4, dtype=np.float32)
	image.pixels.foreach_get(pixels)
	pixels = pixels.reshape(height, width, 4)
	rgb = pixels[..., :3]
	high = rgb.max(axis=2)
	low = rgb.min(axis=2)
	saturation = (high - low) / np.maximum(high, 1e-3)
	iris = np.clip((saturation - 0.25) / 0.2, 0.0, 1.0)[..., None]
	luminance = (rgb @ np.array([0.3, 0.55, 0.15], dtype=np.float32))[..., None]
	dark = luminance * np.array([0.42, 0.27, 0.17], dtype=np.float32) * 1.3
	sclera = np.clip(rgb * 1.12 + 0.03, 0.0, 1.0)
	pixels[..., :3] = dark * iris + sclera * (1.0 - iris)
	copy = bpy.data.images.new(image.name + "_pch", width, height, alpha=True)
	copy.pixels.foreach_set(pixels.ravel())
	if width > TEXTURE_SIZE // 2:
		copy.scale(TEXTURE_SIZE // 2, TEXTURE_SIZE // 2)
	copy.pack()
	return copy


def tint_materials(proxy, extras):
	"""Piel morena y pelo negro sobre las texturas de MakeHuman."""
	_make_opaque(proxy)
	for obj in extras:
		if obj.name.endswith("low-poly"):
			_make_opaque(obj)
	tinted = {}
	for node in _image_nodes(proxy):
		if node.image.name not in tinted:
			tinted[node.image.name] = _tint_image(node.image, SKIN_TARGET)
		node.image = tinted[node.image.name]
	for obj in extras:
		for node in _image_nodes(obj):
			image = node.image
			if obj.name.endswith("low-poly"):
				if image.name not in tinted:
					tinted[image.name] = _darken_iris(image)
				node.image = tinted[image.name]
			elif obj.name.endswith(("short02", "braid01", "long01", "ponytail01", "eyebrow001", "eyelashes01")):
				if image.name not in tinted:
					tinted[image.name] = _tint_image(image, HAIR_TARGET, strength=0.92)
				node.image = tinted[image.name]
			elif image.size[0] > TEXTURE_SIZE:
				image.scale(TEXTURE_SIZE, TEXTURE_SIZE)


# --- Ropa -------------------------------------------------------------------

def _linear(name):
	def channel(c):
		return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
	return [channel(c) for c in WOOL[name]] + [1.0]


class BodyInfo:
	"""Vértices del cuerpo con sus pesos, para ajustar la ropa. Por defecto,
	en reposo; con [points] y [normals], en otra postura (la de caída)."""

	def __init__(self, proxy, points=None, normals=None):
		self.points = points if points is not None else [proxy.matrix_world @ v.co for v in proxy.data.vertices]
		names = {g.index: g.name for g in proxy.vertex_groups}
		self.weights = []
		for vertex in proxy.data.vertices:
			self.weights.append({names[g.group]: g.weight for g in vertex.groups if g.weight > 0.001})
		self.tree = kdtree.KDTree(len(self.points))
		for index, point in enumerate(self.points):
			self.tree.insert(point, index)
		self.tree.balance()
		polygons = [tuple(p.vertices) for p in proxy.data.polygons]
		self.bvh = bvhtree.BVHTree.FromPolygons(self.points, polygons)
		self.normals = normals if normals is not None else [v.normal.copy() for v in proxy.data.vertices]
		uv_layer = proxy.data.uv_layers.active
		self.polygons = []
		for polygon in proxy.data.polygons:
			uvs = [tuple(uv_layer.data[li].uv) for li in polygon.loop_indices] if uv_layer else [(0.0, 0.0)] * len(polygon.vertices)
			self.polygons.append((tuple(polygon.vertices), uvs))

	def push_out(self, point, ease):
		"""Si [point] está dentro del cuerpo o a menos de [ease] de su
		superficie, lo saca por la normal hasta esa distancia."""
		location, normal, _index, _distance = self.bvh.find_nearest(point)
		if location is None:
			return point
		gap = (point - location).dot(normal)
		if gap < ease:
			return point + normal * (ease - gap)
		return point

	def part_weight(self, index, suffixes):
		return sum(w for bone, w in self.weights[index].items() if bone.endswith(suffixes) or bone in suffixes)

	def is_trunk(self, index):
		return self.part_weight(index, ARM_BONES) < 0.35 and self.part_weight(index, LEG_BONES) < 0.5

	def nearest_weights(self, point, count=4, exclude=()):
		"""Pesos medios de los vértices más cercanos; sin los huesos que
		terminan en [exclude]."""
		total = {}
		found = self.tree.find_n(point, count)
		for _co, index, distance in found:
			factor = 1.0 / max(distance, 1e-4)
			for bone, weight in self.weights[index].items():
				if exclude and bone.endswith(exclude):
					continue
				total[bone] = total.get(bone, 0.0) + weight * factor
		norm = sum(total.values())
		if norm <= 0.0:
			return {"Spine1": 1.0}
		return {bone: weight / norm for bone, weight in total.items()}


class Garment:
	"""Malla de ropa con color, clase de superficie, coordenadas de tejido y
	pesos por vértice."""

	def __init__(self):
		self.verts = []
		self.weights = []
		self.faces = []
		self.face_colors = []
		self.face_uvs = []
		self.face_pieces = []
		# Prenda a la que pertenecen las caras que se añaden (columna del
		# textil, ver TEXTILE_PIECES); 0 = color liso por vértice.
		self.piece = 0
		# Coordenadas del textil fijadas por vértice (paños cortados por
		# patrón): la anchura del paño y su altura colgado recto, en metros.
		self.pattern = {}

	def add_vertex(self, point, weights):
		self.verts.append(point)
		self.weights.append(weights)
		return len(self.verts) - 1

	def add_face(self, indices, color, uvs):
		self.faces.append(indices)
		self.face_colors.append(color)
		self.face_uvs.append(uvs)
		self.face_pieces.append(self.piece)

	def tube(self, rings, color_fn, weight_fn, closed_top=False):
		"""[rings]: lista de anillos (listas de puntos, mismo número). Une
		anillos consecutivos con caras y asigna UV de tejido por metros."""
		segments = len(rings[0])
		ids = []
		v_acc = 0.0
		vs = [0.0]
		for r in range(1, len(rings)):
			v_acc += (rings[r][0] - rings[r - 1][0]).length
			vs.append(v_acc)
		for ring in rings:
			ids.append([self.add_vertex(p, weight_fn(p)) for p in ring])
		for r in range(len(rings) - 1):
			u_acc = [0.0]
			for s in range(1, segments + 1):
				u_acc.append(u_acc[-1] + (rings[r][s % segments] - rings[r][s - 1]).length)
			for s in range(segments):
				a, b = ids[r][s], ids[r][(s + 1) % segments]
				c, d = ids[r + 1][(s + 1) % segments], ids[r + 1][s]
				uvs = [(u_acc[s], vs[r]), (u_acc[s + 1], vs[r]), (u_acc[s + 1], vs[r + 1]), (u_acc[s], vs[r + 1])]
				self.add_face([a, b, c, d], color_fn(s, r), uvs)
		if closed_top:
			top = ids[-1]
			center = sum((self.verts[i] for i in top), Vector()) / len(top)
			c = self.add_vertex(center, weight_fn(center))
			for s in range(segments):
				self.add_face([top[s], top[(s + 1) % segments], c], color_fn(s, len(rings) - 1),
					[(0.0, 0.0), (0.1, 0.0), (0.05, 0.1)])

	def add_body_surface(self, body, face_filter, offset, color_fn, uv_scale=1.8, border_passes=6):
		"""Copia las caras del cuerpo que cumplen [face_filter], separadas
		[offset] por la normal, con los pesos exactos del cuerpo."""
		mapping = {}
		for verts, uvs in body.polygons:
			if not face_filter(verts):
				continue
			ids = []
			for i in verts:
				if i not in mapping:
					mapping[i] = self.add_vertex(body.points[i] + body.normals[i] * offset, dict(body.weights[i]))
				ids.append(mapping[i])
			# Color por cara: el del primer vértice (franjas por altura).
			self.add_face(ids, color_fn(verts[0]), [(u * uv_scale, v * uv_scale) for u, v in uvs])
		# El borde sale en escalera (caras enteras del cuerpo): se alisa a lo
		# largo del propio borde y se vuelve a sacar del cuerpo.
		created = set(mapping.values())
		edge_count = {}
		for face in self.faces:
			if not created.issuperset(face):
				continue
			for k, a in enumerate(face):
				b = face[(k + 1) % len(face)]
				key = (min(a, b), max(a, b))
				edge_count[key] = edge_count.get(key, 0) + 1
		border = {}
		for (a, b), n in edge_count.items():
			if n == 1:
				border.setdefault(a, []).append(b)
				border.setdefault(b, []).append(a)
		for _ in range(border_passes):
			moved = {}
			for i, others in border.items():
				if len(others) == 2:
					moved[i] = self.verts[i].lerp((self.verts[others[0]] + self.verts[others[1]]) * 0.5, 0.6)
			for i, point in moved.items():
				self.verts[i] = body.push_out(point, offset)
		return mapping

	def box(self, center, size, frame, color, weights):
		"""Caja rígida (sandalias, bolsa, tupu) con pesos fijos."""
		hx, hy, hz = size[0] * 0.5, size[1] * 0.5, size[2] * 0.5
		corners = [Vector((x, y, z)) for z in (-hz, hz) for y in (-hy, hy) for x in (-hx, hx)]
		ids = [self.add_vertex(center + frame @ c, weights) for c in corners]
		quads = [(0, 1, 3, 2), (4, 6, 7, 5), (0, 4, 5, 1), (2, 3, 7, 6), (0, 2, 6, 4), (1, 5, 7, 3)]
		for q in quads:
			self.add_face([ids[i] for i in q], color, [(0, 0), (size[0], 0), (size[0], size[2]), (0, size[2])])

	def to_object(self, name, collection, armature):
		mesh = bpy.data.meshes.new(name)
		mesh.from_pydata([tuple(v) for v in self.verts], [], [tuple(f) for f in self.faces])
		mesh.validate()
		colors = mesh.color_attributes.new("Color", "FLOAT_COLOR", "CORNER")
		surface = mesh.uv_layers.new(name="Surface")
		cloth = mesh.uv_layers.new(name="Cloth")
		for polygon in mesh.polygons:
			color = self.face_colors[polygon.index]
			piece = float(self.face_pieces[polygon.index])
			# Coordenadas del textil en metros: alrededor del cuerpo y altura.
			# Así el dibujo del textil cae a la altura real de cada prenda.
			indices = [mesh.loops[li].vertex_index for li in polygon.loop_indices]
			cut = all(i in self.pattern for i in indices)
			if cut:
				coords = [self.pattern[i] for i in indices]
			else:
				coords = [textile_coords(mesh.vertices[i].co) for i in indices]
			low = min(c[0] for c in coords)
			for corner, loop_index in enumerate(polygon.loop_indices):
				u, v = coords[corner]
				if not cut and u - low > TEXTILE_AROUND * 0.5:
					u -= TEXTILE_AROUND
				colors.data[loop_index].color = color
				surface.data[loop_index].uv = (FABRIC_CLASS, piece)
				cloth.data[loop_index].uv = (u, v)
			polygon.use_smooth = True
		mesh.color_attributes.active_color = colors
		material = bpy.data.materials.get(CLOTH_MATERIAL) or bpy.data.materials.new(CLOTH_MATERIAL)
		mesh.materials.append(material)
		obj = bpy.data.objects.new(name, mesh)
		collection.objects.link(obj)
		groups = {}
		for index, weights in enumerate(self.weights):
			total = sum(weights.values()) or 1.0
			for bone, weight in weights.items():
				if weight / total < 0.002:
					continue
				if bone not in groups:
					groups[bone] = obj.vertex_groups.new(name=bone)
				groups[bone].add([index], weight / total, "REPLACE")
		obj.parent = armature
		modifier = obj.modifiers.new("Armature", "ARMATURE")
		modifier.object = armature
		return obj


# --- Textiles (alcance v4.0) -------------------------------------------------
#
# Cada personaje lleva una textura de tela pintada aquí, con una columna por
# prenda. La ropa guarda en UV1 sus coordenadas en metros (vuelta al cuerpo y
# altura) y en UV0.y la prenda; el shader del juego elige la columna y repite
# el dibujo cada TEXTILE_PERIOD metros. Los diseños son reconstrucciones (R)
# a partir de las piezas de museo de PCH-010, PCH-017 y PCH-018.

TEXTILE_PIECES = {"garment": 1, "belt": 2, "lliclla": 3, "manto": 4, "headwear": 5, "bag": 6}
TEXTILE_COLUMNS = 6
TEXTILE_PERIOD = 0.3
TEXTILE_HEIGHT = 2.0
TEXTILE_AROUND = 1.2
TEXTILE_COLUMN_PX = 128
TEXTILE_HEIGHT_PX = 1024
TEXTILE_CENTER_Y = 0.03


def textile_coords(point):
	"""(u, v) en metros: vuelta alrededor del eje del cuerpo y altura."""
	angle = math.atan2(point.y - TEXTILE_CENTER_Y, point.x) % (2.0 * math.pi)
	return angle / (2.0 * math.pi) * TEXTILE_AROUND, point.z


class TextileCanvas:
	"""Lienzo del textil: columnas de TEXTILE_COLUMN_PX píxeles de ancho
	(un periodo del dibujo) por TEXTILE_HEIGHT_PX de alto (de 0 a
	TEXTILE_HEIGHT metros de altura)."""

	def __init__(self, seed):
		import numpy as np
		self.np = np
		self.width = TEXTILE_COLUMN_PX
		self.pixels = np.zeros((TEXTILE_HEIGHT_PX, TEXTILE_COLUMNS * self.width, 3), dtype=np.float32)
		self.rng = np.random.default_rng(seed)

	def _rows(self, z0, z1):
		a = int(max(0.0, min(z0, z1)) / TEXTILE_HEIGHT * TEXTILE_HEIGHT_PX)
		b = int(min(TEXTILE_HEIGHT, max(z0, z1)) / TEXTILE_HEIGHT * TEXTILE_HEIGHT_PX)
		return a, max(a + 1, b)

	def column(self, piece):
		return self.pixels[:, (piece - 1) * self.width:piece * self.width]

	def fill(self, piece, color):
		self.column(piece)[:] = WOOL[color]

	def band(self, piece, z0, z1, color):
		a, b = self._rows(z0, z1)
		self.column(piece)[a:b] = WOOL[color]

	def stripes(self, piece, z0, z1, colors, count):
		"""Franjas horizontales iguales entre z0 y z1."""
		a, b = self._rows(z0, z1)
		edges = self.np.linspace(a, b, count + 1).astype(int)
		for k in range(count):
			self.column(piece)[edges[k]:edges[k + 1]] = WOOL[colors[k % len(colors)]]

	def zigzag(self, piece, z0, z1, ground, figure, teeth=4):
		"""Zigzag escalonado: [teeth] dientes por periodo."""
		np = self.np
		a, b = self._rows(z0, z1)
		height = b - a
		col = self.column(piece)
		col[a:b] = WOOL[ground]
		x = np.arange(self.width)
		phase = (x * teeth / self.width) % 1.0
		tri = np.abs(phase * 2.0 - 1.0)
		steps = np.floor(tri * 4.0) / 4.0
		for row in range(height):
			level = row / max(height - 1, 1)
			mask = np.abs(steps - level) < 0.18
			col[a + row, mask] = WOOL[figure]

	def diamonds(self, piece, z0, z1, ground, figure, inner, count=3):
		"""Rombos escalonados (rombos de gradas) con un punto central."""
		np = self.np
		a, b = self._rows(z0, z1)
		height = b - a
		col = self.column(piece)
		col[a:b] = WOOL[ground]
		cell = self.width / count
		ys, xs = np.mgrid[0:height, 0:self.width]
		cx = (xs % cell) / cell * 2.0 - 1.0
		cy = ys / max(height - 1, 1) * 2.0 - 1.0
		d = np.floor((np.abs(cx) + np.abs(cy)) * 4.0) / 4.0
		ring = (d >= 0.5) & (d < 0.75)
		center = d < 0.25
		region = col[a:b]
		region[ring] = WOOL[figure]
		region[center] = WOOL[inner]

	def tocapu(self, piece, z0, z1, colors, rows=2):
		"""Fila de t'oqapu: cuadros con motivos geométricos sencillos
		(PCH-017, R). Cada cuadro mide la altura de una fila."""
		np = self.np
		a, b = self._rows(z0, z1)
		col = self.column(piece)
		row_h = (b - a) // rows
		size = row_h
		per_row = max(1, self.width // size)
		size = self.width // per_row
		for r in range(rows):
			for c in range(per_row):
				y0 = a + r * row_h
				x0 = c * size
				ground = colors[(r + c) % len(colors)]
				figure = colors[(r + c + 2) % len(colors)]
				cell = col[y0:y0 + row_h, x0:x0 + size]
				cell[:] = WOOL[ground]
				h, w = cell.shape[:2]
				ys, xs = np.mgrid[0:h, 0:w]
				u = xs / max(w - 1, 1) * 2.0 - 1.0
				v = ys / max(h - 1, 1) * 2.0 - 1.0
				kind = (r * 3 + c) % 4
				if kind == 0:
					mask = (np.abs(u) < 0.25) | (np.abs(v) < 0.25)
				elif kind == 1:
					mask = ((np.floor((u + 1.0) * 2.0) + np.floor((v + 1.0) * 2.0)) % 2) == 0
				elif kind == 2:
					mask = (np.maximum(np.abs(u), np.abs(v)) > 0.45) & (np.maximum(np.abs(u), np.abs(v)) < 0.75)
				else:
					mask = np.abs(u - v) < 0.3
				cell[mask] = WOOL[figure]
				cell[:, :max(1, w // 24)] = WOOL["wool_dark"]
				cell[:max(1, h // 24), :] = WOOL["wool_dark"]

	def weave(self, strength=0.035):
		"""Variación suave de hilo por columnas (urdimbre) y filas (trama),
		como un tejido de cara de urdimbre. La trama fina la pone el mapa de
		tejido del juego; si aquí fuera marcada, la tela parecería un mantel
		de cuadros."""
		np = self.np
		height, width = self.pixels.shape[:2]
		warp = self.rng.normal(0.0, 1.0, width)
		weft = self.rng.normal(0.0, 1.0, height)
		shade = 1.0 + strength * (warp[None, :] * 0.7 + weft[:, None] * 0.3)
		self.pixels *= shade[..., None]
		np.clip(self.pixels, 0.0, 1.0, out=self.pixels)

	def to_image(self, name):
		np = self.np
		height, width = self.pixels.shape[:2]
		rgba = np.ones((height, width, 4), dtype=np.float32)
		rgba[..., :3] = self.pixels
		# Blender guarda las filas de abajo arriba.
		image = bpy.data.images.new(name, width, height, alpha=False)
		image.pixels.foreach_set(rgba.ravel())
		image.pack()
		return image


def paint_textile(spec, dims, seed):
	"""Textil del personaje según su ropa y las alturas reales de las
	prendas ([dims], en metros)."""
	canvas = TextileCanvas(seed)
	garment = TEXTILE_PIECES["garment"]
	body = spec["body"]
	band = spec.get("band", "wool_dark")
	alt = spec.get("band_alt", "wool_cream")
	canvas.fill(garment, body)
	if spec["garment"] == "unku":
		hem = dims["bottom"]
		canvas.band(garment, hem, hem + 0.012, "wool_dark")
		canvas.zigzag(garment, hem + 0.012, hem + 0.06, band, alt if band != alt else "wool_cream")
		canvas.band(garment, hem + 0.06, hem + 0.07, "wool_dark")
		if spec.get("band_style") == "tocapu":
			# Cinturón de t'oqapu a la altura de la cintura (solo autoridades).
			waist = dims["waist"]
			canvas.tocapu(garment, waist - 0.05, waist + 0.03, [band, alt, "wool_red", "wool_ochre", "wool_cream"], rows=2)
		else:
			waist = dims["waist"]
			canvas.stripes(garment, waist - 0.02, waist + 0.005, [band, body, band], 3)
	else:
		hem = dims["bottom"]
		canvas.stripes(garment, hem, hem + 0.05, [band, body, band], 3)
		belt = TEXTILE_PIECES["belt"]
		stripe = spec.get("belt", "wool_red")
		canvas.fill(belt, stripe)
		waist = dims["waist"]
		canvas.band(belt, waist - 0.045, waist - 0.035, "wool_cream")
		canvas.diamonds(belt, waist - 0.035, waist + 0.035, stripe, "wool_cream", "wool_dark", count=4)
		canvas.band(belt, waist + 0.035, waist + 0.045, "wool_cream")
	if spec.get("lliclla"):
		piece = TEXTILE_PIECES["lliclla"]
		main = spec["lliclla"]
		stripe = spec.get("lliclla_stripe", "wool_red")
		canvas.fill(piece, main)
		low = dims["shoulder"] - 0.26
		# Bandas decoradas (pallay) entre franjas lisas.
		canvas.stripes(piece, low, low + 0.03, [stripe, "wool_cream", stripe], 3)
		canvas.diamonds(piece, low + 0.07, low + 0.12, stripe, "wool_cream", "wool_dark", count=3)
		canvas.zigzag(piece, low + 0.17, low + 0.21, main, stripe)
		canvas.stripes(piece, low + 0.25, low + 0.29, [stripe, main, stripe], 3)
	if spec.get("manto"):
		piece = TEXTILE_PIECES["manto"]
		manto = spec["manto"]
		canvas.fill(piece, manto)
		low = dims["knee"]
		canvas.stripes(piece, low, low + 0.08, ["wool_dark", manto, "wool_cream", manto, "wool_dark"], 5)
		canvas.band(piece, dims["shoulder"] - 0.12, dims["shoulder"] - 0.1, "wool_dark")
	headwear = TEXTILE_PIECES["headwear"]
	if spec.get("headband"):
		canvas.fill(headwear, spec["headband"])
		canvas.zigzag(headwear, 0.0, TEXTILE_HEIGHT, spec["headband"], "wool_dark", teeth=10)
	elif spec.get("head_cloth"):
		canvas.stripes(headwear, 1.3, 2.0, [spec["head_cloth"], "wool_cream", spec["head_cloth"], "wool_dark"], 28)
	if spec.get("chuspa"):
		bag = TEXTILE_PIECES["bag"]
		canvas.diamonds(bag, 0.0, TEXTILE_HEIGHT, spec["chuspa"], "wool_cream", "wool_dark", count=2)
	canvas.weave()
	return canvas.to_image("pch_textile")


def set_cloth_texture(image):
	"""El textil va como color base del material de la ropa, para que el
	glTF lo lleve y Godot lo pase al shader."""
	material = bpy.data.materials.get(CLOTH_MATERIAL)
	if material is None:
		return
	material.use_nodes = True
	tree = material.node_tree
	for node in list(tree.nodes):
		tree.nodes.remove(node)
	output = tree.nodes.new("ShaderNodeOutputMaterial")
	bsdf = tree.nodes.new("ShaderNodeBsdfPrincipled")
	texture = tree.nodes.new("ShaderNodeTexImage")
	texture.image = image
	tree.links.new(texture.outputs["Color"], bsdf.inputs["Base Color"])
	tree.links.new(bsdf.outputs["BSDF"], output.inputs["Surface"])
	bsdf.inputs["Roughness"].default_value = 0.9


def _ring_points(center, radii, z, segments, offset, noise=None):
	points = []
	for s in range(segments):
		angle = 2.0 * math.pi * (s + 0.5) / segments
		r = radii[s] + offset + (noise(angle) if noise else 0.0)
		points.append(Vector((center.x + math.cos(angle) * r, center.y + math.sin(angle) * r, z)))
	return points


def _skirt_weights(body, point, hip_z, follow):
	"""Pesos de falda: la cadera, más el muslo de su lado hacia el bajo."""
	base = body.nearest_weights(Vector((point.x * 0.6, point.y, max(point.z, hip_z))))
	f = follow * min(1.0, max(0.0, (hip_z - point.z) / 0.45))
	if f <= 0.0:
		return base
	side = max(-1.0, min(1.0, point.x / 0.07))
	weights = {bone: w * (1.0 - f) for bone, w in base.items()}
	weights["LeftUpLeg"] = weights.get("LeftUpLeg", 0.0) + f * (0.5 + 0.5 * side)
	weights["RightUpLeg"] = weights.get("RightUpLeg", 0.0) + f * (0.5 - 0.5 * side)
	return weights


def _sandal_width(t):
	"""Media anchura de la suela a lo largo del pie (0 = talón, 1 = punta)."""
	points = ((0.0, 0.030), (0.3, 0.034), (0.7, 0.046), (0.9, 0.041), (1.0, 0.030))
	for (t0, w0), (t1, w1) in zip(points, points[1:]):
		if t <= t1:
			k = (t - t0) / (t1 - t0)
			return w0 + (w1 - w0) * k
	return points[-1][1]


def build_sandal(g, body, heel, forward, lateral, length, weights, thickness=0.014, segments=24):
	g.piece = 0
	sole = _linear("sole")
	strap = _linear("rope")
	outline = []
	for k in range(segments):
		angle = 2.0 * math.pi * k / segments
		t = 0.5 - 0.5 * math.cos(angle)
		u = math.sin(angle) * _sandal_width(t)
		outline.append(heel + forward * (t * length) + lateral * u)
	bottom = [g.add_vertex(p + Vector((0.0, 0.0, 0.001)), weights) for p in outline]
	top = [g.add_vertex(p + Vector((0.0, 0.0, thickness)), weights) for p in outline]
	# La ropa se dibuja por las dos caras (shader de tela), así que la
	# orientación de cada cara no importa.
	g.add_face(list(reversed(bottom)), sole, [(0.0, 0.0)] * segments)
	g.add_face(top, sole, [(0.0, 0.0)] * segments)
	for k in range(segments):
		a, b = k, (k + 1) % segments
		g.add_face([bottom[a], bottom[b], top[b], top[a]], sole, [(0, 0), (0.01, 0), (0.01, 0.01), (0, 0.01)])

	def strap_path(points, width=0.009):
		"""Tira fina apoyada en el pie a lo largo de [points]."""
		placed = [body.push_out(p, 0.004) for p in points]
		ids = []
		for k, point in enumerate(placed):
			ahead = placed[min(k + 1, len(placed) - 1)] - placed[max(k - 1, 0)]
			_location, normal, _index, _distance = body.bvh.find_nearest(point)
			normal = normal if normal is not None else Vector((0.0, 0.0, 1.0))
			across = ahead.cross(normal).normalized() * (width * 0.5)
			ids.append((g.add_vertex(point - across, weights), g.add_vertex(point + across, weights)))
		for k in range(len(ids) - 1):
			quad = [ids[k][0], ids[k + 1][0], ids[k + 1][1], ids[k][1]]
			g.add_face(quad, strap, [(0, 0), (0.01, 0), (0.01, 0.01), (0, 0.01)])

	def on_foot(t, u, z):
		return heel + forward * (t * length) + lateral * (u * _sandal_width(t)) + Vector((0.0, 0.0, z))

	post = on_foot(0.84, 0.0, thickness + 0.004)
	for edge in (1.0, -1.0):
		strap_path([post] + [on_foot(0.84 - 0.32 * k / 5.0, edge * k / 5.0, thickness + 0.03 * math.sin(math.pi * k / 10.0) + 0.01)
			for k in range(1, 6)])
	# Tira del talón: de un lado de la suela, por detrás del tobillo, al otro.
	around_heel = [heel + lateral * (math.cos(math.pi * k / 8.0) * _sandal_width(0.15))
		- forward * (math.sin(math.pi * k / 8.0) * 0.012) + Vector((0.0, 0.0, 0.055)) for k in range(9)]
	strap_path([on_foot(0.32, 1.0, thickness + 0.02)] + around_heel + [on_foot(0.32, -1.0, thickness + 0.02)])


def build_clothes(spec, body, armature, rig_bones):
	"""Tocados y ojotas de [spec] sobre el cuerpo en reposo (MakeHuman mira a
	−Y, así que la espalda es +Y), y las medidas del cuerpo que usan las
	prendas cosidas (build_sewn_clothes) y el textil."""
	collection = bpy.context.scene.collection
	g = Garment()
	female = spec["garment"] == "anacu"
	hip_z = rig_bones["LeftUpLeg"].head_local.z
	waist_z = rig_bones["Spine"].head_local.z
	shoulder_z = rig_bones["LeftArm"].head_local.z
	knee_z = rig_bones["LeftLeg"].head_local.z
	ankle_z = rig_bones["LeftFoot"].head_local.z
	# Bajo de la prenda: el unku, por encima de la rodilla; el anacu, al tobillo.
	bottom_z = knee_z + 0.05 if not female else ankle_z + 0.035

	g.piece = TEXTILE_PIECES["headwear"]
	# 1. Tocados sobre la cabeza: cinta (llautu) o paño que sigue el cráneo.
	head = rig_bones["Head"]
	forehead_z = head.head_local.z + (head.tail_local.z - head.head_local.z) * 0.55
	if spec.get("headband") and not spec.get("head"):
		def band_face(verts):
			return all(abs(body.points[i].z - (forehead_z + 0.01)) < 0.022 and body.part_weight(i, ("Head",)) > 0.8 for i in verts)
		g.add_body_surface(body, band_face, 0.02, lambda i: _linear(spec["headband"]))
	if spec.get("head_cloth") and not spec.get("head"):
		def cloth_face(verts):
			return all(body.points[i].z > forehead_z - 0.01 and body.part_weight(i, ("Head",)) > 0.8 for i in verts)
		g.add_body_surface(body, cloth_face, 0.024, lambda i: _linear(spec["head_cloth"]))

	# 2. Ojotas: suela con la silueta del pie (talón redondo, más ancha en el
	# metatarso) y tiras finas: una en V desde entre los dedos y otra que
	# rodea el talón.
	for side in ("Left", "Right"):
		foot = rig_bones[side + "Foot"]
		toe = rig_bones[side + "ToeBase"]
		heel = Vector((foot.head_local.x, foot.head_local.y + 0.055, 0.0))
		tip = Vector((toe.tail_local.x, toe.tail_local.y - 0.022, 0.0))
		along = tip - heel
		length = along.length
		forward = along.normalized()
		lateral = forward.cross(Vector((0.0, 0.0, 1.0))).normalized()
		weights = {side + "Foot": 1.0}
		build_sandal(g, body, heel, forward, lateral, length, weights)

	# Espalda (MakeHuman mira a −Y): el punto más atrasado del tronco entre la
	# cintura y los hombros, para colocar los huesos del manto detrás.
	back_y = max(body.points[i].y for i in range(len(body.points))
		if waist_z - 0.05 < body.points[i].z < shoulder_z and body.is_trunk(i))
	dims = {"bottom": bottom_z, "waist": waist_z, "shoulder": shoulder_z, "knee": knee_z, "hip": hip_z,
		"back": back_y + 0.06}
	return g.to_object("clothes", collection, armature), dims


# --- Huesos de muelle del manto (alcance v4.0) ------------------------------
#
# Tres cadenas de dos huesos detrás de la espalda (izquierda, centro y
# derecha), del hombro a la rodilla. En el juego, SpringBoneSimulator3D las
# mece con la inercia del cuerpo (NpcActor).

CAPE_CHAINS = ("L", "C", "R")
CAPE_SPREAD = 0.13


def add_cape_bones(armature, dims, back_y):
	data = armature.data
	bpy.context.view_layer.objects.active = armature
	bpy.ops.object.mode_set(mode="EDIT")
	parent = data.edit_bones["Spine1"]
	for chain in CAPE_CHAINS:
		x = {"L": CAPE_SPREAD, "C": 0.0, "R": -CAPE_SPREAD}[chain]
		top = Vector((x, back_y, dims["shoulder"] - 0.06))
		middle = Vector((x, back_y + 0.02, dims["waist"]))
		bottom = Vector((x, back_y + 0.04, dims["knee"] + 0.06))
		first = data.edit_bones.new("Cape_%s_1" % chain)
		first.head, first.tail = top, middle
		first.parent = parent
		second = data.edit_bones.new("Cape_%s_2" % chain)
		second.head, second.tail = middle, bottom
		second.parent = first
		second.use_connect = True
	bpy.ops.object.mode_set(mode="OBJECT")
	for chain in CAPE_CHAINS:
		for index in (1, 2):
			armature.pose.bones["Cape_%s_%d" % (chain, index)].rotation_mode = "QUATERNION"


def _smooth(edge0, edge1, x):
	t = max(0.0, min(1.0, (x - edge0) / (edge1 - edge0)))
	return t * t * (3.0 - 2.0 * t)


# --- Ropa cortada y cosida (ADR-0020) ---------------------------------------
#
# Las prendas grandes se construyen como en el telar: paños que se doblan y se
# cosen sobre el cuerpo (unku, anacu) o se echan sobre los hombros y se
# prenden al pecho (lliclla, manto). Cada paño cae por su peso con la
# simulación de tela de Blender en tres tramos: quieto con los brazos en A,
# mientras los brazos bajan a la postura de reposo y quieto otra vez. La forma
# final, con los brazos abajo, toma los pesos del cuerpo en esa postura y se
# devuelve a la pose de reposo del esqueleto invirtiendo el skinning: en el
# juego, con los brazos bajados, la tela queda como cayó.

SEW_CELL = 0.025
SHAWL_CELL = 0.03
ARM_DROP = 36.0
SETTLE_FRAMES = 12
LOWER_FRAMES = 30
REST_FRAMES = 30
SIM_FRAMES = SETTLE_FRAMES + LOWER_FRAMES + REST_FRAMES
WOOL_BENDING = 0.6
# Masa por vértice de los paños echados sobre los hombros: con más, la tela
# estira con su peso, el borde del cuello cede y el paño resbala.
SHAWL_MASS = 0.15


FOREARM_STRAIGHTEN = 0.8


def keyframe_arm_drop(armature, straighten=False):
	"""Los brazos bajan ARM_DROP grados desde la A, girando sobre el eje
	delante-atrás que pasa por el hombro. Con [straighten], el antebrazo se
	estira casi del todo: colgando rectos, las manos no atraviesan el manto
	(para el unku y el anacu no, porque las manos barrerían el bajo)."""
	armature.animation_data_create()
	for side, sign in (("Left", 1.0), ("Right", -1.0)):
		arm = armature.data.bones[side + "Arm"]
		fore = armature.data.bones[side + "ForeArm"]
		turn = Matrix.Rotation(math.radians(ARM_DROP) * sign, 3, "Y")
		arm_rest = arm.matrix_local.to_3x3()
		fore_rest = fore.matrix_local.to_3x3()
		straight = _rotation_between(fore.tail_local - fore.head_local, arm.tail_local - arm.head_local)
		straight = Quaternion().slerp(straight.to_quaternion(), FOREARM_STRAIGHTEN).to_matrix()
		targets = {
			side + "Arm": (arm_rest.inverted() @ turn @ arm_rest).to_quaternion(),
			side + "ForeArm": (fore_rest.inverted() @ straight @ fore_rest).to_quaternion() if straighten else Quaternion(),
		}
		for name, target in targets.items():
			pose_bone = armature.pose.bones[name]
			pose_bone.rotation_mode = "QUATERNION"
			for frame, quat in ((1, Quaternion()), (SETTLE_FRAMES, Quaternion()), (SETTLE_FRAMES + LOWER_FRAMES, target)):
				pose_bone.rotation_quaternion = quat
				pose_bone.keyframe_insert("rotation_quaternion", frame=frame)


def clear_arm_drop(armature):
	armature.animation_data_clear()
	for pose_bone in armature.pose.bones:
		pose_bone.rotation_quaternion = Quaternion()
	bpy.context.scene.frame_set(1)


def posed_body(proxy):
	"""Cuerpo en la postura del fotograma actual (el de caída)."""
	depsgraph = bpy.context.evaluated_depsgraph_get()
	evaluated = proxy.evaluated_get(depsgraph)
	mesh = evaluated.to_mesh()
	points = [proxy.matrix_world @ v.co for v in mesh.vertices]
	normals = [v.normal.copy() for v in mesh.vertices]
	evaluated.to_mesh_clear()
	return BodyInfo(proxy, points, normals)


def skin_matrices(armature):
	return {pb.name: pb.matrix @ pb.bone.matrix_local.inverted() for pb in armature.pose.bones}


def unpose(point, weights, matrices):
	"""Inversa del skinning lineal: la posición en reposo que, con [weights],
	el esqueleto lleva a [point]."""
	total = sum(weights.values()) or 1.0
	blend = Matrix.Diagonal((0.0, 0.0, 0.0, 0.0))
	for bone, weight in weights.items():
		blend = blend + matrices[bone] * (weight / total)
	return blend.inverted_safe() @ point


def _smooth_weights(mesh, weights, passes=4, amount=0.5):
	"""Suaviza los pesos sobre la malla para que la tela no se rasgue entre
	vértices vecinos que siguen a huesos distintos."""
	neighbours = [set() for _ in mesh.vertices]
	for edge in mesh.edges:
		a, b = edge.vertices
		neighbours[a].add(b)
		neighbours[b].add(a)
	for _ in range(passes):
		result = []
		for index, own in enumerate(weights):
			others = neighbours[index]
			if not others:
				result.append(own)
				continue
			mixed = {bone: w * (1.0 - amount) for bone, w in own.items()}
			for other in others:
				for bone, w in weights[other].items():
					mixed[bone] = mixed.get(bone, 0.0) + w * amount / len(others)
			result.append(mixed)
		weights = result
	return weights


def _delete_loose(obj):
	bm = bmesh.new()
	bm.from_mesh(obj.data)
	bmesh.ops.delete(bm, geom=[v for v in bm.verts if not v.link_faces], context="VERTS")
	bm.to_mesh(obj.data)
	bm.free()


def _vertex_group(obj, name, values):
	group = obj.vertex_groups.new(name=name)
	for index, value in enumerate(values):
		if value > 0.0:
			group.add([index], min(1.0, value), "REPLACE")
	return group


def simulate_piece(obj, colliders, pin=None, shrink=None, shrink_amount=0.0, mass=0.4, bending=WOOL_BENDING,
		self_collision=True, start=1, end=SIM_FRAMES, air=3.0, friction=20.0):
	"""Caída de [obj] entre los fotogramas [start] y [end] de la bajada de
	brazos (keyframe_arm_drop), con [colliders] deformados por el esqueleto.
	[mass]: masa por vértice, que en Blender fija cuánto estira la tela con
	su peso frente a la rigidez. [pin] y [shrink]: valores por vértice
	(sujeción al sitio; encogido de la tela, como una faja)."""
	scene = bpy.context.scene
	scene.frame_set(start)
	added = []
	for collider in colliders:
		modifier = collider.modifiers.new("pch_collision", "COLLISION")
		# Un centímetro de holgura: la tela no cae pegada a la piel.
		collider.collision.thickness_outer = 0.01
		collider.collision.cloth_friction = 10.0
		added.append((collider, modifier))
	cloth = obj.modifiers.new("pch_cloth", "CLOTH")
	settings = cloth.settings
	settings.quality = 10
	settings.mass = mass
	settings.tension_stiffness = 40.0
	settings.compression_stiffness = 60.0
	settings.shear_stiffness = 15.0
	settings.bending_stiffness = bending
	settings.air_damping = air
	if pin is not None:
		settings.vertex_group_mass = _vertex_group(obj, "pch_pin", pin).name
		settings.pin_stiffness = 1.0
	if shrink is not None:
		settings.vertex_group_shrink = _vertex_group(obj, "pch_shrink", shrink).name
		settings.shrink_min = 0.0
		settings.shrink_max = shrink_amount
	collision = cloth.collision_settings
	collision.friction = friction
	collision.distance_min = 0.006
	collision.collision_quality = 4
	collision.use_self_collision = self_collision
	collision.self_distance_min = 0.004
	cloth.point_cache.frame_start = start
	cloth.point_cache.frame_end = end
	for frame in range(start, end + 1):
		scene.frame_set(frame)
	bpy.context.view_layer.objects.active = obj
	bpy.ops.object.modifier_apply(modifier=cloth.name)
	for collider, modifier in added:
		collider.modifiers.remove(modifier)
	for name in ("pch_pin", "pch_shrink"):
		group = obj.vertex_groups.get(name)
		if group is not None:
			obj.vertex_groups.remove(group)


def bind_piece(obj, armature, proxy, weight_rule, smooth_passes=4):
	"""Tras caer (último fotograma, brazos abajo): pesos del cuerpo en esa
	postura según [weight_rule](punto, cuerpo), y vuelta a la pose de reposo."""
	body = posed_body(proxy)
	matrices = skin_matrices(armature)
	mesh = obj.data
	weights = [weight_rule(obj.matrix_world @ v.co, body) for v in mesh.vertices]
	weights = _smooth_weights(mesh, weights, passes=smooth_passes)
	for vertex, w in zip(mesh.vertices, weights):
		vertex.co = unpose(vertex.co.copy(), w, matrices)
	for group in list(obj.vertex_groups):
		obj.vertex_groups.remove(group)
	groups = {}
	for index, w in enumerate(weights):
		total = sum(w.values()) or 1.0
		for bone, value in w.items():
			if value / total < 0.002:
				continue
			if bone not in groups:
				groups[bone] = obj.vertex_groups.new(name=bone)
			groups[bone].add([index], value / total, "REPLACE")
	for modifier in [m for m in obj.modifiers if m.type == "ARMATURE"]:
		obj.modifiers.remove(modifier)
	modifier = obj.modifiers.new("Armature", "ARMATURE")
	modifier.object = armature


def _without(weights, suffixes, keep=0.0):
	"""[weights] con los huesos que terminan en [suffixes] reducidos a [keep]."""
	result = {}
	for bone, w in weights.items():
		result[bone] = w * keep if bone.endswith(suffixes) else w
	if sum(result.values()) <= 0.0:
		return weights
	return result


def hide_covered_skin(proxy, garment, dims, female):
	"""Quita la piel que el unku o el anacu tapan siempre (tronco y muslos),
	como se hace en los juegos: al andar no asoma a través de la tela y hay
	menos triángulos. Una cara se quita si está en esa zona y un rayo desde
	ella hacia fuera choca con la prenda."""
	depsgraph = bpy.context.evaluated_depsgraph_get()
	tree = bvhtree.BVHTree.FromObject(garment, depsgraph)
	low = dims["bottom"] + 0.03
	high = dims["seam"] - 0.04
	groups = {g.index: g.name for g in proxy.vertex_groups}

	def limb(vertex):
		weight = sum(g.weight for g in vertex.groups if groups.get(g.group, "").endswith(ARM_BONES + ("Neck", "Neck1", "Head")))
		return weight > 0.2

	mesh = proxy.data
	bm = bmesh.new()
	bm.from_mesh(mesh)
	bm.verts.ensure_lookup_table()
	bm.normal_update()
	dead = []
	for face in bm.faces:
		center = face.calc_center_median()
		if not low < center.z < high or any(limb(mesh.vertices[v.index]) for v in face.verts):
			continue
		hit, _normal, _index, distance = tree.ray_cast(center + face.normal * 0.002, face.normal, 0.25)
		if hit is not None:
			dead.append(face)
	bmesh.ops.delete(bm, geom=dead, context="FACES_ONLY")
	bm.to_mesh(mesh)
	bm.free()


def tube_garment(spec, body, bones, dims, cell=SEW_CELL):
	"""Unku o anacu: un paño doblado sobre los hombros, con abertura para la
	cabeza, y cosido a los lados (el anacu, más ancho y hasta el tobillo).
	Devuelve la prenda; deja en [dims] el centro del tronco y la costura."""
	female = spec["garment"] == "anacu"
	shoulder_z = bones["LeftArm"].head_local.z
	arm_x = bones["LeftArm"].head_local.x
	neck = bones["Neck"].head_local
	trunk = body.is_trunk
	chest = [p for i, p in enumerate(body.points) if abs(p.z - (shoulder_z - 0.12)) < 0.03 and trunk(i)]
	hips = [p for i, p in enumerate(body.points) if abs(p.z - dims["hip"]) < 0.04 and trunk(i)]
	if female:
		half_w = max(abs(p.x) for p in hips) + 0.07
	else:
		half_w = max(max(abs(p.x) for p in chest) + 0.05, arm_x + 0.035)
	ys = [p.y for i, p in enumerate(body.points) if dims["hip"] - 0.05 < p.z < shoulder_z and trunk(i)]
	front_y, back_y = min(ys) - 0.03, max(ys) + 0.03
	cy = (front_y + back_y) * 0.5
	b = (back_y - front_y) * 0.5
	high = [p for i, p in enumerate(body.points) if body.part_weight(i, ("Neck", "Neck1", "Head")) < 0.3
		and front_y < p.y < back_y and p.z > shoulder_z - 0.15]

	def shoulder_top(x):
		zs = [p.z for p in high if abs(abs(p.x) - abs(x)) < 0.025]
		return (max(zs) if zs else shoulder_z) + 0.025

	top_z = shoulder_top(0.0)
	hem_z = dims["bottom"]
	if female:
		# El anacu se cose bajo los brazos y su borde alto, doblado, se prende
		# sobre los dos hombros: cubre el pecho hasta el cuello.
		seam_top = shoulder_z - 0.11
	else:
		arm_dir = (bones["LeftArm"].tail_local - bones["LeftArm"].head_local).normalized()
		reach = (half_w - arm_x) / max(arm_dir.x, 1e-3)
		seam_top = bones["LeftArm"].head_local.z + arm_dir.z * max(reach, 0.0) - 0.075
	flare_amount = 0.25 if female else 0.15
	cols = max(8, int(round(2.0 * half_w / cell)))
	front_rows = max(8, int(round((top_z - hem_z) / cell)))
	bridge_rows = max(4, int(round(2.0 * b / cell)))

	def depth(phi, z):
		# Bajo la costura, sección cerrada; por encima, el borde de la sisa se
		# separa para que el paso sobre el hombro tenga anchura.
		opening = _smooth(seam_top - 0.02, seam_top + 0.08, z)
		return max(math.sin(phi), 0.55 * opening)

	tops = [shoulder_top(-half_w * math.cos(math.pi * c / cols)) for c in range(cols + 1)]
	tops = [sum(tops[max(0, c - 1):c + 2]) / len(tops[max(0, c - 1):c + 2]) for c in range(cols + 1)]
	rows = [("front", hem_z + (top_z - hem_z) * r / front_rows) for r in range(front_rows + 1)]
	rows += [("over", r / bridge_rows) for r in range(1, bridge_rows)]
	rows += [("back", hem_z + (top_z - hem_z) * r / front_rows) for r in range(front_rows, -1, -1)]
	g = Garment()
	g.piece = TEXTILE_PIECES["garment"]
	grid = {}
	for ri, (kind, value) in enumerate(rows):
		for c in range(cols + 1):
			phi = math.pi * c / cols
			x = -half_w * math.cos(phi)
			col_top = tops[c]
			if kind == "over":
				d = depth(phi, col_top)
				y = cy - b * d + 2.0 * b * d * value
				z = col_top + 0.01 * math.sin(math.pi * value)
				height = col_top
			else:
				z = hem_z + (value - hem_z) / (top_z - hem_z) * (col_top - hem_z)
				height = value
				# Vuelo hacia el bajo, con una ondulación que siembra pliegues.
				flare = flare_amount * max(0.0, 1.0 - (z - hem_z) / max(seam_top - hem_z, 0.1))
				wave = 1.0 + flare * (1.0 + 0.5 * math.sin(phi * 7.0 + (0.0 if kind == "front" else 1.7)))
				x *= 1.0 + flare * 0.6
				y = cy + (-1.0 if kind == "front" else 1.0) * b * depth(phi, z) * wave
			index = g.add_vertex(Vector((x, y, z)), {})
			g.pattern[index] = (half_w * (1.0 - math.cos(phi)), height)
			grid[(ri, c)] = index
	count = len(rows)
	merge = {}
	for r in range(front_rows + 1):
		for c in (0, cols):
			if g.verts[grid[(r, c)]].z <= seam_top:
				merge[grid[(count - 1 - r, c)]] = grid[(r, c)]
	color = _linear(spec["body"])
	for ri in range(count - 1):
		for c in range(cols):
			quad = [grid[(ri, c)], grid[(ri, c + 1)], grid[(ri + 1, c + 1)], grid[(ri + 1, c)]]
			center = sum((g.verts[i] for i in quad), Vector()) * 0.25
			over = rows[ri][0] == "over" or rows[ri + 1][0] == "over"
			# Abertura para la cabeza, algo más ancha en el anacu.
			neck_x, neck_y = (0.115, 0.09) if female else (0.105, 0.08)
			if over and center.z > top_z - 0.03 and (center.x / neck_x) ** 2 + ((center.y - (neck.y + 0.005)) / neck_y) ** 2 < 1.0:
				continue
			g.add_face([merge.get(i, i) for i in quad], color, [(0.0, 0.0)] * 4)
	dims.update({"cy": cy, "seam": seam_top})
	return g


def shawl(spec, body, surface, bones, dims, kind, cell=SHAWL_CELL):
	"""Lliclla o manto: un paño echado sobre los hombros que rodea el cuello
	por detrás y se prende (o se anuda) al pecho. Se construye ya con los
	brazos abajo ([body] y [surface] en la postura de caída), colgando casi
	recto. Devuelve la prenda, la sujeción por vértice y el prendedor."""
	manto = kind == "manto"
	shoulder_z = bones["LeftArm"].head_local.z
	neck = bones["Neck"].head_local
	length = (shoulder_z - dims["knee"] - 0.02) if manto else 0.46
	ys = [p.y for i, p in enumerate(body.points) if abs(p.z - (shoulder_z - 0.1)) < 0.04 and body.is_trunk(i)]
	# El prendedor (o el nudo) va alto, bajo las clavículas: más abajo, el paño
	# gira sobre él y el borde resbala espalda abajo.
	pin_point = surface.push_out(Vector((0.0, min(ys) - 0.02, shoulder_z + (0.0 if manto else -0.02))), 0.02)
	# Borde alto: una curva suave que sale de una esquina junto al prendedor,
	# sube por el pecho, pasa por los hombros, rodea el cuello por detrás y
	# baja a la otra esquina.
	shoulders = [p for i, p in enumerate(body.points) if p.z > shoulder_z - 0.2
		and body.part_weight(i, ("Neck", "Neck1", "Head")) < 0.3]

	def top_at(x, y):
		near = [p.z for p in shoulders if (p.x - x) ** 2 + (p.y - y) ** 2 < 0.03 ** 2]
		return surface.push_out(Vector((x, y, (max(near) if near else shoulder_z) + 0.02)), 0.02)

	corner = pin_point + Vector((0.04, 0.0, 0.0))
	chest_y = (corner.y + neck.y) * 0.5
	controls = [corner, top_at(0.09, chest_y), top_at(0.13, neck.y + 0.01), top_at(0.08, neck.y + 0.08), top_at(0.0, neck.y + 0.1)]
	controls = controls + [Vector((-p.x, p.y, p.z)) for p in reversed(controls[:-1])]
	dense = []
	for k in range(len(controls) - 1):
		p0 = controls[max(k - 1, 0)]
		p1, p2 = controls[k], controls[k + 1]
		p3 = controls[min(k + 2, len(controls) - 1)]
		for t in [i / 20.0 for i in range(20)]:
			t2, t3 = t * t, t * t * t
			dense.append(0.5 * (2.0 * p1 + (p2 - p0) * t + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 + (3.0 * p1 - p0 - 3.0 * p2 + p3) * t3))
	dense.append(controls[-1])
	along = [0.0]
	for k in range(1, len(dense)):
		along.append(along[-1] + (dense[k] - dense[k - 1]).length)
	cols = max(8, int(round(along[-1] / cell)))
	rows = max(4, int(round(length / cell)))
	path = []
	for c in range(cols + 1):
		target = along[-1] * c / cols
		k = next(i for i in range(1, len(along)) if along[i] >= target - 1e-9) if c > 0 else 1
		t = (target - along[k - 1]) / max(along[k] - along[k - 1], 1e-9)
		path.append(dense[k - 1].lerp(dense[k], min(1.0, max(0.0, t))))
	g = Garment()
	g.piece = TEXTILE_PIECES[kind]
	low = dims["knee"] if manto else shoulder_z - 0.26
	color = _linear(spec[kind])
	ids = []
	pin = []
	center = Vector((0.0, neck.y + 0.01, 0.0))
	for c in range(cols + 1):
		edge = path[c]
		outward = Vector((edge.x - center.x, edge.y - center.y, 0.0))
		outward = outward.normalized() if outward.length > 1e-6 else Vector((0.0, -1.0, 0.0))
		# Sobre los brazos el paño se abre un poco (el manto, ancho, algo más);
		# delante y detrás, recto.
		tilt = math.radians(5.0 + (17.0 if manto else 7.0) * abs(outward.x) ** 2)
		direction = (outward * math.sin(tilt) + Vector((0.0, 0.0, -1.0)) * math.cos(tilt)).normalized()
		column = []
		for r in range(rows + 1):
			index = g.add_vertex(edge + direction * (length * r / rows), {})
			g.pattern[index] = (along[-1] * c / cols, low + length * (1.0 - r / rows))
			column.append(index)
			# Prendido: los extremos del borde alto, junto al prendedor.
			pin.append(1.0 if r == 0 and min(c, cols - c) <= 1 else 0.0)
		ids.append(column)
	# Fuera del cuerpo y de la ropa de debajo, y alisado para que las columnas
	# vecinas no se crucen.
	for _ in range(4):
		for c in range(cols + 1):
			for r in range(1, rows + 1):
				i = ids[c][r]
				g.verts[i] = surface.push_out(g.verts[i], 0.02)
		smoothed = {}
		for c in range(1, cols):
			for r in range(1, rows + 1):
				around = [ids[c - 1][r], ids[c + 1][r], ids[c][r - 1], ids[c][min(r + 1, rows)]]
				smoothed[ids[c][r]] = g.verts[ids[c][r]].lerp(sum((g.verts[j] for j in around), Vector()) * 0.25, 0.5)
		for i, point in smoothed.items():
			g.verts[i] = point
	for c in range(cols + 1):
		for r in range(1, rows + 1):
			g.verts[ids[c][r]] = surface.push_out(g.verts[ids[c][r]], 0.02)
	for c in range(cols):
		for r in range(rows):
			g.add_face([ids[c][r], ids[c + 1][r], ids[c + 1][r + 1], ids[c][r + 1]], color, [(0.0, 0.0)] * 4)
	return g, pin, pin_point


def soft_bag(center, size, piece, color, segments=(6, 3, 6), sag=0.25, seed=0):
	"""Bolsa o bulto de tela llena: caja de lados abombados, con la base
	caída y arrugas en las esquinas donde la tela se junta."""
	g = Garment()
	g.piece = piece
	hx, hy, hz = size[0] * 0.5, size[1] * 0.5, size[2] * 0.5
	nx, ny, nz = segments
	ids = {}

	def point(i, j, k):
		u, v, w = 2.0 * i / nx - 1.0, 2.0 * j / ny - 1.0, 2.0 * k / nz - 1.0
		# Superelipsoide: caras planas que se redondean hacia las aristas.
		p = Vector((u, v, w))
		n = max(abs(u), abs(v), abs(w))
		p = p / max(p.length, 1e-6) * n
		q = Vector((math.copysign(abs(p.x) ** 0.6, p.x), math.copysign(abs(p.y) ** 0.6, p.y), math.copysign(abs(p.z) ** 0.6, p.z)))
		wrinkle = 0.06 * math.sin(7.0 * u + seed) * math.sin(5.0 * w + 1.3 * seed) * (abs(u) * abs(w))
		bulge = 1.0 + wrinkle
		bottom = (1.0 - w) * 0.5
		return center + Vector((q.x * hx * bulge * (1.0 + sag * bottom * 0.3), q.y * hy * bulge, q.z * hz - sag * hz * bottom * (1.0 - abs(u)) * 0.3))

	def vid(i, j, k):
		key = (i, j, k)
		if key not in ids:
			p = point(i, j, k)
			ids[key] = g.add_vertex(p, {})
			# Textil alrededor del eje vertical de la bolsa, como en la ropa.
			angle = math.atan2(p.y - center.y, p.x - center.x) % (2.0 * math.pi)
			g.pattern[ids[key]] = (angle / (2.0 * math.pi) * 2.0 * (size[0] + size[1]), p.z)
		return ids[key]

	faces = []
	for i in range(nx):
		for k in range(nz):
			faces.append([vid(i, 0, k), vid(i + 1, 0, k), vid(i + 1, 0, k + 1), vid(i, 0, k + 1)])
			faces.append([vid(i, ny, k), vid(i, ny, k + 1), vid(i + 1, ny, k + 1), vid(i + 1, ny, k)])
	for j in range(ny):
		for k in range(nz):
			faces.append([vid(0, j, k), vid(0, j, k + 1), vid(0, j + 1, k + 1), vid(0, j + 1, k)])
			faces.append([vid(nx, j, k), vid(nx, j + 1, k), vid(nx, j + 1, k + 1), vid(nx, j, k + 1)])
	for i in range(nx):
		for j in range(ny):
			faces.append([vid(i, j, 0), vid(i, j + 1, 0), vid(i + 1, j + 1, 0), vid(i + 1, j, 0)])
			faces.append([vid(i, j, nz), vid(i + 1, j, nz), vid(i + 1, j + 1, nz), vid(i, j + 1, nz)])
	for face in faces:
		g.add_face(face, color, [(0.0, 0.0)] * 4)
	return g


class ClothedSurface:
	"""Superficie del cuerpo y de la ropa ya hecha, para tender encima
	correas y cuerdas."""

	def __init__(self, objects):
		points, polygons = [], []
		for obj in objects:
			depsgraph = bpy.context.evaluated_depsgraph_get()
			evaluated = obj.evaluated_get(depsgraph)
			mesh = evaluated.to_mesh()
			base = len(points)
			points.extend(obj.matrix_world @ v.co for v in mesh.vertices)
			polygons.extend(tuple(base + i for i in p.vertices) for p in mesh.polygons)
			evaluated.to_mesh_clear()
		self.bvh = bvhtree.BVHTree.FromPolygons(points, polygons)

	def push_out(self, point, ease):
		location, normal, _index, _distance = self.bvh.find_nearest(point)
		if location is None:
			return point
		gap = (point - location).dot(normal)
		if gap < ease:
			return point + normal * (ease - gap)
		return point


def on_surface(surface, guides, thickness):
	"""Puntos sobre [surface]: cada guía (punto, dirección) se proyecta con un
	rayo en esa dirección (desde delante, desde detrás o desde arriba)."""
	placed = []
	for point, direction in guides:
		direction = direction.normalized()
		hit, _normal, _index, _distance = surface.bvh.ray_cast(point - direction * 1.0, direction)
		placed.append(hit - direction * thickness if hit is not None else surface.push_out(point, thickness))
	for _ in range(3):
		placed = [placed[0]] + [surface.push_out((placed[k - 1] + placed[k] * 2.0 + placed[k + 1]) * 0.25, thickness)
			for k in range(1, len(placed) - 1)] + [placed[-1]]
	return placed


def strap(g, surface, body, placed, width, color):
	"""Correa plana por los puntos [placed] (ya sobre la superficie), con los
	pesos del cuerpo más cercano (sin los brazos)."""
	ids = []
	for k, point in enumerate(placed):
		ahead = (placed[min(k + 1, len(placed) - 1)] - placed[max(k - 1, 0)]).normalized()
		_location, normal, _i, _d = surface.bvh.find_nearest(point)
		normal = normal if normal is not None else Vector((0.0, -1.0, 0.0))
		across = ahead.cross(normal).normalized() * (width * 0.5)
		weights = body.nearest_weights(point, exclude=ARM_BONES)
		ids.append((g.add_vertex(point - across, weights), g.add_vertex(point + across, weights)))
	for k in range(len(ids) - 1):
		g.add_face([ids[k][0], ids[k + 1][0], ids[k + 1][1], ids[k][1]], color, [(0.0, 0.0)] * 4)


def _sewn_object(g, name, armature):
	obj = g.to_object(name, bpy.context.scene.collection, armature)
	for modifier in [m for m in obj.modifiers if m.type == "ARMATURE"]:
		obj.modifiers.remove(modifier)
	for group in list(obj.vertex_groups):
		obj.vertex_groups.remove(group)
	_delete_loose(obj)
	return obj


def build_sewn_clothes(spec, body, armature, proxy, dims):
	"""Prendas cortadas y cosidas de [spec], caídas sobre el cuerpo y unidas
	al esqueleto. Devuelve los objetos."""
	bones = armature.data.bones
	female = spec["garment"] == "anacu"
	hip_z = dims["hip"]
	waist_z = dims["waist"]
	shoulder_z = dims["shoulder"]
	keyframe_arm_drop(armature)
	done = []

	# 1. Unku o anacu.
	g = tube_garment(spec, body, bones, dims)
	garment = _sewn_object(g, "sewn_garment", armature)
	seam = dims["seam"]
	shrink = None
	if female:
		# La faja ciñe el anacu a la cintura: la tela de esa franja encoge.
		shrink = [math.exp(-((v.co.z - waist_z) / 0.035) ** 2) for v in garment.data.vertices]
	simulate_piece(garment, [proxy], shrink=shrink, shrink_amount=0.32)
	# Cuánto sigue el bajo a los muslos al andar: lo bastante para que no los
	# atraviesen, sin partir la falda en perneras. La tejedora, arrodillada,
	# la necesita más alta para cubrir las rodillas.
	follow = spec.get("skirt_follow", 0.6 if female else 0.65)

	def garment_weights(p, posed):
		if p.z < hip_z - 0.03:
			return _skirt_weights(posed, p, hip_z, follow)
		near = posed.nearest_weights(p)
		if female:
			return _without(near, ARM_BONES + ("Shoulder",))
		# El unku sobre el hombro sigue al brazo; por debajo de la sisa, al tronco.
		keep = _smooth(seam - 0.04, seam + 0.1, p.z)
		return _without(near, ARM_BONES, keep)

	bind_piece(garment, armature, proxy, garment_weights)
	done.append(garment)

	# 2. Lliclla o manto sobre los hombros.
	pin_point = None
	for kind in ("lliclla", "manto"):
		if not spec.get(kind):
			continue
		# Se echa sobre los hombros con los brazos ya abajo y estirados.
		armature.animation_data_clear()
		keyframe_arm_drop(armature, straighten=True)
		bpy.context.scene.frame_set(SIM_FRAMES)
		g, pin, pin_point = shawl(spec, posed_body(proxy), ClothedSurface([proxy] + done), bones, dims, kind)
		piece = _sewn_object(g, "sewn_" + kind, armature)
		# El manto, grande y pesado, necesita chocar consigo mismo para plegarse
		# sin atravesarse; la lliclla, corta, cae mejor sin ello.
		manto = kind == "manto"
		simulate_piece(piece, [proxy] + done, pin=pin, mass=SHAWL_MASS,
			start=SETTLE_FRAMES + LOWER_FRAMES, end=SIM_FRAMES + 40, air=1.0,
			friction=10.0 if manto else 5.0, self_collision=manto, bending=1.5 if manto else WOOL_BENDING)
		cy = dims["cy"]

		def shawl_weights(p, posed, manto=(kind == "manto")):
			near = posed.nearest_weights(p)
			if not manto:
				return near
			# Detrás, el manto cuelga de los huesos de muelle (CAPE_CHAINS).
			behind = _smooth(cy - 0.02, cy + 0.06, p.y)
			upper = _without(near, ARM_BONES, 0.5)
			hang = _smooth(shoulder_z - 0.06, shoulder_z - 0.2, p.z) * behind
			lower = _smooth(waist_z + 0.06, waist_z - 0.06, p.z)
			weights = {bone: w * (1.0 - hang) for bone, w in upper.items()}
			side = max(-1.0, min(1.0, p.x / CAPE_SPREAD))
			shares = {"L": max(0.0, side), "R": max(0.0, -side)}
			shares["C"] = 1.0 - shares["L"] - shares["R"]
			for chain, share in shares.items():
				if share > 0.0:
					weights["Cape_%s_1" % chain] = weights.get("Cape_%s_1" % chain, 0.0) + hang * share * (1.0 - lower)
					weights["Cape_%s_2" % chain] = weights.get("Cape_%s_2" % chain, 0.0) + hang * share * lower
			return weights

		bind_piece(piece, armature, proxy, shawl_weights)
		done.append(piece)

	# 3. Bulto de viaje (q'ipi) y chuspa, con sus correas sobre la ropa.
	clear_arm_drop(armature)
	hide_covered_skin(proxy, garment, dims, female)
	extra = Garment()
	surface = ClothedSurface([proxy] + done)
	chest = bones["Spine1"].head_local
	if spec.get("bundle"):
		# Apoyado en la espalda: un rayo desde detrás encuentra la ropa.
		height = waist_z + 0.14
		hit, _normal, _index, _distance = surface.bvh.ray_cast(Vector((0.0, 1.0, height)), Vector((0.0, -1.0, 0.0)))
		back = hit.y if hit is not None else max(p.y for i, p in enumerate(body.points) if waist_z < p.z < shoulder_z and body.is_trunk(i))
		center = Vector((0.0, back + 0.1, height))
		bag = soft_bag(center, (0.36, 0.2, 0.32), TEXTILE_PIECES["bag"], _linear(spec["bundle"]), segments=(8, 4, 7), seed=3)
		for i in range(len(bag.verts)):
			bag.weights[i] = {"Spine1": 0.75, "Spine": 0.25}
		bag_obj = bag.to_object("sewn_bundle", bpy.context.scene.collection, armature)
		done.append(bag_obj)
		# Las correas, de color liso: con el textil de bolsa salían rayadas.
		extra.piece = 0
		knot = surface.push_out(Vector((0.0, chest.y - 0.15, shoulder_z - 0.1)), 0.012)
		front_dir, back_dir, down = Vector((0.0, 1.0, 0.0)), Vector((0.0, -1.0, 0.0)), Vector((0.0, 0.0, -1.0))
		for side in (-1.0, 1.0):
			corner = center + Vector((side * 0.15, -0.06, 0.14))
			over = Vector((side * 0.11, dims["cy"], shoulder_z + 0.1))
			guides = [(corner.lerp(over, t / 6.0), back_dir) for t in range(6)]
			guides += [(over, down)]
			guides += [(over.lerp(knot + Vector((side * 0.02, 0.0, 0.0)), t / 8.0), front_dir) for t in range(1, 9)]
			strap(extra, surface, body, on_surface(surface, guides, 0.006), 0.034, _linear(spec["bundle"]))
		knot_bag = soft_bag(knot + Vector((0.0, -0.012, 0.0)), (0.045, 0.03, 0.035), 0, _linear(spec["bundle"]), segments=(4, 3, 4), sag=0.0, seed=1)
		base = len(extra.verts)
		for i, p in enumerate(knot_bag.verts):
			extra.add_vertex(p, {"Spine1": 1.0})
			extra.pattern[base + i] = knot_bag.pattern[i]
		for face, color in zip(knot_bag.faces, knot_bag.face_colors):
			extra.add_face([base + i for i in face], color, [(0.0, 0.0)] * 4)
	if spec.get("chuspa"):
		left_hip = bones["LeftUpLeg"].head_local
		side_x = max(p.x for i, p in enumerate(body.points) if abs(p.z - (hip_z + 0.03)) < 0.03 and body.is_trunk(i))
		center = surface.push_out(Vector((side_x + 0.03, dims["cy"] - 0.02, hip_z + 0.02)), 0.03)
		bag = soft_bag(center, (0.05, 0.15, 0.17), TEXTILE_PIECES["bag"], _linear(spec["chuspa"]), segments=(2, 5, 6), seed=5)
		extra.piece = TEXTILE_PIECES["bag"]
		base = len(extra.verts)
		for i, p in enumerate(bag.verts):
			extra.add_vertex(p, {"Hips": 0.7, "LeftUpLeg": 0.3})
			extra.pattern[base + i] = bag.pattern[i]
		for face, color in zip(bag.faces, bag.face_colors):
			extra.add_face([base + i for i in face], color, [(0.0, 0.0)] * 4)
		extra.piece = 0
		shoulder = bones["RightArm"].head_local
		top = Vector((shoulder.x * 0.55, dims["cy"], shoulder_z + 0.1))
		for direction in (Vector((0.0, 1.0, 0.0)), Vector((0.0, -1.0, 0.0))):
			start = center + Vector((0.0, -direction.y * 0.065, 0.085))
			guides = [(start.lerp(top, t / 14.0), direction) for t in range(14)] + [(top, Vector((0.0, 0.0, -1.0)))]
			strap(extra, surface, body, on_surface(surface, guides, 0.004), 0.022, _linear(spec["chuspa"]))
	# 4. Faja del anacu sobre la tela ceñida, y tupu de la lliclla.
	if female:
		extra.piece = TEXTILE_PIECES["belt"]
		cloth_points = [garment.matrix_world @ v.co for v in garment.data.vertices if abs(v.co.z - waist_z) < 0.05]
		center = Vector((0.0, sum(p.y for p in cloth_points) / len(cloth_points), waist_z))
		ring = []
		for s in range(48):
			angle = 2.0 * math.pi * (s + 0.5) / 48
			direction = Vector((math.cos(angle), math.sin(angle), 0.0))
			reach = max([(p - center).dot(direction) for p in cloth_points if (p - center).normalized().dot(direction) > 0.97] or [0.15])
			ring.append(reach + 0.006)
		ring = [(ring[s - 1] + 2.0 * ring[s] + ring[(s + 1) % 48]) * 0.25 for s in range(48)]
		stripe = spec.get("belt", "wool_red")
		belt = [_ring_points(center, ring, waist_z + dz, 48, 0.0) for dz in (-0.045, 0.045)]
		extra.tube(belt, lambda s, r: _linear(stripe), body.nearest_weights)
	if spec.get("lliclla") and pin_point is not None:
		extra.piece = 0
		extra.box(surface.push_out(pin_point, 0.012), (0.03, 0.008, 0.04), Matrix.Identity(3), _linear("copper"), {"Spine1": 1.0})
	if extra.faces:
		done.append(extra.to_object("sewn_extra", bpy.context.scene.collection, armature))
	return done


def build_tool(armature, beat_seconds):
	"""Chaquitaclla rígida en la mano derecha. Se coloca en la pose del golpe
	del trabajo, con la punta en el suelo delante del pie, y se devuelve a la
	pose de reposo de la mano para que el esqueleto la lleve."""
	scene = bpy.context.scene
	for track in armature.animation_data.nla_tracks:
		track.mute = track.name != "work"
	scene.frame_set(1 + int(round(beat_seconds * ANIM_FPS)))
	bpy.context.view_layer.update()
	pose_bone = armature.pose.bones["RightHand"]
	posed = pose_bone.matrix.copy()
	rest = pose_bone.bone.matrix_local.copy()
	to_rest = rest @ posed.inverted()
	# El palo pasa por el puño cerrado: entre la palma y los dedos doblados.
	fingers = armature.pose.bones["RightFingerBase"]
	hand = (pose_bone.tail + fingers.tail) * 0.5
	# MakeHuman mira a −Y: la punta va delante (−Y) y al suelo.
	tip = Vector((hand.x, hand.y - 0.35, 0.0))
	axis = (hand - tip).normalized()
	side = axis.cross(Vector((1.0, 0.0, 0.0))).normalized()
	other = axis.cross(side).normalized()
	g = Garment()

	def ring(center, radius):
		return [center + (side * math.cos(a) + other * math.sin(a)) * radius for a in (2.0 * math.pi * k / 7 for k in range(7))]

	g.tube([ring(tip, 0.02), ring(tip + axis * 1.5, 0.018)], lambda s_, r: _linear("wood"), lambda p: {"RightHand": 1.0})
	frame = Matrix((side, other, axis)).transposed()
	g.box(tip + axis * 0.38, (0.03, 0.16, 0.025), frame, _linear("wood_light"), {"RightHand": 1.0})
	g.box(tip + axis * 0.05, (0.04, 0.07, 0.09), frame, _linear("wood_light"), {"RightHand": 1.0})
	g.verts = [to_rest @ v for v in g.verts]
	for track in armature.animation_data.nla_tracks:
		track.mute = False
	scene.frame_set(1)
	return g.to_object("tool", bpy.context.scene.collection, armature)


# --- Captura de movimiento de CMU (ASF/AMC) -------------------------------

ASF_TO_METERS = (1.0 / 0.45) * 2.54 / 100.0


class AsfBone:
	def __init__(self, name):
		self.name = name
		self.direction = Vector((0.0, 0.0, 0.0))
		self.length = 0.0
		self.axis = Matrix.Identity(3)
		self.dof = []
		self.parent = None
		self.children = []


def _euler_matrix(degrees, order="XYZ"):
	"""Matriz de rotación de los ángulos (x, y, z) en grados, aplicados en el
	orden indicado (convención de CMU: X, luego Y, luego Z)."""
	result = Matrix.Identity(3)
	for axis in order:
		angle = math.radians(degrees["XYZ".index(axis)])
		result = Matrix.Rotation(angle, 3, axis) @ result
	return result


def parse_asf(path):
	bones = {"root": AsfBone("root")}
	root_order = []
	section = None
	current = None
	with open(path, encoding="latin-1") as handle:
		for raw in handle:
			line = raw.strip()
			if not line or line.startswith("#"):
				continue
			if line.startswith(":"):
				section = line.split()[0]
				if section == ":root":
					current = bones["root"]
				continue
			words = line.split()
			if section == ":root":
				if words[0] == "order":
					root_order = [w.lower() for w in words[1:]]
				elif words[0] == "orientation":
					current.axis = _euler_matrix([float(w) for w in words[1:4]])
			elif section == ":bonedata":
				if words[0] == "begin":
					current = None
				elif words[0] == "name":
					current = AsfBone(words[1])
					bones[words[1]] = current
				elif words[0] == "direction":
					current.direction = Vector([float(w) for w in words[1:4]])
				elif words[0] == "length":
					current.length = float(words[1]) * ASF_TO_METERS
				elif words[0] == "axis":
					current.axis = _euler_matrix([float(w) for w in words[1:4]], words[4] if len(words) > 4 else "XYZ")
				elif words[0] == "dof":
					current.dof = [w.lower() for w in words[1:]]
			elif section == ":hierarchy":
				if words[0] in ("begin", "end"):
					continue
				parent = bones[words[0]]
				for child_name in words[1:]:
					child = bones[child_name]
					child.parent = parent
					parent.children.append(child)
	bones["root"].dof = root_order
	return bones


def parse_amc(path):
	frames = []
	current = None
	with open(path, encoding="latin-1") as handle:
		for raw in handle:
			line = raw.strip()
			if not line or line.startswith("#") or line.startswith(":"):
				continue
			words = line.split()
			if len(words) == 1 and words[0].isdigit():
				current = {}
				frames.append(current)
				continue
			if current is not None:
				current[words[0]] = [float(w) for w in words[1:]]
	return frames


def amc_local(bone, values):
	"""Rotación local (en ejes globales del ASF) y traslación de la raíz."""
	angles = [0.0, 0.0, 0.0]
	translation = Vector((0.0, 0.0, 0.0))
	for dof, value in zip(bone.dof, values):
		if dof in ("rx", "ry", "rz"):
			angles["xyz".index(dof[1])] = value
		elif dof in ("tx", "ty", "tz"):
			translation["xyz".index(dof[1])] = value * ASF_TO_METERS
	motion = _euler_matrix(angles)
	return bone.axis @ motion @ bone.axis.inverted(), translation


class Take:
	"""Una toma de CMU a 30 fps: rotaciones locales por hueso y raíz."""

	def __init__(self, asf_path, amc_path, start=0, end=None):
		self.bones = parse_asf(asf_path)
		frames = parse_amc(amc_path)[start:end]
		self.local = []
		self.root_pos = []
		step = 120 // ANIM_FPS
		for frame in frames[::step]:
			pose = {}
			for name, bone in self.bones.items():
				values = frame.get(name)
				if values is None:
					pose[name] = Matrix.Identity(3)
					continue
				rotation, translation = amc_local(bone, values)
				pose[name] = rotation
				if name == "root":
					self.root_pos.append(translation)
			self.local.append(pose)

	def __len__(self):
		return len(self.local)

	def globals_at(self, index):
		result = {}

		def visit(bone, parent_rotation):
			rotation = parent_rotation @ self.local[index][bone.name]
			result[bone.name] = rotation
			for child in bone.children:
				visit(child, rotation)

		visit(self.bones["root"], Matrix.Identity(3))
		return result

	def leg_length(self):
		return self.bones["lfemur"].length + self.bones["ltibia"].length


# Cambio de ejes: el ASF tiene Y arriba; Blender, Z arriba.
Y_UP_TO_Z_UP = Matrix.Rotation(math.radians(90.0), 3, "X")


def _rotation_between(a, b):
	return a.normalized().rotation_difference(b.normalized()).to_matrix()


ARM_MOTION = ("lhumerus", "rhumerus", "lradius", "rradius", "lwrist", "rwrist")


def find_cycle(take, min_seconds, max_seconds, bones=("lfemur", "rfemur", "ltibia", "rtibia", "lhumerus", "rhumerus"),
		motion_bones=(), motion_weight=0.0):
	"""Busca dentro de la toma un tramo cuyo final se parezca a su comienzo.

	Con [motion_weight], además premia el movimiento de [motion_bones] dentro
	del tramo: solo con el parecido del bucle ganan los tramos más quietos, y
	en los gestos y el trabajo eso deja los brazos casi parados."""
	best = (1e9, 0, len(take) - 1)
	low = int(min_seconds * ANIM_FPS)
	high = int(max_seconds * ANIM_FPS)
	margin = len(take) // 10
	# Movimiento por fotograma (rad/s) y sumas acumuladas para cada tramo.
	prefix = [0.0]
	for f in range(len(take) - 1):
		step = 0.0
		for name in motion_bones:
			a = take.local[f][name].to_quaternion()
			b = take.local[f + 1][name].to_quaternion()
			step += a.rotation_difference(b).angle * ANIM_FPS
		prefix.append(prefix[-1] + step)
	for start in range(margin, len(take) - low - margin, 2):
		for length in range(low, high + 1):
			end = start + length
			if end >= len(take) - margin:
				break
			cost = 0.0
			for name in bones:
				a = take.local[start][name].to_quaternion()
				b = take.local[end][name].to_quaternion()
				cost += a.rotation_difference(b).angle
			if motion_weight > 0.0:
				cost -= motion_weight * (prefix[end] - prefix[start]) / length
			if cost < best[0]:
				best = (cost, start, end)
	return best[1], best[2]


class Retargeter:
	"""Traslada las rotaciones globales de CMU al esqueleto cmu_mb."""

	def __init__(self, take, armature, start=0, end=None):
		self.take = take
		self.armature = armature
		bones = armature.data.bones
		self.rest = {b.name: b.matrix_local.to_3x3() for b in bones}
		self.rest_head = {b.name: b.head_local.copy() for b in bones}
		# Orientación: la izquierda media de la pelvis del sujeto durante el
		# tramo se lleva a la del esqueleto (+X) con un giro en planta. Así el
		# personaje mira al frente aunque el sujeto mirara a otro lado.
		end = len(take) - 1 if end is None else end
		# Izquierda menos derecha: los huesos de la cadera también apuntan algo
		# hacia delante y hacia abajo; restándolos queda solo el eje lateral.
		hip_axis = take.bones["lhipjoint"].direction - take.bones["rhipjoint"].direction
		source_left = Vector((0.0, 0.0, 0.0))
		for index in range(start, end + 1, 3):
			left = Y_UP_TO_Z_UP @ (take.globals_at(index)["root"] @ hip_axis)
			left.z = 0.0
			if left.length > 1e-6:
				source_left += left.normalized()
		target_left = bones["LHipJoint"].tail_local - bones["LHipJoint"].head_local
		target_left.z = 0.0
		heading = math.atan2(target_left.y, target_left.x) - math.atan2(source_left.y, source_left.x)
		self.frame = Matrix.Rotation(heading, 3, "Z") @ Y_UP_TO_Z_UP
		# Las direcciones de reposo de CMU se giran solo con el cambio de ejes
		# y el giro de reposo; el giro del tramo se aplica a la pose.
		rest_left = Y_UP_TO_Z_UP @ hip_axis
		rest_left.z = 0.0
		rest_heading = math.atan2(target_left.y, target_left.x) - math.atan2(rest_left.y, rest_left.x)
		self.rest_frame = Matrix.Rotation(rest_heading, 3, "Z") @ Y_UP_TO_Z_UP
		self.align = {}
		for cmu_name, rig_name in CMU_TO_RIG.items():
			bone = take.bones[cmu_name]
			if cmu_name == "root" or bone.direction.length < 1e-6:
				self.align[cmu_name] = Matrix.Identity(3)
				continue
			source_dir = self.rest_frame @ bone.direction
			target_dir = bones[rig_name].tail_local - bones[rig_name].head_local
			self.align[cmu_name] = _rotation_between(source_dir, target_dir)
		target_leg = (bones["LeftUpLeg"].tail_local - bones["LeftUpLeg"].head_local).length + \
			(bones["LeftLeg"].tail_local - bones["LeftLeg"].head_local).length
		self.scale = target_leg / take.leg_length()

	def world_rotations(self, globals_):
		frame_inv = self.rest_frame.inverted()
		result = {}
		for cmu_name, rig_name in CMU_TO_RIG.items():
			# Pose en el marco del tramo; reposo en el marco de reposo.
			source = self.frame @ globals_[cmu_name] @ frame_inv
			result[rig_name] = source @ self.align[cmu_name].inverted() @ self.rest[rig_name]
		return result

	def basis(self, world):
		"""Rotaciones locales (matrix_basis) a partir de las del mundo."""
		result = {}
		for bone in self.armature.data.bones:
			if bone.name not in world:
				continue
			if bone.parent is None:
				local = self.rest[bone.name].inverted() @ world[bone.name]
			else:
				parent_world = world.get(bone.parent.name, self.rest[bone.parent.name])
				local = self.rest[bone.name].inverted() @ self.rest[bone.parent.name] @ parent_world.inverted() @ world[bone.name]
			result[bone.name] = local.to_quaternion()
		return result

	def hips_location(self, position):
		"""Desplazamiento local de la cadera para la posición de la raíz."""
		world = self.frame @ position * self.scale
		offset = world - self.rest_head["Hips"]
		return self.rest["Hips"].inverted() @ offset


def _toe_track(armature, name, count):
	"""Posición (armazón) de las puntas de los pies en cada fotograma de la
	pista [name], recién horneada."""
	scene = bpy.context.scene
	for track in armature.animation_data.nla_tracks:
		track.mute = track.name != name
	toes = []
	for frame in range(count):
		scene.frame_set(frame + 1)
		bpy.context.view_layer.update()
		toes.append((armature.pose.bones["LeftToeBase"].head.copy(), armature.pose.bones["RightToeBase"].head.copy()))
	for track in armature.animation_data.nla_tracks:
		track.mute = False
	scene.frame_set(1)
	return toes


def lock_feet(armature, name, frames, contact=0.06, smooth_passes=3):
	"""Pies sin patinar en un ciclo de locomoción sin avance.

	Mide la punta del pie de apoyo (la más baja, si toca el suelo) en el ciclo
	horneado. Su velocidad media hacia atrás es la velocidad real del ciclo.
	Después corrige el adelanto de la cadera fotograma a fotograma para que el
	pie de apoyo retroceda a esa velocidad constante: así, al mover al
	personaje a esa velocidad, el pie queda fijo en el suelo. MakeHuman mira a
	−Y, así que «hacia atrás» es +Y del armazón.

	Devuelve (velocidad del ciclo en m/s, longitud del paso en m)."""
	count = len(frames) - 1
	toes = _toe_track(armature, name, count + 1)
	steps = []
	for f in range(count):
		left, right = toes[f]
		planted = 0 if left.z <= right.z else 1
		if min(left.z, right.z) > contact:
			steps.append(None)
			continue
		steps.append(toes[f + 1][planted] - toes[f][planted])
	known = [d for d in steps if d is not None]
	if not known:
		return 0.0, 0.0
	per_frame = sum(d.y for d in known) / len(known)

	def periodic(correction):
		# Periódica y centrada, y suavizada para que la cadera no dé tirones.
		drift = correction[-1]
		correction = [c - drift * k / count for k, c in enumerate(correction)]
		for _ in range(smooth_passes):
			correction = [(correction[k - 1] + 2.0 * correction[k] + correction[(k + 1) % (count + 1)]) * 0.25
				for k in range(count + 1)]
			correction[-1] = correction[0]
		mean = sum(correction[:-1]) / count
		return [c - mean for c in correction]

	# Hacia atrás (Y) el pie debe retroceder a velocidad constante; de lado
	# (X), quedarse quieto.
	forward = [0.0]
	lateral = [0.0]
	for d in steps:
		forward.append(forward[-1] + (0.0 if d is None else per_frame - d.y))
		lateral.append(lateral[-1] + (0.0 if d is None else -d.x))
	forward = periodic(forward)
	lateral = periodic(lateral)
	rest = armature.data.bones["Hips"].matrix_local.to_3x3().inverted()
	locked = []
	for k, (rotations, hips) in enumerate(frames):
		locked.append((rotations, hips + rest @ Vector((lateral[k], forward[k], 0.0))))
	# Rehornear la pista con la cadera corregida.
	track = armature.animation_data.nla_tracks[name]
	action = track.strips[0].action
	armature.animation_data.nla_tracks.remove(track)
	bpy.data.actions.remove(action)
	bake_action(armature, name, locked)
	speed = per_frame * ANIM_FPS
	return speed, speed * (count / ANIM_FPS) * 0.5


def bake_action(armature, name, frames):
	"""[frames]: lista de (rotaciones locales por hueso, posición de cadera)."""
	action = bpy.data.actions.new(name)
	armature.animation_data.action = action
	for pose_bone in armature.pose.bones:
		pose_bone.rotation_mode = "QUATERNION"
	previous = {}
	for index, (rotations, hips) in enumerate(frames):
		for pose_bone in armature.pose.bones:
			quat = rotations.get(pose_bone.name, Quaternion())
			# Continuidad del cuaternión para que la interpolación no dé vueltas.
			last = previous.get(pose_bone.name)
			if last is not None and last.dot(quat) < 0.0:
				quat = -quat
			previous[pose_bone.name] = quat
			pose_bone.rotation_quaternion = quat
			pose_bone.keyframe_insert("rotation_quaternion", frame=index + 1)
			if pose_bone.name == "Hips":
				pose_bone.location = hips
				pose_bone.keyframe_insert("location", frame=index + 1)
	track = armature.animation_data.nla_tracks.new()
	track.name = name
	track.strips.new(name, 1, action)
	armature.animation_data.action = None


def _slerp_matrix(a, b, t):
	return a.to_quaternion().slerp(b.to_quaternion(), t).to_matrix()


def _following(world, rest, bone, parent):
	"""Rotación de [bone] si mantuviera su relación de reposo con [parent]."""
	return world[parent] @ rest[parent].inverted() @ rest[bone]


# MakeHuman mira a −Y: delante y arriba de la cabeza en el armazón.
FACE_FORWARD = Vector((0.0, -1.0, 0.0))
FACE_UP = Vector((0.0, 0.0, 1.0))


def tidy_posture(world, rest, straighten=0.4, neck_keep=0.3, level=0.75):
	"""Corrige lo que la captura trae de más para un cuerpo de MakeHuman:
	- la columna se endereza en parte (los sujetos de CMU van algo
	  encorvados y el pecho de MakeHuman ya se inclina hacia delante);
	- cuello y cabeza siguen sobre todo al pecho, y solo conservan
	  [neck_keep] del movimiento propio de la toma;
	- la cara se nivela: se quita casi todo el cabeceo y el alabeo respecto
	  al horizonte, para que no cuelgue ni se tuerza."""
	for bone, parent in (("Spine", "LowerBack"), ("Spine1", "Spine")):
		world[bone] = _slerp_matrix(world[bone], _following(world, rest, bone, parent), straighten)
	for bone, parent in (("Neck", "Spine1"), ("Neck1", "Neck"), ("Head", "Neck1")):
		world[bone] = _slerp_matrix(world[bone], _following(world, rest, bone, parent), 1.0 - neck_keep)
	head = world["Head"] @ rest["Head"].inverted()
	face = head @ FACE_FORWARD
	flat = Vector((face.x, face.y, 0.0))
	if flat.length > 1e-4:
		pitch_fix = face.rotation_difference(flat.normalized())
		pitch_fix = Quaternion().slerp(pitch_fix, level)
		head = pitch_fix.to_matrix() @ head
		face = head @ FACE_FORWARD
		up = head @ FACE_UP
		wanted = (FACE_UP - face * FACE_UP.dot(face)).normalized()
		current = (up - face * up.dot(face)).normalized()
		roll_fix = Quaternion().slerp(current.rotation_difference(wanted), level)
		world["Head"] = roll_fix.to_matrix() @ head @ rest["Head"]


# Dedos relajados: la captura de CMU apenas trae dedos y la pose de reposo de
# MakeHuman los tiene abiertos y rígidos. Curvatura local en grados.
FINGER_CURL = {"LeftFingerBase": 22.0, "RightFingerBase": 22.0, "LeftHandFinger1": 38.0,
	"RightHandFinger1": 38.0, "LThumb": 12.0, "RThumb": 12.0}


# Mano que sujeta una herramienta (la derecha del agricultor): dedos cerrados.
GRIP_CURL = {"RightFingerBase": 55.0, "RightHandFinger1": 75.0, "RThumb": 35.0}
# Mano o manos que agarran en el personaje que se está generando.
GRIP_BONES = set()


def relax_fingers(basis):
	for bone, degrees in FINGER_CURL.items():
		if bone in GRIP_BONES:
			degrees = GRIP_CURL[bone]
		basis[bone] = Quaternion((1.0, 0.0, 0.0), math.radians(degrees))
	return basis


def cycle_frames(take, retarget, start, end, in_place=True, blend=6, override=None, extra=None, hips=None):
	"""Fotogramas de un ciclo cerrado: se quita el avance de la raíz y los
	últimos fotogramas se funden con los primeros."""
	count = end - start
	p0 = take.root_pos[start]
	p1 = take.root_pos[end]
	frames = []
	for k in range(count + 1):
		i = start + k
		local = dict(take.local[i])
		if override is not None:
			local.update(override(k))
		saved = take.local[i]
		take.local[i] = local
		globals_ = take.globals_at(i)
		take.local[i] = saved
		world = retarget.world_rotations(globals_)
		tidy_posture(world, retarget.rest)
		if extra is not None:
			extra(world, k / max(count, 1))
		position = take.root_pos[i].copy()
		if in_place:
			drift = p0 + (p1 - p0) * (k / count)
			position.x -= drift.x
			position.z -= drift.z
		location = hips(k) if hips is not None else retarget.hips_location(position)
		frames.append((relax_fingers(retarget.basis(world)), location))
	# Fundido: el ciclo acaba exactamente donde empieza.
	first_rot, first_hips = frames[0]
	for b in range(blend):
		k = count - blend + 1 + b
		t = (b + 1) / blend
		rot, hips = frames[k]
		mixed = {name: q.slerp(first_rot.get(name, q), t) for name, q in rot.items()}
		frames[k] = (mixed, hips.lerp(first_hips, t))
	frames[-1] = frames[0]
	return frames, (p1 - p0)


def add_rotation(world, bone, pitch=0.0, yaw=0.0, roll=0.0, children=()):
	"""Gira [bone] (y los huesos de [children]) en ejes del personaje
	(MakeHuman: X a su izquierda, −Y delante, Z arriba)."""
	turn = Matrix.Rotation(math.radians(yaw), 3, "Z") @ Matrix.Rotation(math.radians(pitch), 3, "X") @ Matrix.Rotation(math.radians(roll), 3, "Y")
	for name in (bone,) + tuple(children):
		if name in world:
			world[name] = turn @ world[name]


def build_animations(armature, spec, cmu_dir):
	"""Hornea las animaciones del personaje y devuelve datos de ritmo."""
	armature.animation_data_create()
	info = {}
	GRIP_BONES.clear()
	if spec.get("tool"):
		GRIP_BONES.update(GRIP_CURL.keys())

	def take(subject, motion):
		return Take(os.path.join(cmu_dir, "%s.asf" % subject), os.path.join(cmu_dir, "%s_%s.amc" % (subject, motion)))

	# Reposo: los primeros seis segundos de la toma 82_08 («stand still»), en
	# los que el sujeto está de pie, relajado y apenas se mueve.
	idle = Take(os.path.join(cmu_dir, "82.asf"), os.path.join(cmu_dir, "82_08.amc"), 0, 6 * 120)
	start, end = find_cycle(idle, 3.5, 5.0)
	rt = Retargeter(idle, armature, start, end)
	frames, _ = cycle_frames(idle, rt, start, end, blend=20)
	bake_action(armature, "idle", frames)
	# Agotado: el mismo reposo, encorvado y con la respiración marcada.
	upper = ("LowerBack", "Spine", "Spine1", "Neck", "Neck1", "Head", "LeftShoulder", "RightShoulder",
		"LeftArm", "RightArm", "LeftForeArm", "RightForeArm", "LeftHand", "RightHand", "LThumb", "RThumb",
		"LeftFingerBase", "RightFingerBase", "LeftHandFinger1", "RightHandFinger1")

	def tired(world, t):
		breath = math.sin(t * 2.0 * math.pi * 3.0)
		# Cabeceo positivo = hacia delante (MakeHuman mira a −Y).
		add_rotation(world, "LowerBack", pitch=16.0 + 2.0 * breath, children=upper[1:])
		add_rotation(world, "Neck", pitch=12.0, children=("Neck1", "Head"))

	# Segundo reposo (toma 77_02, «standing»): el juego alterna los dos para
	# que nadie repita el mismo bucle de pocos segundos.
	standing = take("77", "02")
	start_b, end_b = find_cycle(standing, 4.0, 6.0)
	rt_b = Retargeter(standing, armature, start_b, end_b)
	frames, _ = cycle_frames(standing, rt_b, start_b, end_b, blend=20)
	bake_action(armature, "idle_b", frames)
	start2, end2 = find_cycle(idle, 1.4, 1.6)
	frames, _ = cycle_frames(idle, rt, start2, end2, blend=8, extra=tired)
	bake_action(armature, "tired", frames)

	# Paseo y carrera: un ciclo de dos pasos, sin avance.
	walk = take("07", "01")
	start, end = find_cycle(walk, 0.9, 1.4)
	rt = Retargeter(walk, armature, start, end)
	frames, advance = cycle_frames(walk, rt, start, end)
	bake_action(armature, "walk", frames)
	info["walk_cycle_speed"], info["walk_stride"] = lock_feet(armature, "walk", frames)
	run = take("09", "01")
	start, end = find_cycle(run, 0.55, 0.9)
	rt = Retargeter(run, armature, start, end)
	frames, advance = cycle_frames(run, rt, start, end, blend=3)
	bake_action(armature, "run", frames)
	info["run_cycle_speed"], info["run_stride"] = lock_feet(armature, "run", frames)

	# Hablar con gestos.
	talk = take("18", "08")
	start, end = find_cycle(talk, 2.5, 4.0, bones=("lhumerus", "rhumerus", "lradius", "rradius", "lfemur", "rfemur"),
		motion_bones=ARM_MOTION, motion_weight=0.12)
	rt = Retargeter(talk, armature, start, end)
	frames, _ = cycle_frames(talk, rt, start, end, blend=12)
	bake_action(armature, "talk", frames)

	if "work" in spec.get("animations", ()):
		dig = take("79", "04")
		start, end = find_cycle(dig, 2.0, 3.2, bones=("lhumerus", "rhumerus", "lradius", "rradius", "lowerback", "thorax"),
			motion_bones=ARM_MOTION + ("lowerback",), motion_weight=0.08)
		rt = Retargeter(dig, armature, start, end)
		frames, _ = cycle_frames(dig, rt, start, end, blend=10)
		bake_action(armature, "work", frames)
		# Golpe: cuando la mano derecha está más baja.
		info["work_beat"] = _lowest_hand_time(dig, rt, start, end, "rwrist")

	if "weave" in spec.get("animations", ()):
		# Tejedora sentada sobre los talones con las dos rodillas en el suelo,
		# como en el dibujo 80 de Guamán Poma (PCH-010, R). CMU no tiene esa
		# postura: la parte baja se calcula con la geometría del esqueleto y
		# el tronco, los brazos y la cabeza salen de la toma de coser (79_05).
		sew = take("79", "05")
		start, end = find_cycle(sew, 2.4, 3.4, bones=("lhumerus", "rhumerus", "lradius", "rradius"),
			motion_bones=ARM_MOTION, motion_weight=0.08)
		rt = Retargeter(sew, armature, start, end)
		bones = armature.data.bones
		hips_head = bones["Hips"].head_local
		hip_height = 0.36
		legs = {}
		for side in ("Left", "Right"):
			thigh = bones[side + "UpLeg"]
			shin = bones[side + "Leg"]
			foot = bones[side + "Foot"]
			hip = thigh.head_local - hips_head + Vector((0.0, 0.0, hip_height))
			thigh_len = (thigh.tail_local - thigh.head_local).length
			drop = max(hip.z - 0.07, 0.0)
			ahead = math.sqrt(max(thigh_len ** 2 - drop ** 2, 0.0))
			# MakeHuman mira a −Y: las rodillas van delante y las espinillas,
			# tumbadas hacia atrás; los empeines apoyados con las puntas atrás.
			legs[side + "UpLeg"] = Vector((hip.x * 0.15, -ahead, -drop))
			# Algo hundidas: pies y talones quedan bajo la falda y el terreno.
			legs[side + "Leg"] = Vector((hip.x * -0.2, 1.0, -0.65))
			legs[side + "Foot"] = Vector((0.0, 0.25, -1.0))
			legs[side + "ToeBase"] = Vector((0.0, 0.2, -1.0))

		weave_upper = ("Spine", "Spine1", "Neck", "Neck1", "Head", "LeftShoulder", "RightShoulder",
			"LeftArm", "RightArm", "LeftForeArm", "RightForeArm", "LeftHand", "RightHand", "LThumb", "RThumb",
			"LeftFingerBase", "RightFingerBase", "LeftHandFinger1", "RightHandFinger1")

		def kneel(world, _t):
			world["Hips"] = rt.rest["Hips"].copy()
			for name, direction in legs.items():
				rest_dir = bones[name].tail_local - bones[name].head_local
				world[name] = _rotation_between(rest_dir, direction) @ rt.rest[name]
			# Algo inclinada sobre el telar, y los brazos hacia abajo y hacia
			# delante, hasta el extremo del tejido (la toma era de coser
			# sentado, con las manos a la altura del pecho).
			add_rotation(world, "LowerBack", pitch=12.0, children=weave_upper)
			for side in ("Left", "Right"):
				hand_chain = (side + "ForeArm", side + "Hand", ("L" if side == "Left" else "R") + "Thumb",
					side + "FingerBase", side + "HandFinger1")
				add_rotation(world, side + "Arm", pitch=18.0, children=hand_chain)
				add_rotation(world, side + "ForeArm", pitch=26.0, children=hand_chain[1:])

		hips_offset = rt.rest["Hips"].inverted() @ Vector((0.0, 0.0, hip_height - hips_head.z))
		frames, _ = cycle_frames(sew, rt, start, end, blend=12, extra=kneel, hips=lambda _k: hips_offset)
		bake_action(armature, "weave", frames)
		info["weave_beat"] = _lowest_hand_time(sew, rt, start, end, "rwrist")
	return info


def _lowest_hand_time(take, retarget, start, end, bone_name):
	"""Instante (s) del ciclo en que [bone_name] está más bajo."""
	best = (1e9, 0)
	for k in range(end - start + 1):
		globals_ = take.globals_at(start + k)
		position = Vector((0.0, 0.0, 0.0))
		bone = take.bones[bone_name]
		chain = []
		while bone is not None and bone.name != "root":
			chain.append(bone)
			bone = bone.parent
		for b in reversed(chain):
			position += globals_[b.name] @ (b.direction * b.length)
		height = (take.root_pos[start + k] + position).y
		if height < best[0]:
			best = (height, k)
	return best[1] / ANIM_FPS


# --- Personajes ---------------------------------------------------------------

PEOPLE = {
	# Habitantes comunes (PCH-018).
	"pch_npc_weaver": dict(head="Medical_Female_01", skirt_follow=0.9, garment="anacu", body="wool_brown", band="wool_red", belt="wool_red",
		lliclla="wool_cream", lliclla_stripe="wool_red", hair="long01", skin="young_asian_female",
		macro={"gender": 0.0, "age": 0.45, "muscle": 0.5, "weight": 0.6, "height": 0.25, "proportions": 0.45},
		animations=("weave",)),
	"pch_npc_farmer": dict(head="Business_Male_06", garment="unku", body="wool_cream", band="wool_brown", manto="wool_brown",
		head_cloth="wool_red", chuspa="wool_ochre", tool="chaquitaclla", hair="short02", skin="middleage_asian_male",
		macro={"gender": 1.0, "age": 0.6, "muscle": 0.65, "weight": 0.55, "height": 0.3, "proportions": 0.45},
		animations=("work",)),
	"pch_npc_villager": dict(head="Female_Adult_11", garment="anacu", body="wool_dark", band="wool_ochre", belt="wool_green",
		lliclla="wool_grey", lliclla_stripe="wool_green", hair="long01", skin="middleage_asian_female",
		macro={"gender": 0.0, "age": 0.6, "muscle": 0.5, "weight": 0.65, "height": 0.22, "proportions": 0.45}),
	# Otras dos vecinas, para que los tres habitantes no sean clones.
	"pch_npc_villager_b": dict(head="Sports_Female_02", garment="anacu", body="wool_brown", band="wool_red", belt="wool_ochre",
		lliclla="wool_red", lliclla_stripe="wool_dark", hair="long01", skin="young_asian_female",
		macro={"gender": 0.0, "age": 0.4, "muscle": 0.5, "weight": 0.55, "height": 0.28, "proportions": 0.45}),
	"pch_npc_villager_c": dict(head="Business_Female_01", garment="anacu", body="wool_grey", band="wool_blue", belt="wool_red",
		lliclla="wool_ochre", lliclla_stripe="wool_red", hair="long01", skin="middleage_asian_female",
		macro={"gender": 0.0, "age": 0.55, "muscle": 0.5, "weight": 0.7, "height": 0.2, "proportions": 0.45}),
	"pch_npc_commoner": dict(head="Business_Male_02", garment="unku", body="wool_grey", band="wool_dark", manto="wool_cream",
		chuspa="wool_red", hair="short02", skin="young_asian_male",
		macro={"gender": 1.0, "age": 0.45, "muscle": 0.6, "weight": 0.5, "height": 0.32, "proportions": 0.45}),
	# Mensajero (PCH-011): ropa de viaje sin insignias, con su bulto.
	"pch_npc_messenger": dict(head="Male_Adult_10", garment="unku", body="wool_brown", band="wool_dark", bundle="wool_cream",
		head_cloth="wool_grey", chuspa="wool_cream", hair="short02", skin="young_asian_male",
		macro={"gender": 1.0, "age": 0.4, "muscle": 0.7, "weight": 0.4, "height": 0.35, "proportions": 0.5}),
	# Autoridades (PCH-017): franja ajedrezada, cinta y manto teñido.
	"pch_npc_curaca": dict(head="Male_Adult_09", garment="unku", body="wool_cream", band="wool_red", band_style="tocapu",
		band_alt="wool_dark", manto="wool_red", headband="wool_ochre", chuspa="wool_blue", hair="short02",
		skin="old_asian_male",
		macro={"gender": 1.0, "age": 0.75, "muscle": 0.5, "weight": 0.6, "height": 0.33, "proportions": 0.45}),
	"pch_npc_principal": dict(head="Business_Male_02", garment="unku", body="wool_ochre", band="wool_dark", band_style="tocapu",
		band_alt="wool_cream", manto="wool_blue", headband="wool_red", hair="short02", skin="middleage_asian_male",
		macro={"gender": 1.0, "age": 0.55, "muscle": 0.6, "weight": 0.55, "height": 0.35, "proportions": 0.45}),
	"pch_npc_authority": dict(head="Business_Male_06", garment="unku", body="wool_cream", band="wool_dark", band_style="tocapu",
		band_alt="wool_red", manto="wool_brown", headband="wool_red", hair="short02", skin="middleage_asian_male",
		macro={"gender": 1.0, "age": 0.5, "muscle": 0.6, "weight": 0.5, "height": 0.3, "proportions": 0.5}),
}


# --- Cabezas de Rocketbox (ADR-0017) ---------------------------------------
#
# La cara de MakeHuman se sustituye por la cabeza de un avatar de la Microsoft
# Rocketbox Avatar Library (MIT): piel, ojos y pelo hechos por artistas. Del
# FBX se toman las caras de los materiales de cabeza y de pelo; se escalan
# por la anchura de la cara a la altura de los ojos, se colocan sobre los ojos
# de MakeHuman, se pegan al cuello del cuerpo y toman sus pesos.

def _rocketbox_skin(image):
	"""Piel de Rocketbox llevada al mismo moreno que el cuerpo. El alfa de la
	textura no es transparencia y se descarta."""
	import numpy as np
	width, height = image.size
	pixels = np.empty(width * height * 4, dtype=np.float32)
	image.pixels.foreach_get(pixels)
	pixels = pixels.reshape(height, width, 4)
	rgb = pixels[..., :3]
	bright = rgb.mean(axis=2)
	mask = (bright > 0.15) & (bright < 0.9)
	mean = rgb[mask].mean(axis=0)
	gain = np.array(SKIN_TARGET, dtype=np.float32) / np.maximum(mean, 1e-3)
	pixels[..., :3] = np.clip(rgb * gain, 0.0, 1.0)
	pixels[..., 3] = 1.0
	copy = bpy.data.images.new(image.name + "_pch", width, height, alpha=False)
	copy.pixels.foreach_set(pixels.ravel())
	if width > TEXTURE_SIZE:
		copy.scale(TEXTURE_SIZE, TEXTURE_SIZE)
	copy.pack()
	return copy


def _load_texture(folder, key, scale_to=TEXTURE_SIZE, non_color=False):
	files = sorted(f for f in os.listdir(folder) if key in f)
	if not files:
		return None
	image = bpy.data.images.load(os.path.join(folder, files[0]))
	if non_color:
		image.colorspace_settings.name = "Non-Color"
	if image.size[0] > scale_to:
		image.scale(scale_to, scale_to)
	image.pack()
	return image


def _rocketbox_materials(head, folder):
	"""Materiales propios para la cabeza («rb.head», con normales) y el pelo
	(«rb.hair», con alfa)."""
	for material in list(head.data.materials):
		if material is None:
			continue
		material.use_nodes = True
		tree = material.node_tree
		for node in list(tree.nodes):
			if node.type != "OUTPUT_MATERIAL":
				tree.nodes.remove(node)
		output = next(n for n in tree.nodes if n.type == "OUTPUT_MATERIAL")
		bsdf = tree.nodes.new("ShaderNodeBsdfPrincipled")
		tree.links.new(bsdf.outputs["BSDF"], output.inputs["Surface"])
		if material.name.endswith("_head"):
			color = _load_texture(folder, "head_color", 2048)
			texture = tree.nodes.new("ShaderNodeTexImage")
			texture.image = _rocketbox_skin(color)
			tree.links.new(texture.outputs["Color"], bsdf.inputs["Base Color"])
			normal_image = _load_texture(folder, "head_normal", TEXTURE_SIZE, non_color=True)
			if normal_image is not None:
				normal_texture = tree.nodes.new("ShaderNodeTexImage")
				normal_texture.image = normal_image
				normal_map = tree.nodes.new("ShaderNodeNormalMap")
				tree.links.new(normal_texture.outputs["Color"], normal_map.inputs["Color"])
				tree.links.new(normal_map.outputs["Normal"], bsdf.inputs["Normal"])
			bsdf.inputs["Roughness"].default_value = 0.6
			material.name = "rb.head"
		else:
			hair = _load_texture(folder, "opacity_color", TEXTURE_SIZE)
			if hair is not None:
				texture = tree.nodes.new("ShaderNodeTexImage")
				texture.image = hair
				tree.links.new(texture.outputs["Color"], bsdf.inputs["Base Color"])
				tree.links.new(texture.outputs["Alpha"], bsdf.inputs["Alpha"])
			material.name = "rb.hair"


def _skin_width(points, z, band=0.012):
	xs = [p.x for p in points if abs(p.z - z) < band]
	return max(xs) - min(xs)


def graft_rocketbox_head(spec, rocketbox_dir, armature, proxy, extras, body):
	folder = os.path.join(rocketbox_dir, spec["head"])
	fbx = os.path.join(folder, spec["head"] + ".fbx")
	if not os.path.isfile(fbx):
		raise SystemExit("Falta la cabeza de Rocketbox %s (ADR-0017)" % fbx)
	before = set(bpy.data.objects)
	bpy.ops.import_scene.fbx(filepath=fbx)
	imported = [o for o in bpy.data.objects if o not in before]
	source = next(o for o in imported if o.type == "MESH")
	skeleton = next(o for o in imported if o.type == "ARMATURE")
	bones = {b.name: skeleton.matrix_world @ b.head_local for b in skeleton.data.bones}
	data = source.data.copy()
	data.transform(source.matrix_world)
	head = bpy.data.objects.new("head", data)
	bpy.context.scene.collection.objects.link(head)
	for obj in imported:
		bpy.data.objects.remove(obj)
	# Solo cabeza (material 1) y pelo (material 2); el cuerpo y la ropa
	# modernos (material 0) se descartan.
	mesh = bmesh.new()
	mesh.from_mesh(head.data)
	bmesh.ops.delete(mesh, geom=[f for f in mesh.faces if f.material_index == 0], context="FACES")
	mesh.to_mesh(head.data)
	mesh.free()
	_rocketbox_materials(head, folder)
	# Escala y posición: anchura de la cara y punto medio de los ojos.
	eyes = next(o for o in extras if o.name.endswith("low-poly"))
	mh_eye = sum((eyes.matrix_world @ v.co for v in eyes.data.vertices), Vector()) / len(eyes.data.vertices)
	rb_eye = (bones["Bip01 LEye"] + bones["Bip01 REye"]) * 0.5
	mh_skin = [body.points[i] for i in range(len(body.points)) if body.part_weight(i, ("Head",)) > 0.8]
	rb_skin = [head.data.vertices[i].co for p in head.data.polygons
		if head.data.materials[p.material_index].name == "rb.head" for i in p.vertices]
	scale = _skin_width(mh_skin, mh_eye.z) / _skin_width(rb_skin, rb_eye.z)
	head.data.transform(Matrix.Translation(mh_eye) @ Matrix.Scale(scale, 4) @ Matrix.Translation(-rb_eye))
	# Fuera la cabeza de MakeHuman (ojos, cejas, pestañas, pelo) y la piel del
	# cuerpo que la nueva cabeza tapa.
	for obj in extras:
		bpy.data.objects.remove(obj)
	tree = bvhtree.BVHTree.FromObject(head, bpy.context.evaluated_depsgraph_get())
	lowest = min(v.co.z for v in head.data.vertices)
	mesh = bmesh.new()
	mesh.from_mesh(proxy.data)
	covered = []
	for face in mesh.faces:
		center = face.calc_center_median()
		location, _normal, _index, distance = tree.find_nearest(center)
		if center.z > lowest + 0.012 and location is not None and distance < 0.03:
			covered.append(face)
	bmesh.ops.delete(mesh, geom=covered, context="FACES")
	mesh.to_mesh(proxy.data)
	mesh.free()
	# El borde inferior de la cabeza se pega a la superficie del cuerpo.
	mesh = bmesh.new()
	mesh.from_mesh(head.data)
	for vertex in mesh.verts:
		if vertex.is_boundary and vertex.co.z < lowest + 0.05:
			location, normal, _index, _distance = body.bvh.find_nearest(vertex.co)
			if location is not None:
				vertex.co = location + normal * 0.001
	mesh.to_mesh(head.data)
	mesh.free()
	# Pesos: la cabeza propiamente sigue al hueso «Head»; el cuello, al cuerpo.
	head_z = armature.data.bones["Head"].head_local.z
	groups = {}
	for vertex in head.data.vertices:
		weights = {"Head": 1.0} if vertex.co.z > head_z + 0.03 else body.nearest_weights(vertex.co)
		for bone, weight in weights.items():
			if weight < 0.01:
				continue
			if bone not in groups:
				groups[bone] = head.vertex_groups.new(name=bone)
			groups[bone].add([vertex.index], weight, "REPLACE")
	for polygon in head.data.polygons:
		polygon.use_smooth = True
	head.parent = armature
	modifier = head.modifiers.new("Armature", "ARMATURE")
	modifier.object = armature
	return head, tree, mh_eye.z


def build_headwear(spec, head, eye_z, armature):
	"""Cinta (llautu) o paño sobre la cabeza de Rocketbox: la propia superficie
	del cráneo separada unos milímetros, como la ropa sobre el cuerpo, para
	que se ajuste a esa cabeza y a su pelo pintado."""
	if not spec.get("headband") and not spec.get("head_cloth"):
		return None
	data = head.data
	data.calc_normals_split() if hasattr(data, "calc_normals_split") else None
	normals = [v.normal.copy() for v in data.vertices]
	scalp = [p for p in data.polygons if data.materials[p.material_index].name == "rb.head"]
	g = Garment()
	g.piece = TEXTILE_PIECES["headwear"]

	def cover(low, high, offset, color):
		mapping = {}
		for polygon in scalp:
			zs = [data.vertices[i].co.z for i in polygon.vertices]
			if min(zs) < low or (high is not None and max(zs) > high):
				continue
			# Solo la parte de arriba y de los lados: la cara queda libre.
			center = polygon.center
			if center.y < -0.02 and center.z < eye_z + 0.03:
				continue
			ids = []
			for i in polygon.vertices:
				if i not in mapping:
					mapping[i] = g.add_vertex(data.vertices[i].co + normals[i] * offset, {"Head": 1.0})
				ids.append(mapping[i])
			g.add_face(ids, _linear(color), [(0.0, 0.0), (0.05, 0.0), (0.05, 0.05), (0.0, 0.05)][:len(ids)])
		return mapping

	tree = bvhtree.BVHTree.FromObject(head, bpy.context.evaluated_depsgraph_get())

	def smooth_border(mapping, offset, passes=12):
		"""El borde sale en escalera (caras enteras): se alisa a lo largo del
		propio borde y se vuelve a apoyar sobre la cabeza."""
		created = set(mapping.values())
		edges = {}
		for face in g.faces:
			if not created.issuperset(face):
				continue
			for k, a in enumerate(face):
				b = face[(k + 1) % len(face)]
				key = (min(a, b), max(a, b))
				edges[key] = edges.get(key, 0) + 1
		border = {}
		for (a, b), n in edges.items():
			if n == 1:
				border.setdefault(a, []).append(b)
				border.setdefault(b, []).append(a)
		for _ in range(passes):
			moved = {}
			for i, others in border.items():
				if len(others) == 2:
					moved[i] = g.verts[i].lerp((g.verts[others[0]] + g.verts[others[1]]) * 0.5, 0.6)
			for i, point in moved.items():
				location, normal, _index, _distance = tree.find_nearest(point)
				g.verts[i] = location + normal * offset if location is not None else point

	if spec.get("head_cloth"):
		smooth_border(cover(eye_z + 0.02, None, 0.012, spec["head_cloth"]), 0.012)
	if spec.get("headband"):
		smooth_border(cover(eye_z + 0.028, eye_z + 0.065, 0.009, spec["headband"]), 0.009)
	if not g.faces:
		return None
	return g.to_object("headwear", bpy.context.scene.collection, armature)


def build_person(name, cmu_dir, rocketbox_dir):
	spec = PEOPLE[name]
	bpy.context.scene.render.fps = ANIM_FPS
	armature, proxy, extras = build_body(spec)
	tint_materials(proxy, extras)
	body = BodyInfo(proxy)
	clothes, dims = build_clothes(spec, body, armature, armature.data.bones)
	if spec.get("manto"):
		add_cape_bones(armature, dims, dims["back"])
	sewn = build_sewn_clothes(spec, body, armature, proxy, dims)
	# Una sola malla de ropa, como antes: mismo material y mismas capas.
	bpy.ops.object.select_all(action="DESELECT")
	for obj in [clothes] + sewn:
		obj.select_set(True)
	bpy.context.view_layer.objects.active = clothes
	bpy.ops.object.join()
	if spec.get("head"):
		head, _head_tree, eye_z = graft_rocketbox_head(spec, rocketbox_dir, armature, proxy, extras, body)
		build_headwear(spec, head, eye_z, armature)
	set_cloth_texture(paint_textile(spec, dims, seed=sum(ord(c) for c in name)))
	info = build_animations(armature, spec, cmu_dir)
	if spec.get("tool") == "chaquitaclla":
		build_tool(armature, info["work_beat"])
	# Ritmo del personaje para el juego (velocidad de cada ciclo, golpes de
	# trabajo), como propiedades del esqueleto que viajan en los «extras» del
	# glTF y Godot importa como metadatos. Las demás propiedades se quitan.
	for datablock in [o for o in bpy.context.scene.objects] + [o.data for o in bpy.context.scene.objects if o.data] + list(bpy.data.materials):
		for key in list(datablock.keys()):
			del datablock[key]
	for key, value in sorted(info.items()):
		armature["pch_" + key] = round(float(value), 4)
	# MakeHuman mira a −Y; el proyecto, a +Y (−Z de Godot).
	armature.rotation_euler = (0.0, 0.0, math.pi)
	for pose_bone in armature.pose.bones:
		pose_bone.rotation_quaternion = Quaternion()
		pose_bone.location = (0.0, 0.0, 0.0)
	return info


def reset_scene():
	bpy.ops.wm.read_factory_settings(use_empty=True)


def export(name, out_dir):
	path = os.path.join(out_dir, name + ".glb")
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
		export_extras=True,
		export_vertex_color="ACTIVE",
		# WebP: texturas mucho más ligeras que PNG, con alfa para el pelo.
		export_image_format="WEBP",
		export_image_quality=88,
		export_texcoords=True,
		export_normals=True,
	)
	return path


def _preview_cloth(material, textile):
	"""Material de vista previa que imita el shader del juego: columna de la
	prenda y repetición cada TEXTILE_PERIOD metros; color por vértice en las
	piezas lisas."""
	tree = material.node_tree
	for node in list(tree.nodes):
		tree.nodes.remove(node)
	output = tree.nodes.new("ShaderNodeOutputMaterial")
	bsdf = tree.nodes.new("ShaderNodeBsdfPrincipled")
	bsdf.inputs["Roughness"].default_value = 0.9
	tree.links.new(bsdf.outputs["BSDF"], output.inputs["Surface"])
	vertex = tree.nodes.new("ShaderNodeVertexColor")
	vertex.layer_name = "Color"
	if textile is None:
		tree.links.new(vertex.outputs["Color"], bsdf.inputs["Base Color"])
		return

	def node(kind, **values):
		created = tree.nodes.new(kind)
		for key, value in values.items():
			setattr(created, key, value)
		return created

	def math(operation, a, b=None):
		created = node("ShaderNodeMath", operation=operation)
		for index, value in enumerate((a, b)):
			if value is None:
				continue
			if isinstance(value, float):
				created.inputs[index].default_value = value
			else:
				tree.links.new(value, created.inputs[index])
		return created.outputs[0]

	cloth_uv = node("ShaderNodeUVMap", uv_map="Cloth")
	surface_uv = node("ShaderNodeUVMap", uv_map="Surface")
	cloth_xyz = node("ShaderNodeSeparateXYZ")
	surface_xyz = node("ShaderNodeSeparateXYZ")
	tree.links.new(cloth_uv.outputs["UV"], cloth_xyz.inputs[0])
	tree.links.new(surface_uv.outputs["UV"], surface_xyz.inputs[0])
	repeat = math("FRACT", math("DIVIDE", cloth_xyz.outputs["X"], TEXTILE_PERIOD))
	column = math("SUBTRACT", math("ROUND", surface_xyz.outputs["Y"]), 1.0)
	u = math("DIVIDE", math("ADD", column, repeat), float(TEXTILE_COLUMNS))
	v = math("DIVIDE", cloth_xyz.outputs["Y"], TEXTILE_HEIGHT)
	combine = node("ShaderNodeCombineXYZ")
	tree.links.new(u, combine.inputs[0])
	tree.links.new(v, combine.inputs[1])
	texture = node("ShaderNodeTexImage")
	texture.image = textile
	texture.interpolation = "Closest"
	tree.links.new(combine.outputs[0], texture.inputs["Vector"])
	use_textile = math("GREATER_THAN", surface_xyz.outputs["Y"], 0.5)
	mix = node("ShaderNodeMix", data_type="RGBA")
	tree.links.new(use_textile, mix.inputs["Factor"])
	tree.links.new(vertex.outputs["Color"], mix.inputs[6])
	tree.links.new(texture.outputs["Color"], mix.inputs[7])
	tree.links.new(mix.outputs[2], bsdf.inputs["Base Color"])


def render_preview(name, preview_dir, pose=""):
	"""Vista de frente (+Y) y de cara, opcionalmente en un instante de una
	animación («walk:0.3»)."""
	scene = bpy.context.scene
	armature = next(o for o in scene.objects if o.type == "ARMATURE")
	suffix = ""
	if pose:
		anim_name, _, second = pose.partition(":")
		for track in armature.animation_data.nla_tracks:
			track.mute = track.name != anim_name
		scene.frame_set(1 + int(round(float(second or "0") * ANIM_FPS)))
		suffix = "_" + anim_name
	else:
		for track in armature.animation_data.nla_tracks:
			track.mute = True
		scene.frame_set(1)
	cam = bpy.data.objects.new("PreviewCamera", bpy.data.cameras.new("PreviewCamera"))
	scene.collection.objects.link(cam)
	scene.camera = cam
	cam.data.lens = 55
	sun = bpy.data.objects.new("PreviewSun", bpy.data.lights.new("PreviewSun", "SUN"))
	sun.data.energy = 3.0
	sun.rotation_euler = (math.radians(50), 0.0, math.radians(200))
	scene.collection.objects.link(sun)
	world = bpy.data.worlds.new("PreviewWorld")
	world.use_nodes = True
	world.node_tree.nodes["Background"].inputs["Color"].default_value = (0.6, 0.64, 0.7, 1.0)
	world.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.7
	scene.world = world
	cloth = bpy.data.materials.get(CLOTH_MATERIAL)
	textile = None
	if cloth is not None and cloth.node_tree is not None:
		textile = next((n.image for n in cloth.node_tree.nodes if n.type == "TEX_IMAGE"), None)
		_preview_cloth(cloth, textile)
	scene.render.engine = "BLENDER_EEVEE"
	scene.render.resolution_x = 640
	scene.render.resolution_y = 900
	for view, location, target in (("", (0.9, 3.6, 1.15), (0.0, 0.0, 0.85)), ("_cara", (0.25, 0.95, 1.5), (0.0, 0.0, 1.45))):
		cam.location = location
		cam.rotation_euler = (Vector(target) - Vector(location)).to_track_quat("-Z", "Y").to_euler()
		scene.render.filepath = os.path.join(preview_dir, name + suffix + view + ".png")
		bpy.ops.render.render(write_still=True)
	if cloth is not None:
		if textile is not None:
			set_cloth_texture(textile)
	if not os.environ.get("PCH_KEEP_PREVIEW"):
		for obj in (cam, sun):
			bpy.data.objects.remove(obj)


def main():
	argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
	parser = argparse.ArgumentParser(description="Genera los personajes realistas de la campaña 01 (ADR-0016).")
	parser.add_argument("--cmu", required=True, help="directorio con las tomas ASF/AMC de CMU")
	parser.add_argument("--rocketbox", required=True, help="directorio con las carpetas de los avatares de Rocketbox")
	parser.add_argument("--out", default=DEFAULT_OUT)
	parser.add_argument("--preview", default="")
	parser.add_argument("--pose", default="")
	parser.add_argument("--no-export", action="store_true")
	parser.add_argument("names", nargs="*")
	args = parser.parse_args(argv)
	names = args.names if args.names else list(PEOPLE.keys())
	os.makedirs(args.out, exist_ok=True)
	for name in names:
		if name not in PEOPLE:
			raise SystemExit("Personaje desconocido: %s" % name)
		reset_scene()
		info = build_person(name, args.cmu, args.rocketbox)
		meshes = [o for o in bpy.context.scene.objects if o.type == "MESH"]
		tris = sum(sum(len(p.vertices) - 2 for p in o.data.polygons) for o in meshes)
		print("PERSONAJE %s | triángulos %d | mallas %d | %s" % (
			name, tris, len(meshes), " ".join("%s=%.3f" % (k, v) for k, v in sorted(info.items()))))
		if args.preview:
			os.makedirs(args.preview, exist_ok=True)
			render_preview(name, args.preview, args.pose)
		if not args.no_export:
			export(name, args.out)


main()
