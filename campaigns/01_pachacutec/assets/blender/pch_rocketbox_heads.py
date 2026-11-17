"""Genera el set híbrido Rocketbox: cuerpo y ropa Quaternius + cabeza realista.

Conserva el cuerpo, la ropa, el esqueleto y los clips de Universal Base
Characters (Quaternius, CC0) y sustituye solo la cabeza, los ojos, las cejas y
el pelo por la cabeza Rocketbox del elenco anterior (MIT), escalada por la
anchura de la cara en la línea de ojos y apoyada en el cuello. La cabeza queda
rígida al hueso `Head`; los clips UAL se siguen añadiendo en Godot con
`QuaterniusClips`.

El set Quaternius **no se toca**: este script lee `pch_npc_<rol>_q.glb` y
escribe `pch_npc_<rol>_rb.glb`. Se activa con `--visual-set=rocketbox`.

Las cabezas Rocketbox son escaneos de personas reales teñidos; **no son
retratos andinos** ni una reconstrucción antropológica.

Uso:

    blender --background --factory-startup \
        --python campaigns/01_pachacutec/assets/blender/pch_rocketbox_heads.py -- \
        [--only pch_npc_sisa_rb] [--out DIR] [--preview DIR]
"""

import argparse
import os
import sys

import bmesh
import bpy
import numpy as np
from mathutils import Matrix, Vector

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, SCRIPT_DIR)
import pch_dressed as kit  # noqa: E402
REPO_DIR = os.path.normpath(os.path.join(SCRIPT_DIR, "..", "..", "..", ".."))
MODELS_DIR = os.path.normpath(os.path.join(SCRIPT_DIR, "..", "models"))
FACES_DIR = os.path.join(REPO_DIR, "shared_assets", "characters", "quaternius", "faces")
DEFAULT_PREVIEW = "/tmp/opencode/rocketbox_preview"

# Ojo: el Q body se recorta a 1,54 m; los donantes tienen el cuello por debajo.
Q_HEAD_CUT = 1.54
# La línea de ojos de MakeHuman queda unos 3 cm sobre el hueso Head.
DONOR_EYE_OFFSET = 0.030

SPECS = {
	"pch_npc_sisa_rb": dict(
		q="pch_npc_sisa_q.glb",
		donor="pch_npc_weaver.glb",
		skin="pch_face_sisa.png",
		hair=(0.055, 0.045, 0.038),
		notes="Sisa híbrida: cuerpo y ropa Q, cabeza Rocketbox",
	),
}


def load_scene(path):
	bpy.ops.wm.read_factory_settings(use_empty=True)
	bpy.ops.import_scene.gltf(filepath=path)


def remove_object(name):
	obj = bpy.data.objects.get(name)
	if obj is not None:
		bpy.data.objects.remove(obj, do_unlink=True)


def cut_above(obj, z):
	mesh = bmesh.new()
	mesh.from_mesh(obj.data)
	top = [vertex for vertex in mesh.verts if vertex.co.z > z]
	bmesh.ops.delete(mesh, geom=top, context="VERTS")
	mesh.to_mesh(obj.data)
	mesh.free()
	obj.data.update()


def face_width(obj, z, limit=0.14):
	band = [v.co.x for v in obj.data.vertices if abs(v.co.z - z) < 0.012 and abs(v.co.x) < limit]
	return (max(band) - min(band)) if band else 0.0


def nose_tip(obj, min_z=-10.0):
	points = [v.co.copy() for v in obj.data.vertices if v.co.z > min_z]
	return max(points, key=lambda point: -point.y)


def _skin_mask(rgb):
	r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
	return (r > 0.2) & (r < 0.95) & (r > g) & (g > b) & ((r - b) > 0.04)


def _linear(channel):
	return channel / 12.92 if channel <= 0.04045 else ((channel + 0.055) / 1.055) ** 2.4


def tint_hair(head, target):
	"""Pelo del donante a negro/marrón oscuro; conserva el alfa."""
	target = np.array([_linear(c) for c in target], dtype=np.float32)
	for material in head.data.materials:
		if material is None or not material.use_nodes or not material.name.startswith("rb.hair"):
			continue
		for node in material.node_tree.nodes:
			if node.type != "TEX_IMAGE" or node.image is None:
				continue
			image = node.image
			width, height = image.size
			pixels = np.empty(width * height * 4, dtype=np.float32)
			image.pixels.foreach_get(pixels)
			pixels = pixels.reshape(height, width, 4)
			mask = pixels[..., 3] > 0.2
			if not mask.any():
				continue
			mean = pixels[..., :3][mask].mean(axis=0)
			gain = target / np.maximum(mean, 1e-4)
			pixels[..., :3] = np.clip(pixels[..., :3] * gain, 0.0, 1.0)
			copy = bpy.data.images.new(image.name + "_dark", width, height, alpha=True)
			copy.pixels.foreach_set(pixels.ravel())
			copy.pack()
			node.image = copy


def simplify_head_material(head):
	"""Quita el mapa de normales de la cabeza: su autosombra marcaba demasiado
	la cara bajo el sol del juego y no se lee a la distancia de una escena."""
	for material in head.data.materials:
		if material is None or not material.use_nodes or not material.name.startswith("rb.head"):
			continue
		tree = material.node_tree
		for node in list(tree.nodes):
			if node.type == "NORMAL_MAP":
				tree.nodes.remove(node)
			elif node.type == "TEX_IMAGE" and node.image is not None and "normal" in node.image.name.lower():
				tree.nodes.remove(node)


def tint_head(head, target):
	"""Lleva la piel de la cabeza al tono de la cara Quaternius.

	Los tonos medidos con PIL están en sRGB; los píxeles de Blender son
	lineales, así que la conversión es obligatoria o la cara sale pálida.
	"""
	target = np.array([_linear(c) for c in target], dtype=np.float32)
	for material in head.data.materials:
		if material is None or not material.use_nodes or not material.name.startswith("rb.head"):
			continue
		for node in material.node_tree.nodes:
			if node.type != "TEX_IMAGE" or node.image is None:
				continue
			if node.image.colorspace_settings.name == "Non-Color" or "normal" in node.image.name.lower():
				continue
			image = node.image
			width, height = image.size
			pixels = np.empty(width * height * 4, dtype=np.float32)
			image.pixels.foreach_get(pixels)
			pixels = pixels.reshape(height, width, 4)
			mask = _skin_mask(pixels[..., :3])
			if not mask.any():
				continue
			mean = pixels[..., :3][mask].mean(axis=0)
			# Tinte suave: el promedio de la cara Q incluye labios y sombras;
			# aplicado entero deja la piel anaranjada.
			gain = 1.0 + (target / np.maximum(mean, 1e-4) - 1.0) * 0.45
			pixels[..., :3] = np.clip(pixels[..., :3] * gain, 0.0, 1.0)
			copy = bpy.data.images.new(image.name + "_qskin", width, height, alpha=True)
			copy.pixels.foreach_set(pixels.ravel())
			copy.pack()
			node.image = copy


def head_eye_z(donor_arm):
	bone = donor_arm.data.bones.get("Head") if donor_arm is not None else None
	return (donor_arm.matrix_world @ bone.head_local).z + DONOR_EYE_OFFSET if bone is not None else 1.2


def remove_headwear(clothes):
	"""Elimina la cinta/paño de cabeza Q del mesh de ropa."""
	if clothes is None:
		return
	surface = clothes.data.uv_layers.get("UVMap")
	if surface is None:
		return
	mesh = bmesh.new()
	mesh.from_mesh(clothes.data)
	mesh.faces.ensure_lookup_table()
	uv_layer = mesh.loops.layers.uv.get(surface.name)
	if uv_layer is None:
		mesh.free()
		return
	remove = []
	for face in mesh.faces:
		for loop in face.loops:
			if abs(loop[uv_layer].uv[1] - 5.0) < 0.1:
				remove.append(face)
				break
	if remove:
		bmesh.ops.delete(mesh, geom=remove, context="FACES")
	mesh.to_mesh(clothes.data)
	mesh.free()
	clothes.data.update()


def build(spec, name, out_dir):
	q_path = os.path.join(MODELS_DIR, spec["q"])
	donor_path = os.path.join(MODELS_DIR, spec["donor"])
	load_scene(q_path)
	q_arm = next((o for o in bpy.data.objects if o.type == "ARMATURE"), None)
	q_body = bpy.data.objects.get("Body")
	q_eyes = bpy.data.objects.get("Eyes")
	if q_arm is None or q_body is None or q_eyes is None:
		raise SystemExit("Modelo Q incompleto: %s" % q_path)
	q_eye = sum((q_eyes.matrix_world @ v.co for v in q_eyes.data.vertices), Vector()) / len(q_eyes.data.vertices)
	q_width = face_width(q_body, q_eye.z)
	q_nose = nose_tip(q_body, 1.55)
	cut_above(q_body, Q_HEAD_CUT)
	for name_to_remove in ("Hair", "Eyes", "Eyebrows"):
		remove_object(name_to_remove)
	# Donante: se conserva solo la cabeza.
	before = set(bpy.data.objects)
	bpy.ops.import_scene.gltf(filepath=donor_path)
	donor_head = bpy.data.objects.get("head")
	donor_arm = next((o for o in bpy.data.objects if o.type == "ARMATURE" and o not in before), None)
	if donor_head is None:
		raise SystemExit("El donante no trae cabeza: %s" % donor_path)
	donor_eye_z = head_eye_z(donor_arm)
	donor_width = face_width(donor_head, donor_eye_z)
	donor_nose = nose_tip(donor_head)
	for obj in list(bpy.data.objects):
		if obj not in before and obj not in (donor_head, donor_arm):
			if obj.type in {"MESH", "ARMATURE", "EMPTY"}:
				bpy.data.objects.remove(obj, do_unlink=True)
	scale = q_width / max(donor_width, 0.001)
	# La cabeza baja 1 cm: el cuello Rocketbox es más largo que el UBC y el
	# collar Q tapa el nacimiento sin dejar un cuello de jirafa.
	offset = Vector((0.0, q_nose.y - donor_nose.y * scale, q_eye.z - 0.010 - donor_eye_z * scale))
	donor_head.data.transform(Matrix.Translation(offset) @ Matrix.Scale(scale, 4))
	donor_head.data.update()
	tint_head(donor_head, TINTS[spec["skin"]])
	simplify_head_material(donor_head)
	if spec.get("hair"):
		tint_hair(donor_head, spec["hair"])
	# La cabeza sustituye a la Q y sigue rígida al hueso Head.
	donor_head.parent = q_arm
	donor_head.parent_type = "OBJECT"
	donor_head.matrix_parent_inverse = Matrix.Identity(4)
	donor_head.matrix_basis = Matrix.Identity(4)
	donor_head.vertex_groups.clear()
	donor_head.vertex_groups.new(name="Head").add(list(range(len(donor_head.data.vertices))), 1.0, "REPLACE")
	donor_head.modifiers.new("Armature", "ARMATURE").object = q_arm
	donor_head.name = "HeadRB"
	# La cinta Q está modelada para el cráneo UBC y no se adapta sin flotar.
	# En el híbrido se retira; el pelo del donante queda libre.
	remove_headwear(bpy.data.objects.get("Clothes"))
	if donor_arm is not None:
		bpy.data.objects.remove(donor_arm, do_unlink=True)
	q_arm["pch_note"] = spec.get("notes", "")
	q_arm["pch_head"] = "rocketbox"
	q_arm["pch_head_scale"] = round(scale, 4)
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
	print("EXPORTED", path, "scale", round(scale, 3), "eye", round(q_eye.z, 3),
		"head_z", round(min(v.co.z for v in donor_head.data.vertices), 3),
		round(max(v.co.z for v in donor_head.data.vertices), 3))
	return path


# Tonos medios de piel de las caras Quaternius (sRGB), medidos con el mismo
# criterio que la textura del cuerpo; la cabeza se lleva a ese tono.
TINTS = {
	"pch_face_sisa.png": (0.820, 0.680, 0.580),
	"pch_face_madre.png": (0.618, 0.394, 0.250),
	"pch_face_anciana.png": (0.557, 0.352, 0.224),
}


# --- Vista previa -----------------------------------------------------------

def _preview_shader(material, image):
	tree = material.node_tree
	tree.nodes.clear()
	output = tree.nodes.new("ShaderNodeOutputMaterial")
	bsdf = tree.nodes.new("ShaderNodeBsdfPrincipled")
	bsdf.inputs["Roughness"].default_value = 0.9
	texture = tree.nodes.new("ShaderNodeTexImage")
	texture.image = image
	tree.links.new(texture.outputs["Color"], bsdf.inputs["Base Color"])
	tree.links.new(bsdf.outputs["BSDF"], output.inputs["Surface"])


def _preview_textile(material):
	"""Mapea el atlas como el shader del juego: pieza en UV0.y, tejido en UV1."""
	image = next((node.image for node in material.node_tree.nodes
		if node.type == "TEX_IMAGE" and node.image), None)
	if image is None:
		return
	tree = material.node_tree
	tree.nodes.clear()
	output = tree.nodes.new("ShaderNodeOutputMaterial")
	bsdf = tree.nodes.new("ShaderNodeBsdfPrincipled")
	bsdf.inputs["Roughness"].default_value = 0.9
	uv0 = tree.nodes.new("ShaderNodeUVMap")
	uv0.uv_map = "UVMap"
	uv1 = tree.nodes.new("ShaderNodeUVMap")
	uv1.uv_map = "UVMap.001"
	sep0 = tree.nodes.new("ShaderNodeSeparateXYZ")
	sep1 = tree.nodes.new("ShaderNodeSeparateXYZ")
	tree.links.new(uv0.outputs["UV"], sep0.inputs["Vector"])
	tree.links.new(uv1.outputs["UV"], sep1.inputs["Vector"])
	piece = tree.nodes.new("ShaderNodeMath")
	piece.operation = "SUBTRACT"
	piece.inputs[1].default_value = 1.0
	tree.links.new(sep0.outputs["Y"], piece.inputs[0])
	warp = tree.nodes.new("ShaderNodeMath")
	warp.operation = "DIVIDE"
	warp.inputs[1].default_value = 0.3
	tree.links.new(sep1.outputs["X"], warp.inputs[0])
	warp2 = tree.nodes.new("ShaderNodeMath")
	warp2.operation = "FRACT"
	tree.links.new(warp.outputs[0], warp2.inputs[0])
	column = tree.nodes.new("ShaderNodeMath")
	column.operation = "ADD"
	tree.links.new(piece.outputs[0], column.inputs[0])
	tree.links.new(warp2.outputs[0], column.inputs[1])
	column2 = tree.nodes.new("ShaderNodeMath")
	column2.operation = "DIVIDE"
	column2.inputs[1].default_value = 6.0
	tree.links.new(column.outputs[0], column2.inputs[0])
	height = tree.nodes.new("ShaderNodeMath")
	height.operation = "DIVIDE"
	height.inputs[1].default_value = 2.0
	tree.links.new(sep1.outputs["Y"], height.inputs[0])
	height2 = tree.nodes.new("ShaderNodeMath")
	height2.operation = "FRACT"
	tree.links.new(height.outputs[0], height2.inputs[0])
	combine = tree.nodes.new("ShaderNodeCombineXYZ")
	tree.links.new(column2.outputs[0], combine.inputs["X"])
	tree.links.new(height2.outputs[0], combine.inputs["Y"])
	texture = tree.nodes.new("ShaderNodeTexImage")
	texture.image = image
	texture.interpolation = "Closest"
	tree.links.new(combine.outputs["Vector"], texture.inputs["Vector"])
	tree.links.new(texture.outputs["Color"], bsdf.inputs["Base Color"])
	tree.links.new(bsdf.outputs["BSDF"], output.inputs["Surface"])


def render_preview(path, spec, preview_dir):
	load_scene(path)
	for obj in bpy.data.objects:
		if obj.type != "MESH" or not obj.data.materials:
			continue
		if obj.name == "Body":
			face = os.path.join(FACES_DIR, spec["skin"])
			if os.path.isfile(face):
				image = bpy.data.images.load(face)
				for material in obj.data.materials:
					if material is not None:
						_preview_shader(material, image)
		for material in obj.data.materials:
			if material is not None and material.name.startswith("pch_cloth"):
				_preview_textile(material)
	height = 1.8
	bpy.ops.mesh.primitive_plane_add(size=6, location=(0, 0, 0))
	floor = bpy.context.active_object
	mat = bpy.data.materials.new("floor")
	mat.use_nodes = True
	bsdf = next(n for n in mat.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
	bsdf.inputs["Base Color"].default_value = (0.30, 0.24, 0.18, 1.0)
	floor.data.materials.append(mat)
	world = bpy.context.scene.world or bpy.data.worlds.new("World")
	bpy.context.scene.world = world
	world.use_nodes = True
	bg = world.node_tree.nodes.get("Background")
	bg.inputs[0].default_value = (0.36, 0.46, 0.62, 1.0)
	bg.inputs[1].default_value = 1.0
	for loc, energy, size in (((-1.7, 2.2, 2.6), 420, 1.8), ((1.8, 1.4, 2.0), 160, 1.2), ((0.2, -1.8, 2.4), 260, 1.5)):
		bpy.ops.object.light_add(type="AREA", location=loc)
		light = bpy.context.active_object
		light.data.energy = energy
		light.data.size = size
		direction = Vector((0.0, 0.0, 1.2)) - light.location
		light.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
	bpy.context.scene.render.engine = "CYCLES"
	bpy.context.scene.cycles.samples = 40
	bpy.context.scene.render.resolution_x = 900
	bpy.context.scene.render.resolution_y = 1100
	bpy.context.scene.view_settings.view_transform = "AgX"
	os.makedirs(preview_dir, exist_ok=True)
	for suffix, location, target, lens in (
		("front", (0.0, 3.6, 1.05), (0.0, 0.0, 0.95), 62),
		("face", (0.0, 0.9, 1.62), (0.0, 0.0, 1.62), 85),
		("three", (2.6, 2.8, 1.1), (0.0, 0.0, 0.95), 62),
	):
		bpy.ops.object.camera_add(location=location)
		camera = bpy.context.active_object
		camera.data.lens = lens
		direction = Vector(target) - camera.location
		camera.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
		bpy.context.scene.camera = camera
		bpy.context.scene.render.filepath = os.path.join(preview_dir, "rocketbox_%s.png" % suffix)
		bpy.ops.render.render(write_still=True)
	print("PREVIEW", preview_dir)


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("--out", default=MODELS_DIR)
	parser.add_argument("--preview", default="")
	parser.add_argument("--only", default="")
	args = parser.parse_args(sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else [])
	names = [args.only] if args.only else list(SPECS.keys())
	for name in names:
		if name not in SPECS:
			raise SystemExit("Personaje desconocido: %s" % name)
		spec = SPECS[name]
		path = build(spec, name, args.out)
		if args.preview:
			render_preview(path, spec, args.preview)
	print("ROCKETBOX_OK", len(names))


if __name__ == "__main__":
	main()
