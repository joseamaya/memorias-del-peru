# 09 — Biblia narrativa general

- **Versión:** 2.0 (mundo abierto regional) — 2026-11-19
- **Estado:** aprobada como capa narrativa de la antología; la estructura lineal de cinco escenas queda como material histórico
- **Ámbito:** qué se cuenta y con qué reglas. No fija fases, sistemas ni pruebas.
- **Documentos que la desarrollan:** [01 — Visión y alcance](01_vision_y_alcance.md), [11 — Diseño de mundo](11_diseno_de_mundo.md), [12 — Campañas](12_campanas.md), [05 — Plan de implementación](05_plan_de_implementacion.md), [07 — Convenciones históricas](07_convenciones_historicas.md), [biblia de la campaña 01](../campaigns/01_pachacutec/documentation/biblia_campana.md)

> **Cambio de modelo (2026-11-19).** Los “actos” siguen siendo unidades dramáticas, pero dejan de ser mapas separados: se viven como **fases históricas del mismo territorio**. Las descripciones de actos de este documento se conservan como material narrativo y se reinterpretan en el mundo abierto. La estructura de región, sectores y experiencias vive en [docs/11](11_diseno_de_mundo.md) y [docs/12](12_campanas.md).

---

## 0. Cómo se usa este documento

1. **Manda en lo narrativo.** Toda campaña, guion, misión y diálogo debe poder justificarse con esta biblia. Si un guion la contradice, se corrige el guion.
2. **No manda en lo técnico ni en el proceso.** Las fases, los sistemas, las pruebas y el rendimiento viven en `docs/01`–`08`. La clasificación histórica operativa vive en [docs/07](07_convenciones_historicas.md) §2.
3. **Cada campaña tiene su propio documento de guion** (ver §10). Esta biblia da el marco; el detalle de protagonista, elenco, misiones y banderas vive en la documentación de la campaña.
4. **Una campaña es un producto.** Se desarrolla y se cierra una antes de abrir la siguiente (§11). Tener cuatro campañas diseñadas no significa construirlas a la vez.
5. **Nada entra al juego sin ficha.** Todo elemento histórico relevante se registra con clasificación y fuente; ver §9 y [docs/07](07_convenciones_historicas.md).

### 0.1. Glosario de este documento

| Término | Significado |
|---|---|
| Campaña | Una época histórica jugable, independiente, con protagonista propio |
| Región | Territorio continuo y explorable de una campaña (2–4 km² de área densa; hasta ~8 km² con wilderness) |
| Sector | Unidad de composición y streaming del territorio (256–512 m) |
| Acto | Unidad dramática de una campaña (cinco por campaña); en mundo abierto se vive como fase, no como mapa |
| Fase histórica | Estado del mundo que cambia la región y la historia: paz, noticia, guerra, posguerra, obra |
| Secuencia controlada | Escena con control limitado del jugador: asamblea, batalla, sueño, clímax |
| Episodio | Unidad menor que un acto: viaje, asedio, asamblea |
| Expediente | Dossier histórico y geográfico de una campaña antes de escribir su guion (§9) |
| Ficha | Entrada del registro histórico con clasificación, fuente y estado (docs/07 §3) |

---

# 1. Identidad del videojuego

## 1.1. Concepto central

*Memorias del Perú* es una antología de **RPG históricos de mundo abierto regional** que permite vivir diferentes momentos decisivos de la historia peruana desde la perspectiva de personas comunes que participaron en ellos.

El jugador no encarna a los grandes líderes históricos. Vive la historia desde abajo: como un habitante, trabajador, mensajero, combatiente o integrante de una comunidad que se ve involucrada en acontecimientos que transforman el país.

Cada campaña presenta un protagonista diferente, con su propia familia, relaciones, motivaciones, conflictos y evolución personal. También presenta una **región continua y explorable** con comunidades, caminos, campos, ríos, montañas y lugares que existen más allá de la misión activa.

Los personajes históricos aparecen como parte del mundo y conservan su importancia. El protagonista ficticio participa en los acontecimientos sin reemplazar a sus protagonistas históricos ni apropiarse de sus decisiones.

El género jugable es el **RPG histórico en primera persona de mundo abierto regional**: exploración, vida cotidiana, interacción contextualizada, decisiones y combate subordinados al relato. Los sistemas concretos de cada campaña se definen en [docs/11](11_diseno_de_mundo.md) y en su documentación.

## 1.2. Promesa al jugador

No se trata de memorizar fechas o contemplar acontecimientos desde fuera, ni de recorrer un pasillo de escenarios históricos.

El jugador conocerá cómo vivía la gente, qué temía, qué defendía, qué perdía y qué esperaba de su futuro. Los acontecimientos históricos serán experiencias que deberá atravesar, pero también podrá salir de su comunidad, tomar un camino distinto, encontrar a alguien, descubrir un lugar, trabajar y volver a casa.

**El territorio y sus habitantes deben existir más allá de la misión activa.**

## 1.3. Principios narrativos

1. **La historia desde las personas:** los grandes acontecimientos se experimentan a través de vidas individuales.
2. **Rigor histórico:** los hechos documentados son el marco de la ficción.
3. **Protagonistas creíbles:** cada personaje debe actuar de acuerdo con su condición, conocimientos, recursos y contexto.
4. **Personajes históricos respetados:** no modificar sus decisiones fundamentales para favorecer la ficción.
5. **Consecuencias humanas:** los conflictos afectan a familias, comunidades y relaciones.
6. **Diversidad de experiencias:** cada campaña tiene un tono, ritmo y conflicto particular.
7. **Historia sin lecciones forzadas:** el aprendizaje surge de explorar, conversar, observar y participar.
8. **Ambigüedad humana:** evitar representar a todos los personajes de un bando como buenos o malos de manera automática.
9. **El lugar importa:** cada región tiene geografía, economía, comunidad y memoria propias; no es un decorado intercambiable.
10. **La vida sigue:** el mundo ofrece trabajo, rutinas, relaciones y descubrimientos que no dependen de la misión principal.

---

# 2. Estructura general

El juego está pensado como una antología de cuatro campañas independientes, accesibles desde el menú principal cuando estén construidas.

| Campaña | Título | Periodo | Conflicto central | Estado |
|---|---|---|---|---|
| I | El despertar del Sol | Siglo XV, guerra contra los chancas | Defender el Cusco y vivir el ascenso de Pachacútec | **Redefinición a mundo abierto (F0–F3)** |
| II | La llama de la rebelión | 1780–1783 | La rebelión de Túpac Amaru II y sus consecuencias | Concepto; expediente por hacer |
| III | Entre dos banderas | 1820–1824 | El proceso de independencia del Perú | Concepto; región por decidir |
| IV | Los últimos defensores | 1881–1883 | La resistencia de la Breña durante la Guerra del Pacífico | Concepto; expediente por hacer |

Cada campaña debe poder disfrutarse por separado. No requiere conocer las otras para comprender su historia.

La posible conexión entre los protagonistas mediante memorias ancestrales queda fuera del alcance de esta versión. La «Memoria» del diario de la campaña 01 es una pestaña de conocimiento histórico, no un vínculo entre campañas.

**Nombre visible:** la pantalla de título muestra el nombre del juego y el de la campaña en curso. En la campaña 01 la línea de campaña es *El despertar del Sol*; el nombre descriptivo completo —*Pachacútec y la defensa del Cusco*— se usa en documentación.

### 2.1. Modelo de mundo abierto

Cada campaña se desarrolla en **una región continua** (2–4 km² de área densa; hasta ~8 km² con wilderness), no en una sucesión de niveles. La estructura dramática de cinco actos se conserva, pero se vive como **fases históricas del mismo territorio**:

| Acto | Fase del mundo | Qué cambia |
|---|---|---|
| I | Paz / vida cotidiana | Rutinas, caminos y comunidad |
| II | Noticia / movilización | Refugiados, precios, patrullas |
| III | Guerra | Accesos, combate, ausencias |
| IV | Posguerra | Casas vacías, heridos, cuentas |
| V | Reconstrucción | Obras, nombre nuevo, cierre |

Las secuencias controladas se reservan para asambleas, batallas, sueños y clímax. El resto del mundo sigue siendo explorable y habitable antes, durante y después de la historia principal. La región, los sectores y las experiencias se diseñan en [docs/11](11_diseno_de_mundo.md).

---

# 3. Campaña I — El despertar del Sol

## 3.1. Identidad

**Periodo:** siglo XV, durante el conflicto entre los incas y los chancas.
**Región:** valle del Cusco y aproximación occidental, con la llacta de Rumi, la quebrada, el paso y el Cusco de 1438. La distancia está comprimida y el valle intermedio es ficción declarada.
**Espacios principales:** la llacta, el paso de montaña y el Cusco preimperial.
**Personaje histórico central:** Cusi Yupanqui, posteriormente conocido como Pachacútec.
**Tono:** épico, íntimo, de supervivencia y transformación.
**Fases:** paz, noticia, guerra, posguerra y obra sobre el mismo territorio.

## 3.2. Premisa

El protagonista es un joven de una llacta del valle del Cusco cuya vida cotidiana se ve amenazada por la expansión chanca y la crisis política del poder inca.

Cuando la amenaza alcanza la ciudad, las divisiones internas, la incertidumbre y la decisión de abandonar el Cusco ponen a la población ante una situación límite.

Mientras Cusi Yupanqui organiza la resistencia, el protagonista se ve involucrado en la defensa de su hogar y en una guerra que cambiará el destino de la región.

Su historia no es la de un gran general. Es la de una persona que debe proteger a los suyos, sobrevivir y encontrar su lugar en un mundo que está cambiando.

## 3.3. Protagonista

**Identidad:** Rumi, 17 años, joven de la llacta. La ficha completa —familia, miedo, motivación, oficio y objetivo final— está en la [biblia de la campaña](../campaigns/01_pachacutec/documentation/biblia_campana.md) §2.

Debe tener:
- Un vínculo familiar importante.
- Una responsabilidad cotidiana.
- Una relación significativa con otro personaje de su comunidad.
- Una motivación personal que vaya más allá de combatir.
- Una razón verosímil para participar en la defensa de la ciudad.

No debe ser un guerrero excepcional desde el comienzo. Su experiencia y capacidades deben evolucionar a partir de lo que vive.

## 3.4. Personajes principales

- **Cusi Yupanqui:** figura central de la resistencia y del cambio político. El protagonista puede conocerlo, recibir instrucciones de sus representantes y presenciar su ascenso, pero no dirigir sus decisiones.
- **Viracocha Inca:** figura del poder establecido, cuya retirada y decisiones deben contextualizarse históricamente. No es un villano: es un gobernante que calcula.
- **Familia del protagonista:** representa lo que está en juego para una persona común.
- **Compañero de camino:** personaje que comparte las dificultades y puede tener una visión diferente de la resistencia.
- **Personaje de posición contraria:** alguien de la comunidad que considera que resistir es una decisión equivocada o peligrosa.

Los personajes secundarios deben tener objetivos propios y no existir únicamente para entregar misiones.

## 3.5. Estructura de actos

> Los cinco actos se conservan como unidades dramáticas. En el juego se viven como fases del mismo territorio, no como mapas separados. Las descripciones siguientes son material narrativo; la puesta en escena de mundo se define en `campaigns/01_pachacutec/documentation/mundo/`.

### Acto I — Una ciudad al borde del colapso

Presentación de la vida cotidiana, la comunidad y las primeras noticias sobre la amenaza chanca.

El protagonista tiene responsabilidades, relaciones y problemas personales. La crisis política comienza a afectar la vida de la población.

**Objetivos narrativos:**
- Presentar el mundo y sus costumbres.
- Construir el vínculo emocional con la familia.
- Mostrar la amenaza antes de que llegue a la ciudad.
- Presentar las divisiones políticas.

**Clímax:** la decisión de abandonar o defender el Cusco genera una ruptura. La amenaza se vuelve inmediata.

### Acto II — La defensa del Cusco

La población debe prepararse. Cusi Yupanqui decide resistir mientras otros sectores abandonan la ciudad.

El protagonista participa en la preparación, el abastecimiento y la organización de la defensa.

**Objetivos narrativos:**
- Mostrar el liderazgo emergente de Cusi.
- Crear tensión entre quienes quieren resistir y quienes quieren escapar.
- Introducir los primeros peligros y enfrentamientos.
- Elevar el riesgo personal.

**Clímax:** las fuerzas chancas llegan y la batalla se vuelve inevitable.

### Acto III — La guerra de los chancas

El protagonista vive el enfrentamiento desde una posición limitada y humana.

No controla el ejército ni decide el resultado de la guerra. Participa en tareas de defensa, comunicación, protección y combate, y presencia la actuación de los líderes.

**Objetivos narrativos:**
- Mostrar el caos y el costo de la batalla.
- Poner a prueba las relaciones construidas.
- Dar importancia a las acciones pequeñas dentro de un acontecimiento enorme.
- Hacer que la victoria tenga un costo.

**Clímax:** victoria cusqueña y transformación del equilibrio político.

### Acto IV — El precio de la victoria

La ciudad debe afrontar las consecuencias de la guerra. Hay pérdidas, heridos, incertidumbre y disputas por el poder.

La victoria no resuelve automáticamente los problemas del protagonista.

**Objetivos narrativos:**
- Mostrar las consecuencias humanas.
- Resolver conflictos personales.
- Mostrar las tensiones del nuevo orden.
- Preparar el cambio político.

**Clímax:** Cusi consolida su posición y se produce la transición hacia una nueva etapa.

### Acto V — El nacimiento de una nueva era

El protagonista presencia la transformación de Cusi Yupanqui en Pachacútec y el comienzo de un nuevo proyecto político.

La historia personal alcanza su desenlace mientras el Cusco comienza a transformarse.

**Objetivos narrativos:**
- Mostrar el cambio desde la perspectiva de la población.
- Cerrar los vínculos personales.
- Dejar una imagen memorable de la transformación histórica.

**Final:** el protagonista comprende que la victoria vivida fue el inicio de una transformación mucho mayor.

> **Estado.** La campaña está en desarrollo; el detalle de actos, misiones y banderas vive en la [biblia de la campaña](../campaigns/01_pachacutec/documentation/biblia_campana.md).

## 3.6. Arco emocional

De la vida cotidiana y la incertidumbre al miedo, la responsabilidad, la pérdida y finalmente la aceptación de que el mundo conocido ha cambiado.

## 3.7. Consideraciones históricas

La guerra contra los chancas y el ascenso de Pachacútec se conocen principalmente mediante crónicas posteriores. El guion debe contrastar las distintas versiones, señalar las incertidumbres y evitar presentar cada episodio legendario como un hecho comprobado.

---

# 4. Campaña II — La llama de la rebelión

## 4.1. Identidad

**Periodo:** 1780–1783.
**Región propuesta:** corredor del Vilcanota y punas de Canas/Canchis: Tinta, Tungasuca, Pampamarca, Sangarará, Sicuani y caminos de altura. Cusco se trata como destino lejano o secuencia controlada, no como parte del mapa continuo.
**Personajes históricos centrales:** Túpac Amaru II, Micaela Bastidas y dirigentes de la rebelión.
**Tono:** tensión, indignación, esperanza y tragedia.
**Mundo:** pueblos, haciendas, obrajes, tambos, mercados, iglesia, caminos y puna; trueque, tributo y redes de información.

## 4.2. Premisa

El protagonista vive en una comunidad andina bajo el sistema colonial. Su vida está condicionada por las obligaciones económicas, los abusos de las autoridades y las tensiones sociales.

La rebelión encabezada por Túpac Amaru II transforma su entorno. Lo que comienza como una crisis política se convierte en un levantamiento de grandes dimensiones.

El protagonista debe decidir cómo involucrarse mientras intenta proteger a su familia y a su comunidad.

A medida que la rebelión crece, descubre que luchar contra un sistema injusto no garantiza que todos compartan los mismos objetivos ni que el movimiento esté libre de contradicciones.

## 4.3. Protagonista

**Identidad provisional:** joven arriero, trabajador o integrante de una comunidad de la región de Tinta.

La ocupación definitiva debe seleccionarse en función de su capacidad para justificar desplazamientos, relaciones sociales y participación en los acontecimientos.

Debe tener:
- Una familia afectada por el orden colonial.
- Una relación con el comercio, los caminos o las actividades productivas.
- Un vínculo personal que lo conecte con la comunidad.
- Una motivación inicial concreta, no necesariamente política.
- Una evolución desde la preocupación personal hacia una participación consciente en la rebelión.

## 4.4. Personajes principales

- **Túpac Amaru II:** dirigente de la rebelión. Su papel político e histórico no debe ser reemplazado por el protagonista.
- **Micaela Bastidas:** figura fundamental en la organización, comunicación y sostenimiento del movimiento.
- **Dirigentes y colaboradores:** personajes que permiten representar la diversidad de intereses y responsabilidades de la rebelión.
- **Autoridades coloniales:** representantes de un sistema con intereses y métodos diferentes.
- **Familia del protagonista:** vínculo emocional y representación del impacto de la rebelión.
- **Miembros de la comunidad:** personas que pueden apoyar, rechazar o temer las consecuencias del levantamiento.

## 4.5. Estructura de actos

### Acto I — El peso de la corona

La vida cotidiana está condicionada por tributos, repartos, obligaciones laborales y abusos de autoridades.

El protagonista intenta mantener a su familia y cumplir sus responsabilidades.

**Clímax:** la tensión social alcanza un punto de ruptura y empiezan a circular noticias sobre la rebelión.

### Acto II — La rebelión comienza

La captura y ejecución del corregidor Antonio de Arriaga marcan el inicio del levantamiento.

El protagonista presencia cómo se reorganiza la vida de la región. Aparecen nuevas alianzas, convocatorias y enfrentamientos.

**Clímax:** el protagonista toma una decisión que lo involucra directamente en el movimiento.

### Acto III — Sangre en los Andes

La rebelión se expande. El protagonista participa en actividades de abastecimiento, comunicación, organización y combate, según su perfil.

La victoria de Sangarará y el intento de tomar Cusco representan momentos decisivos.

**Clímax:** la campaña contra Cusco no consigue el resultado esperado y el movimiento comienza a enfrentar dificultades crecientes.

### Acto IV — La caída de los líderes

La rebelión sufre derrotas y persecuciones. Los dirigentes son capturados y ejecutados.

El protagonista vive la desintegración de su entorno y debe enfrentar la represión.

**Clímax:** ejecución de Túpac Amaru II, Micaela Bastidas y otros dirigentes.

### Acto V — La rebelión continúa

La resistencia no termina con la ejecución de los primeros dirigentes. Diego Cristóbal Túpac Amaru y otros líderes continúan la lucha.

El protagonista debe decidir qué hacer ante un movimiento que ha cambiado y una comunidad que intenta sobrevivir.

**Final:** cierre de la experiencia personal, mostrando que las consecuencias de la rebelión perduran más allá de sus principales dirigentes.

## 4.6. Arco emocional

De la preocupación por la supervivencia cotidiana a la esperanza de transformación, seguido por el desencanto, el miedo y la necesidad de continuar viviendo después de la tragedia.

## 4.7. Consideraciones históricas

La rebelión debe representarse como un movimiento complejo, con distintas etapas, liderazgos y objetivos. No debe reducirse a la captura y ejecución de Túpac Amaru II. La participación de comunidades indígenas, mestizos, criollos y otros sectores debe investigarse y representarse sin simplificaciones.

---

# 5. Campaña III — Entre dos banderas

## 5.1. Identidad

**Periodo:** 1820–1824.
**Región:** por decidir mediante expediente comparativo. Candidatas: Ayacucho–Huanta–Cangallo; Jauja–Tarma–Huancayo; Lima–Huarochirí–Yauyos. No se fija una ubicación arbitraria.
**Personajes históricos centrales:** José de San Martín, Simón Bolívar, José de la Riva-Agüero, José Bernardo de Tagle y otros personajes según la localización elegida.
**Tono:** incertidumbre, intriga, esperanza y conflicto moral.
**Mundo:** pueblos, haciendas, coca, puna, caminos, cuarteles y redes de información; la guerra irregular y la vida cotidiana pesan más que las grandes batallas.

## 5.2. Premisa

El protagonista vive en el Perú durante el proceso de independencia. La llegada de las expediciones libertadoras y el debilitamiento del poder virreinal generan nuevas oportunidades, pero también divisiones y riesgos.

Las personas deben decidir cómo actuar en un contexto en el que las lealtades políticas, familiares y económicas no siempre coinciden.

El protagonista comienza involucrándose por razones personales y termina participando en una transformación política y militar que supera sus expectativas.

La independencia no debe presentarse como una decisión sencilla ni como un proceso uniforme. Para muchos habitantes significó esperanza; para otros, incertidumbre, pérdidas o nuevas obligaciones.

## 5.3. Protagonista

**Identidad provisional:** joven mensajero, arriero o colaborador de redes patriotas.

La ubicación debe definirse antes de cerrar el personaje. La región elegida determinará qué acontecimientos puede vivir y qué personajes históricos puede conocer.

Debe tener:
- Una familia o comunidad dividida por el conflicto.
- Una actividad que le permita desplazarse o transportar información.
- Una relación con personas de posiciones políticas diferentes.
- Un objetivo personal que se transforme durante la campaña.
- Una participación creíble en la causa patriota o en las circunstancias del proceso.

## 5.4. Personajes principales

- **Representantes patriotas:** dirigentes, oficiales y colaboradores de las fuerzas libertadoras.
- **Representantes realistas:** militares, funcionarios y personas que defienden el orden virreinal.
- **Personajes locales:** comerciantes, campesinos, artesanos, autoridades y miembros de comunidades.
- **Familia del protagonista:** permite mostrar cómo el conflicto divide o transforma las relaciones.
- **Compañero de campaña:** alguien que comparte el recorrido, pero no necesariamente las mismas convicciones.

No todos los personajes realistas deben ser crueles ni todos los patriotas idealistas. Las motivaciones deben ser humanas y contextualizadas.

## 5.5. Estructura de actos

### Acto I — Rumores de libertad

El protagonista vive bajo el orden virreinal. Las noticias sobre la expedición libertadora y los movimientos políticos comienzan a alterar su entorno.

**Clímax:** el protagonista queda involucrado en una tarea que lo conecta con las redes del proceso independentista.

### Acto II — Una tierra dividida

Las comunidades y ciudades comienzan a tomar posiciones. Se desarrollan redes de información, apoyo y resistencia.

El protagonista descubre que las decisiones políticas pueden romper amistades y familias.

**Clímax:** una operación o acontecimiento local expone al protagonista y a sus allegados a un riesgo mayor.

### Acto III — La guerra se acerca

La campaña militar se intensifica. El protagonista participa en tareas de reconocimiento, comunicación, abastecimiento y apoyo.

La guerra afecta a la población y obliga a tomar decisiones difíciles.

**Clímax:** la situación militar cambia y el protagonista debe abandonar la seguridad de su entorno.

### Acto IV — La independencia no es el final

Se produce la proclamación de la independencia, pero la guerra continúa. El protagonista descubre que el cambio político no resuelve automáticamente las divisiones sociales ni las necesidades de la población.

**Clímax:** el proceso entra en una fase decisiva y el protagonista debe participar en el esfuerzo final.

### Acto V — El precio de la libertad

La campaña final de 1824 conduce a los acontecimientos de Junín y Ayacucho.

El protagonista debe vivir el desenlace desde una posición compatible con su historia y ubicación. No debe aparecer artificialmente en todas las grandes batallas.

**Final:** la independencia se consolida militarmente, pero el protagonista comprende que construir un país es un proceso que apenas comienza.

## 5.6. Arco emocional

De la incertidumbre a la participación, de la esperanza a la confrontación con las contradicciones del proceso, hasta comprender que la independencia es un comienzo y no una solución inmediata.

## 5.7. Consideraciones históricas

La campaña debe diferenciar las proclamaciones locales, la declaración de independencia y el desenlace militar de 1824. La independencia del Perú fue un proceso prolongado y con participación de fuerzas y poblaciones de diferentes regiones.

---

# 6. Campaña IV — Los últimos defensores

## 6.1. Identidad

**Periodo:** 1881–1883.
**Región propuesta:** valle del Mantaro y puna hacia Ayacucho: Jauja, Concepción, Huancayo, Pucará y Marcavalle. Huamachuco queda fuera del mapa continuo; se resuelve como epílogo narrado o secuencia final.
**Personaje histórico central:** Andrés Avelino Cáceres.
**Tono:** supervivencia, resistencia, sacrificio y reconstrucción.
**Mundo:** valle, pueblos, haciendas, puentes, quebradas, cuevas, pastos y rutas de altura; requisiciones, ocultamiento y logística.

## 6.2. Premisa

El protagonista vive en una comunidad de la sierra central durante la Guerra del Pacífico. La ocupación, las requisiciones, la violencia y la incertidumbre alteran la vida cotidiana.

La resistencia organizada por Andrés Avelino Cáceres necesita el apoyo de las comunidades y de las montoneras.

El protagonista termina involucrado en una lucha en la que el conocimiento del territorio, la cooperación y la resistencia son fundamentales.

La campaña debe mostrar tanto la dimensión militar como el costo que la guerra impone a la población.

## 6.3. Protagonista

**Identidad provisional:** joven campesino o habitante de una comunidad de la sierra central que termina integrándose a una montonera.

Debe tener:
- Una familia o comunidad que proteger.
- Conocimiento del territorio.
- Una actividad cotidiana relacionada con el entorno.
- Un motivo personal para involucrarse en la resistencia.
- Una relación compleja con los líderes militares y las necesidades de la guerra.

No debe convertirse en un comandante capaz de decidir el rumbo de la campaña. Su papel será el de un participante que vive las consecuencias de las decisiones de otros.

## 6.4. Personajes principales

- **Andrés Avelino Cáceres:** líder de la resistencia. Debe aparecer como figura militar y política, sin convertirse en un personaje omnipotente.
- **Integrantes de las montoneras:** combatientes con motivaciones y procedencias diferentes.
- **Autoridades y líderes locales:** representan las tensiones entre cooperación, supervivencia y poder.
- **Familia del protagonista:** permite mostrar el impacto de la ocupación y la guerra.
- **Población civil:** debe tener presencia narrativa y no funcionar únicamente como escenario.

## 6.5. Estructura de actos

### Acto I — La ocupación

La guerra llega a la comunidad. La población experimenta requisiciones, desplazamientos, temor y pérdida de recursos.

El protagonista intenta proteger a los suyos y mantener su vida cotidiana.

**Clímax:** una situación de violencia o una decisión de las fuerzas de ocupación obliga al protagonista a involucrarse.

### Acto II — La resistencia

El protagonista entra en contacto con las fuerzas de Cáceres y las montoneras.

Aprende a desplazarse, reconocer caminos, transportar información y colaborar con la resistencia.

**Clímax:** participa por primera vez en una acción coordinada contra las fuerzas enemigas.

### Acto III — La campaña de la sierra

La resistencia organiza operaciones y aprovecha el terreno. El protagonista participa en acciones de reconocimiento, abastecimiento, emboscadas y enfrentamientos.

Las victorias de Pucará, Marcavalle y Concepción pueden formar parte de la campaña si su ubicación y cronología son compatibles con el recorrido del protagonista.

**Clímax:** la resistencia alcanza un momento de éxito que genera nuevas expectativas, pero también nuevas represalias y riesgos.

### Acto IV — El sacrificio

La resistencia enfrenta problemas de abastecimiento, enfermedad, agotamiento, divisiones y superioridad material del enemigo.

El protagonista debe afrontar pérdidas y decisiones difíciles.

**Clímax:** la batalla de Huamachuco representa un desenlace militar devastador para la resistencia organizada de Cáceres.

### Acto V — Después de la guerra

La campaña militar termina, pero las consecuencias permanecen.

El protagonista regresa a una comunidad transformada. Debe reconstruir su vida y comprender el costo de la resistencia.

**Final:** no se presenta una victoria militar inexistente. Se cierra la historia personal destacando la resistencia, el sacrificio y las consecuencias para la población.

## 6.6. Arco emocional

De la preocupación por la supervivencia a la participación en la resistencia, seguido por la esperanza, el agotamiento, la pérdida y la necesidad de reconstruir.

## 6.7. Consideraciones históricas

La Campaña de la Breña debe mostrar la relación entre las fuerzas regulares, las montoneras y las comunidades. Evitar idealizar la guerra o representar a la población como un bloque uniforme. Investigar las diferencias regionales, las operaciones militares, la logística y las consecuencias de la ocupación.

---

# 7. Identidad diferenciada de las campañas

Las cuatro campañas no deben sentirse como la misma aventura con diferentes vestimentas.

| Elemento | Pachacútec | Túpac Amaru II | Independencia | Cáceres |
|---|---|---|---|---|
| Conflicto | Defensa y cambio político | Rebelión | Ruptura del orden colonial | Resistencia ante ocupación |
| Región | Valle del Cusco y aproximación occidental | Vilcanota: Tinta–Canas–Canchis | Por decidir; candidata Ayacucho–Huanta | Valle del Mantaro y puna |
| Escala | ~3,5 × 2,5 km | ~4 × 3 km | ~4 × 3 km | ~4 × 3 km |
| Motivación inicial | Proteger el hogar | Sobrevivir a los abusos | Proteger a los suyos | Proteger la comunidad |
| Evolución | Participar en una transformación | Asumir el costo de rebelarse | Elegir y sostener una causa | Resistir y reconstruir |
| Tono | Épico e íntimo | Trágico y tenso | Esperanzador y ambiguo | Crudo y resiliente |

La superficie total incluye wilderness y aproximaciones; el **área densa** (asentamientos, campos, rutas y POI) es de 2–4 km². La escala exacta se fija en el expediente de cada campaña.

---

# 8. Reglas para escribir los guiones

## 8.1. Protagonistas

Cada protagonista debe tener:
- Nombre y edad.
- Procedencia y entorno familiar.
- Ocupación y posición social.
- Personalidad y defectos.
- Motivación inicial.
- Miedo principal.
- Relaciones importantes.
- Evolución emocional.
- Objetivo final.

No debe ser un héroe perfecto ni tener conocimientos que no corresponden a su época o condición.

## 8.2. Personajes secundarios

Cada personaje importante debe tener:
- Objetivo propio.
- Motivación.
- Relación con el protagonista.
- Conflicto personal.
- Evolución a lo largo de la campaña.

Los personajes históricos no deben convertirse en simples dispensadores de misiones.

## 8.3. Misiones

Cada misión debe tener una razón narrativa y una consecuencia.

Evitar misiones repetitivas que solo consistan en:
- Eliminar enemigos.
- Transportar objetos sin contexto.
- Hablar con personajes para recibir otra tarea.
- Viajar a un lugar sin que ocurra algo significativo.

Combinar:
- Exploración.
- Interacción social.
- Actividades cotidianas.
- Investigación.
- Reconocimiento.
- Comunicación.
- Supervivencia.
- Combate.
- Decisiones personales.

**Reglas de mundo abierto:**

- La misión no es la única razón para recorrer el territorio: el mundo ofrece descubrimientos, oficios, relaciones y rumores por sí mismo.
- Las indicaciones se dan con personas, hitos y caminos; no con marcadores flotantes como única guía.
- Las misiones secundarias nacen de personas y lugares concretos, no de una lista genérica.
- Las secuencias controladas se reservan para asambleas, batallas, sueños y clímax; el resto se juega en el mundo.
- Una misión no puede resolverse con una escena lineal nueva si el mismo contenido cabe en el territorio.

## 8.4. Combate

El combate debe surgir de las circunstancias de cada periodo.

No todos los protagonistas deben ser soldados profesionales. Su experiencia, entrenamiento, armamento y capacidades deben responder a su historia.

Las batallas históricas deben representarse desde una escala y perspectiva verosímiles para el protagonista.

## 8.5. Diálogos

Los diálogos deben:
- Reflejar las relaciones entre los personajes.
- Evitar explicaciones históricas artificiales.
- Usar vocabulario coherente con el periodo, sin dificultar innecesariamente la comprensión.
- Incorporar las lenguas y formas de comunicación pertinentes con asesoría histórica y lingüística.
- Permitir descubrir información mediante conversaciones naturales.

La norma de escritura de las lenguas originarias se fija por campaña en su documentación, según [docs/07](07_convenciones_historicas.md) §5. Mientras no exista, toda forma quechua es provisional.

## 8.6. Decisiones

Las decisiones del jugador pueden afectar:
- Relaciones personales.
- Confianza de personajes.
- Recursos y oportunidades.
- Desarrollo de conflictos secundarios.
- Supervivencia de personajes ficticios.

No deben permitir cambiar arbitrariamente el resultado de acontecimientos históricos fundamentales.

## 8.7. Muerte del protagonista

El protagonista es ficticio y puede morir, pero su muerte nunca cambia el hecho histórico: la campaña se reanuda desde el último punto disponible —en la campaña 01, el inicio del mapa— y el desenlace documentado se mantiene. La derrota del jugador no es una derrota de la historia.

---

# 9. Criterios de rigor histórico

Cada campaña debe contar con un **expediente histórico** antes de cerrar su guion.

Debe contener:

1. Cronología de acontecimientos.
2. Localizaciones y desplazamientos.
3. **Geografía histórica y clasificación del territorio** (documentado / aproximado / ficción).
4. Personajes históricos y sus roles.
5. Organización política y social.
6. Vestimenta, arquitectura, herramientas y armamento.
7. Actividades cotidianas y economía.
8. Costumbres, creencias y prácticas culturales.
9. Fuentes primarias y estudios historiográficos.
10. Controversias y vacíos documentales.
11. Elementos ficticios que se incorporarán al guion.
12. **Diseño de la región**: sectores, rutas, asentamientos, recursos y límites de jugabilidad.

Cada acontecimiento narrativo debe clasificarse como:

- **Documentado:** respaldado por fuentes históricas.
- **Interpretación:** reconstrucción razonable a partir de evidencias.
- **Ficción narrativa:** personaje, diálogo o situación creada para el juego.
- **Controversial:** asunto con versiones históricas diferentes.

La ficción no debe presentarse al jugador como un hecho histórico demostrado.

### 9.1. Equivalencia con la clasificación operativa

La clasificación operativa del proyecto es la de [docs/07](07_convenciones_historicas.md) §2, con su estado de verificación. La de esta biblia se lee así:

| Biblia | docs/07 | Nota |
|---|---|---|
| Documentado | **H** (fuente escrita) + **A** (evidencia arqueológica) | La ficha indica cuál de las dos |
| Interpretación | **R** | Debe declarar en qué H/A se basa |
| Ficción narrativa | **N** | No puede contradecir H/A sin declararlo |
| Controversial | Bandera sobre la ficha | Se anota en «Discrepancias entre fuentes»; no sustituye a la clasificación |

Una campaña no cierra su guion con fichas «pendientes» de elementos que aparecen en el juego.

### 9.2. Violencia y sensibilidad

Las campañas II y IV incluyen ejecuciones, represión y violencia de ocupación. La política de representación está en [docs/07](07_convenciones_historicas.md) §7: se muestra la consecuencia humana, no el espectáculo; lo que no se muestra se declara.

---

# 10. Estructura del documento de guion de cada campaña

Cada campaña debe desarrollarse mediante un documento propio con estas secciones:

1. Sinopsis general.
2. Contexto histórico.
3. Cronología.
4. Protagonista y biografía.
5. Personajes secundarios.
6. Personajes históricos.
7. Antagonistas y conflictos.
8. Arco emocional.
9. Estructura de actos.
10. Capítulos y misiones.
11. Escenas principales y diálogos clave.
12. Decisiones y consecuencias.
13. Clímax y desenlace.
14. Registro de rigor histórico.
15. Bibliografía y fuentes.
16. **Diseño de mundo**: región, sectores, rutas, POI, fases históricas y experiencias no principales.

Cada misión debe especificar:
- Contexto.
- Objetivo narrativo.
- Objetivo del jugador.
- Personajes involucrados.
- Desarrollo.
- Conflicto.
- Resolución.
- Consecuencias.
- Información histórica que aporta.

Además, cada campaña en desarrollo mantiene un **guion de escenas** (`campaigns/<campaña>/documentation/guion_escenas.md`) que baja cada misión a lugar, momento, personajes presentes, bloqueo, cámara, textos, banderas, consecuencias y criterio de aceptación. Se redacta con la [plantilla de guion de escena](10_plantilla_guion_de_escena.md). Las campañas futuras no escriben este documento hasta que su etapa se abra.

El guion de la campaña 01 se construye sobre la [biblia de la campaña](../campaigns/01_pachacutec/documentation/biblia_campana.md), que ya fija actos, sistemas y banderas. Su guion de escenas está en [guion_escenas.md](../campaigns/01_pachacutec/documentation/guion_escenas.md).

---

# 11. Orden de desarrollo

El desarrollo narrativo se realiza en etapas. Cada etapa se convierte en una o más fases de [docs/05](05_plan_de_implementacion.md) cuando se abre.

| Etapa | Contenido | Fase del plan | Estado |
|---|---|---|---|
| 1 — Desarrollar Pachacútec | Mantener la historia y el elenco; rediseñar la región, las fases de mundo y la vertical slice | F0–F5 | **Redefinición en curso** |
| 2 — Desarrollar Túpac Amaru II | Investigar cronología y liderazgos, definir región, protagonista y economía colonial; construir actos y misiones | F6 | No abierta |
| 3 — Desarrollar la Independencia | Elegir región y recorrido con expediente comparativo, definir la posición del protagonista, construir el guion | F6 | No abierta |
| 4 — Desarrollar la Campaña de la Breña | Definir comunidad, región y protagonista; investigar montoneras y operaciones; construir el guion | F6 | No abierta |

**Regla de oro:** no se desarrollan simultáneamente los diálogos y misiones de las cuatro campañas. Primero se aprueba la estructura narrativa y geográfica de una; después se construye.

Cada etapa empieza por el **expediente histórico y geográfico** (§9) y solo pasa al guion cuando el expediente está aprobado. La región se diseña antes de construir terreno; la vertical slice se valida antes de producir la campaña completa.

---

# 12. Visión final

*Memorias del Perú* busca que el jugador descubra que la historia de un país no está formada únicamente por sus gobernantes, generales y grandes personajes.

También está formada por quienes trabajaron, lucharon, resistieron, cuidaron a sus familias y sobrevivieron a los acontecimientos que transformaron su sociedad.

Cada campaña contará una historia humana distinta, en un territorio con identidad propia, y todas compartirán una misma intención: acercar al jugador a la historia peruana haciéndolo parte de ella.

**La historia no solo se recuerda. También se vive. Y el lugar donde se vive también cuenta.**

---

# Anexo A — Decisiones de diseño

1. **Cinco actos, un territorio.** La campaña 01 conserva cinco actos como unidades dramáticas, pero se viven como fases del mismo mundo abierto regional; no son cinco mapas.
2. **Título.** La línea de campaña en pantalla es *El despertar del Sol*. El nombre descriptivo *Pachacútec y la defensa del Cusco* se mantiene en documentación.
3. **Protagonista con identidad.** Rumi, 17 años, con familia, miedo y motivación declarados. El oficio se fija con el primer encargo.
4. **Clasificación.** Se conserva H/A/R/N de [docs/07](07_convenciones_historicas.md); la clasificación de §9 se mapea sobre ella. «Controversial» es una bandera, no una categoría. La geografía usa GD/GR/GN.
5. **Una campaña es un producto.** Las campañas II–IV no se escriben ni se construyen hasta que les toque su etapa.
6. **Etapas y fases.** Las etapas de §11 se convierten en fases de `docs/05` cuando se abren; no conviven dos numeraciones activas.
7. **Origen del protagonista.** Rumi vive en una llacta del valle, no en el Cusco: la ciudad se descubre al final del camino.
8. **Mundo abierto regional.** El área densa es de 2–4 km² por campaña, con hasta ~8 km² incluyendo wilderness; la densidad manda sobre la extensión. No se construyen mapas gigantes vacíos.
9. **Sin vínculo sobrenatural.** Las cuatro campañas son independientes; no hay memorias ancestrales ni conexión mágica entre protagonistas en esta versión.

# Anexo B — Pendientes declarados

| Pendiente | Bloquea | Dónde se resuelve |
|---|---|---|
| Norma de escritura quechua | Nombres propios, fichas y diálogos con quechua | Documentación de la campaña 01 §4 |
| Región de la campaña III | Todo el guion de la III | Expediente comparativo de la campaña III |
| Alcance de Huamachuco en la IV | Actos III–IV de la IV | Expediente de la campaña IV |
| Región y protagonista de la II | Todo el guion de la II | Expediente de la campaña II |
| Geografía de la campaña 01 | Terreno, sectores y POI | Dossier `campaigns/01_pachacutec/documentation/mundo/` |
| Assets coloniales, republicanos y armas de fuego | Campañas II–IV | Fase de cada campaña, con licencia registrada |
| Selector de campañas y guardado | Antología completa | F1/F4 |
| Adopción de Terrain3D y Cyclops | Terreno y blockout | Spikes de F1 |
