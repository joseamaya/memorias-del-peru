# 15 — Resumen de la redefinición

- **Versión:** 1.0 — 2026-11-19
- **Ámbito:** mapa de los entregables de la F0 y estado de la decisión.
- **Uso:** entrada rápida para el responsable; el detalle vive en los documentos enlazados.

## 1. Entregables de la primera tarea

| # | Entregable | Dónde está | Estado |
|---|---|---|---|
| 1 | Diagnóstico del proyecto actual | [docs/14](14_auditoria_y_migracion.md) §2–§5 | Completo |
| 2 | Nueva definición del producto | [docs/01](01_vision_y_alcance.md) | Completo |
| 3 | GDD actualizado | [docs/11](11_diseno_de_mundo.md) | Completo |
| 4 | Diseño conceptual de las cuatro campañas | [docs/12](12_campanas.md) | Completo; regiones II–IV sujetas a expediente |
| 5 | Propuesta de mundo abierto regional | [docs/11](11_diseno_de_mundo.md) §4–§10 | Completo |
| 6 | Diseño de la región Pachacútec | [mundo/](../campaigns/01_pachacutec/documentation/mundo/README.md) | Completo para revisión histórica |
| 7 | Arquitectura técnica propuesta | [docs/02](02_arquitectura.md) | Completo |
| 8 | Pipeline Terrain3D / Cyclops / Blender / Godot | [docs/13](13_pipeline_de_escenarios.md) | Completo; adopción pendiente de F1 |
| 9 | Sistemas a conservar, adaptar, reconstruir o retirar | [docs/14](14_auditoria_y_migracion.md) §6 | Completo |
| 10 | Plan de implementación por etapas | [docs/05](05_plan_de_implementacion.md) | Completo |
| 11 | Riesgos técnicos y de producción | [docs/14](14_auditoria_y_migracion.md) §8 | Completo |
| 12 | Criterios para aprobar la vertical slice | [F0](fases/F0-redefinicion-mundo-abierto.md) §5 y [docs/05](05_plan_de_implementacion.md) §F3 | Completo |

## 2. Decisión de producto

*Memorias del Perú* pasa de una sucesión de escenas lineales a una antología de cuatro RPG históricos de **mundo abierto regional**. Cada campaña tiene:

- Un protagonista común.
- Una región continua con 2–4 km² de área densa (hasta ~8 km² con wilderness).
- Una comunidad habitable y varios núcleos.
- NPC con identidad, rutinas y memoria.
- Historia principal, secundarias, encargos, descubrimientos y acontecimientos.
- Guardado completo, día/noche, mapa del diario y combate contextual.

La campaña 01 conserva la historia, el elenco y el registro histórico. Los cinco actos se viven como fases del mismo territorio.

## 3. Estado del repositorio

- **F0 cerrada y aprobada:** documentación redefinida; sin cambios de código, escenas ni assets.
- **F1 cerrada (2026-11-19); F2 cerrada y aprobada con cambios (2026-11-20); F3 en preparación:** el relieve regional de 3,5 × 2,5 km está en blockout (seis sectores, río, quebrada, paso y cumbres; ~1,5 s de generación) los seis sectores ya se transmiten por cercanía sobre el terreno continuo y ocho rutas de blockout están dibujadas con navmesh por sector y enlaces entre ellos. S3 — Llacta de Rumi tiene su blockout (17 casas, plaza, manantial, telar, corral y acequia; 78–85 FPS y 120 draw calls) y S1 — Cusco preimperial también (28 casas, Coricancha, mercado, talleres y depósitos; 76–82 FPS y 247 draw calls). S4, S5 y S6 (quebrada, paso y frontera) tienen su blockout con 5, 3 y 5 POI; 80/95/103 FPS y 146/103/83 draw calls. Los 30 POI ya se descubren por proximidad, diálogo o evento, alimentan diario y mapa, respetan fases y persisten en el guardado. El recorrido Cusco–frontera se valida de forma automatizada en 2.758 m y 23 min a pie, con seis sectores y ocho POI. El mundo tiene un modo de revisión con cámara cercana, etiquetas con H y vista cenital con T, y ya se recorre a pie con el jugador en primera persona sobre la colisión del terreno. El blockout se aprobó con cambios el 2026-11-20 tras recorrer la ruta A; la ruta oeste queda solo con recorrido automatizado y se declara no verificada. El sector gris integra Terrain3D, Cyclops, navmesh sobre el relieve, 60 NPC (25 animados), guardado y un blockout con seis casas, multitud y vegetación MultiMesh. El presupuesto queda en 255–287 draw calls, 101,7 MB, 61–66 FPS y frame máximo de 30,3 ms; el streaming carga en 21,4 ms de media con 1 KB de crecimiento en 60 ciclos. La adopción definitiva de Terrain3D/Cyclops se decide con el sector real de F2.
- **F4-L y F5-L retiradas (decisión del 2026-11-20):** la campaña lineal y su trama inventada salen del repositorio y solo quedan en el historial de git. El punto de partida para repensar la campaña es el contexto histórico.
- **F2–F6 previstas:** geografía, vertical slice, producción, cierre y campañas II–IV.
- **Adopción provisional:** Terrain3D y Cyclops están instalados y medidos; la revisión definitiva se hace con el sector real de F2 y el veredicto del blockout.

## 4. Decisiones aprobadas

Se aprueban las recomendaciones de la F0:

1. **Duración:** 6–8 h de historia principal por campaña; 8–12 h con contenido secundario.
2. **Portada:** cuatro campañas visibles; solo la 01 jugable hasta su fase; las otras indican “en diseño”.
3. **Campaña III:** expediente comparativo con **Ayacucho–Huanta–Cangallo** como hipótesis principal.
4. **Campaña IV:** valle del Mantaro; Huamachuco como epílogo narrado o secuencia final.
5. **Addons:** autorizar los spikes de Terrain3D y Cyclops, no su adopción definitiva.
6. **Fases:** F4-L/F5-L retiradas (2026-11-20); F0 cerrada; F1 y F2 cerradas; F3 en preparación con la campaña por repensar.

## 5. No verificado

- Rendimiento real de Terrain3D en la UHD 770 con la región prevista.
- Comportamiento de Cyclops en exportación y CI.
- Coste del navmesh sobre terreno y de los interiores aditivos.
- Región definitiva de la campaña III y alcance de Huamachuco en la IV.
- Duración real de la campaña 01 en mundo abierto.
- Que el guion lineal sobreviva completo a la reestructuración; se conserva la historia, no la implementación.

## 6. Siguiente paso

La F1 está cerrada. El siguiente paso es cerrar F2:

1. Hacer la prueba humana de 20–30 min con el [protocolo de blockout](../campaigns/01_pachacutec/documentation/mundo/prueba_blockout.md).
2. Corregir las incidencias bloqueantes y mayores, y repetir la ruta afectada.
3. Aprobar el blockout y registrar el veredicto en la ficha de F2 y en la bitácora.
4. Revisar la adopción definitiva de Terrain3D y Cyclops con el sector real.
5. No producir arte definitivo ni abrir la vertical slice hasta ese veredicto.
