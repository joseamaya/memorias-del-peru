# Campaña 01 — Pachacútec: La defensa del Cusco

## 1. Premisa

Siglo XV. La confederación chanca avanza sobre el Cusco. Según la tradición recogida por varios cronistas, el inca gobernante y su heredero abandonan la ciudad, y un hijo del inca, Cusi Yupanqui, organiza su defensa. Tras la victoria, Cusi Yupanqui asume el nombre de Pachacútec e inicia la expansión que dará forma al Tahuantinsuyu.

El jugador recorre entornos andinos, convive con habitantes de una llacta y participa en los acontecimientos previos a la defensa y durante ella.

> La premisa resume una **tradición narrada en crónicas**, con versiones divergentes (ver §3). En el juego se presenta como tal, no como un relato único comprobado.

## 2. Pilares de la campaña

- Vida cotidiana de la llacta antes de la amenaza: trabajo agrícola, reciprocidad, rituales.
- Tensión creciente: noticias del avance chanca, abandono de la ciudad por la élite.
- La defensa como esfuerzo colectivo de ayllus y aliados.

## 3. Contexto historiográfico (resumen inicial)

Clasificación según [docs/07_convenciones_historicas.md](../../../docs/07_convenciones_historicas.md). Las referencias de este resumen son orientativas; las citas con edición, capítulo y página están en las fichas del [registro histórico](registro_historico.md).

| Aspecto | Estado de la cuestión | Clasif. |
|---|---|---|
| Guerra contra los chancas y defensa del Cusco por Cusi Yupanqui | Narrada por Juan de Betanzos (*Suma y narración de los Incas*, 1551), Pedro Cieza de León (*El señorío de los Incas*) y Pedro Sarmiento de Gamboa (*Historia de los Incas*, 1572), entre otros. | H (tradición) |
| Protagonista de la victoria | El Inca Garcilaso de la Vega (*Comentarios reales*, 1609) atribuye la victoria sobre los chancas a Inca Viracocha, no a Pachacútec. | H (discrepancia) |
| Fecha (c. 1438) | Procede de cronologías derivadas de crónicas (p. ej. la usada por John H. Rowe a partir de Cabello Valboa); su precisión es discutida. En el juego: “siglo XV”, sin año exacto en pantalla salvo nota explicativa. | R |
| Escala y unidad política de los chancas | Investigaciones arqueológicas en Andahuaylas (Bauer, Kellett y Aráoz Silva, *The Chanka: Archaeological Research in Andahuaylas (Apurimac), Peru*, 2010) cuestionan que existiera un estado chanca centralizado de la magnitud descrita por las crónicas. | A |
| Pururaucas (piedras que se convierten en guerreros) | Leyenda de la tradición recogida por Pachacuti Yamqui Salcamaygua (PCH-031). Se cuenta como creencia de los personajes, nunca como hecho ni como mecánica. | N / H (tradición) |
| Síntesis moderna | María Rostworowski, *Pachacútec Inca Yupanqui* (1953) e *Historia del Tahuantinsuyu* (1988). | — |

## 4. Grafía

- Interfaz: formas hispanizadas consolidadas para nombres muy conocidos (Pachacútec, Cusco, Viracocha, chanca).
- Términos culturales: forma de uso común en español con variante en quechua (alfabeto oficial) registrada en la ficha (p. ej. llacta / llaqta, chanca / chanka, ayllu). La forma quechua de “quero” está pendiente de verificar (PCH-004).
- **Pendiente:** elegir el diccionario de referencia del quechua para la campaña. Hasta entonces, toda forma quechua de las fichas se considera provisional.
- Decisión revisable por el asesor histórico/lingüístico cuando se incorpore.

## 5. Documentos de la campaña

| Documento | Estado |
|---|---|
| [registro_historico.md](registro_historico.md) | Completo para el slice: 19 fichas verificadas (7 sobre la comprobación del agente); PCH-014 fuera del slice |
| [alcance_vertical_slice.md](alcance_vertical_slice.md) | Referencia del acto I (mapa, assets y textos); el modelo de museo queda superado por ADR-0038 |
| [biblia_campana.md](biblia_campana.md) | **Aprobada (v1.0)** — diseño de los tres actos y del núcleo RPG (ADR-0038, ADR-0039) |
| Guion y personajes | En el alcance v2 §2, §5 y §6.4 |
| [guion_facilitador.md](guion_facilitador.md) | Listo para el piloto — sesiones de prueba |
| [plantilla_sesion.md](plantilla_sesion.md) | Plantilla de registro de cada sesión |
| [hoja_verificacion_fichas.md](hoja_verificacion_fichas.md) | Hoja de trabajo para verificar las fichas: dónde consultar cada fuente y correcciones detectadas |

## 6. Notas de producción (Fase 2)

- Modelo del quero: cilindro de bloqueo; la forma y la decoración incisa se ajustarán en la Fase 4.
- Fase 4: el quero, el pututu, el adoratorio, el telar y las dos viviendas tienen modelo generado por `assets/blender/pch_models.py` (ADR-0010); los personajes los genera `assets/blender/pch_people.py` con cuerpos de MakeHuman, ropa propia y captura de movimiento de CMU (ADR-0016, alcance v3.8). El ichu y la queñua (`pch_ichu_*`, `pch_quenua_*`) los reparte `scripts/world/vegetation.gd`.
- Sonido del quero (`shared_assets/audio/quero_bebida.wav`): era un placeholder sintético. Desde el 2026-11-11 es una grabación CC0 de Freesound, como el resto del audio (`shared_assets/audio/LICENSE.md`).
