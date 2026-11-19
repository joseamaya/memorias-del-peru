#!/usr/bin/env bash
# Mezcla el audio de los dos tráileres (35 s y 15 s) a partir de la música y
# los efectos del juego. La música es «Over The Andes» (Pixabay, generada con
# IA); el crédito y el aviso están en shared_assets/audio/LICENSE.md.
#
# Uso: tools/trailer_audio.sh
set -euo pipefail
cd "$(dirname "$0")/.."

AUDIO=shared_assets/audio
OUT=build/trailer
mkdir -p "$OUT"

# --- Tráiler completo (35 s) -------------------------------------------------
ffmpeg -y -v error \
  -i "$AUDIO/musica_intro_over_the_andes.ogg" \
  -i "$AUDIO/ambiente_viento_andes.ogg" \
  -i "$AUDIO/agua_arroyo.wav" \
  -i "$AUDIO/honda_zumbido.wav" \
  -i "$AUDIO/honda_impacto.wav" \
  -i "$AUDIO/murmullo_plaza.wav" \
  -i "$AUDIO/tambor_defensa.wav" \
  -i "$AUDIO/pututu_caracola.wav" \
  -i "$AUDIO/golpe_porra.wav" \
  -i "$AUDIO/fuego_campamento.wav" \
  -filter_complex "\
[0:a]atrim=0:35,volume=0.92,afade=t=in:st=0:d=0.8,afade=t=out:st=33.2:d=1.8[music];\
[1:a]atrim=0:8.5,volume=0.22,afade=t=out:st=6.3:d=2.2[wind];\
[2:a]atrim=0:2.7,adelay=12900:all=1,volume=0.16,afade=t=in:st=0:d=0.4,afade=t=out:st=2.2:d=0.5[water];\
[3:a]asplit=3[w1][w2][w3];[w1]adelay=10300:all=1,volume=0.5[wh1];[w2]adelay=11300:all=1,volume=0.5[wh2];[w3]adelay=12300:all=1,volume=0.5[wh3];\
[4:a]asplit=3[i1][i2][i3];[i1]adelay=10620:all=1,volume=0.72[im1];[i2]adelay=11620:all=1,volume=0.72[im2];[i3]adelay=12620:all=1,volume=0.72[im3];\
[5:a]asplit=2[m1][m2];[m1]atrim=0:3,adelay=3600:all=1,volume=0.14[mu1];[m2]atrim=0:2.5,adelay=19900:all=1,volume=0.16[mu2];\
[6:a]atrim=0:8.1,adelay=22500:all=1,volume=0.55,afade=t=in:st=0:d=0.4,afade=t=out:st=6.9:d=1.2[drum];\
[7:a]atrim=0:1.6,adelay=17700:all=1,volume=0.34[putu];\
[8:a]asplit=3[p1][p2][p3];[p1]adelay=25200:all=1,volume=0.42[po1];[p2]adelay=27700:all=1,volume=0.42[po2];[p3]adelay=31800:all=1,volume=0.55[po3];\
[9:a]atrim=0:1.7,adelay=30400:all=1,volume=0.13,afade=t=in:st=0:d=0.3,afade=t=out:st=1.2:d=0.5[fire];\
[music][wind][water][wh1][wh2][wh3][im1][im2][im3][mu1][mu2][drum][putu][po1][po2][po3][fire]amix=inputs=17:duration=longest:normalize=0,loudnorm=I=-14:TP=-1.0:LRA=11,alimiter=limit=0.95,volume=-2.5dB[out]" \
  -map "[out]" -t 35 -ar 48000 -ac 2 -c:a pcm_s16le "$OUT/trailer_35s.wav"
echo "audio 35s"

# --- Tráiler corto (15 s) ----------------------------------------------------
ffmpeg -y -v error \
  -i "$AUDIO/musica_intro_over_the_andes.ogg" \
  -i "$AUDIO/ambiente_viento_andes.ogg" \
  -i "$AUDIO/honda_zumbido.wav" \
  -i "$AUDIO/honda_impacto.wav" \
  -i "$AUDIO/pututu_caracola.wav" \
  -i "$AUDIO/tambor_defensa.wav" \
  -i "$AUDIO/golpe_porra.wav" \
  -i "$AUDIO/fuego_campamento.wav" \
  -filter_complex "\
[0:a]atrim=16:31,asetpts=PTS-STARTPTS,volume=0.95,afade=t=in:st=0:d=0.35,afade=t=out:st=13.5:d=1.5[music];\
[1:a]atrim=0:2.4,volume=0.2,afade=t=out:st=1.2:d=1.2[wind];\
[2:a]asplit=2[w1][w2];[w1]adelay=3900:all=1,volume=0.5[wh1];[w2]adelay=4900:all=1,volume=0.5[wh2];\
[3:a]asplit=2[i1][i2];[i1]adelay=4170:all=1,volume=0.7[im1];[i2]adelay=5170:all=1,volume=0.7[im2];\
[4:a]atrim=0:1.5,adelay=7100:all=1,volume=0.36[putu];\
[5:a]atrim=0:4.7,adelay=7100:all=1,volume=0.55,afade=t=in:st=0:d=0.3,afade=t=out:st=4.0:d=0.7[drum];\
[6:a]asplit=2[p1][p2];[p1]adelay=9250:all=1,volume=0.45[po1];[p2]adelay=11400:all=1,volume=0.55[po2];\
[7:a]atrim=0:0.9,adelay=11500:all=1,volume=0.14,afade=t=in:st=0:d=0.2,afade=t=out:st=0.7:d=0.2[fire];\
[music][wind][wh1][wh2][im1][im2][putu][drum][po1][po2][fire]amix=inputs=11:duration=longest:normalize=0,loudnorm=I=-14:TP=-1.0:LRA=11,alimiter=limit=0.95[out]" \
  -map "[out]" -t 15 -ar 48000 -ac 2 -c:a pcm_s16le "$OUT/trailer_15s.wav"
echo "audio 15s"
