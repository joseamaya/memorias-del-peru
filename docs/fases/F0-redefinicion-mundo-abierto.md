# F0 · Redefinición a mundo abierto — tareas

**Estado:** cerrada · **Apertura:** 2026-11-19 · **Cierre:** 2026-11-19.
**Criterio de salida:** el de [docs/05](../05_plan_de_implementacion.md) §Fase 0.
**Alcance:** documentación. No se toca código, escenas ni assets.

## 1. Contexto

La dirección lineal de 40–50 minutos no satisface el objetivo de producto. El proyecto se redefine como una antología de cuatro RPG históricos de mundo abierto regional. La campaña 01 se convierte en un territorio continuo con fases históricas, no en cinco escenas separadas.

La versión lineal (Fases 0–3) se conserva como historial y banco de pruebas. **F4-L y F5-L quedan congeladas.**

## 2. Tareas

| # | Tarea | Estado | Criterio de aceptación | Evidencia |
|---|---|---|---|---|
| 0.1 | Diagnóstico del repositorio | Cerrada | Estado, límites, activos reutilizables, riesgos y dependencias | [docs/05](../05_plan_de_implementacion.md) §Estado; bitácora |
| 0.2 | Nueva visión y alcance | Cerrada | [docs/01](../01_vision_y_alcance.md) describe el producto nuevo y sus métricas | Enlaces y revisión |
| 0.3 | GDD de mundo abierto | Cerrada | [docs/11](../11_diseno_de_mundo.md) fija bucle, escala, NPC, misiones, progresión, economía y combate | Revisión del responsable |
| 0.4 | Cuatro campañas | Cerrada | [docs/12](../12_campanas.md) con concepto, región, protagonista y estado | Revisión histórica inicial |
| 0.5 | Arquitectura | Cerrada | [docs/02](../02_arquitectura.md) con capas, persistencia, navegación, streaming y NPC | Revisión técnica |
| 0.6 | Pipeline | Cerrada | [docs/13](../13_pipeline_de_escenarios.md) con versiones, licencias, pasos y riesgos | Verificación de releases |
| 0.7 | Región Pachacútec | Cerrada | Dossier geográfico y reestructuración narrativa en `campaigns/01_pachacutec/documentation/mundo/` | Revisión histórica y de diseño |
| 0.8 | Plan y pruebas | Cerrada | [docs/05](../05_plan_de_implementacion.md) y [docs/06](../06_estrategia_de_pruebas.md) actualizados | Enlaces y guardas de CI |
| 0.9 | Reglas de trabajo | Cerrada | [AGENTS.md](../../AGENTS.md) y [README.md](../../README.md) describen el producto nuevo | Revisión |
| 0.10 | Bitácora | Cerrada | Decisión, alternativas, consecuencias y fases congeladas | Entrada del 2026-11-19 |
| 0.11 | Aprobación del responsable | **Aprobada** | El responsable aprueba el plan y autoriza F1 | Comentario del responsable; PR #8 |

## 3. Qué no se hace en F0

- No se añade Terrain3D ni Cyclops.
- No se modifica `project.godot`, `core/` ni `campaigns/*/scenes`.
- No se produce arte, audio ni assets definitivos.
- No se borran las escenas lineales.
- No se implementa guardado, navegación ni streaming.

## 4. Decisiones pendientes del responsable

| Decisión | Opciones | Recomendación |
|---|---|---|
| Duración de campaña | 6–8 h / 4–5 h | 6–8 h; la slice demuestra el bucle |
| Región | 2–4 km² de área densa; hasta ~8 km² con wilderness | 3,5 × 2,5 km totales para la campaña 01; 2 × 2 km para la slice |
| Portada | Cuatro campañas visibles / solo la 01 | Cuatro visibles, solo la 01 jugable; las otras “en diseño” |
| Campaña III | Ayacucho–Huanta / Jauja–Tarma / Lima–Huarochirí | Expediente comparativo; hipótesis Ayacucho–Huanta |
| Campaña IV | Mantaro + Huamachuco como epílogo / otra región | Mantaro; Huamachuco como epílogo narrado o secuencia final |
| Addons | Adoptar ya / spikes | Spikes en F1; adopción solo con medidas |

## 5. Criterios de la vertical slice (F3)

La F3 no se aprueba si falta uno de estos puntos:

- [ ] Territorio continuo de al menos 400 × 400 m, sin pantallas de carga exteriores.
- [ ] Comunidad con 8–12 casas, plaza, 3 interiores transitables y límite natural.
- [ ] 20–30 NPC, al menos 8 nombrados, rutinas de mañana, tarde y noche.
- [ ] Una misión principal de 3 etapas con una consecuencia que cambie el mundo.
- [ ] Dos actividades secundarias con sentido económico o social, no fetch.
- [ ] Un descubrimiento no marcado que el jugador pueda encontrar sin indicación.
- [ ] Ciclo día/noche con luz, horarios y descanso funcionales.
- [ ] Guardado/carga conserva misión, NPC, inventario, hora y un cambio del jugador.
- [ ] ≥ 30 FPS en Bajo y ≥ 60 FPS en Medio, 1080p, UHD 770; ≤ 350 draw calls; ≤ 250 MB VRAM; hitch < 50 ms; carga de sector < 150 ms.
- [ ] Cero errores y advertencias de GDScript procedentes de `res://`.
- [ ] Suite y recorrido de la slice en verde.
- [ ] 30–45 min de juego real en una pasada humana, con contenido no principal.
- [ ] 100 % del contenido usado clasificado y con fuente; 0 anacronismos sin declarar.
- [ ] El jugador puede volver a la comunidad sin marcador y describir un lugar descubierto.
- [ ] Acta de revisión con decisión: continuar, recortar o replantear.

## 6. Evidencia

- PR de documentación con enlaces verificados.
- Revisión del responsable en el PR.
- Entrada en la [bitácora](../bitacora.md).
