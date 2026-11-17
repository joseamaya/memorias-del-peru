#!/usr/bin/env python3
"""Genera las texturas de rostro por personaje del prototipo Quaternius.

Parte de las albedo de Universal Base Characters (Quaternius, CC0) y pinta
encima, en el espacio UV de la cabeza, el tono de piel, los labios, las ojeras
y las líneas de edad. No sustituye una cara esculpida: es una capa de detalle
reproducible (R) sobre la malla base.

Las coordenadas UV se midieron con `tools/export_face_uv.py`; en la cabeza
femenina, más corta, la nariz, la frente y el mentón se ajustaron a mano porque
el punto 3D no proyecta limpio. El resultado se guarda a 1024 px en
`shared_assets/characters/quaternius/faces/`.

Uso:
    python3 tools/build_face_textures.py [--source DIR] [--out DIR]
"""

import argparse
import math
import random
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_SOURCE = ROOT / "shared_assets" / "characters" / "quaternius" / "faces" / "source"
DEFAULT_OUT = ROOT / "shared_assets" / "characters" / "quaternius" / "faces"

SOURCE = {
	"male": "T_Superhero_Male_Dark.png",
	"female": "T_Superhero_Female_Dark_BaseColor.png",
}

# Puntos UV medidos sobre la malla UBC (ver `export_face_uv.py`). v crece
# hacia la frente; el mentón queda abajo.
UV = {
	"male": {
		"eye_l": (0.1403, 0.8268),
		"eye_r": (0.2331, 0.8260),
		"mouth": (0.1867, 0.7736),
		"nose": (0.1863, 0.7833),
		"forehead": (0.1874, 0.9077),
		"chin": (0.1859, 0.7246),
		"cheek_l": (0.1240, 0.8035),
		"cheek_r": (0.2490, 0.8024),
		"outline": [
			(0.186, 0.714), (0.155, 0.722), (0.132, 0.750), (0.120, 0.790),
			(0.120, 0.840), (0.132, 0.885), (0.150, 0.915), (0.175, 0.936),
			(0.205, 0.936), (0.230, 0.915), (0.248, 0.885), (0.256, 0.840),
			(0.256, 0.790), (0.243, 0.750), (0.218, 0.722),
		],
	},
	"female": {
		"eye_l": (0.1349, 0.8241),
		"eye_r": (0.2326, 0.8241),
		"mouth": (0.1837, 0.7901),
		"nose": (0.1838, 0.8120),
		"forehead": (0.1838, 0.9359),
		"chin": (0.1791, 0.7706),
		"cheek_l": (0.1289, 0.8060),
		"cheek_r": (0.2386, 0.8060),
		"outline": [
			(0.180, 0.760), (0.150, 0.768), (0.130, 0.795), (0.120, 0.835),
			(0.122, 0.880), (0.135, 0.920), (0.155, 0.945), (0.180, 0.958),
			(0.207, 0.958), (0.230, 0.942), (0.248, 0.915), (0.256, 0.875),
			(0.256, 0.830), (0.245, 0.795), (0.220, 0.768),
		],
	},
}

# Tono de piel (multiplicador sRGB sobre la albedo de UBC), edad y labios.
# La combinación es reconstrucción (R): no hay retratos ni tonos documentados.
CHARACTERS = {
	"pch_npc_sisa_q": dict(
		gender="female", tone=(1.20, 1.12, 1.05), age=0.0,
		lips="full", blush=0.55, sun=0.0, beard_shadow=0.0,
	),
	"pch_npc_curaca_q": dict(
		gender="male", tone=(0.84, 0.78, 0.74), age=0.9,
		lips="thin", blush=0.18, sun=0.6, beard_shadow=0.35,
	),
	"pch_npc_mensajero_q": dict(
		gender="male", tone=(1.00, 0.95, 0.90), age=0.3,
		lips="normal", blush=0.15, sun=0.8, beard_shadow=0.0,
	),
	"pch_npc_chanca_q": dict(
		gender="male", tone=(0.80, 0.74, 0.70), age=0.4,
		lips="thin", blush=0.08, sun=0.9, beard_shadow=0.0,
	),
	# Arquetipos de multitud: mujer mayor y hombre joven. Pómulos anchos,
	# nariz recta, labios llenos y piel media/oscura; reconstrucción (R).
	"pch_npc_anciana_q": dict(
		gender="female", tone=(0.84, 0.76, 0.70), age=1.0,
		lips="thin", blush=0.10, sun=1.0, beard_shadow=0.0,
		forehead_shift=0.060,
	),
	"pch_npc_joven_q": dict(
		gender="male", tone=(0.90, 0.82, 0.76), age=0.0,
		lips="normal", blush=0.25, sun=0.7, beard_shadow=0.0,
	),
}

SIZE = 2048
OUT_SIZE = 1024


def uv_xy(point: tuple) -> tuple:
	return (point[0] * SIZE, (1.0 - point[1]) * SIZE)


def face_mask(points: dict) -> Image.Image:
	"""Máscara blanda de la isla frontal de la cara."""
	mask = Image.new("L", (SIZE, SIZE), 0)
	draw = ImageDraw.Draw(mask)
	draw.polygon([uv_xy(point) for point in points["outline"]], fill=255)
	mask = mask.filter(ImageFilter.GaussianBlur(80))
	return mask


def composite_layer(base: Image.Image, overlay: Image.Image, mask: Image.Image) -> Image.Image:
	"""Compone una capa RGBA solo dentro de la máscara de la cara."""
	overlay = overlay.filter(ImageFilter.GaussianBlur(1.4))
	alpha = np.asarray(overlay.getchannel("A"), dtype=np.float32) / 255.0
	alpha *= np.asarray(mask, dtype=np.float32) / 255.0
	rgb = np.asarray(overlay.convert("RGB"), dtype=np.float32)
	out = np.asarray(base.convert("RGB"), dtype=np.float32)
	out = out * (1.0 - alpha[..., None]) + rgb * alpha[..., None]
	return Image.fromarray(np.clip(out, 0, 255).astype(np.uint8), "RGB")


def ellipse(layer: Image.Image, center: tuple, radius: tuple, color: tuple, alpha: int) -> None:
	x, y = center
	rx, ry = radius
	draw = ImageDraw.Draw(layer, "RGBA")
	draw.ellipse([x - rx, y - ry, x + rx, y + ry], fill=(*color, alpha))


def line(layer: Image.Image, points: list, color: tuple, alpha: int, width: int) -> None:
	draw = ImageDraw.Draw(layer, "RGBA")
	draw.line([(x, y) for x, y in points], fill=(*color, alpha), width=width, joint="curve")


def crease(layer: Image.Image, points: list, color: tuple, alpha: int,
		width: int, highlight: bool = True) -> None:
	"""Surco oscuro con una luz fina encima: la arruga se lee, no es una raya."""
	line(layer, points, color, alpha, width)
	if highlight:
		lifted = [(x, y - max(2.0, width * 0.8)) for x, y in points]
		line(layer, lifted, (214, 178, 154), int(alpha * 0.35), max(1, width - 1))


def arc(layer: Image.Image, x0: float, x1: float, y: float, bend: float,
		color: tuple, alpha: int, width: int) -> None:
	points = []
	steps = 16
	for index in range(steps + 1):
		t = float(index) / float(steps)
		x = x0 + (x1 - x0) * t
		# Parábola suave: los extremos bajan, el centro sube.
		y_offset = bend * (1.0 - 4.0 * (t - 0.5) ** 2)
		points.append((x, y - y_offset))
	line(layer, points, color, alpha, width)


def add_skin_noise(image: Image.Image, mask: Image.Image, seed: int) -> Image.Image:
	"""Grano fino y manchas grandes: la piel deja de ser una superficie lisa."""
	array = np.asarray(image, dtype=np.float32)
	rng = np.random.default_rng(1438 + seed)
	fine = rng.normal(0.0, 3.5, array.shape[:2])
	coarse = rng.normal(0.0, 1.0, (24, 24)).astype(np.float32)
	coarse = np.asarray(Image.fromarray(coarse, "F").resize(
		(array.shape[1], array.shape[0]), Image.BICUBIC))
	weight = np.asarray(mask, dtype=np.float32) / 255.0
	array += (fine + coarse * 2.2)[..., None] * weight[..., None]
	return Image.fromarray(np.clip(array, 0, 255).astype(np.uint8), "RGB")


def paint_character(name: str, config: dict, source: Path, out_dir: Path) -> Path:
	points = UV[config["gender"]]
	base = Image.open(source / SOURCE[config["gender"]]).convert("RGB")
	base = base.resize((SIZE, SIZE), Image.LANCZOS)
	array = np.asarray(base, dtype=np.float32)
	tone = np.array(config["tone"], dtype=np.float32)[None, None, :]
	base = Image.fromarray(np.clip(array * tone, 0, 255).astype(np.uint8), "RGB")

	mask = face_mask(points)
	age = float(config["age"])
	eye_l = uv_xy(points["eye_l"])
	eye_r = uv_xy(points["eye_r"])
	mouth = uv_xy(points["mouth"])
	nose = uv_xy(points["nose"])
	forehead = uv_xy(points["forehead"])
	chin = uv_xy(points["chin"])
	cheek_l = uv_xy(points["cheek_l"])
	cheek_r = uv_xy(points["cheek_r"])

	# Rubor y sol: manchas grandes y suaves, no un degradado uniforme.
	layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
	for cheek in (cheek_l, cheek_r):
		ellipse(layer, cheek, (SIZE * 0.035, SIZE * 0.030), (168, 92, 70),
			int(70 * config["blush"]))
	if config["sun"] > 0.0:
		for offset in (-0.020, 0.020):
			ellipse(layer, (cheek_l[0] + SIZE * offset, cheek_l[1] + SIZE * 0.012),
				(SIZE * 0.026, SIZE * 0.022), (150, 92, 64), int(38 * config["sun"]))
			ellipse(layer, (cheek_r[0] + SIZE * offset, cheek_r[1] + SIZE * 0.012),
				(SIZE * 0.026, SIZE * 0.022), (150, 92, 64), int(38 * config["sun"]))
	base = composite_layer(base, layer, mask)

	# Labios: forma y línea de la boca. El color se mezcla con la albedo.
	layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
	full = config["lips"] == "full"
	thin = config["lips"] == "thin"
	rx = SIZE * (0.016 if full else 0.012 if thin else 0.014)
	ry = SIZE * (0.0062 if full else 0.0032 if thin else 0.0046)
	ellipse(layer, (mouth[0], mouth[1] + SIZE * 0.0012), (rx, ry), (116, 50, 56),
		220 if not thin else 170)
	line(layer, [(mouth[0] - rx * 0.78, mouth[1]), (mouth[0], mouth[1] + SIZE * 0.0015),
		(mouth[0] + rx * 0.78, mouth[1])], (48, 20, 18), 240, 4)
	if age > 0.5:
		# Comisuras caídas: la edad se lee en la boca, no solo en la piel.
		for side in (-1.0, 1.0):
			line(layer, [(mouth[0] + side * rx * 0.82, mouth[1]),
				(mouth[0] + side * rx * 0.98, mouth[1] - SIZE * 0.004)],
				(92, 42, 36), 150, 2)
	base = composite_layer(base, layer, mask)

	# Ojos: sombra del párpado, ojera y patas de gallo.
	layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
	for eye in (eye_l, eye_r):
		ellipse(layer, (eye[0], eye[1] + SIZE * 0.010), (SIZE * 0.024, SIZE * 0.009),
			(112, 76, 58), int(18 + 56 * age))
		ellipse(layer, (eye[0], eye[1] - SIZE * 0.014), (SIZE * 0.021, SIZE * 0.0060),
			(102, 68, 54), int(8 + 100 * age))
	if age > 0.4:
		for eye, side in ((eye_l, -1.0), (eye_r, 1.0)):
			for index in range(4):
				start_x = eye[0] + side * SIZE * 0.021
				start_y = eye[1] + SIZE * (0.004 - 0.0032 * index)
				crease(layer, [(start_x, start_y),
					(start_x + side * SIZE * 0.011, start_y + SIZE * (0.004 - 0.0032 * index))],
					(74, 48, 38), int(190 * age), 2)
	base = composite_layer(base, layer, mask)

	# Frente y surcos: solo cuando la edad lo pide.
	if age > 0.35:
		layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
		shift = float(config.get("forehead_shift", 0.0))
		for index, offset in enumerate((0.010, 0.022, 0.034, 0.046)):
			width = SIZE * (0.064 - 0.005 * index)
			y = forehead[1] + SIZE * shift - SIZE * offset
			points = []
			for step in range(17):
				t = float(step) / 16.0
				x = forehead[0] - width * 0.5 + width * t
				points.append((x, y - SIZE * 0.0026 * (1.0 - 4.0 * (t - 0.5) ** 2)))
			crease(layer, points, (58, 38, 32), int(255 * age), 5)
		for side in (-1.0, 1.0):
			start = (nose[0] + side * SIZE * 0.008, nose[1] - SIZE * 0.004)
			end = (mouth[0] + side * SIZE * 0.018, mouth[1] + SIZE * 0.004)
			mid = ((start[0] + end[0]) * 0.5 + side * SIZE * 0.006,
				(start[1] + end[1]) * 0.5)
			crease(layer, [start, mid, end], (66, 42, 34), int(230 * age), 4)
		# Entrecejo: dos surcos verticales entre las cejas, no en la frente alta.
		for side in (-1.0, 1.0):
			x = mouth[0] + side * SIZE * 0.009
			y0 = eye_l[1] - SIZE * 0.040
			y1 = eye_l[1] - SIZE * 0.010
			crease(layer, [(x, y0), (x + side * SIZE * 0.002, y1)],
				(64, 42, 34), int(200 * age), 3)
		if age > 0.7:
			# Mandíbula y mentón: la piel cede con la edad.
			for side in (-1.0, 1.0):
				ellipse(layer, (chin[0] + side * SIZE * 0.030, chin[1] + SIZE * 0.012),
					(SIZE * 0.024, SIZE * 0.014), (74, 50, 40), int(80 * age))
			arc(layer, mouth[0] - SIZE * 0.020, mouth[0] + SIZE * 0.020,
				chin[1] - SIZE * 0.004, -SIZE * 0.0018,
				(74, 50, 40), int(150 * age), 3)
		# Manchas de sol pequeñas, con semilla fija para que sea reproducible.
		rng = random.Random(1438 + len(name))
		for _ in range(int(14 * config["sun"])):
			cx = rng.uniform(0.115, 0.260) * SIZE
			cy = rng.uniform(0.790, 0.900) * SIZE
			radius = rng.uniform(1.4, 4.0 if config["sun"] > 0.8 else 2.8) * SIZE / 2048.0
			ellipse(layer, (cx, cy), (radius, radius), (120, 82, 60),
				rng.randint(24, 54))
		base = composite_layer(base, layer, mask)

	# Sombra de barba en el Curaca: la barba 3D ya existe; esto le da volumen.
	if config["beard_shadow"] > 0.0:
		layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
		for side in (-1.0, 1.0):
			ellipse(layer, (chin[0] + side * SIZE * 0.022, chin[1] + SIZE * 0.010),
				(SIZE * 0.030, SIZE * 0.022), (58, 48, 44),
				int(70 * config["beard_shadow"]))
		ellipse(layer, (chin[0], chin[1] + SIZE * 0.002),
			(SIZE * 0.036, SIZE * 0.028), (58, 48, 44),
			int(80 * config["beard_shadow"]))
		base = composite_layer(base, layer, mask)

	# Suaviza el ruido de la albedo y afina el detalle al tamaño final.
	base = base.filter(ImageFilter.GaussianBlur(0.5))
	base = base.resize((OUT_SIZE, OUT_SIZE), Image.LANCZOS)
	mask_small = mask.resize((OUT_SIZE, OUT_SIZE), Image.LANCZOS)
	base = add_skin_noise(base, mask_small, len(name))
	out_dir.mkdir(parents=True, exist_ok=True)
	path = out_dir / ("pch_face_%s.png" % name.replace("pch_npc_", "").replace("_q", ""))
	base.save(path, optimize=True)
	return path


def main() -> None:
	parser = argparse.ArgumentParser()
	parser.add_argument("--source", default=str(DEFAULT_SOURCE))
	parser.add_argument("--out", default=str(DEFAULT_OUT))
	args = parser.parse_args()
	source = Path(args.source)
	out_dir = Path(args.out)
	for name, config in CHARACTERS.items():
		path = paint_character(name, config, source, out_dir)
		print("FACE", name, path)


if __name__ == "__main__":
	main()
