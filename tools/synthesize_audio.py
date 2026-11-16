#!/usr/bin/env python3
"""Sintetiza los sonidos de ambiente y combate de los actos II y III.

Los archivos resultantes son de autoría propia del proyecto (licencia propia,
como el golpe del telar) y se versionan en `shared_assets/audio/`.

Uso:
    python3 tools/synthesize_audio.py
"""

from pathlib import Path

import numpy as np
from scipy import signal
from scipy.io import wavfile

SR = 44100
OUT = Path(__file__).resolve().parent.parent / "shared_assets" / "audio"
RNG = np.random.default_rng(20261114)


def normalize(samples: np.ndarray, rms_db: float, peak_db: float = -1.5) -> np.ndarray:
    samples = samples - float(np.mean(samples))
    rms = float(np.sqrt(np.mean(samples * samples)))
    if rms < 1e-9:
        return samples
    samples = samples / rms * (10.0 ** (rms_db / 20.0))
    peak = float(np.max(np.abs(samples)))
    limit = 10.0 ** (peak_db / 20.0)
    if peak > limit:
        samples = samples / peak * limit
    return samples


def crossfade_loop(samples: np.ndarray, fade_seconds: float) -> np.ndarray:
    fade = int(SR * fade_seconds)
    length = len(samples) - fade
    out = samples[:length].copy()
    t = np.linspace(0.0, 1.0, fade, endpoint=False)
    out[:fade] = samples[:fade] * t + samples[length:length + fade] * (1.0 - t)
    return out


def bandpass(samples: np.ndarray, low: float, high: float, order: int = 2) -> np.ndarray:
    sos = signal.butter(order, [low / (SR / 2.0), high / (SR / 2.0)], btype="band", output="sos")
    return signal.sosfilt(sos, samples)


def lowpass(samples: np.ndarray, cutoff: float, order: int = 2) -> np.ndarray:
    sos = signal.butter(order, cutoff / (SR / 2.0), btype="low", output="sos")
    return signal.sosfilt(sos, samples)


def write(name: str, samples: np.ndarray) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    data = np.clip(samples, -1.0, 1.0)
    wavfile.write(OUT / name, SR, (data * 32767.0).astype(np.int16))
    print(f"{name}: {len(data) / SR:.2f} s")


def water() -> np.ndarray:
    duration = 10.0
    n = int(SR * (duration + 0.5))
    t = np.arange(n) / SR
    babble = bandpass(RNG.normal(0.0, 1.0, n), 350.0, 3200.0)
    mod = 0.6 + 0.25 * np.sin(2.0 * np.pi * 0.13 * t) + 0.15 * np.sin(2.0 * np.pi * 0.31 * t + 1.2)
    gurgle = 0.5 + 0.5 * np.sin(2.0 * np.pi * 0.7 * t + 0.5 * np.sin(2.0 * np.pi * 0.11 * t)) ** 2
    rumble = lowpass(RNG.normal(0.0, 1.0, n), 220.0) * 0.5
    samples = babble * mod * (0.7 + 0.3 * gurgle) + rumble
    return normalize(crossfade_loop(samples, 0.5), -22.0)


def fire() -> np.ndarray:
    duration = 10.0
    n = int(SR * (duration + 0.5))
    t = np.arange(n) / SR
    rumble = lowpass(RNG.normal(0.0, 1.0, n), 180.0) * 0.4
    crackle = np.zeros(n)
    for _ in range(int(duration * 18)):
        position = int(RNG.integers(0, n - 2000))
        length = int(RNG.integers(200, 1200))
        envelope = np.exp(-np.linspace(0.0, 8.0, length))
        burst = bandpass(RNG.normal(0.0, 1.0, length), 800.0, 6000.0) * envelope
        crackle[position:position + length] += burst * float(RNG.uniform(0.3, 1.0))
    for _ in range(int(duration * 2)):
        position = int(RNG.integers(0, n - 2000))
        length = 2000
        frequency = float(RNG.uniform(150.0, 400.0))
        pop = np.sin(2.0 * np.pi * frequency * np.linspace(0.0, 0.045, length)) * np.exp(-np.linspace(0.0, 10.0, length))
        crackle[position:position + length] += pop * 0.4
    return normalize(crossfade_loop(rumble + crackle, 0.5), -20.0)


def drum() -> np.ndarray:
    duration = 8.0
    n = int(SR * duration)
    samples = np.zeros(n)
    for index, start in enumerate([0.0, 0.75, 2.0, 2.75, 4.0, 4.75, 6.0, 6.75]):
        position = int(start * SR)
        length = int(0.5 * SR)
        t = np.arange(length) / SR
        base = 95.0 if index % 2 == 0 else 120.0
        frequency = base * (0.6 + 0.4 * np.exp(-t * 8.0))
        phase = 2.0 * np.pi * np.cumsum(frequency) / SR
        hit = np.sin(phase) * np.exp(-t * 7.0)
        hit += RNG.normal(0.0, 1.0, length) * np.exp(-t * 35.0) * 0.4
        samples[position:position + length] += hit
    for start in [1.5, 3.5, 5.5, 7.5]:
        position = int(start * SR)
        length = int(0.25 * SR)
        t = np.arange(length) / SR
        frequency = 240.0 * (0.8 + 0.2 * np.exp(-t * 12.0))
        phase = 2.0 * np.pi * np.cumsum(frequency) / SR
        samples[position:position + length] += np.sin(phase) * np.exp(-t * 14.0) * 0.35
    return normalize(samples, -18.0)


def whoosh() -> np.ndarray:
    duration = 0.35
    n = int(SR * duration)
    t = np.arange(n) / SR
    envelope = np.sin(np.pi * t / duration) ** 2
    samples = bandpass(RNG.normal(0.0, 1.0, n), 500.0, 4000.0) * envelope
    frequency = 1200.0 - 1000.0 * t / duration
    phase = 2.0 * np.pi * np.cumsum(frequency) / SR
    samples += np.sin(phase) * envelope * 0.15
    return normalize(samples, -16.0)


def breath() -> np.ndarray:
    duration = 2.2
    n = int(SR * duration)
    t = np.arange(n) / SR
    noise = bandpass(RNG.normal(0.0, 1.0, n), 180.0, 1400.0)
    inhale = np.exp(-((t - 0.45) / 0.18) ** 2)
    exhale = np.exp(-((t - 1.45) / 0.28) ** 2)
    samples = noise * (inhale * 0.8 + exhale * 0.6)
    return normalize(samples, -24.0)


def impact(duration: float, base: float, rms_db: float) -> np.ndarray:
    n = int(SR * duration)
    t = np.arange(n) / SR
    frequency = base * (0.5 + 0.5 * np.exp(-t * 20.0))
    phase = 2.0 * np.pi * np.cumsum(frequency) / SR
    samples = np.sin(phase) * np.exp(-t * 18.0)
    samples += RNG.normal(0.0, 1.0, n) * np.exp(-t * 30.0) * 0.5
    return normalize(samples, rms_db)


def main() -> None:
    write("agua_arroyo.wav", water())
    write("fuego_campamento.wav", fire())
    write("tambor_defensa.wav", drum())
    write("honda_zumbido.wav", whoosh())
    write("honda_impacto.wav", impact(0.25, 110.0, -12.0))
    write("golpe_porra.wav", impact(0.3, 70.0, -12.0))
    write("respiracion.wav", breath())


if __name__ == "__main__":
    main()
