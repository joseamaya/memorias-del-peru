# Campaña 01 — Pachacútec: El despertar del Sol

## 1. Premisa

Siglo XV. La confederación chanca avanza sobre el Cusco. Según la tradición recogida por varios cronistas, el inca gobernante y su heredero abandonan la ciudad, y un hijo del inca, Cusi Yupanqui, organiza su defensa. Tras la victoria, Cusi Yupanqui asume el nombre de Pachacútec e inicia la expansión que dará forma al Tahuantinsuyu.

El jugador es Rumi, un joven de una llacta del valle. Vive la mañana en que llega la noticia, cruza el paso con la comitiva, participa en la defensa y vuelve a una casa que ya no es la misma.

> La premisa resume una **tradición narrada en crónicas**, con versiones divergentes (ver §3). En el juego se presenta como tal, no como un relato único comprobado.

## 2. Pilares de la campaña

- Vida cotidiana de la llacta antes de la amenaza: trabajo agrícola, reciprocidad, rituales.
- Tensión creciente: noticias del avance chanca, abandono de la ciudad por la élite.
- La defensa como esfuerzo colectivo de ayllus y aliados.
- El costo: la victoria no devuelve lo perdido.

## 3. Contexto historiográfico (resumen)

Clasificación según [docs/07_convenciones_historicas.md](../../../docs/07_convenciones_historicas.md). Las referencias de este resumen son orientativas; las citas con edición, capítulo y página están en las fichas del [registro histórico](registro_historico.md) y el detalle en el [expediente](expediente_historico.md).

| Aspecto | Estado de la cuestión | Clasif. |
|---|---|---|
| Guerra contra los chancas y defensa del Cusco por Cusi Yupanqui | Narrada por Juan de Betanzos (*Suma y narración de los Incas*, 1551), Pedro Cieza de León (*El señorío de los Incas*) y Pedro Sarmiento de Gamboa (*Historia de los Incas*, 1572), entre otros. | H (tradición) |
| Protagonista de la victoria | El Inca Garcilaso de la Vega (*Comentarios reales*, 1609) atribuye la victoria sobre los chancas a Inca Viracocha, no a Pachacútec. | H (discrepancia) |
| Fecha (c. 1438) | Procede de cronologías derivadas de crónicas (p. ej. la usada por John H. Rowe a partir de Cabello Valboa); su precisión es discutida. En el juego: «siglo XV», sin año exacto en pantalla salvo nota explicativa. | R |
| Escala y unidad política de los chancas | Investigaciones arqueológicas en Andahuaylas (Bauer, Kellett y Aráoz Silva, *The Chanka*, 2010) cuestionan que existiera un estado chanca centralizado de la magnitud descrita por las crónicas. | A |
| Pururaucas (piedras que se convierten en guerreros) | Leyenda de la tradición recogida por Pachacuti Yamqui Salcamaygua (PCH-031). Se cuenta como creencia de los personajes, nunca como hecho ni como mecánica. | N / H (tradición) |
| Síntesis moderna | María Rostworowski, *Pachacútec Inca Yupanqui* (1953) e *Historia del Tahuantinsuyu* (1988). | — |

## 4. Grafía

- Interfaz: formas hispanizadas consolidadas para nombres muy conocidos (Pachacútec, Cusco, Viracocha, chanca).
- Términos culturales: forma de uso común en español con variante en quechua (alfabeto oficial) registrada en la ficha (p. ej. llacta / llaqta, chanca / chanka, ayllu).
- **Nombres ficticios:** Rumi, Sisa, Asto, Puma y Anca son formas provisionales, registradas como N. La norma de escritura quechua sigue pendiente de elección; hasta entonces, toda forma quechua es provisional.
- Decisión revisable por el asesor histórico/lingüístico cuando se incorpore.

## 5. Documentos de la campaña

| Documento | Estado |
|---|---|
| [biblia_campana.md](biblia_campana.md) | **v1.1 (narrativa)** — los cinco actos, el protagonista, el elenco, los sistemas y las banderas; la estructura de mundo se adapta en `mundo/` |
| [mundo/](mundo/README.md) | **v0.1 (propuesta F0)** — expediente geográfico, mapa conceptual, sectores y reestructuración narrativa a mundo abierto |
| [expediente_historico.md](expediente_historico.md) | **v1.0** — cronología, lugares, personajes, cultura material, controversias y ficción declarada |
| [registro_historico.md](registro_historico.md) | 29 fichas verificadas; PCH-025 (armadura acolchada) fuera del juego; PCH-032 a PCH-036 verificadas el 2026-11-15 |
| [hoja_verificacion_fichas.md](hoja_verificacion_fichas.md) | Hoja de trabajo para verificar las fichas: dónde consultar cada fuente y correcciones detectadas |
| [guion_campana.md](guion_campana.md) | **Cerrado (v1.1)** — 15 secciones, fichas de misión, banderas y finales |
| [guion_escenas.md](guion_escenas.md) | **v1.0** — 22 escenas con bloqueo, cámara, textos, banderas y aceptación |
| [guia_visual.md](guia_visual.md) | Idea visual, paleta por acto, escala, formas, personajes y capturas de referencia |
| [prototipo_maniqui.md](prototipo_maniqui.md) | Elenco activo de maniquíes UAL1: looks, integración, rendimiento y capturas |
| [personajes_quaternius.md](personajes_quaternius.md) | Histórico del elenco UBC retirado; se conserva como documento |
| [checklist_biblia.md](checklist_biblia.md) | Checklist de diseño por acto; pendientes de duración y arte/audio |

## 6. Estado de construcción

**La versión lineal está congelada desde el 2026-11-19.** Los actos I–V se juegan de principio a fin con blockout y materiales propios; el guion, el guion de escenas y las 141 pruebas se conservan como banco de pruebas. El elenco activo son diez maniquíes UAL1 (CC0) integrados en `NpcActor` y `CharacterModelVisual`; el legado UBC se retiró y su documento histórico se conserva en [personajes_quaternius.md](personajes_quaternius.md).

**La campaña nueva se redefine como mundo abierto regional.** La región, los sectores y la adaptación de los cinco actos viven en [mundo/](mundo/README.md). La implementación lineal no se amplía: se usa como referencia de contenido, tono y pruebas hasta que la vertical slice la sustituya.

El estado por tarea y la evidencia viven en la [ficha de F0](../../../docs/fases/F0-redefinicion-mundo-abierto.md); el estado de las fases, en [docs/05](../../../docs/05_plan_de_implementacion.md). La [ficha de F4](../../../docs/fases/F4-arte-audio-equilibrio.md) y la F5 lineal quedan congeladas.

## 7. Notas de producción

- Los modelos, texturas y audios viven en `assets/` con su licencia registrada.
- Los guiones de Blender (`assets/blender/`) generan los modelos de forma reproducible.
- Los objetos rituales reutilizables (quero y ofrenda) conservan su escena y su script.
