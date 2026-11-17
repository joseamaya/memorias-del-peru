"""Mide los puntos UV de la cara sobre los cuerpos UBC.

`tools/build_face_textures.py` pinta en el espacio UV de la cabeza. Este script
imprime las coordenadas de los ojos, la boca, la nariz, la frente, el mentón y
las mejillas para que esos valores no se inventen: se copian de aquí.

Uso (desde la raíz del repositorio):

    blender --background --factory-startup \
        --python tools/export_face_uv.py -- \
        --body shared_assets/characters/quaternius/base

Requiere Blender; no se ejecuta en el juego ni en las pruebas de Godot.
"""

import argparse
import json
import os
import sys

import bpy
from mathutils import Vector
from mathutils.geometry import closest_point_on_tri


def uv_at(body: bpy.types.Object, point: Vector) -> tuple | None:
	"""UV interpolada del punto de la superficie más cercano a [param point]."""
	result = body.closest_point_on_mesh(point)
	if not result[0]:
		return None
	face_index = result[3]
	polygon = body.data.polygons[face_index]
	triangle = [body.data.vertices[index].co for index in polygon.vertices[:3]]
	closest = closest_point_on_tri(point, triangle[0], triangle[1], triangle[2])
	v0 = triangle[1] - triangle[0]
	v1 = triangle[2] - triangle[0]
	v2 = closest - triangle[0]
	d00 = v0.dot(v0)
	d01 = v0.dot(v1)
	d11 = v1.dot(v1)
	d20 = v2.dot(v0)
	d21 = v2.dot(v1)
	denominator = d00 * d11 - d01 * d01
	if abs(denominator) < 1e-12:
		return None
	v = (d11 * d20 - d01 * d21) / denominator
	w = (d00 * d21 - d01 * d20) / denominator
	u = 1.0 - v - w
	uvs = [body.data.uv_layers[0].data[li].uv for li in polygon.loop_indices[:3]]
	return (
		round(uvs[0].x * u + uvs[1].x * v + uvs[2].x * w, 4),
		round(uvs[0].y * u + uvs[1].y * v + uvs[2].y * w, 4),
	)


def measure(gender: str, base_dir: str) -> dict:
	bpy.ops.wm.read_factory_settings(use_empty=True)
	file_name = "Superhero_Male_FullBody.gltf" if gender == "male" else "Superhero_Female_FullBody.gltf"
	bpy.ops.import_scene.gltf(filepath=os.path.join(base_dir, file_name))
	body_name = "SuperHero_Male" if gender == "male" else "Superhero_Female"
	body = bpy.data.objects[body_name]
	eyes = bpy.data.objects["Eyes"]
	left = [vertex.co for vertex in eyes.data.vertices if vertex.co.x < 0.0]
	right = [vertex.co for vertex in eyes.data.vertices if vertex.co.x > 0.0]
	left_center = sum(left, Vector()) / len(left)
	right_center = sum(right, Vector()) / len(right)
	# Los rangos de cota son distintos: la cabeza femenina es más corta. Se
	# eligieron mirando la malla; coinciden con los que usa el pintor de caras.
	if gender == "male":
		mouth_range = (1.630, 1.660)
		forehead_z, chin_z, cheek_z = 1.775, 1.612, 1.685
		mouth_forward = -0.100
		nose = Vector((0.0, -0.130, 1.680))
	else:
		mouth_range = (1.618, 1.645)
		forehead_z, chin_z, cheek_z = 1.715, 1.590, 1.640
		mouth_forward = -0.090
		nose = Vector((0.0, -0.120, 1.645))
	mouth_vertices = [vertex.co for vertex in body.data.vertices
		if mouth_range[0] < vertex.co.z < mouth_range[1]
		and abs(vertex.co.x) < 0.030 and vertex.co.y < mouth_forward]
	if not mouth_vertices:
		raise SystemExit("No se encontró la boca para %s" % gender)
	mouth = sum(mouth_vertices, Vector()) / len(mouth_vertices)
	# Frente y mentón se miden por cota; las mejillas, a media altura de la cara.
	forehead = Vector((0.0, -0.085, forehead_z))
	chin = Vector((0.0, -0.100, chin_z))
	cheek_l = Vector((-0.055, -0.085, cheek_z))
	cheek_r = Vector((0.055, -0.085, cheek_z))
	points = {
		"eye_l": left_center,
		"eye_r": right_center,
		"mouth": mouth,
		"nose": nose,
		"forehead": forehead,
		"chin": chin,
		"cheek_l": cheek_l,
		"cheek_r": cheek_r,
	}
	result = {}
	for name, point in points.items():
		uv = uv_at(body, point)
		if uv is not None:
			result[name] = uv
	print("FACE_UV", gender, json.dumps(result))
	return result


def main() -> None:
	parser = argparse.ArgumentParser()
	root = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
	parser.add_argument("--body", default=os.path.join(
		root, "shared_assets", "characters", "quaternius", "base"))
	args = parser.parse_args(sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else [])
	for gender in ("male", "female"):
		measure(gender, args.body)


if __name__ == "__main__":
	main()
