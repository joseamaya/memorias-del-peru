# 15 — Resumen de la redefinición

- **Versión:** 1.0 — 2026-11-19
- **Ámbito:** mapa de los entregables de la F0 y estado de la decisión.
- **Uso:** entrada rápida para el responsable; el detalle vive en los documentos enlazados.

## 1. Entregables de la primera tarea

| # | Entregable | Dónde está | Estado |
|---|---|---|---|
| 1 | Diagnóstico del proyecto actual | [docs/14](14_auditoria_y_migracion.md) §2–§5 | Completo |
| 2 | Nueva definición del producto | [docs/01](01_vision_y_alcance.md) | Completo |
| 3 | GDD actualizado | [docs/11](11_diseno_de_mundo.md) | Completo como propuesta |
| 4 | Diseño conceptual de las cuatro campañas | [docs/12](12_campanas.md) | Completo; regiones II–IV por validar |
| 5 | Propuesta de mundo abierto regional | [docs/11](11_diseno_de_mundo.md) §4–§10 | Completo |
| 6 | Diseño preliminar de la región Pachacútec | [mundo/](../campaigns/01_pachacutec/documentation/mundo/README.md) | Propuesta; revisión histórica pendiente |
| 7 | Arquitectura técnica propuesta | [docs/02](02_arquitectura.md) | Completo como propuesta |
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

- **F0 entregada:** documentación redefinida; el PR queda pendiente de merge.
- **F1 en curso:** la base de reloj, estado y guardado (1.6) y la definición/horario de NPC (1.5) están implementadas; 1.1–1.4, el resto de 1.5 y 1.7 están pendientes.
- **F4-L y F5-L congeladas:** la versión lineal se conserva como historial y banco de pruebas.
- **F2–F6 previstas:** geografía, vertical slice, producción, cierre y campañas II–IV.
- **No adoptado:** Terrain3D y Cyclops son candidatos; su adopción depende de F1.

## 4. Decisiones pendientes del responsable

1. Duración objetivo: 6–8 h (recomendado) o 4–5 h.
2. Portada: cuatro campañas visibles con solo la 01 jugable (recomendado) o solo la 01.
3. Campaña III: expediente comparativo con Ayacucho–Huanta como hipótesis (recomendado).
4. Campaña IV: Mantaro con Huamachuco como epílogo (recomendado) u otra región.
5. Adopción de Terrain3D/Cyclops: autorizar spikes, no adopción definitiva.
6. Congelación de F4-L/F5-L y apertura de F1.

## 5. No verificado

- Rendimiento real de Terrain3D en la UHD 770 con la región prevista.
- Comportamiento de Cyclops en exportación y CI.
- Coste del navmesh sobre terreno y de los interiores aditivos.
- Región definitiva de la campaña III y alcance de Huamachuco en la IV.
- Duración real de la campaña 01 en mundo abierto.
- Que el guion lineal sobreviva completo a la reestructuración; se conserva la historia, no la implementación.

## 6. Siguiente paso

Si el responsable aprueba este resumen y la F0:

1. Abrir F1 y ejecutar los spikes 1.1–1.7.
2. No producir arte definitivo ni construir la región completa hasta aprobar la vertical slice.
3. Registrar en la bitácora la adopción o el descarte de Terrain3D y Cyclops con medidas.
