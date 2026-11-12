"""Compone la música de la introducción (ADR-0027) a partir de las notas de
«quena scale.wav» (MarleneAyni, Freesound 569392, CC0), con un bordón y una
tinya sintetizados. Uso: componer.py <quena_scale.wav> <salida.wav>"""
import sys
import numpy as np
from scipy.io import wavfile
from scipy.signal import butter, sosfilt, fftconvolve

SR = 44100
rng = np.random.default_rng(1438)

# Inicio de cada nota en la grabación (s), medido con analizar.py.
ONSETS = {
    "G4": 0.59, "A4": 4.85, "B4": 9.80, "C5": 14.21, "D5": 18.45, "E5": 22.51,
    "F#5": 26.24, "G5": 30.20, "A5": 33.81, "B5": 37.29, "C6": 40.78,
    "D6": 44.31, "E6": 47.68, "F#6": 51.14, "G6": 54.71,
}
# Melodía en la pentatónica de mi (mi, sol, la, si, re): (nota, inicio, duración).
PHRASES = [
    (3.0, [("E5", 1.6), ("G5", 1.2), ("A5", 2.3)]),
    (9.2, [("B5", 1.4), ("A5", 1.0), ("G5", 1.0), ("E5", 2.4)]),
    (16.6, [("D5", 1.2), ("E5", 1.0), ("G5", 1.5), ("A5", 1.2), ("B5", 2.4)]),
    (25.2, [("D6", 1.4), ("B5", 1.0), ("A5", 1.0), ("G5", 1.5), ("E5", 2.4)]),
    (33.4, [("G5", 1.2), ("E5", 1.0), ("D5", 1.4), ("E5", 2.5)]),
]
LENGTH = 44.0


def load(path):
    sr, x = wavfile.read(path)
    assert sr == SR
    x = x.astype(np.float64)
    if x.ndim == 2:
        x = x.mean(axis=1)
    return x / 32768.0


def note(src, name, dur):
    """Nota de la grabación: ataque natural, misma sonoridad y final suave."""
    start = int((ONSETS[name] - 0.04) * SR)
    seg = src[start:start + int(dur * SR)].copy()
    body = seg[int(0.2 * SR):]
    seg /= np.sqrt(np.mean(body ** 2)) + 1e-9
    seg *= 0.08
    fade_in = int(0.02 * SR)
    seg[:fade_in] *= np.linspace(0, 1, fade_in)
    fade_out = int(min(0.45, dur * 0.35) * SR)
    seg[-fade_out:] *= np.linspace(1, 0, fade_out) ** 1.5
    return seg


def bourdon(length):
    """Bordón grave en mi3 y si3, con aire filtrado y respiración lenta."""
    t = np.arange(int(length * SR)) / SR
    tone = np.zeros_like(t)
    for f, a in ((164.81, 1.0), (329.63, 0.25), (494.4, 0.08), (246.94, 0.35)):
        tone += a * np.sin(2 * np.pi * f * t + rng.uniform(0, 6.28))
    breath = sosfilt(butter(2, [140, 420], "band", fs=SR, output="sos"), rng.standard_normal(len(t)))
    breath /= np.abs(breath).max()
    tone += 0.12 * breath
    swell = 0.75 + 0.25 * np.sin(2 * np.pi * t / 9.0)
    env = np.clip(t / 6.0, 0, 1) * np.clip((length - t) / 6.0, 0, 1)
    out = tone * swell * env
    return 0.02 * out / np.abs(out).max()


def tinya(n):
    """Golpe de tinya (tambor pequeño) lejano: golpe sordo con caída de tono."""
    t = np.arange(int(0.6 * SR)) / SR
    f = 95 * np.exp(-t * 4) + 55
    body = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t * 9)
    skin = sosfilt(butter(2, [300, 1200], "band", fs=SR, output="sos"), rng.standard_normal(len(t))) * np.exp(-t * 45)
    hit = body + 0.25 * skin / np.abs(skin).max()
    return 0.05 * hit / np.abs(hit).max()


def reverb(x, seconds=2.4):
    n = int(seconds * SR)
    t = np.arange(n) / SR
    out = []
    for ch in range(2):
        ir = rng.standard_normal(n) * np.exp(-t * 6.9 / seconds)
        ir = sosfilt(butter(2, 4500, "low", fs=SR, output="sos"), ir)
        ir[: int(0.012 * SR)] = 0
        ir /= np.sqrt(np.sum(ir ** 2))
        out.append(fftconvolve(x, ir)[: len(x)])
    return np.stack(out, axis=1)


def main(src_path, out_path):
    src = load(src_path)
    total = int(LENGTH * SR)
    melody = np.zeros(total)
    for start, notes in PHRASES:
        at = start
        for name, dur in notes:
            seg = note(src, name, dur)
            i = int(at * SR)
            melody[i:i + len(seg)] += seg[: total - i]
            at += dur - 0.06
    drums = np.zeros(total)
    beat = 12.0
    while beat < 34.0:
        for offset, gain in ((0.0, 1.0), (0.75, 0.55)):
            i = int((beat + offset) * SR)
            h = tinya(0)
            drums[i:i + len(h)] += gain * h[: total - i]
        beat += 2.0
    dry = melody + drums
    wet = reverb(dry)
    mix = np.stack([dry, dry], axis=1) * 0.75 + wet * 0.55
    b = bourdon(LENGTH)
    mix += np.stack([b, b * 0.97], axis=1)
    # Final: se funde en los últimos 5 s.
    fade = int(5.0 * SR)
    mix[-fade:] *= np.linspace(1, 0, fade)[:, None] ** 1.5
    rms = np.sqrt(np.mean(mix[int(3 * SR): int(38 * SR)] ** 2))
    mix *= 10 ** (-22 / 20) / rms
    peak = np.abs(mix).max()
    if peak > 10 ** (-1.5 / 20):
        mix *= 10 ** (-1.5 / 20) / peak
    wavfile.write(out_path, SR, (mix * 32767).astype(np.int16))
    print(f"ok rms={20*np.log10(np.sqrt(np.mean(mix**2))):.1f} dB peak={20*np.log10(np.abs(mix).max()):.1f} dBFS")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
