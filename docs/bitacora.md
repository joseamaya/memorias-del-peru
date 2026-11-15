# Bitácora de cambios

Registro cronológico de los cambios y decisiones del desarrollo. Una fila por entrega, con la fecha y el commit.

La bitácora **no es una fuente de verdad**: no crea reglas ni prevalece sobre `docs/00`–`09` ni `AGENTS.md` ([AGENTS.md](../AGENTS.md) §2). Conserva el porqué de lo que se hizo.

## 2026-11-15

| Cambio | Detalle | Commit |
|---|---|---|
| Cierre del guion y de los sistemas de campaña | Se corrige la tarjeta de fin para mostrar el cuerpo narrativo (muerte de Viracocha, nombre de Pachacútec y variantes). Se añaden intro, duda, mensajero, recursos persistentes, oficio aplicado, Sisa, reputación, Palabra, diario en los cinco actos y puntos de control. El acto II gana marcha, llegada y preparación; el III, trampa, tres oleadas y costo con nombre; el IV, cuentas y asamblea con Palabra; el V, telar y tres finales. PCH-032 a PCH-036 verificadas. 97 pruebas; `ARCO_OK`; medición de rendimiento por acto. Pendiente: arte/audio, equilibrio y duración real | — |
| Arco completo I–V en gris | Se encadenan llacta (acto I), paso (acto II), Cusco (acto III), llacta de posguerra (acto IV) y llacta en obra (acto V): asambleas, costo de la batalla, muerte de Viracocha y nombre nuevo. La portada abre la campaña y cada acto entrega el testigo al siguiente. Vídeo de 58 s en `build/campana.mp4` (1080p30). 91 pruebas, 0 advertencias; `ARCO_OK`. Pendiente: pase de arte del paso y de la posguerra, guion escrito y puntos de control | — |
| Acto I jugable en gris | La portada abre la llacta: terreno con relieve, ocho viviendas, tres terrazas con surcos, dos corrales, fuego comunal, vegetación y siete personajes con «Hablar» (madre, hermano, Sisa, curaca, Puma, tejedora y agricultor). Cuatro encargos: los tres primeros dan agua, maíz y manta, fijan el oficio y cambian el objetivo. Se conecta el MCP de Blender al proyecto. 88 pruebas en verde | — |
| Inicio de la campaña El despertar del Sol | Se aprueba la biblia de la campaña en cinco actos y el expediente histórico que la sostiene. La campaña se construye desde cero sobre el motor y el núcleo RPG existentes: acto I (llacta, encargos con recursos, familia, duda, mensajero y asamblea), acto II (paso, emboscada, Cusco, reclutamiento y preparación), acto III (defensa y costo), acto IV (posguerra y asamblea) y acto V (reconstrucción y nombre nuevo). Se ordenan las fuentes: la biblia narrativa general manda en lo narrativo y el plan fija las fases. 86 pruebas del motor en verde | — |
