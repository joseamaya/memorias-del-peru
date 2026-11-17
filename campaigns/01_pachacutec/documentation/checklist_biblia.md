# Checklist de la biblia — Campaña 01

- **Fecha:** 2026-11-16
- **Alcance:** los cinco actos, contra `biblia_campana.md` §4–§8 y §13
- **Método:** revisión de diseño + partida guionizada (`ARCO_OK`) + pruebas por acto

| Acto | ¿Se vive la pregunta? | ¿La decisión tiene consecuencia? | ¿El hecho está clasificado y citado? | Evidencia |
|---|---|---|---|---|
| I — La casa que se vacía | Sí: la noticia llega con el mensajero y la asamblea obliga a responder; la familia y Puma se colocan en la plaza | Sí: recursos, oficio, `confianza_sisa` y `mensajero_ayudado` pagan en II, IV y V | Sí: PCH-007, 011, 015, 016, 019, 021 | `test_act_one_tasks`, `test_assembly`, `test_campaign_progress` |
| II — El paso y la ciudad dividida | Sí: la marcha, el campamento, la emboscada y el Cusco dividido | Sí: sigilo, herido, maíz, explorador, aliados y preparación; cargar a Anca reduce el aliento máximo y dejarlo consume agua y coca | Sí: PCH-022, 024, 026, 027, 028, 030, 031, 036 | `test_paso_sneak`, `test_campaign_bible`, `arc_playthrough` |
| III — La guerra de los chancas | Sí: la plaza resiste y la trampa obliga a elegir antes de la defensa | Sí: `santuario_protegido/orden_llevada`, `costo_anca/costo_joven`, oleadas | Sí: PCH-002, 027, 029 | `test_act_three_cost`, `test_campaign_bible`, `arc_playthrough` |
| IV — El precio de la victoria | Sí: el regreso, las cuentas variables, la asamblea y el mensajero de la noticia | Sí: `hablo_en_asamblea`, `puma_reconciliado`, `asamblea_silencio`, cuentas según coste, aliados y noticia de Viracocha | Sí: PCH-032, 033 | `test_post_acts`, `test_campaign_bible`, `test_end_card_body` |
| V — El nombre nuevo | Sí: la obra cierra el círculo, el oficio deja marca y el nombre llega como tradición | Sí: `casa_reconstruida`, `obra_oficio`, `santuario_protegido/orden_llevada` y tres variantes de final | Sí: PCH-034, 035 | `test_end_card_body`, `test_campaign_bible` |

## Decisiones que se notan

- **Acto I → II:** objetos `agua/maiz/manta/cuerda`, oficio, `confianza_sisa`.
- **Acto II → III:** `mensaje_chanca`, `herido_salvado/dejado`, `maiz_guardado/abandonado`, `scout_spared`, `aliados`, `preparacion_hecha`.
- **Acto III → IV:** `costo_anca/costo_joven`, `santuario_protegido/orden_llevada`.
- **Acto IV → V:** `hablo_en_asamblea`, `puma_reconciliado`, `asamblea_silencio`, `viracocha_muerto`, `obra_oficio`.

## Revisión histórica humana pendiente

Las fichas PCH-032 a PCH-036 están verificadas documentalmente por el agente
(2026-11-15), pero la Fase 5 exige una revisión humana. Para cerrarla, una
persona debe contrastar en las ediciones citadas:

| Ficha | Qué comprobar | Fuente principal |
|---|---|---|
| PCH-032 | Reparto y autoridad de los ayllus tras la victoria; la asamblea concreta es reconstrucción | Betanzos, I parte, caps. VI–X; Sarmiento, caps. XXV–XXVII; Rostworowski, *Historia del Tahuantinsuyu* (1988) |
| PCH-033 | Muerte de Viracocha después de la victoria, sin fecha ni lugar únicos | Betanzos, I parte, caps. VI–X; Sarmiento, caps. XXV–XXVII; Garcilaso, lib. V, como contraste |
| PCH-034 | El nombre nuevo como tradición de los cronistas, no como acto documentado | Betanzos; Sarmiento; Rostworowski, *Pachacútec Inca Yupanqui* (1953) |
| PCH-035 | Técnicas de reconstrucción tomadas de la vivienda, la terraza y el corral ya documentados | PCH-007, PCH-008 y PCH-021 y sus fuentes |
| PCH-036 | Reconocimiento previo como reconstrucción sobre el avance chanca documentado | PCH-003, PCH-024 y PCH-030 y sus fuentes |

Firma de la revisión humana: ____________________ · Fecha: __________


## Pendientes que impiden cerrar la Fase 5

- Duración real de 43–50 min: falta la partida humana cronometrada. El protocolo ya está listo (`--session` y `tools/session_duration.py`); la pasada guionizada (1:58) solo sirve como suelo.
- Remate de arte: texturas finas de roca y props de detalle.
- Prototipo Quaternius: cuerpos re-proporcionados, caras con textura de 1024, cejas propias, mujer mayor, hombre joven y mano en primera persona hechos. Faltan articulación por dedo, presupuesto del Cusco y medición limpia; no se sustituye el elenco hasta cerrarlo.
- Audio: mezcla escuchada por acto.
- Prueba de humo manual de los cinco actos.
- Revisión histórica humana de PCH-032–036 (tabla anterior).

**Las 22 escenas del guion de escenas están implementadas y sin deudas de escena. El combate y el HUD se cerraron en 4.7: honda, porra y escudo, munición, viñeta de salud, respiración y sin barra fija de estado.** Quedan abiertas la duración, el remate de arte/audio y la verificación humana. La aceptación por escena vive en [guion_escenas.md](guion_escenas.md).
