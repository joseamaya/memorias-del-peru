#!/usr/bin/env bash
# Monta los cuatro másteres del tráiler a partir de las capturas de fotogramas.
#
#   V_FRAMES=build/trailer/frames_v \
#   H_FRAMES=build/trailer/frames_h tools/trailer_build.sh
#
# Las capturas se generan con tests/scenes/trailer_capture.tscn (ver
# docs/trailer_redes.md). Las piezas finales quedan en build/trailer/.
set -euo pipefail
cd "$(dirname "$0")/.."

V="${V_FRAMES:-build/trailer/frames_v}"
H="${H_FRAMES:-build/trailer/frames_h}"
OUT=build/trailer
CRF=21

if [ ! -f "$V/000000.jpg" ] || [ ! -f "$H/000000.jpg" ]; then
  echo "Faltan las capturas: $V o $H" >&2
  exit 1
fi

python3 tools/trailer_post.py --stage all
bash tools/trailer_audio.sh

# --- Tarjetas de cierre ------------------------------------------------------
ffmpeg -y -v error -loop 1 -framerate 30 -t 3.0 -i "$OUT/img/endcard_9x16.png" \
  -vf "scale=1080:1920,format=yuv420p" -c:v libx264 -crf "$CRF" -preset medium \
  "$OUT/end_v.mp4"
ffmpeg -y -v error -loop 1 -framerate 30 -t 2.7 -i "$OUT/img/endcard_9x16.png" \
  -vf "scale=1080:1920,format=yuv420p" -c:v libx264 -crf "$CRF" -preset medium \
  "$OUT/end_v15.mp4"
ffmpeg -y -v error -loop 1 -framerate 30 -t 3.0 -i "$OUT/img/endcard_16x9.png" \
  -vf "scale=1920:1080,format=yuv420p" -c:v libx264 -crf "$CRF" -preset medium \
  "$OUT/end_h.mp4"
ffmpeg -y -v error -loop 1 -framerate 30 -t 2.7 -i "$OUT/img/endcard_16x9.png" \
  -vf "scale=1920:1080,format=yuv420p" -c:v libx264 -crf "$CRF" -preset medium \
  "$OUT/end_h15.mp4"

# --- Pasadas sin rótulos -----------------------------------------------------
ffmpeg -y -v error -framerate 30 -start_number 0 -i "$V/%06d.jpg" -frames:v 960 \
  -c:v libx264 -crf "$CRF" -preset medium -pix_fmt yuv420p -movflags +faststart \
  "$OUT/video_v_silent.mp4"
ffmpeg -y -v error -framerate 30 -start_number 0 -i "$H/%06d.jpg" -frames:v 960 \
  -c:v libx264 -crf "$CRF" -preset medium -pix_fmt yuv420p -movflags +faststart \
  "$OUT/video_h_silent.mp4"

# --- Rótulos, subtítulos, etalonaje y tarjeta --------------------------------
ffmpeg -y -v error -i "$OUT/video_v_silent.mp4" -i "$OUT/end_v.mp4" \
  -filter_complex_script "$OUT/filters/full_v.txt" -map "[v]" \
  -c:v libx264 -crf "$CRF" -preset medium -pix_fmt yuv420p -movflags +faststart \
  "$OUT/video_v_35s.mp4"
ffmpeg -y -v error -i "$OUT/video_h_silent.mp4" -i "$OUT/end_h.mp4" \
  -filter_complex_script "$OUT/filters/full_h.txt" -map "[v]" \
  -c:v libx264 -crf "$CRF" -preset medium -pix_fmt yuv420p -movflags +faststart \
  "$OUT/video_h_35s.mp4"
ffmpeg -y -v error -i "$OUT/video_v_silent.mp4" -i "$OUT/end_v15.mp4" \
  -filter_complex_script "$OUT/filters/short_v.txt" -map "[v]" \
  -c:v libx264 -crf "$CRF" -preset medium -pix_fmt yuv420p -movflags +faststart \
  "$OUT/video_v_15s.mp4"
ffmpeg -y -v error -i "$OUT/video_h_silent.mp4" -i "$OUT/end_h15.mp4" \
  -filter_complex_script "$OUT/filters/short_h.txt" -map "[v]" \
  -c:v libx264 -crf "$CRF" -preset medium -pix_fmt yuv420p -movflags +faststart \
  "$OUT/video_h_15s.mp4"

# --- Música y mezcla --------------------------------------------------------
mix() {
  ffmpeg -y -v error -i "$1" -i "$2" -map 0:v -map 1:a -c:v copy \
    -c:a aac -b:a 192k -ar 48000 -movflags +faststart -shortest "$3"
}
mix "$OUT/video_v_35s.mp4" "$OUT/trailer_35s.wav" \
  "$OUT/memorias_del_peru_pachacutec_9x16_35s.mp4"
mix "$OUT/video_h_35s.mp4" "$OUT/trailer_35s.wav" \
  "$OUT/memorias_del_peru_pachacutec_16x9_35s.mp4"
mix "$OUT/video_v_15s.mp4" "$OUT/trailer_15s.wav" \
  "$OUT/memorias_del_peru_pachacutec_9x16_15s.mp4"
mix "$OUT/video_h_15s.mp4" "$OUT/trailer_15s.wav" \
  "$OUT/memorias_del_peru_pachacutec_16x9_15s.mp4"

echo "OK: $OUT"
