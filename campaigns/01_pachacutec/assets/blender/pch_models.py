"""Generador de los modelos de la campaña 01 (alcance del vertical slice, §7).

Construye cada modelo con la API de Blender (bpy/bmesh), sin addons ni archivos
.blend, y lo exporta a glTF binario en `assets/models/`. Todo es determinista:
la misma versión del script produce los mismos archivos.

Uso (desde la raíz del repositorio):

    blender --background --factory-startup \
        --python campaigns/01_pachacutec/assets/blender/pch_models.py -- \
        [--out DIR] [--preview DIR] [nombre ...]

Sin nombres genera todos. `--preview` guarda además un render PNG de cada
modelo para revisarlo sin abrir Blender.

Convenciones (alcance §7 y §7.1):
- 1 unidad = 1 metro, transformaciones aplicadas, origen en la base.
- El frente mira hacia +Y en Blender, que el exportador convierte en −Z de
  Godot, el eje que apunta `look_at`.
- Las mallas cuyo nombre termina en `-convcolonly` las convierte Godot en
  colisión convexa al importar y no se dibujan.

Los modelos son reconstrucciones (R) según las fichas del registro histórico
(PCH-004, 007, 009, 010, 011, 012, 013, 017, 018, 019 y 020); ninguna forma concreta está documentada como
hecho.
"""

import argparse
import math
import os
import random
import sys

import bmesh
import bpy
from mathutils import Matrix, Vector

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DEFAULT_OUT = os.path.normpath(os.path.join(SCRIPT_DIR, "..", "models"))

# Paleta (color base sRGB, rugosidad). Colores planos: sin texturas.
PALETTE = {
	"stone_a": ((0.50, 0.47, 0.42), 0.95),
	"stone_b": ((0.42, 0.40, 0.36), 0.95),
	"stone_c": ((0.58, 0.54, 0.47), 0.95),
	"stone_warm": ((0.55, 0.46, 0.37), 0.95),
	"mud": ((0.47, 0.36, 0.26), 1.0),
	"mud_dark": ((0.30, 0.23, 0.17), 1.0),
	"thatch_a": ((0.74, 0.63, 0.38), 1.0),
	"thatch_b": ((0.64, 0.53, 0.30), 1.0),
	"thatch_c": ((0.54, 0.44, 0.24), 1.0),
	"wood": ((0.42, 0.26, 0.14), 0.8),
	"wood_light": ((0.60, 0.43, 0.26), 0.8),
	"incision": ((0.17, 0.10, 0.06), 0.9),
	"chicha": ((0.78, 0.62, 0.32), 0.4),
	"shell": ((0.86, 0.80, 0.68), 0.5),
	"shell_mottle": ((0.62, 0.45, 0.30), 0.5),
	"shell_lip": ((0.93, 0.64, 0.52), 0.35),
	"ceramic": ((0.62, 0.33, 0.20), 0.8),
	"maize": ((0.86, 0.70, 0.26), 0.7),
	"coca": ((0.30, 0.42, 0.18), 0.8),
	"rope": ((0.62, 0.55, 0.40), 1.0),
	"wool_red": ((0.60, 0.13, 0.10), 0.9),
	"wool_ochre": ((0.80, 0.56, 0.18), 0.9),
	"wool_dark": ((0.16, 0.12, 0.12), 0.9),
	"wool_cream": ((0.86, 0.80, 0.66), 0.9),
	"wool_green": ((0.22, 0.36, 0.26), 0.9),
	"wool_warp": ((0.62, 0.54, 0.42), 0.9),
	"clay_buff": ((0.78, 0.64, 0.47), 0.8),
	"clay_red": ((0.58, 0.2, 0.12), 0.8),
	"clay_black": ((0.13, 0.1, 0.08), 0.8),
	"clay_inside": ((0.25, 0.17, 0.12), 0.9),
	"ichu_base": ((0.52, 0.50, 0.30), 1.0),
	"ichu_tip": ((0.80, 0.70, 0.44), 1.0),
	"quenua_bark": ((0.50, 0.26, 0.17), 0.9),
	"quenua_peel": ((0.70, 0.46, 0.33), 0.9),
	"quenua_leaf": ((0.22, 0.31, 0.18), 0.9),
	"quenua_leaf_light": ((0.31, 0.40, 0.23), 0.9),
	"skin": ((0.55, 0.37, 0.26), 0.7),
	"hair": ((0.07, 0.05, 0.05), 0.8),
	"eye": ((0.05, 0.04, 0.04), 0.5),
	"sole": ((0.30, 0.24, 0.16), 1.0),
	"copper": ((0.74, 0.46, 0.26), 0.45),
	"wool_brown": ((0.43, 0.30, 0.20), 0.9),
	"wool_blue": ((0.20, 0.24, 0.36), 0.9),
	"wool_grey": ((0.52, 0.48, 0.42), 0.9),
}


def srgb_to_linear(value):
	if value <= 0.04045:
		return value / 12.92
	return ((value + 0.055) / 1.055) ** 2.4


# Los modelos se exportan sin material: el importador glTF de Godot crea
# entonces uno propio que usa el color por vértice (COLOR_0) como albedo, y
# cada modelo se dibuja con una sola llamada. Con un material propio, Godot
# ignora el color por vértice.


def linear_color(name):
	color, _roughness = PALETTE[name]
	return [srgb_to_linear(c) for c in color] + [1.0]


class MeshBuilder:
	"""Acumula geometría en un bmesh y la vuelca en un objeto. Cada cara lleva
	el color de su entrada de la paleta como color por vértice. Con
	[double_sided], cada cara se duplica del revés (hojas finas de la
	vegetación), porque sin material propio no hay dibujo a dos caras."""

	def __init__(self, double_sided=False):
		self.bm = bmesh.new()
		self.materials = []
		self.double_sided = double_sided

	def mat_index(self, name):
		if name not in self.materials:
			self.materials.append(name)
		return self.materials.index(name)

	def face(self, points, mat_name):
		verts = [self.bm.verts.new(p) for p in points]
		new_face = self.bm.faces.new(verts)
		new_face.material_index = self.mat_index(mat_name)
		if self.double_sided:
			back = [self.bm.verts.new(p) for p in reversed(points)]
			self.bm.faces.new(back).material_index = new_face.material_index
		return new_face

	def box(self, center, size, mat_name, rotation=None):
		"""Caja de [size] centrada en [center]; [rotation] es una Matrix 3x3."""
		hx, hy, hz = size[0] * 0.5, size[1] * 0.5, size[2] * 0.5
		corners = [
			Vector((-hx, -hy, -hz)), Vector((hx, -hy, -hz)), Vector((hx, hy, -hz)), Vector((-hx, hy, -hz)),
			Vector((-hx, -hy, hz)), Vector((hx, -hy, hz)), Vector((hx, hy, hz)), Vector((-hx, hy, hz)),
		]
		c = Vector(center)
		if rotation is not None:
			corners = [rotation @ v for v in corners]
		verts = [self.bm.verts.new(c + v) for v in corners]
		index = self.mat_index(mat_name)
		for ids in ((0, 3, 2, 1), (4, 5, 6, 7), (0, 1, 5, 4), (1, 2, 6, 5), (2, 3, 7, 6), (3, 0, 4, 7)):
			new_face = self.bm.faces.new([verts[i] for i in ids])
			new_face.material_index = index

	def prism(self, outline, thickness, mat_name, frame):
		"""Extruye un polígono 2D (u, v) [thickness] a lo largo de la normal del
		marco. [frame] = (origen, eje_u, eje_v, normal); la cara frontal queda en
		origen + normal * thickness."""
		origin, axis_u, axis_v, normal = frame
		index = self.mat_index(mat_name)
		back = [self.bm.verts.new(origin + axis_u * u + axis_v * v) for u, v in outline]
		front = [self.bm.verts.new(origin + axis_u * u + axis_v * v + normal * thickness) for u, v in outline]
		count = len(outline)
		faces = [self.bm.faces.new(list(reversed(back))), self.bm.faces.new(front)]
		for i in range(count):
			j = (i + 1) % count
			faces.append(self.bm.faces.new([back[i], back[j], front[j], front[i]]))
		for new_face in faces:
			new_face.material_index = index

	def lathe(self, profile, segments, mat_fn, axis_frame=None, cap_bottom=True, cap_top=False, radial_fn=None):
		"""Sólido de revolución. [profile] = [(radio, altura), ...] de abajo a
		arriba. [mat_fn](segmento, anillo) devuelve el material de cada cara.
		[radial_fn](segmento, anillo) multiplica el radio (relieves).
		[axis_frame] = Matrix 4x4 que coloca el eje Z local."""
		frame = axis_frame if axis_frame is not None else Matrix.Identity(4)
		rings = []
		for ring_index, (radius, height) in enumerate(profile):
			ring = []
			for s in range(segments):
				angle = 2.0 * math.pi * s / segments
				scale = radial_fn(s, ring_index) if radial_fn is not None else 1.0
				local = Vector((math.cos(angle) * radius * scale, math.sin(angle) * radius * scale, height))
				ring.append(self.bm.verts.new(frame @ local))
			rings.append(ring)
		for r in range(len(rings) - 1):
			for s in range(segments):
				t = (s + 1) % segments
				new_face = self.bm.faces.new([rings[r][s], rings[r][t], rings[r + 1][t], rings[r + 1][s]])
				new_face.material_index = self.mat_index(mat_fn(s, r))
		if cap_bottom and profile[0][0] > 0.0:
			new_face = self.bm.faces.new(list(reversed(rings[0])))
			new_face.material_index = self.mat_index(mat_fn(0, 0))
		if cap_top and profile[-1][0] > 0.0:
			new_face = self.bm.faces.new(rings[-1])
			new_face.material_index = self.mat_index(mat_fn(0, len(rings) - 2))

	def tube(self, points, radii, segments, mat_fn):
		"""Tubo por una polilínea 3D con radio variable; anillos perpendiculares
		al tramo. [mat_fn](anillo) da el material de cada tramo."""
		rings = []
		for i, point in enumerate(points):
			if i == 0:
				direction = (points[1] - points[0]).normalized()
			elif i == len(points) - 1:
				direction = (points[i] - points[i - 1]).normalized()
			else:
				direction = (points[i + 1] - points[i - 1]).normalized()
			helper = Vector((0.0, 0.0, 1.0)) if abs(direction.z) < 0.9 else Vector((1.0, 0.0, 0.0))
			axis_a = direction.cross(helper).normalized()
			axis_b = direction.cross(axis_a).normalized()
			ring = []
			for k in range(segments):
				angle = 2.0 * math.pi * k / segments
				offset = (axis_a * math.cos(angle) + axis_b * math.sin(angle)) * radii[i]
				ring.append(self.bm.verts.new(point + offset))
			rings.append(ring)
		for r in range(len(rings) - 1):
			index = self.mat_index(mat_fn(r))
			for k in range(segments):
				t = (k + 1) % segments
				new_face = self.bm.faces.new([rings[r][k], rings[r][t], rings[r + 1][t], rings[r + 1][k]])
				new_face.material_index = index
		cap = self.bm.faces.new(list(reversed(rings[-1])))
		cap.material_index = self.mat_index(mat_fn(len(rings) - 2))

	def blob(self, center, radii, mat_name, rng, rows=4, segments=7):
		"""Mata irregular (follaje): esfera baja con el radio alterado."""
		frame = Matrix.Translation(center) @ Matrix.Diagonal((radii[0], radii[1], radii[2], 1.0))
		profile = []
		for r in range(rows + 1):
			phi = math.pi * r / rows
			profile.append((math.sin(phi) + (0.0 if r in (0, rows) else 0.0), -math.cos(phi)))
		noise = [[rng.uniform(0.82, 1.12) for _ in range(segments)] for _ in range(rows + 1)]
		self.lathe(profile, segments, lambda k, r: mat_name, axis_frame=frame, cap_bottom=False, cap_top=False,
			radial_fn=lambda k, r: noise[r][k])

	def to_object(self, name, collection):
		mesh = bpy.data.meshes.new(name)
		if not self.double_sided:
			bmesh.ops.remove_doubles(self.bm, verts=self.bm.verts, dist=0.0)
		self.bm.normal_update()
		self.bm.to_mesh(mesh)
		self.bm.free()
		colors = mesh.color_attributes.new("Color", "FLOAT_COLOR", "CORNER")
		palette = [linear_color(mat_name) for mat_name in self.materials]
		for polygon in mesh.polygons:
			rgba = palette[polygon.material_index] if palette else [1.0, 1.0, 1.0, 1.0]
			for loop_index in polygon.loop_indices:
				colors.data[loop_index].color = rgba
			polygon.material_index = 0
			polygon.use_smooth = False
		mesh.color_attributes.active_color = colors
		obj = bpy.data.objects.new(name, mesh)
		collection.objects.link(obj)
		return obj


def rot_z(angle):
	return Matrix.Rotation(angle, 3, "Z")


def rot_x(angle):
	return Matrix.Rotation(angle, 3, "X")


def collision_box(collection, name, center, size):
	"""Malla de colisión convexa que Godot no dibuja (sufijo -convcolonly)."""
	builder = MeshBuilder()
	builder.box(center, size, "mud")
	obj = builder.to_object(name + "-convcolonly", collection)
	obj.data.materials.clear()
	return obj


# --- Muros de pirka -------------------------------------------------------

def stone_course(builder, rng, length, height, top_fn, outer_frame, skip_fn, stone_mats):
	"""Cara exterior de un muro de piedra de campo con mortero de barro.

	[outer_frame] = (origen, eje_u, eje_v, normal hacia fuera). [top_fn](u)
	da la altura máxima de las piedras en u (hastiales). [skip_fn](u0, u1, v0,
	v1) excluye huecos (puertas)."""
	origin, axis_u, axis_v, normal = outer_frame
	v = 0.0
	while v < height - 0.08:
		course = rng.uniform(0.2, 0.32)
		if v + course > height:
			course = height - v
		u = -rng.uniform(0.0, 0.25)
		while u < length:
			stone_len = rng.uniform(0.28, 0.6)
			u0 = max(u, 0.0)
			u1 = min(u + stone_len, length)
			u = u + stone_len
			if u1 - u0 < 0.12:
				continue
			v1 = v + course
			if v1 > min(top_fn(u0), top_fn(u1)) + 0.02:
				continue
			if skip_fn(u0, u1, v, v1):
				continue
			gap = 0.025
			depth = rng.uniform(0.14, 0.2)
			bulge = rng.uniform(0.0, 0.04)
			center = (origin + axis_u * ((u0 + u1) * 0.5) + axis_v * (v + course * 0.5)
				+ normal * (bulge - depth * 0.5 + 0.02))
			size_u = (u1 - u0) - gap
			size_v = course - gap
			basis = Matrix((axis_u, axis_v, normal)).transposed()
			jitter = Matrix.Rotation(rng.uniform(-0.04, 0.04), 3, "Z") @ Matrix.Rotation(rng.uniform(-0.03, 0.03), 3, "X")
			builder.box(center, (size_u, size_v, depth), rng.choice(stone_mats), basis @ jitter)
		v += course


def build_house(name, rng, width, depth, wall_height, ridge_height, door_center, stone_mats, thatch_mats):
	"""Vivienda rectangular de pirka con techo de ichu a dos aguas.

	Planta [width] (X) × [depth] (Y); la puerta trapezoidal se abre en el muro
	frontal (+Y), bajo el alero; los hastiales de piedra cierran los lados X."""
	collection = bpy.context.scene.collection
	thickness = 0.45
	door_bottom = 0.9
	door_top = 0.7
	door_height = 1.7
	hw, hd = width * 0.5, depth * 0.5

	core = MeshBuilder()
	stones = MeshBuilder()

	def door_skip(u0, u1, v0, v1):
		if v0 > door_height + 0.05:
			return False
		half = door_bottom * 0.5 + 0.06
		return u1 > door_center - half + hw and u0 < door_center + half + hw

	def flat_top(_u):
		return wall_height

	slope = (ridge_height - wall_height) / hd

	def gable_top(u):
		return ridge_height - abs(u - hd) * slope

	# Núcleo de barro (cara interior enlucida) con la muesca de la puerta.
	c = door_center + hw
	front_outline = [
		(0.0, 0.0), (c - door_bottom * 0.5, 0.0), (c - door_top * 0.5, door_height),
		(c + door_top * 0.5, door_height), (c + door_bottom * 0.5, 0.0), (width, 0.0),
		(width, wall_height), (0.0, wall_height),
	]
	inset = 0.03
	core_thickness = thickness - inset
	x_axis, y_axis, z_axis = Vector((1, 0, 0)), Vector((0, 1, 0)), Vector((0, 0, 1))
	# Frontal (+Y): marco con normal hacia dentro (−Y) desde la cara exterior.
	core.prism(front_outline, core_thickness, "mud",
		(Vector((-hw, hd - inset, 0.0)), x_axis, z_axis, -y_axis))
	core.prism([(0.0, 0.0), (width, 0.0), (width, wall_height), (0.0, wall_height)], core_thickness, "mud",
		(Vector((-hw, -hd + inset, 0.0)), x_axis, z_axis, y_axis))
	gable_outline = [(thickness, 0.0), (depth - thickness, 0.0), (depth - thickness, gable_top(depth - thickness)),
		(hd, ridge_height), (thickness, gable_top(thickness))]
	for side in (-1.0, 1.0):
		core.prism(gable_outline, core_thickness, "mud",
			(Vector((side * (hw - inset), -hd, 0.0)), y_axis, z_axis, Vector((-side, 0, 0))))
	# Dintel de piedra sobre la puerta.
	stones.box((door_center, hd - thickness * 0.5 + 0.01, door_height + 0.08),
		(door_top + 0.5, thickness + 0.04, 0.16), stone_mats[0])
	# Suelo interior de tierra apisonada.
	core.box((0.0, 0.0, 0.01), (width - 2 * thickness, depth - 2 * thickness, 0.02), "mud_dark")

	# Piedras de la cara exterior.
	stone_course(stones, rng, width, wall_height, flat_top,
		(Vector((-hw, hd, 0.0)), x_axis, z_axis, y_axis), door_skip, stone_mats)
	stone_course(stones, rng, width, wall_height, flat_top,
		(Vector((hw, -hd, 0.0)), -x_axis, z_axis, -y_axis), lambda *a: False, stone_mats)
	stone_course(stones, rng, depth, ridge_height, gable_top,
		(Vector((hw, hd, 0.0)), -y_axis, z_axis, x_axis), lambda *a: False, stone_mats)
	stone_course(stones, rng, depth, ridge_height, gable_top,
		(Vector((-hw, -hd, 0.0)), y_axis, z_axis, -x_axis), lambda *a: False, stone_mats)

	# Techo de ichu: cada faldón en hiladas solapadas, de la cumbrera al alero.
	roof = MeshBuilder()
	overhang = 0.45
	roof_thickness = 0.22
	angle = math.atan2(ridge_height - wall_height, hd)
	run = (hd + overhang) / math.cos(angle)
	tiers = 6
	roof_len = width + 0.6
	for side in (-1.0, 1.0):
		rotation = rot_x(-side * angle)
		down = rotation @ Vector((0.0, side, 0.0))
		normal = rotation @ Vector((0.0, 0.0, 1.0))
		for tier in range(tiers):
			t0 = run * tier / tiers
			t1 = run * (tier + 1) / tiers
			# Cada hilada se apoya sobre la siguiente: escalón visible de ichu.
			lift = (tiers - tier) * 0.03
			top = Vector((0.0, 0.0, ridge_height + roof_thickness * 0.5)) + normal * lift
			center = top + down * ((t0 + t1) * 0.5)
			roof.box(center, (roof_len, t1 - t0 + 0.1, roof_thickness), thatch_mats[tier % 2], rotation)
			# Borde inferior de la hilada en mechones de largo desigual.
			edge = top + down * t1 + normal * (roof_thickness * 0.15)
			x = -roof_len * 0.5
			while x < roof_len * 0.5 - 0.05:
				tuft = min(rng.uniform(0.18, 0.34), roof_len * 0.5 - x)
				drop = rng.uniform(0.06, 0.2) if tier == tiers - 1 else rng.uniform(0.03, 0.1)
				mat_name = thatch_mats[2] if rng.random() < 0.5 else thatch_mats[(tier + 1) % 2]
				roof.box(edge + Vector((x + tuft * 0.5, 0.0, 0.0)) + down * (drop * 0.5),
					(tuft - 0.02, drop + 0.08, roof_thickness * 0.7), mat_name, rotation)
				x += tuft
	# Caballete de la cumbrera.
	roof.lathe([(0.16, -roof_len * 0.5), (0.16, roof_len * 0.5)], 8, lambda s, r: thatch_mats[2],
		axis_frame=Matrix.Translation((0.0, 0.0, ridge_height + roof_thickness + 0.02)) @ Matrix.Rotation(math.pi / 2, 4, "Y"),
		cap_bottom=True, cap_top=True)
	# Amarres de cuerda sobre el caballete.
	for i in range(5):
		x = -roof_len * 0.4 + i * roof_len * 0.2
		roof.box((x, 0.0, ridge_height + roof_thickness + 0.02), (0.05, 0.36, 0.36), "rope")

	core.to_object(name + "_walls", collection)
	stones.to_object(name + "_stones", collection)
	roof.to_object(name + "_roof", collection)
	collision_box(collection, name + "_body", (0.0, 0.0, wall_height * 0.5), (width, depth, wall_height))


def build_house_a(rng):
	build_house("pch_house_a", rng, 6.0, 5.0, 2.4, 4.0, 0.0,
		["stone_a", "stone_b", "stone_c"], ["thatch_a", "thatch_b", "thatch_c"])


def build_house_b(rng):
	build_house("pch_house_b", rng, 5.6, 4.6, 2.2, 3.7, -1.1,
		["stone_warm", "stone_a", "stone_b"], ["thatch_b", "thatch_a", "thatch_c"])


# --- Objetos --------------------------------------------------------------

def build_quero(rng):
	"""Quero de madera con decoración incisa geométrica en bandas (PCH-004)."""
	collection = bpy.context.scene.collection
	builder = MeshBuilder()
	height = 0.22
	rows = 22
	segments = 32
	wall = 0.008
	outer = []
	for r in range(rows + 1):
		t = r / rows
		# Base plana, cintura leve y boca abocinada.
		radius = 0.066 + 0.024 * t * t - 0.006 * math.sin(math.pi * t)
		outer.append((radius, height * t))

	def incised(s, r):
		if r in (1, 2, rows - 3, rows - 2):
			return "incision"
		if 6 <= r <= 15:
			# Banda de zigzag: triángulos alternos entre dos líneas.
			band = r - 6
			phase = (s % 8) / 8.0
			tri = abs(phase * 2.0 - 1.0) * 9.0
			if r in (5, 16) or abs(band - tri) < 0.9:
				return "incision"
		if r in (5, 16):
			return "incision"
		return "wood"

	builder.lathe(outer, segments, incised, cap_bottom=True)
	inner = [(radius - wall, z) for radius, z in reversed(outer)]
	inner = [p for p in inner if p[1] >= 0.02]
	# Borde: une el anillo exterior superior con el interior.
	rim_profile = [outer[-1], (outer[-1][0] - wall, height)]
	builder.lathe(rim_profile, segments, lambda s, r: "wood", cap_bottom=False)
	builder.lathe(list(reversed(inner)), segments, lambda s, r: "wood_light", cap_bottom=True)
	# Superficie de la chicha.
	surface = 0.16
	builder.lathe([(0.0, surface), (0.0815 - wall, surface)], segments, lambda s, r: "chicha", cap_bottom=False)
	builder.to_object("pch_quero", collection)


def build_pututu(rng):
	"""Pututu de caracola Strombus sobre una piedra plana (PCH-009).

	Espira corta con nódulos en el hombro, última vuelta que se estrecha
	hacia el canal y labio abocinado hacia +Y; la embocadura está en la punta
	de la espira."""
	collection = bpy.context.scene.collection
	stone = MeshBuilder()
	stone_h = 0.05
	stone.lathe([(0.2, 0.0), (0.22, 0.015), (0.21, stone_h - 0.01), (0.18, stone_h)], 9,
		lambda s, r: "stone_b", cap_bottom=True, cap_top=True,
		radial_fn=lambda s, r: 1.0 + 0.12 * math.sin(s * 2.3 + 0.7))
	stone.to_object("pch_pututu_stone", collection)

	shell = MeshBuilder()
	length = 0.4
	segments = 16
	rows = 20
	profile = []
	for r in range(rows + 1):
		t = r / rows
		# t=0 punta de la espira (embocadura), t=1 canal sifonal.
		if t <= 0.25:
			whorl = math.floor(t / 0.0625)
			radius = 0.016 + 0.09 * (t / 0.25) + 0.008 * (t / 0.0625 - whorl)
		elif t <= 0.35:
			radius = 0.13
		else:
			radius = 0.13 * (1.0 - (t - 0.35) / 0.65) ** 1.1 + 0.018
		profile.append((radius, length * t))

	def lip_weight(s):
		angle = 2.0 * math.pi * s / segments
		return max(0.0, math.cos(angle - math.pi / 2.0)) ** 4

	def lip_rows(r):
		return 6 <= r <= 17

	def shape(s, r):
		scale = 1.0
		if lip_rows(r):
			scale += 1.5 * lip_weight(s) * math.sin(math.pi * (r - 6) / 11.0)
		if r in (5, 6) and s % 3 == 0 and lip_weight(s) < 0.2:
			scale += 0.16
		return scale

	def shell_mat(s, r):
		if lip_rows(r) and lip_weight(s) > 0.3:
			return "shell_lip"
		if r > 2 and (s + int(2.5 * math.sin(r * 0.9))) % 4 == 0:
			return "shell_mottle"
		return "shell"

	# Eje tendido sobre la piedra, a lo largo de X; ligeramente aplanado.
	axis_z = stone_h + 0.11
	lie = (Matrix.Translation((-length * 0.5, 0.0, axis_z))
		@ Matrix.Rotation(math.pi / 2, 4, "Y") @ Matrix.Scale(0.85, 4, (1, 0, 0)))
	shell.lathe(profile, segments, shell_mat, axis_frame=lie, cap_bottom=True, cap_top=True, radial_fn=shape)
	# Embocadura en la punta de la espira.
	shell.lathe([(0.011, 0.0), (0.011, 0.01)], 8, lambda s, r: "shell_mottle",
		axis_frame=Matrix.Translation((-length * 0.5 + 0.002, 0.0, axis_z)) @ Matrix.Rotation(-math.pi / 2, 4, "Y"),
		cap_bottom=True, cap_top=True)
	shell.to_object("pch_pututu_shell", collection)


def build_offering_shrine(rng):
	"""Adoratorio bajo de piedra con ofrenda de maíz y coca (PCH-012)."""
	collection = bpy.context.scene.collection
	core = MeshBuilder()
	stones = MeshBuilder()
	size = 0.7
	height = 0.24
	half = size * 0.5
	core.box((0.0, 0.0, height * 0.5), (size - 0.04, size - 0.04, height), "mud")
	x_axis, y_axis, z_axis = Vector((1, 0, 0)), Vector((0, 1, 0)), Vector((0, 0, 1))
	mats = ["stone_a", "stone_b", "stone_warm"]
	frames = [
		(Vector((-half, half, 0.0)), x_axis, z_axis, y_axis),
		(Vector((half, -half, 0.0)), -x_axis, z_axis, -y_axis),
		(Vector((half, half, 0.0)), -y_axis, z_axis, x_axis),
		(Vector((-half, -half, 0.0)), y_axis, z_axis, -x_axis),
	]
	for frame in frames:
		v = 0.0
		for course in (0.13, 0.11):
			u = -rng.uniform(0.0, 0.1)
			while u < size:
				stone_len = rng.uniform(0.16, 0.3)
				u0, u1 = max(u, 0.0), min(u + stone_len, size)
				u += stone_len
				if u1 - u0 < 0.06:
					continue
				origin, axis_u, axis_v, normal = frame
				center = origin + axis_u * ((u0 + u1) * 0.5) + axis_v * (v + course * 0.5) + normal * rng.uniform(-0.035, -0.015)
				basis = Matrix((axis_u, axis_v, normal)).transposed()
				stones.box(center, (u1 - u0 - 0.015, course - 0.015, 0.08), rng.choice(mats), basis)
			v += course
	# Losa superior irregular.
	# Losa casi cuadrada que cubre la plataforma, con esquinas desiguales.
	slab = []
	for i in range(8):
		angle = 2 * math.pi * i / 8 + math.pi / 4
		reach = (half + 0.01) * (math.sqrt(2.0) if i % 2 == 0 else 1.0) * rng.uniform(0.94, 1.0)
		if i % 2 == 0:
			reach -= 0.06
		slab.append((math.cos(angle) * reach, math.sin(angle) * reach))
	stones.prism(slab, 0.06, "stone_c", (Vector((0.0, 0.0, height)), Vector((1, 0, 0)), Vector((0, 1, 0)), Vector((0, 0, 1))))
	top = height + 0.06
	# Plato de cerámica con maíz.
	stones.lathe([(0.06, 0.0), (0.1, 0.03), (0.095, 0.035), (0.055, 0.012)], 14,
		lambda s, r: "ceramic", axis_frame=Matrix.Translation((-0.05, 0.05, top)), cap_bottom=True, cap_top=True)
	for i in range(14):
		a = rng.uniform(0.0, 2 * math.pi)
		r = rng.uniform(0.0, 0.055)
		stones.box((math.cos(a) * r - 0.05, math.sin(a) * r + 0.05, top + 0.03), (0.014, 0.012, 0.01), "maize", rot_z(a))
	# Mazorca y hojas de coca extendidas.
	stones.lathe([(0.0, 0.0), (0.022, 0.02), (0.024, 0.09), (0.0, 0.13)], 8, lambda s, r: "maize",
		axis_frame=Matrix.Translation((0.06, -0.08, top + 0.022)) @ Matrix.Rotation(math.pi / 2, 4, "Y") @ Matrix.Rotation(0.4, 4, "X"),
		cap_bottom=False)
	for i in range(11):
		a = rng.uniform(0.0, 2 * math.pi)
		r = rng.uniform(0.02, 0.13)
		leaf = [(0.0, 0.0), (0.018, 0.012), (0.04, 0.0), (0.018, -0.012)]
		heading = rng.uniform(0.0, 2 * math.pi)
		axis_u = Vector((math.cos(heading), math.sin(heading), 0.0))
		axis_v = Vector((-math.sin(heading), math.cos(heading), 0.0))
		origin = Vector((0.1 + math.cos(a) * r * 0.6, 0.08 + math.sin(a) * r * 0.6, top + 0.001 + i * 0.0006))
		stones.prism(leaf, 0.002, "coca", (origin, axis_u, axis_v, Vector((0, 0, 1))))
	core.to_object("pch_offering_core", collection)
	stones.to_object("pch_offering_shrine", collection)


def build_loom(rng):
	"""Telar de cintura tendido desde una estaca, con tejido a medio hacer
	(PCH-010). El extremo de la tejedora está en el origen y el telar se
	extiende hacia −Y (detrás, al exportar: +Z de Godot)."""
	collection = bpy.context.scene.collection
	builder = MeshBuilder()
	length = 1.5
	width = 0.42
	near = Vector((0.0, 0.0, 0.16))
	far = Vector((0.0, -length, 0.62))
	direction = (far - near).normalized()
	side = Vector((1.0, 0.0, 0.0))
	up = direction.cross(side).normalized()
	if up.z < 0:
		up = -up
	# Estaca clavada y cuerda hasta la barra del fondo.
	post = Vector((0.0, -length - 0.35, 0.0))
	builder.lathe([(0.035, 0.0), (0.03, 0.78), (0.02, 0.82)], 7, lambda s, r: "wood",
		axis_frame=Matrix.Translation(post), cap_top=True)
	rope_mid = (post + Vector((0, 0, 0.7)) + far) * 0.5
	rope_dir = (far - (post + Vector((0, 0, 0.7))))
	builder.box(rope_mid, (0.015, rope_dir.length, 0.015), "rope",
		Matrix.Rotation(math.atan2(rope_dir.z, rope_dir.y), 3, "X"))
	# Barras del telar: fondo, cerca (cintura), lizo, separadora y espada.
	def bar(center, radius, length_x, mat_name):
		builder.lathe([(radius, -length_x * 0.5), (radius, length_x * 0.5)], 7, lambda s, r: mat_name,
			axis_frame=Matrix.Translation(center) @ Matrix.Rotation(math.pi / 2, 4, "Y"), cap_top=True)

	bar(far, 0.018, width + 0.16, "wood")
	bar(near, 0.018, width + 0.16, "wood")
	woven = 0.55
	heddle = near + direction * (woven + 0.12) + up * 0.02
	bar(heddle, 0.008, width + 0.06, "wood_light")
	bar(near + direction * (woven + 0.32) + up * 0.015, 0.014, width + 0.08, "wood_light")
	sword = near + direction * (woven + 0.05) + up * 0.015
	basis = Matrix((side, direction, up)).transposed()
	builder.box(sword, (width + 0.12, 0.05, 0.008), "wood_light", basis)
	# Urdimbre sin tejer: hilos crudos en franjas.
	threads = 12
	start = near + direction * woven
	span = (far - start).length
	for i in range(threads):
		x = -width * 0.5 + width * (i + 0.5) / threads
		mid = start + direction * (span * 0.5) + side * x
		builder.box(mid, (0.01, span, 0.004), "wool_warp" if i % 4 else "wool_red", basis)
	# Tejido terminado: rombos escalonados sobre fondo rojo, con bandas.
	cols = 21
	rows = 26
	cell_w = width / cols
	cell_h = woven / rows
	for row in range(rows):
		for col in range(cols):
			cx = abs(col - cols // 2)
			cy = abs((row % 13) - 6)
			mat_name = "wool_red"
			if row % 13 in (0, 12) or col in (1, cols - 2):
				mat_name = "wool_dark"
			elif cx + cy in (4, 5):
				mat_name = "wool_ochre"
			elif cx + cy <= 1:
				mat_name = "wool_cream"
			elif cx + cy == 7:
				mat_name = "wool_green"
			center = near + direction * (cell_h * (row + 0.5)) + side * (-width * 0.5 + cell_w * (col + 0.5))
			builder.box(center, (cell_w, cell_h, 0.006), mat_name, basis)
	# Bulto de tela donde descansa el extremo de la cintura.
	for layer, (mat_name, lift) in enumerate((("wool_cream", 0.0), ("wool_dark", 0.045), ("wool_cream", 0.06), ("wool_red", 0.105))):
		thickness_layer = 0.045 if layer % 2 == 0 else 0.015
		builder.box((0.0, 0.05, lift + thickness_layer * 0.5), (0.5 - layer * 0.03, 0.26 - layer * 0.02, thickness_layer), mat_name)
	builder.to_object("pch_loom", collection)


# --- Vegetación (PCH-013) -------------------------------------------------

def build_ichu(rng, blades, height):
	"""Mata de ichu: hojas finas que nacen juntas y se arquean hacia fuera.
	Material de doble cara (sin descarte de caras traseras)."""
	collection = bpy.context.scene.collection
	builder = MeshBuilder(double_sided=True)
	for _ in range(blades):
		heading = rng.uniform(0.0, 2.0 * math.pi)
		lean = rng.uniform(0.15, 0.75)
		blade_h = height * rng.uniform(0.65, 1.0)
		root = Vector((math.cos(heading), math.sin(heading), 0.0)) * rng.uniform(0.02, 0.09)
		outward = Vector((math.cos(heading), math.sin(heading), 0.0))
		side = Vector((-math.sin(heading), math.cos(heading), 0.0))
		width = rng.uniform(0.018, 0.03)
		spine = []
		for t in (0.0, 0.08, 0.55, 1.0):
			spread = lean * blade_h * (0.3 * t + 0.45 * t * t)
			spine.append(root + outward * spread + Vector((0.0, 0.0, blade_h * (t - 0.22 * lean * t * t))))
		for k in range(2):
			w0 = width * (1.0 - k / 3.0)
			w1 = width * (1.0 - (k + 1) / 3.0)
			builder.face([spine[k] - side * w0, spine[k] + side * w0, spine[k + 1] + side * w1, spine[k + 1] - side * w1],
				"ichu_base" if k == 0 else "ichu_tip")
		w2 = width / 3.0
		builder.face([spine[2] - side * w2, spine[2] + side * w2, spine[3]], "ichu_tip")
	builder.to_object("ichu", collection)


def build_ichu_a(rng):
	build_ichu(rng, 20, 0.7)


def build_ichu_b(rng):
	build_ichu(rng, 15, 0.5)


def build_quenua(rng):
	"""Queñua (Polylepis): varios troncos retorcidos de corteza rojiza que se
	descascara y follaje menudo en matas oscuras. Un solo objeto para que el
	juego lo repita con MultiMesh."""
	collection = bpy.context.scene.collection
	builder = MeshBuilder()
	stems = rng.randint(3, 4)
	tips = []

	def bark(ring):
		return "quenua_peel" if (ring + rng.randint(0, 1)) % 3 == 0 else "quenua_bark"

	for stem in range(stems):
		heading = 2.0 * math.pi * stem / stems + rng.uniform(-0.4, 0.4)
		out = Vector((math.cos(heading), math.sin(heading), 0.0))
		height = rng.uniform(2.6, 3.6)
		points = []
		radii = []
		for k in range(6):
			t = k / 5.0
			wobble = Vector((rng.uniform(-0.12, 0.12), rng.uniform(-0.12, 0.12), 0.0)) * (0.0 if k == 0 else 1.0)
			points.append(out * (0.12 + 1.1 * t ** 1.5) + Vector((0.0, 0.0, height * t)) + wobble)
			radii.append(0.15 * (1.0 - 0.7 * t) + 0.025)
		points[0].z = 0.06
		builder.tube(points, radii, 6, bark)
		tips.append(points[-1])
		# Dos ramas laterales desde la mitad superior del tronco.
		for branch in range(2):
			start_index = rng.randint(2, 4)
			start = points[start_index]
			b_heading = heading + rng.uniform(-1.3, 1.3)
			b_out = Vector((math.cos(b_heading), math.sin(b_heading), 0.0))
			length = rng.uniform(0.6, 1.1)
			mid = start + b_out * length * 0.5 + Vector((0.0, 0.0, length * 0.35))
			end = start + b_out * length + Vector((0.0, 0.0, length * 0.55))
			builder.tube([start, mid, end], [radii[start_index] * 0.6, radii[start_index] * 0.4, 0.02], 5, bark)
			tips.append(end)
	for tip in tips:
		for _ in range(2):
			offset = Vector((rng.uniform(-0.35, 0.35), rng.uniform(-0.35, 0.35), rng.uniform(-0.1, 0.2)))
			size = rng.uniform(0.3, 0.48)
			builder.blob(tip + offset, (size, size * rng.uniform(0.8, 1.1), size * 0.5),
				"quenua_leaf" if rng.random() < 0.6 else "quenua_leaf_light", rng, rows=3, segments=6)
	builder.to_object("quenua", collection)


# --- Props de las viviendas (PCH-019 y PCH-020) ----------------------------

def build_jar(rng):
	"""Cántaro de dos asas inspirado en la cerámica Killke del Cusco (PCH-019):
	cuerpo globular, cuello cóncavo, borde algo abierto, fondo crema con bandas
	rojas bordeadas de negro y triángulos negros colgando del borde. La forma y
	el tamaño de uso doméstico son reconstrucción (R)."""
	collection = bpy.context.scene.collection
	b = MeshBuilder()
	points = [(0.0, 0.05), (0.04, 0.1), (0.13, 0.15), (0.22, 0.13), (0.27, 0.075), (0.31, 0.068), (0.35, 0.085)]
	profile = [(r, z) for r, z in _garment_profile([(z, r) for z, r in points], 18)]
	segments = 16

	def jar_mat(seg, ring):
		if ring in (9, 12):
			return "clay_black"
		if ring in (10, 11):
			return "clay_red"
		if ring >= 15 and (seg % 4 == 0 or (seg % 4 == 1 and ring >= 16)):
			return "clay_black"
		return "clay_buff"

	b.lathe(profile, segments, jar_mat, cap_bottom=True)
	# Boca oscura.
	b.lathe([(0.0, 0.335), (0.08, 0.335)], segments, lambda s_, r: "clay_inside", cap_bottom=False)
	# Asas a los lados del cuerpo.
	for side in (-1.0, 1.0):
		points3 = [Vector((side * 0.14, 0.0, 0.18)), Vector((side * 0.185, 0.0, 0.15)), Vector((side * 0.15, 0.0, 0.11))]
		b.tube(points3, [0.016, 0.016, 0.016], 5, lambda r: "clay_buff")
	b.to_object("pch_prop_jar", collection)


def build_firewood(rng):
	"""Haz de leña de queñua apilada junto a la casa (PCH-020, R a partir de los
	usos de Polylepis en PCH-013)."""
	collection = bpy.context.scene.collection
	b = MeshBuilder()
	rows = [(4, 0.0), (3, 1.0), (2, 2.0)]
	for count, row in rows:
		for i in range(count):
			radius = rng.uniform(0.035, 0.05)
			length = rng.uniform(0.8, 1.0)
			y = (i - (count - 1) * 0.5) * 0.1
			z = radius + row * 0.085
			x0 = -length * 0.5 + rng.uniform(-0.05, 0.05)
			bark = "quenua_bark" if rng.random() < 0.6 else "quenua_peel"
			b.tube([Vector((x0, y, z)), Vector((x0 + length * 0.5, y + rng.uniform(-0.02, 0.02), z)), Vector((x0 + length, y, z))],
				[radius, radius * 0.95, radius * 0.85], 6, lambda r, m=bark: m)
	# Dos amarres de cuerda alrededor del haz.
	for x in (-0.25, 0.25):
		loop = [Vector((x, math.cos(2 * math.pi * i / 10) * 0.22, 0.13 + math.sin(2 * math.pi * i / 10) * 0.15)) for i in range(11)]
		b.tube(loop, [0.012] * len(loop), 5, lambda r: "rope")
	b.to_object("pch_prop_firewood", collection)


# --- Personajes (PCH-011, 017 y 018) ---------------------------------------

def _garment_profile(points, rows):
	"""Interpola [(altura, radio), ...] en [rows] anillos de abajo arriba."""
	profile = []
	low, high = points[0][0], points[-1][0]
	for r in range(rows + 1):
		z = low + (high - low) * r / rows
		for i in range(len(points) - 1):
			z0, r0 = points[i]
			z1, r1 = points[i + 1]
			if z0 <= z <= z1:
				t = 0.0 if z1 == z0 else (z - z0) / (z1 - z0)
				profile.append((r0 + (r1 - r0) * t, z))
				break
	return profile


def build_person(rng, spec):
	"""Persona estática de pie, mirando hacia +Y, con los pies en el origen.

	[spec] describe la ropa: "garment" ("unku" para el hombre, "anacu" para la
	mujer), colores de prenda y de franjas, manto, lliclla, tocado, chuspa,
	herramienta o bulto. Sin rig ni animación (alcance v3.3)."""
	collection = bpy.context.scene.collection
	b = MeshBuilder()
	k = spec.get("scale", 1.0)

	def v(x, y, z):
		return Vector((x * k, y * k, z * k))

	# Piernas y ojotas: un objeto por pierna («LegL», «LegR») con el origen
	# en lo alto de la pierna, para que el juego las balancee al caminar.
	leg_top = 0.55 if spec["garment"] == "unku" else 0.3
	for side, leg_name in ((1.0, "LegL"), (-1.0, "LegR")):
		leg = MeshBuilder()
		x = 0.09 * side
		leg.tube([v(x, 0.0, leg_top), v(x, 0.005, 0.3), v(x, 0.0, 0.07)],
			[0.06 * k, 0.05 * k, 0.04 * k], 6, lambda r: "skin")
		leg.box(v(x, 0.05, 0.035), (0.085 * k, 0.2 * k, 0.05 * k), "skin")
		leg.box(v(x, 0.05, 0.008), (0.1 * k, 0.23 * k, 0.016 * k), "sole")
		leg.box(v(x, 0.05, 0.06), (0.012 * k, 0.12 * k, 0.012 * k), "sole")
		leg_obj = leg.to_object(leg_name, collection)
		pivot = v(x, 0.0, leg_top)
		leg_obj.data.transform(Matrix.Translation(-pivot))
		leg_obj.location = pivot

	# Prenda principal como sólido de revolución achatado en profundidad.
	rows = 16
	body = spec["body"]
	band = spec.get("band")
	band_style = spec.get("band_style", "stripe")
	if spec["garment"] == "unku":
		points = [(0.48, 0.25), (0.9, 0.215), (1.12, 0.215), (1.3, 0.22), (1.37, 0.17), (1.41, 0.07)]
		band_rows = {1, 2, 9}
	else:
		points = [(0.06, 0.2), (0.5, 0.21), (0.88, 0.18), (1.18, 0.2), (1.3, 0.19), (1.36, 0.15), (1.4, 0.07)]
		band_rows = {7, 8}
	profile = [(radius * k, z * k) for radius, z in _garment_profile(points, rows)]

	def garment_mat(seg, ring):
		if band is not None and ring in band_rows:
			if band_style == "tocapu" and (seg + ring) % 2 == 0:
				return spec.get("band_alt", "wool_cream")
			return band
		return body

	b.lathe(profile, 14, garment_mat, axis_frame=Matrix.Diagonal((1.0, 0.62, 1.0, 1.0)), cap_bottom=True, cap_top=True)

	# Lliclla: manta sobre los hombros con franjas, sujeta con un tupu.
	if spec.get("lliclla"):
		shawl = _garment_profile([(1.02, 0.215), (1.2, 0.225), (1.33, 0.205), (1.38, 0.16)], 6)
		stripe = spec.get("lliclla_stripe", "wool_red")
		b.lathe([(radius * k, z * k) for radius, z in shawl], 14,
			lambda seg, ring: stripe if ring in (0, 3) else spec["lliclla"],
			axis_frame=Matrix.Diagonal((1.0, 0.66, 1.0, 1.0)), cap_bottom=False, cap_top=False)
		b.lathe([(0.0, 0.0), (0.025 * k, 0.004 * k), (0.0, 0.008 * k)], 8, lambda seg, ring: "copper",
			axis_frame=Matrix.Translation(v(0.0, 0.15, 1.28)) @ Matrix.Rotation(-math.pi / 2, 4, "X"), cap_bottom=False)

	# Manto (yacolla) a la espalda, anudado al pecho.
	if spec.get("manto"):
		b.box(v(0.0, -0.15, 1.02), (0.46 * k, 0.022 * k, 0.64 * k), spec["manto"], rot_x(0.08))
		b.box(v(0.0, -0.11, 1.355), (0.42 * k, 0.1 * k, 0.03 * k), spec["manto"])
		b.blob(v(0.0, 0.15, 1.33), (0.04 * k, 0.03 * k, 0.035 * k), spec["manto"], rng, rows=3, segments=6)

	# Brazos y manos: un objeto por brazo («ArmL» del lado +X, como «LegL»),
	# con el origen en el hombro, para que el juego los balancee al caminar.
	pose = spec.get("arms", (0.0, 0.0))
	for index, side in enumerate((-1.0, 1.0)):
		forward = pose[index]
		arm = MeshBuilder()
		shoulder = v(0.235 * side, 0.0, 1.31)
		elbow = v(0.27 * side, 0.03 + forward * 0.5, 1.05)
		wrist = v(0.26 * side, 0.06 + forward, 0.83 + forward * 0.25)
		arm.tube([shoulder, elbow, wrist], [0.05 * k, 0.042 * k, 0.034 * k], 6, lambda r: "skin")
		arm.blob(wrist + v(0.0, 0.01, -0.04), (0.035 * k, 0.03 * k, 0.05 * k), "skin", rng, rows=3, segments=6)
		arm_obj = arm.to_object("ArmL" if side > 0.0 else "ArmR", collection)
		arm_obj.data.transform(Matrix.Translation(-shoulder))
		arm_obj.location = shoulder

	# Cuello y cabeza: pelo detrás y encima, cara al frente.
	b.tube([v(0.0, 0.0, 1.38), v(0.0, 0.005, 1.45)], [0.045 * k, 0.045 * k], 6, lambda r: "skin")
	head_rows = 6
	head_profile = []
	for r in range(head_rows + 1):
		phi = math.pi * r / head_rows
		head_profile.append((math.sin(phi) * 0.1 * k, (1.53 - math.cos(phi) * 0.115) * k))

	def head_mat(seg, ring):
		angle = 2.0 * math.pi * (seg + 0.5) / 10
		facing = math.cos(angle - math.pi / 2.0)
		if ring >= head_rows - 2:
			return "hair"
		if facing > 0.35 and ring >= 1:
			return "skin"
		if ring == 0:
			return "skin"
		return "hair"

	b.lathe(head_profile, 10, head_mat, axis_frame=Matrix.Diagonal((1.0, 1.08, 1.0, 1.0)), cap_bottom=False)
	b.box(v(0.0, 0.112, 1.51), (0.03 * k, 0.03 * k, 0.05 * k), "skin")
	for side in (-1.0, 1.0):
		b.box(v(0.035 * side, 0.1, 1.55), (0.022 * k, 0.012 * k, 0.012 * k), "eye")
	if spec.get("braids"):
		for side in (-1.0, 1.0):
			b.tube([v(0.06 * side, -0.07, 1.5), v(0.07 * side, -0.11, 1.32), v(0.06 * side, -0.13, 1.12)],
				[0.022 * k, 0.02 * k, 0.014 * k], 5, lambda r: "hair")
	if spec.get("headband"):
		b.lathe([(0.104 * k, 1.565 * k), (0.104 * k, 1.6 * k)], 12, lambda seg, ring: spec["headband"],
			axis_frame=Matrix.Diagonal((1.0, 1.08, 1.0, 1.0)), cap_bottom=False)
	if spec.get("head_cloth"):
		b.lathe([(0.108 * k, 1.56 * k), (0.11 * k, 1.6 * k), (0.07 * k, 1.66 * k)], 12,
			lambda seg, ring: spec["head_cloth"], axis_frame=Matrix.Diagonal((1.0, 1.1, 1.0, 1.0)), cap_bottom=False, cap_top=True)

	# Chuspa (bolsa) al costado con su correa.
	if spec.get("chuspa"):
		b.box(v(-0.24, 0.04, 0.82), (0.05 * k, 0.15 * k, 0.16 * k), spec["chuspa"])
		b.box(v(0.0, 0.0, 1.1), (0.56 * k, 0.29 * k, 0.025 * k), spec["chuspa"], rot_z(0.0) @ Matrix.Rotation(-0.9, 3, "Y"))

	# Chaquitaclla (arado de pie) apoyada en el suelo junto a la mano derecha.
	if spec.get("tool") == "chaquitaclla":
		base = v(0.36, 0.1, 0.0)
		b.tube([base, base + v(0.0, -0.03, 1.55)], [0.02 * k, 0.018 * k], 6, lambda r: "wood")
		b.box(base + v(0.0, 0.0, 0.4), (0.03 * k, 0.16 * k, 0.025 * k), "wood_light")
		b.box(base + v(0.0, 0.02, 0.04), (0.04 * k, 0.07 * k, 0.08 * k), "wood_light")

	# Bulto de viaje atado a la espalda (q'ipi).
	if spec.get("bundle"):
		b.blob(v(0.0, -0.24, 1.05), (0.17 * k, 0.11 * k, 0.2 * k), spec["bundle"], rng, rows=4, segments=8)
		b.box(v(0.0, -0.05, 1.3), (0.44 * k, 0.33 * k, 0.025 * k), "rope", rot_x(0.5))

	b.to_object("person", collection)


PEOPLE = {
	# Habitantes comunes (PCH-018): fibra sin teñir y tintes de tierra.
	"pch_npc_weaver": dict(garment="anacu", scale=0.94, body="wool_brown", band="wool_red",
		lliclla="wool_cream", lliclla_stripe="wool_red", braids=True, arms=(0.18, 0.18)),
	"pch_npc_farmer": dict(garment="unku", body="wool_cream", band="wool_brown", manto="wool_brown",
		head_cloth="wool_red", chuspa="wool_ochre", tool="chaquitaclla", arms=(0.0, 0.1)),
	"pch_npc_villager": dict(garment="anacu", scale=0.94, body="wool_dark", band="wool_ochre", lliclla="wool_grey",
		lliclla_stripe="wool_green", braids=True),
	"pch_npc_commoner": dict(garment="unku", body="wool_grey", band="wool_dark", manto="wool_cream",
		chuspa="wool_red"),
	# Mensajero (PCH-011): ropa de viaje sin insignias, con su bulto.
	"pch_npc_messenger": dict(garment="unku", body="wool_brown", band="wool_dark", bundle="wool_cream",
		head_cloth="wool_grey", chuspa="wool_cream"),
	# Autoridades (PCH-017): distintivos discretos (franja ajedrezada, tocado, manto teñido).
	# La franja imita el t'oqapu, de alto rango: solo la llevan las autoridades.
	"pch_npc_curaca": dict(garment="unku", body="wool_cream", band="wool_red", band_style="tocapu",
		band_alt="wool_dark", manto="wool_red", headband="wool_ochre", chuspa="wool_blue"),
	"pch_npc_principal": dict(garment="unku", body="wool_ochre", band="wool_dark", band_style="tocapu",
		band_alt="wool_cream", manto="wool_blue", headband="wool_red"),
	"pch_npc_authority": dict(garment="unku", body="wool_cream", band="wool_dark", band_style="tocapu",
		band_alt="wool_red", manto="wool_brown", headband="wool_red"),
}


def _person_builder(name):
	return lambda rng: build_person(rng, PEOPLE[name])


MODELS = {
	"pch_house_a": build_house_a,
	"pch_house_b": build_house_b,
	"pch_quero": build_quero,
	"pch_pututu": build_pututu,
	"pch_offering_shrine": build_offering_shrine,
	"pch_loom": build_loom,
	"pch_prop_jar": build_jar,
	"pch_prop_firewood": build_firewood,
	"pch_ichu_a": build_ichu_a,
	"pch_ichu_b": build_ichu_b,
	"pch_quenua_a": build_quenua,
	"pch_quenua_b": build_quenua,
}
MODELS.update({name: _person_builder(name) for name in PEOPLE})


# --- Exportación y vista previa -----------------------------------------

def reset_scene():
	bpy.ops.wm.read_factory_settings(use_empty=True)


def scene_bounds():
	points = []
	for obj in bpy.context.scene.objects:
		if obj.type != "MESH" or obj.name.endswith("-convcolonly"):
			continue
		points.extend(obj.matrix_world @ Vector(corner) for corner in obj.bound_box)
	low = Vector((min(p.x for p in points), min(p.y for p in points), min(p.z for p in points)))
	high = Vector((max(p.x for p in points), max(p.y for p in points), max(p.z for p in points)))
	return low, high


def join_visible(name):
	"""Une en un solo objeto todas las mallas visibles del modelo (las de
	colisión se quedan aparte) para que Godot las dibuje con una llamada."""
	# Piernas y brazos de los personajes se quedan aparte: el juego los mueve.
	visible = [o for o in bpy.context.scene.objects
		if o.type == "MESH" and not o.name.endswith("-convcolonly") and not o.name.startswith(("Leg", "Arm"))]
	if len(visible) > 1:
		for obj in bpy.context.scene.objects:
			obj.select_set(obj in visible)
		bpy.context.view_layer.objects.active = visible[0]
		bpy.ops.object.join()
	joined = bpy.context.view_layer.objects.active if len(visible) > 1 else visible[0]
	joined.name = name
	joined.data.name = name
	bpy.context.view_layer.update()


def export(name, out_dir):
	path = os.path.join(out_dir, name + ".glb")
	bpy.ops.export_scene.gltf(
		filepath=path,
		export_format="GLB",
		export_yup=True,
		export_apply=True,
		export_animations=False,
		export_cameras=False,
		export_lights=False,
		export_extras=False,
		export_vertex_color="ACTIVE",
	)
	return path


def render_preview(name, preview_dir):
	"""Render de comprobación: vista de tres cuartos desde el frente (+Y)."""
	scene = bpy.context.scene
	low, high = scene_bounds()
	center = (low + high) * 0.5
	extent = max((high - low).length, 0.1)
	cam_data = bpy.data.cameras.new("PreviewCamera")
	cam_data.lens = 50
	cam = bpy.data.objects.new("PreviewCamera", cam_data)
	scene.collection.objects.link(cam)
	cam.location = center + Vector((0.9, 1.6, 0.9)).normalized() * extent * 1.45
	cam.rotation_euler = (center - cam.location).to_track_quat("-Z", "Y").to_euler()
	scene.camera = cam
	sun_data = bpy.data.lights.new("PreviewSun", "SUN")
	sun_data.energy = 3.5
	sun = bpy.data.objects.new("PreviewSun", sun_data)
	sun.rotation_euler = (math.radians(45), math.radians(10), math.radians(30))
	scene.collection.objects.link(sun)
	world = bpy.data.worlds.new("PreviewWorld")
	world.use_nodes = True
	world.node_tree.nodes["Background"].inputs["Color"].default_value = (0.55, 0.62, 0.7, 1.0)
	world.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.6
	scene.world = world
	# Material solo para el render: los modelos se exportan sin material.
	preview = bpy.data.materials.new("PreviewVertexColor")
	preview.use_nodes = True
	color_node = preview.node_tree.nodes.new("ShaderNodeVertexColor")
	color_node.layer_name = "Color"
	preview.node_tree.links.new(color_node.outputs["Color"], preview.node_tree.nodes["Principled BSDF"].inputs["Base Color"])
	for obj in scene.objects:
		if obj.name.endswith("-convcolonly"):
			obj.hide_render = True
		elif obj.type == "MESH" and not obj.data.materials:
			obj.data.materials.append(preview)
	scene.render.engine = "BLENDER_EEVEE"
	scene.render.resolution_x = 900
	scene.render.resolution_y = 700
	scene.render.filepath = os.path.join(preview_dir, name + ".png")
	bpy.ops.render.render(write_still=True)
	for obj in (cam, sun):
		bpy.data.objects.remove(obj)


def main():
	argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
	parser = argparse.ArgumentParser(description="Genera los modelos .glb de la campaña 01.")
	parser.add_argument("--out", default=DEFAULT_OUT)
	parser.add_argument("--preview", default="")
	parser.add_argument("names", nargs="*")
	args = parser.parse_args(argv)
	names = args.names if args.names else list(MODELS.keys())
	os.makedirs(args.out, exist_ok=True)
	if args.preview:
		os.makedirs(args.preview, exist_ok=True)
	for name in names:
		if name not in MODELS:
			raise SystemExit("Modelo desconocido: %s" % name)
		reset_scene()
		MODELS[name](random.Random(name))
		join_visible(name)
		low, high = scene_bounds()
		path = export(name, args.out)
		meshes = [o for o in bpy.context.scene.objects if o.type == "MESH"]
		tris = sum(len(p.vertices) - 2 for o in meshes for p in o.data.polygons)
		print("MODELO %s -> %s | min %s max %s | triángulos %d | mallas %d" % (
			name, path, tuple(round(c, 3) for c in low), tuple(round(c, 3) for c in high), tris, len(meshes)))
		if args.preview:
			render_preview(name, args.preview)


main()
