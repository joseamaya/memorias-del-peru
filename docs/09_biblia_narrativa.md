# 09 — Biblia narrativa general

- **Versión:** 2.0 (mundo abierto regional) — 2026-11-19
- **Estado:** aprobada como capa narrativa de la antología
- **Ámbito:** qué se cuenta y con qué reglas. No fija fases, sistemas ni pruebas.
- **Documentos que la desarrollan:** [01 — Visión y alcance](01_vision_y_alcance.md), [11 — Diseño de mundo](11_diseno_de_mundo.md), [12 — Campañas](12_campanas.md), [05 — Plan de implementación](05_plan_de_implementacion.md), [07 — Convenciones históricas](07_convenciones_historicas.md) y la documentación de cada campaña.

> **Cambio de modelo (2026-11-19).** Los “actos” siguen siendo unidades dramáticas, pero dejan de ser mapas separados: se viven como **fases históricas del mismo territorio**. La estructura lineal de cinco escenas se conserva como material histórico en la campaña 01, no como norma de las campañas nuevas.

---

## 0. Cómo se usa este documento

1. **Manda en lo narrativo.** Toda campaña, guion, misión y diálogo debe poder justificarse con esta biblia. Si un guion la contradice, se corrige el guion.
2. **No manda en lo técnico ni en el proceso.** Las fases, los sistemas, las pruebas y el rendimiento viven en `docs/01`–`08` y `docs/11`–`14`.
3. **Cada campaña tiene su propio documento de guion** (ver §10). Esta biblia da el marco; el detalle de protagonista, elenco, misiones y banderas vive en la documentación de la campaña.
4. **Una campaña es un producto.** Se desarrolla y se cierra una antes de abrir la siguiente (§11). Tener cuatro campañas diseñadas no significa construirlas a la vez.
5. **Nada entra al juego sin ficha.** Todo elemento histórico relevante se registra con clasificación y fuente; ver §9 y [docs/07](07_convenciones_historicas.md).
6. **El territorio es narrativo.** Un lugar no es un decorado: tiene historia, economía, habitantes y memoria. La región se diseña antes de escribir sus escenas.

### 0.1. Glosario

| Término | Significado |
|---|---|
| Campaña | Una época histórica jugable, independiente, con protagonista propio |
| Región | Territorio continuo y explorable de una campaña; 2–4 km² de área densa y hasta ~8 km² con wilderness |
| Sector | Unidad de composición y streaming del territorio (256–512 m) |
| Fase histórica | Estado del mundo que cambia la región: paz, noticia, guerra, posguerra, obra |
| Acto | Unidad dramática de una campaña; en mundo abierto se vive como fase, no como mapa |
| Secuencia controlada | Escena con control limitado del jugador: asamblea, batalla, sueño, clímax |
| Episodio | Unidad menor que un acto: viaje, asedio, asamblea |
| Expediente | Dossier histórico y geográfico de una campaña antes de escribir su guion |
| Ficha | Entrada del registro histórico con clasificación, fuente y estado |
| GD / GR / GN | Geografía documentada, reconstrucción aproximada o ficción necesaria |

---

# 1. Identidad del videojuego

## 1.1. Concepto central

*Memorias del Perú* es una antología de **RPG históricos de mundo abierto regional** en primera persona. Cada campaña permite vivir un momento decisivo de la historia peruana desde la perspectiva de una persona común, en un territorio continuo que se puede recorrer, habitar y recordar.

El jugador no encarna a los grandes líderes históricos. Vive la historia desde abajo: como habitante, trabajador, mensajero, combatiente o integrante de una comunidad que se ve involucrada en acontecimientos que transforman el país.

Cada campaña presenta un protagonista diferente, con familia, relaciones, motivaciones, conflictos y evolución personal. También presenta una región con identidad geográfica, económica y cultural propia, y una comunidad que sigue viviendo cuando el jugador no está mirando.

Los personajes históricos aparecen como parte del mundo y conservan su importancia. El protagonista ficticio participa en los acontecimientos sin reemplazar a sus protagonistas históricos ni apropiarse de sus decisiones.

## 1.2. Promesa al jugador

No se trata de memorizar fechas ni de recorrer un pasillo de escenarios históricos.

El jugador conocerá cómo vivía la gente, qué temía, qué defendía, qué perdía y qué esperaba de su futuro. Los acontecimientos históricos serán experiencias que deberá atravesar, pero también podrá salir de su comunidad, tomar un camino distinto, encontrar a alguien, descubrir un lugar, trabajar y volver a casa.

**El territorio y sus habitantes deben existir más allá de la misión activa.**

## 1.3. Principios narrativos

1. **La historia desde las personas:** los grandes acontecimientos se experimentan a través de vidas individuales.
2. **Rigor histórico:** los hechos documentados son el marco de la ficción.
3. **Protagonistas creíbles:** cada personaje actúa según su condición, conocimientos, recursos y contexto.
4. **Personajes históricos respetados:** no se modifican sus decisiones fundamentales para favorecer la ficción.
5. **Consecuencias humanas:** los conflictos afectan a familias, comunidades y relaciones.
6. **Diversidad de experiencias:** cada campaña tiene tono, ritmo y conflicto particular.
7. **Historia sin lecciones forzadas:** el aprendizaje surge de explorar, conversar, observar y participar.
8. **Ambigüedad humana:** evitar representar a un bando entero como bueno o malo.
9. **El lugar importa:** cada región tiene geografía, economía, comunidad y memoria propias.
10. **La vida sigue:** el mundo ofrece trabajo, rutinas, relaciones y descubrimientos que no dependen de la misión principal.

---

# 2. Estructura general

## 2.1. Cuatro campañas independientes

| Campaña | Título | Periodo | Conflicto central | Estado |
|---|---|---|---|---|
| I | El despertar del Sol | Siglo XV, guerra contra los chancas | Defender el Cusco y vivir el ascenso de Pachacútec | **Redefinición a mundo abierto** |
| II | La llama de la rebelión | 1780–1783 | La rebelión de Túpac Amaru II y sus consecuencias | Concepto regional; expediente pendiente |
| III | Entre dos banderas | 1820–1824 | El proceso de independencia del Perú | Concepto regional; expediente comparativo |
| IV | Los últimos defensores | 1881–1883 | La resistencia de la Breña durante la Guerra del Pacífico | Concepto regional; expediente pendiente |

Cada campaña debe poder disfrutarse por separado. No requiere conocer las otras para comprender su historia.

La conexión entre protagonistas mediante memorias ancestrales queda fuera del alcance de esta versión. La «Memoria» del diario es una pestaña de conocimiento histórico, no un vínculo entre campañas.

**Nombre visible:** la pantalla de título muestra el nombre del juego y el de la campaña en curso. En la campaña 01 la línea de campaña es *El despertar del Sol*; el nombre descriptivo completo —*Pachacútec y la defensa del Cusco*— se usa en documentación.

## 2.2. Modelo de mundo abierto

Cada campaña se desarrolla en **una región continua**, no en una sucesión de niveles. El conflicto histórico se vive como **fases del mismo territorio**. La campaña 01 no hereda las fases de la versión anterior; esta tabla es la hipótesis de trabajo que se confirma al rediseñarla:

| Fase | Estado | Qué cambia |
|---|---|---|
| Paz | Vida cotidiana | Rutinas, caminos y comunidad |
| Noticia | Movilización | Refugiados, precios, patrullas |
| Guerra | Conflicto | Accesos, combate, ausencias |
| Posguerra | Vacío y cuentas | Casas vacías, heridos, duelos |
| Obra | Reconstrucción | Obras y cierre |

Las secuencias controladas se reservan para asambleas, batallas, sueños y clímax. El resto del mundo sigue siendo explorable y habitable antes, durante y después de la historia principal.

La región, los sectores y las experiencias se diseñan en [docs/11](11_diseno_de_mundo.md). Cada campaña declara su escala, sus límites y su clasificación geográfica antes de construir terreno.

---

# 3. Campaña I — El despertar del Sol

## 3.1. Identidad

- **Periodo:** siglo XV, durante el conflicto entre los incas y los chancas.
- **Región:** valle del Cusco y aproximación occidental: la llacta, la quebrada, el paso y el Cusco de 1438. La distancia está comprimida y el valle intermedio es ficción declarada.
- **Personaje histórico central:** Cusi Yupanqui, posteriormente conocido como Pachacútec.
- **Tono:** épico, íntimo, de supervivencia y transformación.

## 3.2. Premisa

La vida cotidiana de una comunidad del valle del Cusco se ve amenazada por la expansión chanca y la crisis política del poder inca.

Cuando la amenaza alcanza la ciudad, las divisiones internas, la incertidumbre y la decisión de abandonar el Cusco ponen a la población ante una situación límite. Mientras Cusi Yupanqui organiza la resistencia, la comunidad se ve involucrada en la defensa de su hogar y en una guerra que cambiará el destino de la región.

La historia no es la de un gran general. Es la de una persona que debe proteger a los suyos, sobrevivir y encontrar su lugar en un mundo que está cambiando.

## 3.3. Protagonista

**Por definir.** La campaña anterior tenía un protagonista inventado; se retiró con su trama el 2026-11-20. El nuevo se diseña con el contexto histórico delante: edad, oficio, familia, miedo concreto y motivación que vaya más allá de combatir. No es un guerrero excepcional al empezar; su experiencia y capacidades evolucionan con lo que vive.

## 3.4. Elenco

- **Cusi Yupanqui:** figura central de la resistencia y del cambio político. El protagonista puede conocerlo, recibir instrucciones de sus representantes y presenciar su ascenso, pero no dirigir sus decisiones.
- **Viracocha Inca:** figura del poder establecido, cuya retirada y decisiones deben contextualizarse históricamente. No es un villano: es un gobernante que calcula.
- **La comunidad:** familia, autoridades locales y vecinos; representan lo que está en juego para una persona común.
- **Chancas:** exploradores, guerreros y comunidades; no se representan como un bloque homogéneo.

Los personajes secundarios tendrán objetivos propios y no existirán solo para entregar misiones. Ningún nombre de personaje está fijado.

## 3.5. Fases (hipótesis de trabajo)

| Fase | Pregunta dramática | Mundo |
|---|---|---|
| Paz | ¿Qué haces cuando la noticia llega? | Comunidad habitable, caminos abiertos |
| Noticia | ¿Hasta dónde estás dispuesto a llegar? | Refugiados, controles, precios |
| Guerra | ¿Quién sostiene la línea? | Accesos restringidos, ausencias |
| Posguerra | ¿Qué queda cuando la victoria llega? | Casas vacías, heridos, duelo |
| Obra | ¿Qué se hace con lo que queda? | Terrazas, corral y casa reparados |

Las cinco fases son una **hipótesis derivada del relato histórico**, no una decisión cerrada: se confirman o se recortan al rediseñar la campaña. Las secuencias controladas se reservan para clímax, asambleas, batallas y sueños.

## 3.6. Consideraciones históricas

La guerra chanca y la defensa del Cusco están narradas por Betanzos, Cieza de León y Sarmiento de Gamboa, entre otros, con versiones divergentes. La fecha de 1438 procede de cronologías derivadas de crónicas y es discutida. La escala y unidad política chanca son objeto de debate arqueológico (Bauer, Kellett y Aráoz Silva). Los pururaucas se cuentan como creencia de los personajes, nunca como hecho ni como mecánica.

La campaña no cambia el resultado histórico. El protagonista sostiene su parte, la pierde o la conserva, y paga el precio.

## 3.7. Qué queda de la versión anterior

Nada de la trama inventada: ni el protagonista, ni su familia, ni el elenco ficticio, ni las misiones, ni las escenas. Se retiraron el 2026-11-20 y solo viven en el historial de git.

Quedan el contexto histórico, el territorio del [dossier de mundo](../campaigns/01_pachacutec/documentation/mundo/README.md) y las fichas del registro histórico.

# 4. Campaña II — La llama de la rebelión

## 4.1. Identidad

- **Periodo:** 1780–1783.
- **Región propuesta:** corredor del Vilcanota y punas de Canas/Canchis: Tinta, Tungasuca, Pampamarca, Sangarará, Sicuani y caminos de altura. Cusco se trata como destino lejano o secuencia controlada, no como parte del mapa continuo.
- **Personajes históricos centrales:** Túpac Amaru II, Micaela Bastidas y los dirigentes de la rebelión.
- **Tono:** tensión, indignación, esperanza y tragedia.
- **Fases:** orden colonial, agitación, rebelión, represión y resistencia que continúa.

## 4.2. Premisa

El protagonista vive en una comunidad andina bajo el sistema colonial. Su vida está condicionada por tributos, repartos, obligaciones laborales y abusos de las autoridades. La rebelión encabezada por Túpac Amaru II transforma su entorno; lo que comienza como una crisis política se convierte en un levantamiento de grandes dimensiones.

El protagonista debe decidir cómo involucrarse mientras intenta proteger a su familia y a su comunidad. A medida que la rebelión crece, descubre que luchar contra un sistema injusto no garantiza que todos compartan los mismos objetivos ni que el movimiento esté libre de contradicciones.

## 4.3. Protagonista y elenco

**Protagonista provisional:** joven arriero o comunero de la región de Tinta. Su ocupación debe justificar desplazamientos, relaciones sociales y participación en los acontecimientos. Tiene familia afectada por el orden colonial, relación con caminos o actividades productivas y una motivación inicial concreta, no necesariamente política.

**Elenco:** Túpac Amaru II y Micaela Bastidas como figuras históricas; dirigentes y colaboradores con intereses distintos; autoridades coloniales con lógica propia; familias y comunidades que apoyan, temen o rechazan la rebelión.

## 4.4. Mundo y bucle

- **Mundo:** valle colonial con pueblos, haciendas, obrajes, tambos, mercados, iglesia, caminos y puna.
- **Bucle:** transportar carga, cumplir obligaciones, escuchar rumores, negociar, ayudar, participar en la red de la rebelión.
- **Sistemas propios:** tributo/reparto, trueque, mercado, redes de información, reputación ante autoridades, comunidades y líderes.
- **Fases:** orden colonial → noticia y agitación → rebelión abierta → represión → resistencia que continúa.

## 4.5. Límites y consideraciones históricas

La rebelión debe representarse como un movimiento complejo, con etapas, liderazgos y objetivos distintos. No se reduce a la captura y ejecución de Túpac Amaru II. La participación de comunidades indígenas, mestizos, criollos y otros sectores se investiga y se representa sin simplificaciones.

Cusco y la ejecución de los líderes no caben en un mapa continuo de 4 km². La región se centra en Tinta/Canas/Canchis; Cusco se trata como destino lejano o secuencia controlada. No se teleporta al jugador por conveniencia.

---

# 5. Campaña III — Entre dos banderas

## 5.1. Identidad

- **Periodo:** 1820–1824.
- **Región recomendada:** **Ayacucho–Huanta–Cangallo**, sujeta a expediente comparativo. Alternativas: Jauja–Tarma–Huancayo y Lima–Huarochirí–Yauyos.
- **Personajes históricos centrales:** José de San Martín, Simón Bolívar, José de la Riva-Agüero, José Bernardo de Tagle y los liderazgos locales de la región elegida.
- **Tono:** incertidumbre, intriga, esperanza y conflicto moral.
- **Fases:** orden virreinal, rumores, guerra, independencia proclamada, desenlace y posguerra.

## 5.2. Por qué Ayacucho–Huanta–Cangallo

Es una región coherente para una persona común: pueblos, haciendas, coca, puna, caminos y redes de información. Permite vivir la guerra irregular, la lealtad dividida y la logística antes que las grandes batallas. La batalla de Ayacucho de 1824 puede vivida como acontecimiento de mundo o secuencia controlada, sin convertir al protagonista en su héroe.

La proclamación de Lima y la campaña de San Martín se viven como noticias, cartas y rumores que llegan a la sierra; no se finge que el protagonista está en todos los frentes. La región definitiva se fija en el expediente comparativo.

## 5.3. Premisa

El protagonista vive el proceso de independencia en una región donde las lealtades políticas, familiares y económicas no coinciden. Empieza por razones personales y termina participando en una transformación que supera sus expectativas. La independencia no es una decisión sencilla ni un proceso uniforme: para algunos significó esperanza; para otros, incertidumbre, pérdidas o nuevas obligaciones.

## 5.4. Protagonista y elenco

**Protagonista provisional:** joven mensajero, arriero o colaborador de redes patriotas. Su actividad le permite desplazarse y transportar información; tiene familia o comunidad dividida y un objetivo personal que se transforma.

**Elenco:** representantes patriotas y realistas con motivaciones humanas; autoridades locales; comerciantes, campesinos y artesanos; una familia dividida; un compañero de campaña que no comparte necesariamente las mismas convicciones.

## 5.5. Mundo y bucle

- **Mundo:** pueblos, haciendas, coca, puna, caminos, cuarteles y redes de información.
- **Bucle:** llevar mensajes, ocultar personas o recursos, negociar, elegir bando, participar en acciones locales.
- **Sistemas propios:** información y rumores, confianza de facciones, riesgo de delación, logística de guerrilla.
- **Fases:** orden virreinal → rumores → guerra → independencia proclamada → desenlace militar y posguerra.

## 5.6. Límites y consideraciones históricas

La campaña distingue las proclamaciones locales, la declaración de independencia y el desenlace militar de 1824. No presenta la independencia como una decisión única ni como un proceso uniforme. No todos los realistas son crueles ni todos los patriotas idealistas. La región se decide con fuentes, no por comodidad.

---

# 6. Campaña IV — Los últimos defensores

## 6.1. Identidad

- **Periodo:** 1881–1883.
- **Región recomendada:** valle del Mantaro y puna hacia Ayacucho: Jauja, Concepción, Huancayo, Pucará y Marcavalle.
- **Personaje histórico central:** Andrés Avelino Cáceres.
- **Tono:** supervivencia, resistencia, sacrificio y reconstrucción.
- **Fases:** ocupación, resistencia, campaña de la sierra, sacrificio y posguerra.

## 6.2. Premisa

El protagonista vive en una comunidad de la sierra central durante la Guerra del Pacífico. La ocupación, las requisiciones, la violencia y la incertidumbre alteran la vida cotidiana. La resistencia organizada por Cáceres necesita el apoyo de las comunidades y de las montoneras.

El protagonista termina involucrado en una lucha donde el conocimiento del territorio, la cooperación y la resistencia son fundamentales. La campaña muestra tanto la dimensión militar como el coste que la guerra impone a la población.

## 6.3. Protagonista y elenco

**Protagonista provisional:** campesino o montonera de la sierra central. Tiene familia o comunidad que proteger, conocimiento del territorio, una actividad cotidiana ligada al entorno y un motivo personal para involucrarse. No se convierte en comandante capaz de decidir el rumbo de la campaña.

**Elenco:** Cáceres como figura militar y política, sin omnipotencia; integrantes de montoneras con motivaciones distintas; autoridades y líderes locales; familia y población civil con presencia narrativa.

## 6.4. Mundo y bucle

- **Mundo:** valle, pueblos, haciendas, puentes, quebradas, cuevas, pastos y rutas de altura.
- **Bucle:** sobrevivir a requisiciones, ocultar recursos, guiar, abastecer, emboscar, reconstruir.
- **Sistemas propios:** ganado y agricultura, ocultamiento, reputación ante montoneras y población, represalias.
- **Fases:** ocupación → resistencia → campaña de la sierra → sacrificio → posguerra.

## 6.5. Huamachuco

Huamachuco (1883) está muy lejos del Mantaro y no cabe en un mapa continuo. La campaña cierra su región con la campaña de 1882 y trata Huamachuco como **epílogo narrado o secuencia final controlada**, con decisión del responsable. No se finge un viaje continuo de cientos de kilómetros.

## 6.6. Consideraciones históricas

La Campaña de la Breña debe mostrar la relación entre fuerzas regulares, montoneras y comunidades. Se evita idealizar la guerra o representar a la población como un bloque uniforme. Se investigan las diferencias regionales, las operaciones militares, la logística y las consecuencias de la ocupación.

---

# 7. Identidad diferenciada de las campañas

| Elemento | I — Pachacútec | II — Túpac Amaru II | III — Independencia | IV — Breña |
|---|---|---|---|---|
| Conflicto | Defensa y cambio político | Rebelión | Ruptura del orden colonial | Resistencia ante ocupación |
| Región | Valle del Cusco y aproximación occidental | Vilcanota: Tinta–Canas–Canchis | Ayacucho–Huanta (sujeta a expediente) | Valle del Mantaro y puna |
| Escala | ~3,5 × 2,5 km totales; 2–4 km² densos | ~4 × 3 km; 2–4 km² densos | ~4 × 3 km; 2–4 km² densos | ~4 × 3 km; 2–4 km² densos |
| Motivación inicial | Proteger el hogar | Sobrevivir a los abusos | Proteger a los suyos | Proteger la comunidad |
| Evolución | Participar en una transformación | Asumir el coste de rebelarse | Elegir y sostener una causa | Resistir y reconstruir |
| Tono | Épico e íntimo | Trágico y tenso | Esperanzador y ambiguo | Crudo y resiliente |
| Rasgo de mundo | Reciprocidad, terrazas, guerra chanca | Economía colonial, caminos, mercados | Información, guerrilla, divisiones | Logística, ocultamiento, represalias |

La superficie total incluye wilderness y aproximaciones; el **área densa** (asentamientos, campos, rutas y POI) es de 2–4 km².

---

# 8. Reglas para escribir los guiones

## 8.1. Protagonistas

Cada protagonista debe tener nombre y edad, procedencia y entorno familiar, ocupación y posición social, personalidad y defectos, motivación inicial, miedo principal, relaciones importantes, evolución emocional y objetivo final. No debe ser un héroe perfecto ni tener conocimientos que no corresponden a su época o condición.

## 8.2. Personajes secundarios

Cada personaje importante debe tener objetivo propio, motivación, relación con el protagonista, conflicto personal y evolución. Los personajes históricos no son dispensadores de misiones.

## 8.3. Misiones

Cada misión tiene razón narrativa y consecuencia. Se evitan las misiones que solo consisten en eliminar enemigos, transportar objetos sin contexto, hablar para recibir otra tarea o viajar sin que ocurra algo significativo.

Se combinan exploración, interacción social, actividades cotidianas, investigación, reconocimiento, comunicación, supervivencia, combate y decisiones personales.

**Reglas de mundo abierto:**

- La misión no es la única razón para recorrer el territorio: el mundo ofrece descubrimientos, oficios, relaciones y rumores por sí mismo.
- Las indicaciones se dan con personas, hitos y caminos; no con marcadores flotantes como única guía.
- Las misiones secundarias nacen de personas y lugares concretos, no de una lista genérica.
- Las secuencias controladas se reservan para asambleas, batallas, sueños y clímax; el resto se juega en el mundo.
- Una misión no puede resolverse con una escena lineal nueva si el mismo contenido cabe en el territorio.

## 8.4. Combate

El combate surge de las circunstancias de cada periodo. No todos los protagonistas son soldados profesionales. Las batallas históricas se representan desde una escala y perspectiva verosímiles para el protagonista. El combate no cambia el resultado histórico.

## 8.5. Diálogos

Los diálogos reflejan relaciones, evitan explicaciones históricas artificiales, usan vocabulario coherente con el periodo sin dificultar la comprensión, incorporan lenguas y formas de comunicación pertinentes con asesoría y permiten descubrir información mediante conversaciones naturales.

La norma de escritura de las lenguas originarias se fija por campaña. Mientras no exista, toda forma quechua es provisional.

## 8.6. Decisiones

Las decisiones pueden afectar relaciones personales, confianza, recursos, oportunidades, conflictos secundarios y supervivencia de personajes ficticios. No cambian arbitrariamente el resultado de acontecimientos históricos fundamentales.

## 8.7. Muerte del protagonista

El protagonista es ficticio y puede morir, pero su muerte nunca cambia el hecho histórico: la campaña se reanuda desde el último guardado o punto seguro y el desenlace documentado se mantiene. La derrota del jugador no es una derrota de la historia.

## 8.8. NPC y vida cotidiana

Los NPC importantes tienen casa, oficio, horario, relaciones y memoria. Los NPC de comunidad tienen rutinas y estado; los ambientales no necesitan simulación compleja. El mundo no se detiene cuando el jugador no mira, pero tampoco simula lo que no importa.

---

# 9. Criterios de rigor histórico

Cada campaña debe contar con un **expediente histórico y geográfico** antes de cerrar su guion. Debe contener:

1. Cronología de acontecimientos.
2. Localizaciones y desplazamientos.
3. Geografía histórica y clasificación del territorio (GD/GR/GN).
4. Personajes históricos y sus roles.
5. Organización política y social.
6. Vestimenta, arquitectura, herramientas y armamento.
7. Actividades cotidianas y economía.
8. Costumbres, creencias y prácticas culturales.
9. Fuentes primarias y estudios historiográficos.
10. Controversias y vacíos documentales.
11. Elementos ficticios que se incorporarán al guion.
12. Diseño de la región: sectores, rutas, asentamientos, recursos y límites de jugabilidad.

Cada acontecimiento narrativo se clasifica como documentado, interpretación, ficción narrativa o controversial. La ficción no se presenta como hecho demostrado. La geografía se clasifica como GD, GR o GN.

La violencia se representa por su consecuencia humana, no por espectáculo. Las ejecuciones, represalias y ocupaciones se muestran con el fuera de campo declarado cuando corresponde. Nada de triunfalismo sobre los vencidos.

---

# 10. Estructura documental de cada campaña

Cada campaña desarrolla:

1. Sinopsis general.
2. Contexto histórico.
3. Cronología.
4. Protagonista y biografía.
5. Personajes secundarios.
6. Personajes históricos.
7. Antagonistas y conflictos.
8. Arco emocional.
9. Estructura de fases.
10. Capítulos y misiones.
11. Escenas principales y diálogos clave.
12. Decisiones y consecuencias.
13. Clímax y desenlace.
14. Registro de rigor histórico.
15. Bibliografía y fuentes.
16. **Diseño de mundo**: región, sectores, rutas, POI, fases y experiencias no principales.

La campaña en desarrollo mantiene además un **dossier de región**. Su guion de campaña y sus escenas se escriben después de rediseñarla, con la [plantilla de escena](10_plantilla_guion_de_escena.md). Las campañas futuras no escriben guion de escenas hasta que su etapa se abra.

---

# 11. Orden de desarrollo

| Etapa | Contenido | Fase | Estado |
|---|---|---|---|
| 1 — Pachacútec | Mantener historia y elenco; rediseñar la región, las fases de mundo y la vertical slice | F0–F5 | **Redefinición en curso** |
| 2 — Túpac Amaru II | Investigar cronología y liderazgos; definir región, protagonista y economía colonial; construir actos y misiones | F6 | No abierta |
| 3 — Independencia | Elegir región con expediente comparativo; definir protagonista y recorrido; construir guion | F6 | No abierta |
| 4 — Campaña de la Breña | Definir comunidad, región y protagonista; investigar montoneras y operaciones | F6 | No abierta |

**Regla de oro:** no se desarrollan simultáneamente los diálogos y misiones de las cuatro campañas. Primero se aprueba la estructura narrativa y geográfica de una; después se construye.

Cada etapa empieza por el **expediente histórico y geográfico** y solo pasa al guion cuando el expediente está aprobado. La región se diseña antes de construir terreno; la vertical slice se valida antes de producir la campaña completa.

---

# 12. Visión final

*Memorias del Perú* busca que el jugador descubra que la historia de un país no está formada únicamente por sus gobernantes, generales y grandes personajes.

También está formada por quienes trabajaron, lucharon, resistieron, cuidaron a sus familias y sobrevivieron a los acontecimientos que transformaron su sociedad.

Cada campaña contará una historia humana distinta, en un territorio con identidad propia, y todas compartirán una misma intención: acercar al jugador a la historia peruana haciéndolo parte de ella.

**La historia no solo se recuerda. También se vive. Y el lugar donde se vive también cuenta.**

---

# Anexo A — Decisiones aprobadas

1. **Cuatro campañas independientes** y una sola campaña construida a la vez.
2. **Mundo abierto regional:** 2–4 km² de área densa; hasta ~8 km² con wilderness. La densidad manda sobre la extensión.
3. **Duración objetivo:** 6–8 h de historia principal por campaña; 8–12 h con contenido secundario.
4. **Cinco actos, un territorio:** los actos se viven como fases del mismo mundo, no como mapas separados.
5. **Portada:** cuatro campañas visibles; solo la 01 jugable hasta su fase. Las otras indican “en diseño”.
6. **Campaña III:** expediente comparativo con **Ayacucho–Huanta–Cangallo** como hipótesis principal.
7. **Campaña IV:** valle del Mantaro; Huamachuco como epílogo narrado o secuencia final, no como mapa continuo.
8. **Sin vínculo sobrenatural** entre protagonistas en esta versión.
9. **Clasificación:** H/A/R/N para contenido histórico y GD/GR/GN para geografía.
10. **Protagonistas comunes:** no sustituyen a los grandes personajes ni cambian el resultado histórico.

# Anexo B — Pendientes declarados

| Pendiente | Bloquea | Dónde se resuelve |
|---|---|---|
| Norma de escritura quechua | Nombres propios, fichas y diálogos con quechua | Documentación de la campaña 01 §4 |
| Región definitiva de la campaña III | Todo el guion de la III | Expediente comparativo de la campaña III |
| Alcance de Huamachuco en la IV | Actos III–IV de la IV | Expediente de la campaña IV |
| Región y protagonista de la II | Todo el guion de la II | Expediente de la campaña II |
| Geografía de la campaña 01 | Terreno, sectores y POI | Dossier `campaigns/01_pachacutec/documentation/mundo/` |
| Assets coloniales, republicanos y armas de fuego | Campañas II–IV | Fase de cada campaña, con licencia registrada |
| Selector de campañas y guardado | Antología completa | F1/F4 |
| Adopción de Terrain3D y Cyclops | Terreno y blockout | Spikes de F1 |
