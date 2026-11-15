# Checklist de la biblia — Campaña 01

- **Fecha:** 2026-11-15
- **Alcance:** los cinco actos, contra `biblia_campana.md` §4–§8 y §13
- **Método:** revisión de diseño + partida guionizada (`ARCO_OK`) + pruebas por acto

| Acto | ¿Se vive la pregunta? | ¿La decisión tiene consecuencia? | ¿El hecho está clasificado y citado? | Evidencia |
|---|---|---|---|---|
| I — La casa que se vacía | Sí: la noticia llega con el mensajero y la asamblea obliga a responder | Sí: recursos, oficio, `apoyo_*`, `confianza_sisa` y `mensajero_ayudado` pagan en II, IV y V | Sí: PCH-007, 011, 015, 016, 019, 021 | `test_act_one_tasks`, `test_assembly`, `test_campaign_progress` |
| II — El paso y la ciudad dividida | Sí: la marcha, el campamento, la emboscada y el Cusco dividido | Sí: sigilo, herido, maíz, explorador, aliados y preparación | Sí: PCH-022, 024, 026, 027, 028, 030, 031, 036 | `test_paso_sneak`, `test_campaign_progress`, `arc_playthrough` |
| III — La guerra de los chancas | Sí: la plaza resiste y la trampa obliga a elegir | Sí: `santuario_protegido/orden_llevada`, `costo_anca/costo_joven`, oleadas | Sí: PCH-002, 027, 029 | `test_act_three_cost`, `arc_playthrough` |
| IV — El precio de la victoria | Sí: el regreso, las cuentas y la asamblea | Sí: `hablo_en_asamblea`, `puma_reconciliado`, `asamblea_silencio`, noticia de Viracocha | Sí: PCH-032, 033 | `test_post_acts`, `test_end_card_body` |
| V — El nombre nuevo | Sí: la obra cierra el círculo y el nombre llega como tradición | Sí: `casa_reconstruida`, tres variantes de final | Sí: PCH-034, 035 | `test_end_card_body` |

## Decisiones que se notan

- **Acto I → II:** objetos `agua/maiz/manta/cuerda`, oficio, `confianza_sisa`.
- **Acto II → III:** `mensaje_chanca`, `herido_salvado/dejado`, `maiz_guardado/abandonado`, `scout_spared`, `aliados`, `preparacion_hecha`.
- **Acto III → IV:** `costo_anca/costo_joven`, `santuario_protegido/orden_llevada`.
- **Acto IV → V:** `hablo_en_asamblea`, `puma_reconciliado`, `asamblea_silencio`, `viracocha_muerto`.

## Pendientes que impiden cerrar la Fase 5

- Duración real de 40–50 min: la pasada guionizada dura 74,6 s; falta una partida humana cronometrada y ampliar contenido.
- Perfil Medio: 48,4–52,6 FPS, por debajo del objetivo comprometido de 60 FPS.
- Pase de arte y audio por acto.
- Prueba de humo manual de los cinco actos.

La campaña **pasa la checklist de diseño**; no cumple todavía las métricas de duración y rendimiento de `docs/01`.
