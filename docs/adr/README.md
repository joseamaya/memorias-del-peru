# Registro de decisiones arquitectónicas (ADR)

Un ADR documenta una decisión significativa: contexto, opciones, decisión y consecuencias. Se crea solo cuando se cumple **al menos uno** de estos criterios:

- Se añade o cambia una dependencia externa o una licencia.
- Se cambia un contrato de Core, una regla de dependencia entre capas o un formato de datos.
- Es caro de revertir (más de una hora de trabajo) o afecta a varios sistemas a la vez.
- Se desvía de `docs/00`–`08`, de este archivo o de `AGENTS.md`.
- Dentro de seis meses alguien preguntaría «¿por qué se hizo así?» y la respuesta no estaría en el código ni en el historial del alcance.

No se crea un ADR para:

- Elecciones reversibles de contenido o presentación: música, textos, disposición, ritmo.
- Ajustes que se deshacen en menos de una hora.
- Iteraciones de una decisión todavía abierta: se escribe uno al final, con las alternativas consideradas.

Límites: una página (unas 60 líneas) y **un ADR por decisión**, no por iteración. Lo que no llega a ese umbral se anota en la [bitácora](../bitacora.md).

Estados: **Propuesto** → **Aceptado** → (opcionalmente) **Reemplazado por ADR-XXXX**. Un ADR aceptado no se edita en su fondo; se reemplaza con uno nuevo.

Plantilla:

```markdown
# ADR-NNNN — Título
- Estado: Propuesto | Aceptado | Reemplazado por ADR-XXXX
- Fecha: AAAA-MM-DD
## Contexto
## Opciones consideradas
## Decisión
## Consecuencias
```

| ADR | Título | Estado |
|---|---|---|
| [0001](0001-estructura-de-repositorio.md) | Estructura del repositorio: `docs/` y `tests/` | Aceptado |
| [0002](0002-version-de-godot.md) | Versión de Godot | Aceptado |
| [0003](0003-deteccion-de-interactuables.md) | Detección de interactuables | Aceptado |
| [0004](0004-herramientas-de-desarrollo.md) | Herramientas de desarrollo: skills y servidores MCP | Aceptado (selección de skills reemplazada por ADR-0005) |
| [0005](0005-skills-de-godot.md) | Skills de Godot y desviación consciente del estilo oficial | Aceptado (selección ampliada por ADR-0022) |
| [0006](0006-secuencia-narrativa-por-subtitulos.md) | Secuencia narrativa por subtítulos | Aceptado (duración y reemplazo sustituidos por ADR-0012) |
| [0007](0007-evento-del-mensajero.md) | Evento del mensajero: máquina de estados y progreso garantizado | Aceptado |
| [0008](0008-disponibilidad-de-interactuables.md) | Disponibilidad de interactuables | Aceptado |
| [0009](0009-duracion-y-disparo-del-slice.md) | Duración y disparo del vertical slice | Reemplazado por ADR-0033 (reloj sustituido por ADR-0012) |
| [0010](0010-modelos-generados-con-blender.md) | Modelos generados por script con Blender 5.x | Aceptado (texturas matizadas por ADR-0014; personajes, por ADR-0015 y ADR-0016) |
| [0011](0011-fichas-fuera-del-slice.md) | Fichas de elementos que no están en el juego | Aceptado |
| [0012](0012-ajustes-tras-el-primer-piloto.md) | Ajustes tras el primer piloto | Aceptado (reloj sustituido por ADR-0013; rótulo, por ADR-0023) |
| [0013](0013-ritmo-orientacion-y-cierre.md) | Ritmo, orientación y cierre del slice | Reemplazado por ADR-0030 |
| [0014](0014-texturas-de-detalle-triplanares.md) | Texturas de detalle triplanares | Aceptado |
| [0015](0015-personajes-con-esqueleto.md) | Personajes con esqueleto y animaciones generadas | Aceptado (cuerpo y animaciones sustituidos por ADR-0016) |
| [0016](0016-personajes-realistas-makehuman.md) | Personajes realistas con MakeHuman (MPFB2) y captura de CMU | Aceptado (cabezas matizadas por ADR-0017) |
| [0017](0017-cabezas-rocketbox.md) | Cabezas de la Microsoft Rocketbox Avatar Library | Aceptado |
| [0018](0018-ropa-textiles-caida-y-muelles.md) | Ropa: textiles con diseño, caída simulada y manto con muelles | Aceptado (caída matizada por ADR-0020) |
| [0019](0019-movimiento-natural-de-personajes.md) | Movimiento natural de los personajes | Aceptado |
| [0020](0020-ropa-cortada-y-cosida.md) | Ropa cortada y cosida, con caída en la postura de reposo | Aceptado |
| [0021](0021-construcciones-de-pirca.md) | Construcciones de pirca: casas, poyos, terrazas y corrales | Aceptado |
| [0022](0022-skills-de-arte-y-shaders.md) | Skills de producción de arte y de técnica de shaders | Aceptado |
| [0023](0023-introduccion-del-slice.md) | Introducción del vertical slice | Aceptado (ampliado por ADR-0024 y ADR-0025) |
| [0024](0024-titulo-nota-historica-y-controles.md) | Pantalla de título, nota histórica y controles en pantalla | Aceptado (ampliado por ADR-0025) |
| [0025](0025-imagenes-de-la-introduccion.md) | Imágenes de fondo en la introducción | Aceptado |
| [0026](0026-cierre-corto-y-mensajero.md) | Cierre corto y partida del mensajero | Aceptado |
| [0027](0027-musica-de-la-introduccion.md) | Música de la introducción | Reemplazado por ADR-0028 |
| [0028](0028-musica-epica-de-la-introduccion.md) | Música épica de la introducción | Aceptado (pieza sustituida por ADR-0029) |
| [0029](0029-tema-de-apertura.md) | Tema de apertura de la introducción | Aceptado |
| [0030](0030-ritmo-y-disparo-del-mensajero.md) | Ritmo y disparo del mensajero: por acción y con aproximación visible | Aceptado (reemplaza a ADR-0013; ampliado por ADR-0032) |
| [0031](0031-validacion-por-el-autor.md) | Validación del vertical slice por el autor | Aceptado (umbral de duración ajustado por ADR-0033) |
| [0032](0032-objetivo-del-mirador.md) | Objetivo del mirador y anuncio de la espera | Aceptado (amplía ADR-0030) |
| [0033](0033-duracion-del-slice.md) | Duración del vertical slice: fragmento de 2–3 minutos | Aceptado (reemplaza a ADR-0009) |
| [0034](0034-una-campana-y-museo.md) | Una campaña y modelo de museo explorable | Aceptado (ampliado por ADR-0035) |
| [0035](0035-tour-libre.md) | Tour libre: estelas legibles, sin umbral y con guía opcional | Reemplazado por ADR-0036 |
| [0036](0036-leer-en-el-mundo.md) | Leer en el mundo: sin estelas, contador ni brújula | Aceptado (reemplaza a ADR-0035) |
| [0037](0037-duracion-del-museo.md) | La duración del museo: 6–8 minutos de exploración con lectura | Reemplazado por ADR-0038 |
| [0038](0038-campana-rpg.md) | La campaña 01 pasa a RPG en primera persona | Aceptado (supera ADR-0034, ADR-0036 y ADR-0037) |
| [0039](0039-tres-actos-y-gris.md) | Tres actos y construcción en gris | Aceptado (amplía ADR-0038) |
| [0040](0040-cronica-rectora.md) | Crónica rectora: Betanzos, con Garcilaso y Pachacuti Yamqui como contraste y leyenda | Aceptado |
| [0041](0041-estado-de-campana.md) | Estado de campaña para las banderas entre actos | Aceptado |
