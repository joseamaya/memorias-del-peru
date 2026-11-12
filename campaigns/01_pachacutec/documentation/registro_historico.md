# Registro histórico — Campaña 01: Pachacútec

Formato y reglas en [docs/07_convenciones_historicas.md](../../../docs/07_convenciones_historicas.md). Ningún elemento entra en el Vertical Slice con estado “pendiente”.

Las fichas en estado “pendiente” tienen clasificación definitiva pero citas incompletas (falta edición, capítulo o página). Para pasar a “verificado” deben cumplir el requisito mínimo de su clasificación (docs/07 §2).

---

### PCH-001 — Cusi Yupanqui / Pachacútec
- Tipo: personaje
- Clasificación: H (existencia y papel en la tradición); detalles de su vida: según fuente
- Uso en el juego: por definir
- Fuentes:
  - Sarmiento de Gamboa, *Historia de los Incas* (1572), trad. Markham (Hakluyt Society, 1907; Project Gutenberg n.º 20218, sin paginación).
    - Cap. XXVI «The life of Inca Yupanqui or Pachacuti, the ninth Inca»: el tercer hijo legítimo de Viracocha, «named Cusi, and as surname Inca Yupanqui», es elevado a inca por los capitanes Apu Mayta y Vicaquirau, contra la voluntad de su padre.
    - Cap. XXVII: dirige la defensa del Cusco y vence a los chancas. El enviado que lleva los despojos a Viracocha lo llama «Pachacuti Inca Yupanqui».
    - Cap. XXVIII: segunda victoria sobre los chancas.
  - Betanzos, *Suma y narración de los Incas*, I parte, caps. VI–X, ed. Jiménez de la Espada (Madrid, 1880). Según el índice, en el cap. VIII (p. 33) Inca Yupanqui da batalla a Uscovilca, lo prende y lo mata.
  - Identificadas y sin consultar: Cieza de León, *El señorío de los Incas*; Rostworowski, *Pachacútec Inca Yupanqui* (1953). Se retiran las páginas de la traducción de Bauer y Smith (2007), que procedían del índice de la editorial.
- Discrepancias entre fuentes: Garcilaso, *Comentarios reales*, ed. Urteaga (Lima, 1918), atribuye la victoria sobre los chancas al príncipe Viracocha, que socorre la ciudad abandonada por su padre Yahuar Huácac (lib. IV, caps. XXIII–XXIV; lib. V, caps. XVII–XX; ver PCH-015).
- Notas de representación: no mostrar retratos “auténticos”; toda apariencia física es R
- Estado de verificación: **verificado (H)** por el responsable del proyecto el 2026-11-11, con Sarmiento (caps. XXVI–XXVIII) a la vista y las citas de Betanzos y Garcilaso comprobadas en PCH-015.

### PCH-002 — Guerra chanca y defensa del Cusco
- Tipo: evento
- Clasificación: H (tradición narrada) / A (debate sobre escala, ver PCH-003)
- Uso en el juego: eje narrativo de la campaña
- Fuentes: las de PCH-001 (Sarmiento, caps. XXVI–XXVIII; Betanzos, caps. VI–X) y PCH-015. La parte A, sobre la escala del conflicto, está en PCH-003 (Bauer, Kellett y Aráoz Silva, IFEA 2013, cap. 8).
- Discrepancias entre fuentes: protagonista (Inca Yupanqui en Sarmiento y Betanzos; el príncipe Viracocha en Garcilaso), desarrollo de batallas y fecha. La arqueología sugiere un conflicto entre confederaciones frágiles, menor de lo que cuentan los cronistas (PCH-003).
- Notas de representación: presentar la versión elegida como versión de cronistas. Las versiones alternativas se mencionan dentro del relato (p. ej. personajes que cuentan la historia de forma distinta) o en material de apoyo fuera del juego; en el códice histórico solo si este se aprueba (docs/01 §6)
- Estado de verificación: **verificado (H / A)** por el responsable del proyecto el 2026-11-11, con las fuentes de PCH-001, PCH-003 y PCH-015 a la vista.

### PCH-003 — Los chancas (chanka)
- Tipo: pueblo / organización política
- Clasificación: H (mención en crónicas) / A (investigación arqueológica en Andahuaylas)
- Uso en el juego: antagonista colectivo
- Variantes del nombre: *chanca* (forma hispanizada, usada en la interfaz según docs/07 §5); *chanka* (grafía usada en la bibliografía arqueológica reciente y más cercana a la escritura quechua actual)
- Fuentes:
  - H: Sarmiento de Gamboa, *Historia de los Incas*, caps. XXVI–XXVII (trad. Markham, 1907): los jefes chancas Asto-huaraca y Tomay-huaraca avanzan desde Andahuaylas sobre el Cusco. Betanzos, *Suma y narración*, I parte, cap. VI (ed. 1880, pp. 19–26): el señor chanca Uscovilca. Ambas verificadas en PCH-015.
  - A: Brian S. Bauer, Lucas C. Kellett y Miriam Aráoz Silva, *Los chancas: investigaciones arqueológicas en Andahuaylas (Apurímac, Perú)*, IFEA, Lima, 2013 (traducción de *The Chanka*, Cotsen Institute of Archaeology Press, Monografía 68, 2010), cap. 8 «Los chancas: una visión panorámica», párrafos 7–9 (https://books.openedition.org/ifea/11669).
- Discrepancias entre fuentes: según Bauer y colaboradores (cap. 8), tras el año 1000 los asentamientos de Andahuaylas se trasladan a las cumbres. El conflicto con los incas podría ser una reacción a la centralización del poder en el Cusco, más que la expansión de una formación política organizada: los chancas habrían formado «confederaciones de breve vida», políticamente frágiles. La ideología imperial inca los habría hecho más formidables de lo que probablemente fueron. Los cronistas, que recogen la versión inca, los presentan como un enemigo poderoso y organizado.
- Notas de representación: evitar caricatura como “bárbaros”; mostrar pueblo con cultura propia
- Estado de verificación: **verificado (H / A)** por el responsable del proyecto el 2026-11-11, con la edición del IFEA a la vista (cap. 8) y las crónicas de PCH-015.

### PCH-004 — Quero
- Tipo: objeto
- Clasificación: A (piezas en colecciones) / R (decoración específica)
- Uso en el juego: `campaigns/01_pachacutec/scenes/objects/quero_chicha.tscn` (Fase 2); modelo `pch_quero.glb` (R: perfil abocinado con bandas incisas de zigzag)
- Variantes del nombre: *quero* (forma hispanizada, interfaz). Forma quechua por verificar: aparecen *qiru* y *q'iru* en distintas fuentes; hay que confirmar cuál corresponde al vaso y cuál a otro significado (se ha señalado que *q'iru* podría significar “madera/leña”) según el diccionario de referencia que adopte la campaña
- Fuentes:
  - The Metropolitan Museum of Art, *Kero*, objeto 1994.35.11 (https://www.metmuseum.org/art/collection/search/316839), consultado el 2026-11-11. Inca, siglo XV–inicios del XVI; madera (¿escallonia?); 14,6 cm de alto. Líneas incisas que forman cuadrados, triángulos y rombos en franjas horizontales, con rostros frontales geométricos en la franja superior. Según la ficha del museo, en época inca se hacían y usaban en pares, porque dos personas bebían juntas chicha, y el Estado los regalaba a los líderes provinciales.
  - Identificadas y sin consultar (no son necesarias para la verificación A):
    - Museo Pachacamac, *Qero* MD-00863, Horizonte Tardío (1470–1533), madera tallada e incisa, procedencia Pirámide con rampa 7.
    - ICOM, *Kero Inca, madera*, Museo Regional de Cusco: describe la diferencia entre el kero inca de decoración incisa y el colonial policromo.
- Discrepancias entre fuentes: —
- Notas de representación: preferir decoración incisa geométrica; uso en pares en contextos de reciprocidad
- Estado de verificación: **verificado (A)** por el responsable del proyecto el 2026-11-11, con la ficha del Met a la vista. La grafía quechua del nombre sigue pendiente de diccionario y no afecta a la clasificación A. El tamaño (22 cm en el juego) y la decoración sin rostros del modelo son reconstrucción (R).

### PCH-005 — Chicha de jora
- Tipo: alimento / bebida
- Clasificación: H / A
- Uso en el juego: interacción del quero; recupera estamina (la mecánica de estamina es N)
- Fuentes:
  - H: Pedro Cieza de León, *Segunda parte de la Crónica del Perú (El señorío de los Incas)*, ed. Marcos Jiménez de la Espada (Madrid, 1880; Project Gutenberg n.º 25255, sin paginación).
    - Cap. VII: la chicha, «vino hecho de maíz», la preparan con sus manos las señoras del linaje durante el ayuno del nuevo inca.
    - Cap. XXX, fiesta del Hatun Raimi: tras los sacrificios, las mamaconas sacan mucha chicha y todos los presentes en el Cusco comen juntos y beben de ella, «que tenian por sagrada», en grandes vasos de oro.
  - A: The Met, *Kero*, 1994.35.11 (ver PCH-004). Según el museo, se usaba en pares para beber chicha, y el Estado intercambiaba brindis y regalaba pares de keros a los líderes provinciales para afianzar la relación con las comunidades.
  - Identificadas y sin consultar: Betanzos, *Suma y narración*; Garcilaso, *Comentarios reales*; Morris y Thompson, *Huánuco Pampa* (1985).
- Discrepancias entre fuentes: —
- Notas de representación: bebida de maíz fermentado vinculada al ritual (Cieza) y a la reciprocidad con el Estado (Met). Que se prepare con maíz germinado («jora») no lo dicen estas fuentes y queda como reconstrucción (R). Su efecto en el juego es una licencia mecánica (N).
- Estado de verificación: **verificado (H / A)** por el responsable del proyecto el 2026-11-11, con Cieza (caps. VII y XXX) y la ficha del Met a la vista.

### PCH-006 — Llacta / asentamiento
- Tipo: lugar
- Clasificación: A (asentamientos excavados) / R (esta llacta concreta)
- Uso en el juego: escena completa `mundo_base.tscn`
- Fuentes:
  - A: R. Alan Covey, Kylie E. Quave y otros, «Settlement discontinuity at Ak'awillay and the development of the Inca imperial capital region», *Antiquity* 99 (404): 481–499 (2025), acceso abierto: https://www.cambridge.org/core/journals/antiquity/article/settlement-discontinuity-at-akawillay-and-the-development-of-the-inca-imperial-capital-region/6B5177903D92CCFDC05F520CE36CC60B. Las prospecciones de cobertura total registran «approximately 1000 Late Intermediate Period sites» en la región del Cusco (p. 483). En el valle de Xaquixaguana, «approximately 150 small villages and hamlets occupied the alluvial terraces and low hillslopes near the valley floor» (p. 487). Se han excavado sitios preimperiales mayores (Chokepukio, Wat'a, Pukara Pantillijlla) y contextos de «local households, tombs and public spaces» (pp. 483–484).
  - H: Bernabé Cobo, *Historia del Nuevo Mundo* (1653), ed. Marcos Jiménez de la Espada, t. IV (Sevilla, 1893), lib. XIV, en archive.org: https://archive.org/details/historiadelnuev01andagoog, cap. III «De sus pueblos y casas» (pp. 163–164): «Los quichuas llaman al pueblo Llacta»; los pueblos «eran pequeños como aldeas de á cien vecinos para abajo».
  - Identificadas y sin consultar: Morris y Thompson, *Huánuco Pampa* (1985); Hyslop, *Inka Settlement Planning* (1990).
- Discrepancias entre fuentes: Cobo, testimonio colonial y general, dice que fuera del Cusco y de algunos lugares grandes los pueblos no tenían «calles ni plazas» (ver PCH-016); Covey y colaboradores mencionan espacios públicos en sitios del Intermedio Tardío.
- Notas de representación: la llacta del juego no se identifica con ningún sitio real ni recibe nombre propio. Su tamaño (8 viviendas) cabe en las aldeas y caseríos del Intermedio Tardío que registran las prospecciones del Cusco. La disposición concreta es reconstrucción (R).
- Estado de verificación: **verificado (A / R)**, firmado por el responsable del proyecto el 2026-11-11 sobre la comprobación del agente en las ediciones digitales citadas ([hoja de verificación](hoja_verificacion_fichas.md) §5). El responsable no consultó personalmente las ediciones; las fuentes marcadas «sin contrastar directamente» son de apoyo y no sostienen la clasificación.

### PCH-007 — Vivienda rural de piedra y barro
- Tipo: arquitectura
- Clasificación: A / R
- Uso en el juego: `Llacta/Houses` en `mundo_base.tscn`; modelos `pch_house_a.glb` y `pch_house_b.glb` (R: planta rectangular de pirka con mortero de barro, puerta trapezoidal en el muro largo, hastiales de piedra y techo de ichu a dos aguas). Desde el alcance v4.4 ([ADR-0021](../../../docs/adr/0021-construcciones-de-pirca.md)):
  - los muros son de piedra tosca de contorno irregular asentada en barro, en hiladas desiguales, como describe Cobo (a partir de H);
  - la puerta es más baja (1,55 m), según Cobo;
  - se añade una tercera variante, `pch_house_c.glb`;
  - son reconstrucción (R): el talud del muro, el enlucido de barro desconchado (variantes B y C), el dintel de dos palos, las correas que asoman por los hastiales, el techo de haces con mechones en el alero, la tierra pisada alrededor y el giro de cada casa respecto a la plaza.
  - Los poyos de pirca bajo el quero y el pututu (`pch_pedestal.glb`) son también reconstrucción (R).
- Fuentes:
  - H: Bernabé Cobo, *Historia del Nuevo Mundo* (1653), ed. Marcos Jiménez de la Espada, t. IV (Sevilla, 1893), lib. XIV, en archive.org: https://archive.org/details/historiadelnuev01andagoog, cap. III (pp. 166–168): «En la Sierra hacen las casas de piedra y barro y las cubren de paja. La piedra es tosca y puesta sin orden y concierto, más que irla asentando y juntando con pelladas de barro»; «Las casas son unas redondas y otras á dos aguas; las redondas son más usadas y comunes en tierras frías, como en las provincias del Collao». Sobre las puertas, p. 168: «pequeñas y llanas, y las más tan bajas y estrechas».
  - A (localizada por búsqueda automática, sin contrastar directamente): Susan A. Niles, «Niched Walls in Inca Design», *Journal of the Society of Architectural Historians* 46 (3): 277–285 (1987), copia en línea: https://drmsh.com/PaleoBabble/Niched%20Walls%20in%20Inca%20Design.pdf. Describe edificios rectangulares de una sola sala, con cimientos de piedra y techo de paja, y muros de piedra de campo en matriz de arcilla (p. 277). Las casas de agricultores de Raqay-Raqayniyoq, cerca del Cusco, tenían nichos de forma trapezoidal a casi rectangular (p. 279).
  - Retirada: la cita de Vincent R. Lee en *Andean Past* (2016), que no existe. Identificada y sin consultar: Morris y Thompson, *Huánuco Pampa* (1985).
- Discrepancias entre fuentes: —
- Notas de representación: se descarta la sillería imperial fina, anacrónica para una llacta rural anterior a la expansión. La planta rectangular a dos aguas sigue a Cobo, que la da junto a la redonda (más común en el Collao). La puerta trapezoidal no está documentada para casas rurales en estas fuentes (Cobo solo dice que eran pequeñas y bajas): es reconstrucción (R).
- Estado de verificación: **verificado (A / R)**, firmado por el responsable del proyecto el 2026-11-11 sobre la comprobación del agente en las ediciones digitales citadas ([hoja de verificación](hoja_verificacion_fichas.md) §5). El responsable no consultó personalmente las ediciones; las fuentes marcadas «sin contrastar directamente» son de apoyo y no sostienen la clasificación.

### PCH-008 — Terraza agrícola
- Tipo: arquitectura
- Clasificación: A
- Uso en el juego: `Llacta/Terraces` en `mundo_base.tscn`
- Fuentes:
  - H: Bernabé Cobo, *Historia del Nuevo Mundo* (1653), ed. Marcos Jiménez de la Espada, t. IV (Sevilla, 1893), lib. XIV, en archive.org: https://archive.org/details/historiadelnuev01andagoog, cap. VIII «Del conocimiento y uso que tenían de la agricultura» (pp. 188–189): allanaban las laderas con paredes de piedra que sostenían la tierra a nivel, «todas ellas de piedra seca … como son muchos de los andenes que todavía permanecen en la comarca del Cuzco».
  - A (localizada por búsqueda automática, sin contrastar directamente): Frank Meddens y otros, «Where the Water Flows…», *Latin American Antiquity* 37 (2): 189–207 (2026), CC BY 4.0: https://www.cambridge.org/core/product/ADEECF01245B8D8CC483B5C822646030/core-reader. Documenta terrazas con muro de contención inclinado (tipología de Kendall y Rodríguez 2009) introducidas en el valle de Chicha-Soras en el Horizonte Medio, antes de los incas.
  - Identificadas y sin consultar: Donkin (1979); Kendall (1985).
- Discrepancias entre fuentes: —
- Notas de representación: tres niveles con muro de contención de piedra seca, sin mortero, como describe Cobo para los andenes del Cusco (desde el alcance v4.4, piedra tosca de contorno irregular en hiladas desiguales, [ADR-0021](../../../docs/adr/0021-construcciones-de-pirca.md)), y tierra de cultivo encima, con surcos paralelos al muro, sin cultivo sembrado (R). Las juntas oscuras entre piedras representan la piedra seca. Los escalones de acceso son una licencia de diseño para que el jugador pueda recorrerlas; no se documentan en un sitio concreto.
- Estado de verificación: **verificado (A)**, firmado por el responsable del proyecto el 2026-11-11 sobre la comprobación del agente en las ediciones digitales citadas ([hoja de verificación](hoja_verificacion_fichas.md) §5). El responsable no consultó personalmente las ediciones; las fuentes marcadas «sin contrastar directamente» son de apoyo y no sostienen la clasificación.

### PCH-009 — Pututu
- Tipo: instrumento
- Clasificación: A (piezas en colecciones) / H (su uso anunciando la llegada)
- Uso en el juego: `campaigns/01_pachacutec/scenes/objects/pututu.tscn`; modelo `pch_pututu.glb` (R: caracola con labio rosado sobre una piedra)
- Fuentes:
  - A: Brooklyn Museum, *Incised Strombus-Shell Trumpet*, L52.1 (https://www.brooklynmuseum.org/opencollection/objects/5083), consultado el 2026-11-11. Chavín, 400–200 a. C., Periodo Formativo, sierra norte del Perú; caracola *Strombus*, 28,6 cm; clasificada como instrumento musical. Según el museo, en Chavín de Huántar se tocaban trompetas de caracola en los rituales, y los pueblos indígenas actuales siguen tocándolas para abrir y cerrar las ceremonias públicas.
  - A: Museo Larco, sala 9, vitrina 114, «Ceremonial Trumpet or Pututo, and Whistles» (https://www.museolarco.org/en/?p=2619), consultado el 2026-11-11. Costa norte, 1–1532 d. C.; metal, cerámica y caracola. Según el museo, el *Strombus* se usaba en los Andes como trompeta ceremonial llamada pututo. La vitrina incluye una caracola *Strombus* mochica usada como pututo, cuyo código propio no se localizó en el catálogo. La ficha ML002220 de esa vitrina es una botella mochica con un músico tocando el pututo (https://coleccion.museolarco.org/detail/2220): evidencia iconográfica, no el instrumento.
  - H: Guamán Poma de Ayala, *Nueva corónica y buen gobierno* (c. 1615), dibujo 138, pág. 350 [352] del facsímil de Det Kgl. Bibliotek (https://poma.kb.dk/permalink/2006/poma/352/es/text/): «churu mullu chaski, postillón que lleva trompeta de caracol». Es posterior a la conquista y se usa como indicio del uso de la caracola como señal.
- Discrepancias entre fuentes: —
- Notas de representación: se representa la versión de caracola marina, anterior a los cuernos de vacuno introducidos tras 1532. La forma exacta es una reconstrucción (R).
- Estado de verificación: **verificado (A / H)** por el responsable del proyecto el 2026-11-11, con las fichas del Brooklyn Museum y del Museo Larco y el facsímil de Guamán Poma a la vista. Historia: se marcó «verificado (A)» el 2026-11-10 con el código ML002220 atribuido por error a la caracola de la vitrina 114; la verificación se retiró y se rehízo el 2026-11-11. No hay en estas fuentes un pututu de caracola fechado como inca: su uso en una llacta del siglo XV se infiere de la continuidad de la tradición (del Formativo a 1532) y del dibujo de Guamán Poma (R).

### PCH-010 — Telar y textil
- Tipo: herramienta / vestimenta
- Clasificación: A / R
- Uso en el juego: telar de la tejedora en `Llacta/NPCs/Tejedora`; modelo `pch_loom.glb` (R: telar de cintura atado a una estaca, con rombos escalonados en el tejido). Desde el alcance v3.7 (ADR-0015), la tejedora teje arrodillada en el extremo del telar, como en el dibujo 80 de Guamán Poma citado abajo (R: postura y gesto de tejer reconstruidos sobre esa misma fuente, sin fuente nueva)
- Fuentes:
  - Dumbarton Oaks, *All T'oqapu Tunic*, PC.B.518 (https://museum.doaks.org/objects-1/info/23071), consultado el 2026-11-11. Inca, Horizonte Tardío, 1450–1540; lana y algodón. Urdimbre de algodón sin teñir y trama de fibra de camélido teñida; tejida como un solo rectángulo, doblado y cosido.
  - The Met, *Unfinished Sampler Panel on Loom*, 63.97 (https://www.metmuseum.org/art/collection/search/308378), consultado el 2026-11-11. Costa central del Perú (?), siglos X–XV; algodón, pelo de camélido y madera. Tejido sin terminar sobre su telar; la ficha no indica el tipo de telar.
  - Guamán Poma de Ayala, *Nueva corónica y buen gobierno* (c. 1615), dibujo 80, «awakuq warmi, tejedora de treinta y tres años», pág. 215 [217] del facsímil de Det Kgl. Bibliotek (https://poma.kb.dk/permalink/2006/poma/217/es/text/). Mujer arrodillada que teje en un telar tensado desde un poste. Es posterior a la conquista y se usa como indicio.
  - Identificada y sin consultar: John V. Murra, *La organización económica del estado inca* (Siglo XXI, 1978), sobre producción textil y reciprocidad.
- Discrepancias entre fuentes: —
- Notas de representación: fibras de camélido y algodón (A). El telar de cintura atado a una estaca es reconstrucción (R) inferida del dibujo 80 de Guamán Poma y de los telares andinos en colecciones. Los colores teñidos son A; el motivo geométrico concreto es R.
- Estado de verificación: **verificado (A)** por el responsable del proyecto el 2026-11-11, con las fichas de Dumbarton Oaks y del Met y el facsímil de Guamán Poma a la vista. El tipo de telar queda como R.

### PCH-011 — Mensajero (no chasqui)
- Tipo: personaje
- Clasificación: H / R
- Uso en el juego: `mundo_base.tscn` (`Llacta/NPCs/Mensajero`) y `messenger_event.gd`; modelo `pch_npc_messenger.glb` (R: unku de viaje sin insignias, paño en la cabeza, chuspa y bulto atado a la espalda)
- Fuentes:
  - Pedro Sarmiento de Gamboa, *Historia de los Incas* (1572), cap. XXVII «Coming of the Chancas against Cuzco», en la traducción de Clements R. Markham, *History of the Incas* (Hakluyt Society, 2.ª serie, vol. XXII, Cambridge, 1907); edición digital de Project Gutenberg n.º 20218, sin paginación. Los chancas capturan en Conchacalla a un hombre que se ofrece a guiarlos; a medio camino huye al Cusco y avisa de que avanzan. El texto dice que era «a Quillis-cachi of Cuzco», y su noticia hace que Viracocha apresure la huida a Chita. *Quilliscachi* es en Sarmiento el nombre de un grupo o linaje del valle del Cusco (nota 63 de Markham), no un oficio de mensajero.
  - Inca Garcilaso de la Vega, *Comentarios reales*, I parte, lib. VI, cap. VII «Postas y correos, y los despachos que llevaban», ed. Horacio H. Urteaga (Lima, Sanmartí, 1918), t. 2, pp. 149–152 (escaneo en archive.org: `loscomentariosre02vega`). Describe a los chasquis como correos por relevos al servicio del rey, sin fechar la institución en ningún reinado. Distingue al chasqui del *cacha*, el mensajero que va en persona de un señor a otro.
  - La traducción de Bauer y Smith (2007) no se ha consultado; sus páginas (107–111) proceden del índice de la editorial y no se usan.
- Discrepancias entre fuentes: las crónicas no coinciden en quién da la alarma ni en su nombre.
- Notas de representación: en el juego es **mensajero**, no chasqui. Llamarlo chasqui en una llacta anterior a la expansión sería anacrónico: la institución de postas se documenta para el Estado imperial. Ropa de viaje, sin insignias estatales; llega agotado.
- Estado de verificación: **verificado (H)** por el responsable del proyecto el 2026-11-11, con las ediciones digitales citadas a la vista (Sarmiento, cap. XXVII; Garcilaso, lib. VI, cap. VII). La parte R (ropa de viaje, llegada agotado) se basa en esas fuentes y no requiere cita propia.

### PCH-012 — Ofrenda a la Pachamama
- Tipo: objeto / ritual
- Clasificación: H / R
- Uso en el juego: `campaigns/01_pachacutec/scenes/objects/ofrenda_pachamama.tscn`; modelo `pch_offering_shrine.glb` (R: plataforma baja de piedra con losa, plato de maíz, mazorca y hojas de coca)
- Fuentes:
  - H: Clements R. Markham (trad. y ed.), *Narratives of the rites and laws of the Yncas* (Hakluyt Society, Londres, 1873; escaneo en archive.org: `narrativesofrite00moli`).
    - «Report by Polo de Ondegardo», pp. 155 y 166–167 (según el índice del volumen, voz *Pacha-mama*): en cada pueblo se apartaban tierras para el culto del Sol, el Creador, el Trueno, la Pachamama y las demás huacas, y la Pachamama tenía rebaños propios para sus sacrificios.
    - Cristóbal de Molina, «Fables and rites of the Yncas», pp. 17 y 20: a las huacas se les ofrecían cestos de coca, maíz tostado y conchas mullu, y los sacerdotes sacrificaban maíz y coca pidiendo un buen año.
  - Identificadas y sin consultar: Polo de Ondegardo, *Informaciones acerca de la religión y gobierno de los incas* (ed. Urteaga y Romero, Lima, 1916); Cieza de León, *El señorío de los Incas*; Guamán Poma, *Nueva corónica*.
- Discrepancias entre fuentes: —
- Notas de representación: la Pachamama recibía culto y sacrificios (Polo), y la coca y el maíz se ofrecían a las huacas (Molina). Ninguna de estas fuentes describe una ofrenda de coca dirigida expresamente a la Pachamama sobre un adoratorio bajo: el gesto del juego, la ofrenda concreta y la forma del adoratorio son reconstrucción (R). El gesto se representa como acto de reciprocidad, no como pago.
- Estado de verificación: **verificado (H / R)** por el responsable del proyecto el 2026-11-11, con el volumen de Markham (1873) a la vista.

### PCH-013 — Ichu y queñua
- Tipo: flora
- Clasificación: A
- Uso en el juego: vegetación del terreno; modelos `pch_ichu_a.glb`, `pch_ichu_b.glb` (R: matas de hojas finas y pajizas) y `pch_quenua_a.glb`, `pch_quenua_b.glb` (R: varios troncos retorcidos de corteza rojiza y follaje menudo), repartidos por `vegetation.gd`. Las terrazas quedan sin vegetación por ahora
- Fuentes:
  - Queñua: B. B. Simpson, *A revision of the genus Polylepis (Rosaceae: Sanguisorbeae)*, Smithsonian Contributions to Botany 43 (Smithsonian Institution Press, 1979), p. 52, especie 13, *Polylepis incana* (texto abierto: https://archive.org/details/revisionofgenus431979simp). Se distribuye del centro de Ecuador al departamento del Cusco. Nombres comunes: quihuar, quihual, quenuina, cceuna, qqueuna. Según la obra, los indígenas usan su madera para herramientas de cultivo, construcción y leña.
  - Ichu: *Jarava ichu* Ruiz & Pav. (sinónimo *Stipa ichu*; IPNI 326284-2). Distribución según la World Checklist of Vascular Plants (Kew) y el Catalogue of Life, consultada vía GBIF el 2026-11-11 (https://api.gbif.org/v1/species/5678417/distributions): Perú, Bolivia, Ecuador, Colombia, Venezuela, noroeste de Argentina, México y Centroamérica; introducida solo en España. GBIF registra 31 ejemplares recogidos en el Cusco.
- Discrepancias entre fuentes: —
- Notas de representación: solo especies presentes antes de 1532. Prohibidos el eucalipto y cualquier especie introducida. El aspecto concreto de las matas y los árboles del juego es reconstrucción (R).
- Estado de verificación: **verificado (A)** por el responsable del proyecto el 2026-11-11, con Simpson (1979) y la distribución de la WCVP a la vista. La ficha de POWO, que marca la especie como nativa, no se pudo abrir de forma automática.

### PCH-015 — Evento: la noticia chanca
- Tipo: evento
- Clasificación: H (tradición) / N (puesta en escena)
- Uso en el juego: `messenger_event.gd` y textos `PCH_NARR_*`
- Fuentes:
  - Pedro Sarmiento de Gamboa, *Historia de los Incas* (1572), trad. Markham (Hakluyt Society, 1907; Project Gutenberg n.º 20218, sin paginación).
    - Cap. XXV: Viracocha, ya viejo, nombra sucesor a su hijo Inca Urco, saltándose el orden de sucesión.
    - Cap. XXVI: los chancas avanzan desde Andahuaylas y acampan en Ichu-pampa, a cinco leguas del Cusco. Aconsejado por sus capitanes, Viracocha deja el Cusco y se va a Chita con Inca Urco e Inca Socso; Inca Yupanqui se queda a defender la ciudad.
    - Cap. XXVII: ataque chanca (ver PCH-011).
  - Juan de Betanzos, *Suma y narración de los Incas* (1551), I parte, cap. VI, ed. Marcos Jiménez de la Espada (Madrid, 1880), pp. 19–26 (Project Gutenberg n.º 25705). El señor chanca Uscovilca marcha sobre el Cusco. Viracocha sale con la gente de la ciudad al peñol de Caca Xaqui Xahuana y se lleva a sus seis hijos, entre ellos Inca Urco, «en quien pensaba dejar el lugar y nombre de su persona». Inca Yupanqui se queda con tres compañeros. Los caps. VII–X (pp. 26–62) siguen con la defensa y las victorias.
  - Retirados: las páginas de la traducción de Bauer y Smith (2007), tomadas del índice de la editorial, y el artículo de J. J. Huertas Vallejos en *Historia y Cultura* 20, que no se localizó en ningún catálogo. El cap. XIII de Betanzos, citado antes, no trata de la guerra.
- Discrepancias entre fuentes:
  - Garcilaso, *Comentarios reales*, ed. Urteaga (Lima, 1918), cuenta otra versión: en el libro IV, caps. XXIII–XXIV, «El Inca desampara la ciudad y el príncipe heredero la socorre», el que huye es Yahuar Huácac. En el libro V, caps. XVII–XX, el príncipe Viracocha vence a los chancas y destrona a su padre. Esto se comprobó por los títulos de capítulo del índice.
  - Entre Sarmiento y Betanzos cambia el lugar de la retirada (Chita o el peñol de Caca Xaqui Xahuana), pero en ambos el inca abandona la ciudad con su heredero Inca Urco.
- Notas de representación: el guion sigue la versión de Betanzos y Sarmiento y la presenta como lo que dice el mensajero, no como verdad única. No se escenifica la batalla: el juego termina cuando la llacta responde. La llegada a la plaza, la reunión y la partida son puesta en escena (N).
- Estado de verificación: **verificado (H)** por el responsable del proyecto el 2026-11-11, con las ediciones digitales citadas a la vista (Sarmiento, caps. XXV–XXVI; Betanzos, cap. VI; Garcilaso, índice del t. 2). La parte N está justificada en las notas de representación.

### PCH-016 — Plaza y caminos
- Tipo: lugar
- Clasificación: A / R / N (plaza como licencia de diseño)
- Uso en el juego: `Llacta/Plaza`, `Llacta/PathSouth`, `Llacta/PathEast`, `Llacta/PathWest`
- Fuentes:
  - A: Covey, Quave y otros, *Antiquity* 99 (2025), pp. 483–484 (ver PCH-006): en los sitios del Intermedio Tardío de la región del Cusco hay contextos excavados de «public spaces».
  - Caminos (localizada por búsqueda automática, sin contrastar directamente): Ministerio de Cultura del Perú, Proyecto Qhapaq Ñan, *Guía de identificación y registro del Qhapaq Ñan* (2023), https://qhapaqnan.cultura.pe/sites/default/files/mi/archivo/GuiaIdentificacionRegistrosCaminos2023.pdf. Caminos con calzada de tierra y caminos empedrados (§4.2–4.3), y rutas anteriores a los incas reutilizadas por el Estado inca (§2.1). Cita a Hyslop (1992 [1984]).
  - Ushnu (localizada por búsqueda automática, sin contrastar directamente): Rubén Stehberg y otros, «Plataforma ceremonial ushnu inca de Chena», *Chungara* 48 (4): 557–588 (2016), https://www.redalyc.org/pdf/326/32649574006.pdf. El ushnu se halla «solo en instalaciones políticamente jerarquizadas dentro del planeamiento urbano inka» (p. 560).
  - Identificadas y sin consultar: Morris y Thompson (1985); Hyslop, *The Inka Road System* (1984).
- Discrepancias entre fuentes: **Bernabé Cobo, *Historia del Nuevo Mundo* (1653), ed. Jiménez de la Espada, t. IV (1893), lib. XIV, cap. III, p. 163**: fuera del Cusco y de algunos lugares grandes, en los pueblos «las casas estaban amontonadas, sin orden … de modo que ni formaban calles ni plazas». Es un testimonio colonial que generaliza, pero contradice que toda aldea tuviera plaza. Covey y colaboradores sí hablan de espacios públicos en sitios del Intermedio Tardío.
- Notas de representación: la plaza central de tierra apisonada es una **licencia de diseño (N)** apoyada en los espacios públicos del Intermedio Tardío (R): el juego necesita un lugar de reunión visible para el evento, aunque Cobo dice que las aldeas pequeñas no solían tener plaza. Los caminos de tierra son reconstrucción (R). No se incluye ushnu, que corresponde a centros incas jerarquizados.
- Estado de verificación: **verificado (A / R / N)**, firmado por el responsable del proyecto el 2026-11-11 sobre la comprobación del agente en las ediciones digitales citadas ([hoja de verificación](hoja_verificacion_fichas.md) §5). El responsable no consultó personalmente las ediciones; las fuentes marcadas «sin contrastar directamente» son de apoyo y no sostienen la clasificación.

### PCH-017 — Curaca y hombres principales
- Tipo: personaje / organización social
- Clasificación: H / R
- Uso en el juego: `Llacta/NPCs/Curaca`, `Llacta/NPCs/Principal1`, `Llacta/NPCs/Principal2`; modelos `pch_npc_curaca.glb`, `pch_npc_principal.glb` y `pch_npc_authority.glb` (R: unku con franja ajedrezada, manto teñido y cinta en la cabeza como distintivos discretos; sin vara ni orejeras, que serían coloniales o imperiales). Desde el alcance v4.0, el distintivo del unku es un cinturón de dos filas de t'oqapu con motivos geométricos sencillos a la altura de la cintura (R, ver notas)
- Fuentes:
  - H: Juan de Betanzos, *Suma y narración de los Incas*, I parte, cap. VII, ed. Jiménez de la Espada (Madrid, 1880), Project Gutenberg n.º 25705 (p. 26 y ss.): ante el avance de Uscovilca, Inca Yupanqui decide «inviar sus mensajeros á los caciques de los pueblos comarcanos … que les rogaba que le favoresciesen con sus poderes y gente», y envía a sus cuatro compañeros «á los caciques y Señores que ansí eran en torno de la ciudad en espacio de tres leguas». Los caciques responden que solo ayudarán cuando él junte gente propia.
  - Definición de curaca (localizadas por búsqueda automática, sin contrastar directamente): María Rostworowski, «Las macroetnias en el ámbito andino», *Allpanchis* 35/36: 3–28 (1990), https://revistas.ucsp.edu.pe/index.php/Allpanchis/article/download/882/1280/6247: grupos étnicos «gobernados por sus Hatun Curaca», con «varios curacas subalternos» (p. 18). Ricardo Alva Mariñas, *Bulletin de l'IFEA* 37 (1) (2008), https://www.redalyc.org/pdf/126/12611728018.pdf: los curacas, «llamados también caciques», con autoridad política y religiosa basada en el linaje (p. 258).
  - Corregida: la cita anterior a Sarmiento, cap. 27 («Inca Yupanqui convoca a los curacas») no se sostiene; en los caps. XXVI–XXVIII Sarmiento no recoge esa petición. Identificadas y sin consultar: Rostworowski (1961 y 1978).
- Discrepancias entre fuentes: Betanzos llama «caciques y Señores» a los jefes de los pueblos vecinos y dice que al principio no acudieron; el juego muestra a un curaca que parte hacia el Cusco tras la noticia, una puesta en escena (N) que no contradice la petición documentada.
- Notas de representación: el curaca y los hombres principales **parten hacia el Cusco para sumarse a la defensa**; el guion debe impedir la lectura de huida. Distintivos de autoridad discretos (R). La franja ajedrezada del unku imita el t'oqapu, que según Dumbarton Oaks (PC.B.518) solo podía llevar la gente de alto rango en el Estado inca. Ponerla en un curaca local anterior a la expansión es reconstrucción (R) y no está documentado.
- Estado de verificación: **verificado (H / R)**, firmado por el responsable del proyecto el 2026-11-11 sobre la comprobación del agente en las ediciones digitales citadas ([hoja de verificación](hoja_verificacion_fichas.md) §5). El responsable no consultó personalmente las ediciones; las fuentes marcadas «sin contrastar directamente» son de apoyo y no sostienen la clasificación.

### PCH-018 — Vestimenta y apariencia del habitante común
- Tipo: vestimenta
- Clasificación: R (a partir de A)
- Uso en el juego: tejedora, agricultor, mensajero y habitantes; modelos `pch_npc_weaver.glb` y `pch_npc_villager.glb` (R: anacu con faja de franjas, lliclla con franjas sujeta con tupu, trenzas), `pch_npc_farmer.glb` (R: unku, manto, paño en la cabeza, chuspa y chaquitaclla) y `pch_npc_commoner.glb` (R: unku, manto y chuspa). Ojotas en todos. Desde el alcance v3.8 ([ADR-0016](../../../docs/adr/0016-personajes-realistas-makehuman.md)), los cuerpos son de MakeHuman, con la piel teñida a un moreno de la sierra y el pelo negro (R: interpretación sin retratos auténticos), y las mujeres llevan el pelo largo suelto en lugar de trenzas, porque la trenza disponible en MakeHuman trae un flequillo moderno. Desde el alcance v3.9 ([ADR-0017](../../../docs/adr/0017-cabezas-rocketbox.md)), las cabezas son de la Rocketbox Avatar Library: rostros de personas actuales con la piel teñida y peinados de cada avatar (corto, coleta, moño o melena), sin barba (R: interpretación, no retratos andinos). **Peinados: anacronismo declarado** (revisión de anacronismos del 2026-11-12, [hoja de verificación](hoja_verificacion_fichas.md) §7). Son cortes actuales, no reconstrucciones. Se aceptan como limitación de los recursos libres: ni MakeHuman ni Rocketbox ofrecen pelo largo trenzado ni cortes andinos sin rasgos modernos, y modelarlos queda fuera del slice. La versión definitiva debería llevar pelo largo, suelto o trenzado, en las mujeres, y en los hombres pelo sin corte moderno. Desde el alcance v4.0, las prendas llevan textiles con diseño: franjas y zigzag escalonado en el unku, faja con rombos de gradas, lliclla con bandas decoradas y manto con franjas en el borde (R: motivos geométricos inspirados en las piezas de colección citadas, sin copiar ninguna pieza concreta). Desde el alcance v4.3 ([ADR-0020](../../../docs/adr/0020-ropa-cortada-y-cosida.md)), las prendas se construyen como paños de telar:
  - el unku, como un rectángulo doblado con abertura para el cuello y los lados cosidos hasta las sisas, la hechura de la túnica de Dumbarton Oaks (a partir de A);
  - el anacu, como un paño cosido bajo los brazos y prendido sobre los hombros;
  - la lliclla y el manto, como paños echados sobre los hombros, prendidos con tupu o anudados al pecho;
  - el bulto, como un fardo de tela atado al pecho.

  Las medidas, la forma de anudar y la caída son reconstrucción (R). El unku del juego mide unos 55 cm de ancho, menos que la túnica del Met (75,6 cm), para que los brazos bajados no atraviesen la tela; es una desviación declarada.
- Fuentes en que se basa (A, consultadas el 2026-11-11):
  - Dumbarton Oaks, *All T'oqapu Tunic*, PC.B.518: túnica (unku) tejida como un rectángulo doblado con abertura para el cuello y los lados cosidos hasta las sisas; algodón y fibra de camélido teñida. Según la ficha, el t'oqapu estaba reservado a personas de alto rango.
  - The Met, *Tunic*, inca, 1460–1540, 33.149.100 (https://www.metmuseum.org/art/collection/search/308120): pelo de camélido y algodón, 75,6 × 94 cm.
  - The Met, *Tupu (pin)*, inca, 1400–1533, aleación de cobre, 1987.394.546 (https://www.metmuseum.org/art/collection/search/315606).
  - Guamán Poma de Ayala, *Nueva corónica* (c. 1615): dibujo 80 (tejedora, pág. 215 [217]) y dibujos 70–89 de la «visita general» (págs. 194–233 [196–235]). Son posteriores a la conquista y se usan solo como indicio, no como modelo directo.
- Discrepancias entre fuentes: —
- Notas de representación:
  - Qué se infiere (R): el hombre común viste un unku de la misma hechura que las túnicas de colección, pero liso y sin t'oqapu, con manto y chuspa. La mujer lleva un vestido largo (anacu) con faja de franjas y una manta (lliclla) sujeta con un tupu de cobre, como en el dibujo 80 y la pieza del Met.
  - Sin retratos «auténticos»; variantes de color y de tocado para distinguir oficios; sin prendas ni elementos coloniales. La apariencia es interpretación declarada.
- Estado de verificación: **verificado (R)** por el responsable del proyecto el 2026-11-11: se indican las piezas A en que se basa y qué se infiere.


### PCH-019 — Cerámica doméstica (cántaros)
- Tipo: objeto
- Clasificación: A (estilo Killke del Cusco) / R (forma y tamaño de uso doméstico)
- Uso en el juego: cántaros junto a la puerta de las viviendas; modelo `pch_prop_jar.glb` (R: dos asas, cuerpo globular, cuello cóncavo, fondo crema con bandas rojas bordeadas de negro y triángulos negros colgando del borde)
- Fuentes:
  - Brian S. Bauer y Charles Stanish, *Killke and Killke-related pottery from Cuzco, Peru, in the Field Museum of Natural History*, Fieldiana Anthropology, n. s., 15 (Field Museum, 1990), texto completo en https://archive.org/details/killkekillkerela15baue.
    - «Definition of Killke Style» (pp. 1–2): los motivos más frecuentes son «broad red or occasionally black bands outlined by one to three narrow black lines», rombos reticulados y «rows of pendant solid or cross-hatched triangles», pintados sobre un engobe crema sin pigmento («unpigmented buff slip background»).
    - «Killke Polychrome Vessels» (pp. 5–11): jarras de asa alta con cuello cóncavo y borde algo abierto (figs. 2–4, pp. 6–8) y una olla de dos asas (fig. 9, p. 10).
    - El estudio presenta el estilo Killke como el antecedente inmediato de la cerámica inca clásica en la región del Cusco.
- Discrepancias entre fuentes: —
- Notas de representación: se elige el estilo Killke, y no el inca imperial (aríbalos), porque la llacta es anterior a la expansión. Las piezas del estudio son vasijas finas de unos 8 a 18 cm; el cántaro del juego, de 35 cm y de uso doméstico, es una reconstrucción (R).
- Estado de verificación: **verificado (A / R)**, firmado por el responsable del proyecto el 2026-11-11 sobre la comprobación del agente en la edición digital citada (secciones y figuras indicadas) ([hoja de verificación](hoja_verificacion_fichas.md) §5). El responsable no consultó personalmente las ediciones; las fuentes marcadas «sin contrastar directamente» son de apoyo y no sostienen la clasificación.

### PCH-020 — Leña de queñua
- Tipo: objeto / recurso
- Clasificación: R (a partir de A)
- Uso en el juego: haces de leña junto a la puerta de las viviendas; modelo `pch_prop_firewood.glb` (R: ramas de corteza rojiza atadas con cuerda)
- Fuentes: B. B. Simpson, *A revision of the genus Polylepis*, Smithsonian Contributions to Botany 43 (1979), p. 52, *Polylepis incana* (texto abierto: https://archive.org/details/revisionofgenus431979simp): «The wood is used by Indians to manufacture instruments for cultivation, for house construction, and as firewood». Ver PCH-013, verificada.
- Discrepancias entre fuentes: —
- Notas de representación: la fuente documenta el uso actual de la madera de queñua como leña. Que una casa del siglo XV guardara un haz atado junto a la puerta es reconstrucción (R).
- Estado de verificación: **verificado (R)**, firmado por el responsable del proyecto el 2026-11-11 sobre la comprobación del agente en la edición digital citada, p. 52 ([hoja de verificación](hoja_verificacion_fichas.md) §5). El responsable no consultó personalmente la edición.

### PCH-021 — Corral de pirca seca
- Tipo: arquitectura / pastoreo
- Clasificación: R
- Uso en el juego: `Llacta/Corrals` en `mundo_base.tscn`: dos corrales bajos de pirca seca (1 m), con una entrada, en las afueras del oeste y el noroeste ([ADR-0021](../../../docs/adr/0021-construcciones-de-pirca.md)). Están vacíos: las llamas siguen fuera del slice (PCH-014).
- Fuentes:
  - A (principal; leída por el agente el 2026-11-12 en la edición en línea): Brian S. Bauer, Lucas C. Kellett y Miriam Aráoz Silva, *Los chancas: investigaciones arqueológicas en Andahuaylas (Apurímac, Perú)*, IFEA, Lima, 2013, cap. 6 «La Fase Chanca en la región de Andahuaylas (1000-1400 d. C.)», párrafos 11, 29 y 32 (https://books.openedition.org/ifea/11659). Es la misma obra que PCH-003. El párrafo 11 dice que los sitios de la Fase Chanca situados cerca de grandes pastizales «a menudo también contienen restos de corrales de piedra». Los párrafos 29 y 32 describen concentraciones de corrales en y alrededor de los asentamientos de cumbre, como indicio de un agropastoralismo cada vez más importante. No se nombra ningún sitio concreto con corrales.
  - A (apoyo; resumen y datos leídos por el agente el 2026-11-12 en la página de la revista): Trinidad Aguilar Meza, «Estructuras para la caza y el pastoreo: un legado prehispánico», *Devenir* 5 (9): 153–172 (2018), DOI 10.21754/devenir.v5i9.205, https://revistas.uni.edu.pe/index.php/devenir/article/view/205 (PDF: https://revistas.uni.edu.pe/index.php/devenir/article/view/205/115). Prospección en comunidades altoandinas del Cusco, a más de 3900 m (Waqoto, La Raya, Qelloqocha). Según el resumen, «las kanchas sirven para el pastoreo de llamas y alpacas». El resumen no dice que sean de piedra ni las data.
- Discrepancias entre fuentes: —
- Notas de representación:
  - Bauer y colaboradores documentan corrales de piedra asociados a asentamientos del Intermedio Tardío (1000–1400 d. C.) en Andahuaylas, la región vecina al oeste del Cusco. Aguilar Meza documenta kanchas pastoriles prehispánicas en la sierra del Cusco.
  - Se infiere (R) que una llacta de la región del Cusco hacia 1438 tendría corrales de piedra en sus afueras. Es una analogía regional: ninguna de las dos fuentes describe un corral de un sitio del Cusco de esa fecha.
  - El tamaño, la altura del muro (1 m), la entrada única, la piedra seca sin mortero y la posición en las afueras son R.
- Estado de verificación: **verificado (R)** por el responsable del proyecto el 2026-11-12, con el cap. 6, párrafos 11 y 32, de Bauer y colaboradores a la vista ([hoja de verificación](hoja_verificacion_fichas.md) §6). El agente había localizado y leído las dos fuentes ese mismo día.

### PCH-022 — El Cusco antes de la expansión inca
- Tipo: evento / contexto político
- Clasificación: A (el Cusco consolida su región antes de expandirse) / R («el señorío más fuerte de la región»)
- Uso en el juego: tarjetas de la introducción `PCH_INTRO_1` y `PCH_INTRO_2` ([ADR-0023](../../../docs/adr/0023-introduccion-del-slice.md)): «Los Andes, siglo XV.» y «En el valle del Cusco gobiernan los incas. Todavía no son un imperio: son el señorío más fuerte de la región.»
- Fuentes:
  - A (leída por el agente el 2026-11-12 en la edición en línea; sin paginación por pasaje): R. Alan Covey, Kylie E. Quave y otros, «Settlement discontinuity at Ak'awillay and the development of the Inca imperial capital region», *Antiquity* 99 (404): 481–499 (2025), la misma obra que PCH-006: https://www.cambridge.org/core/journals/antiquity/article/settlement-discontinuity-at-akawillay-and-the-development-of-the-inca-imperial-capital-region/6B5177903D92CCFDC05F520CE36CC60B.
    - Habla de «the many named groups living in the Cuzco region during the Late Intermediate Period (c. AD 1000–1400)».
    - Según las crónicas, hubo alianzas matrimoniales y anexiones incas «as late as the early 1400s».
    - Conclusión: los incas «built alliances, conquered rivals and consolidated sovereign control over their capital region».
    - Sitúa el periodo imperial en el siglo XV; la expansión fuera de la región del Cusco la fechaba la cronología tradicional en 1438, y modelos recientes la adelantan unas décadas.
  - A (identificada, sin consultar): R. Alan Covey, *How the Incas Built Their Heartland: State Formation and the Innovation of Imperial Strategies in the Sacred Valley, Peru*, University of Michigan Press, 2006; edición en acceso abierto de 2025: https://doi.org/10.3998/mpub.88668. Según la descripción de la editorial, describe la sociedad inca «in the centuries leading up to imperial expansion».
- Discrepancias entre fuentes: la fecha del inicio de la expansión (1438 en la cronología tradicional; algo antes según los modelos recientes que cita Covey). Por eso las tarjetas dicen «siglo XV», sin año.
- Notas de representación:
  - «Todavía no son un imperio»: se apoya en Covey y otros (2025). Antes de la expansión, los incas consolidan su dominio en la región del Cusco, entre muchos otros grupos.
  - «El señorío más fuerte de la región» es una inferencia (R): la fuente dice que se aliaron con unos grupos, vencieron a sus rivales y consolidaron su control, no que fueran ya el más fuerte en un año concreto.
  - «Señorío» es un término castellano para una entidad política andina; se usa en lugar de «reino» o «estado» para no presuponer su forma de gobierno.
- Estado de verificación: **verificado (A / R)** por el responsable del proyecto el 2026-11-12, con la conclusión de Covey y otros (2025) a la vista ([hoja de verificación](hoja_verificacion_fichas.md) §8). El agente había localizado y leído la fuente ese mismo día. Covey (2006) sigue sin consultar y no sostiene la clasificación.

### PCH-023 — Mapa de la introducción
- Tipo: lugar
- Clasificación: R (posición de la llacta respecto al Cusco) / N (dibujo del relieve)
- Uso en el juego: capa de la tarjeta `PCH_INTRO_2` de la introducción, `scripts/ui/intro_map.gd` ([ADR-0025](../../../docs/adr/0025-imagenes-de-la-introduccion.md)). Rótulos «Cusco», «Tu llacta» y «N».
- Fuentes:
  - Se apoya en PCH-006 (A / R): la llacta es una de las aldeas del Intermedio Tardío de la región del Cusco que registran las prospecciones (Covey y otros 2025), y no se identifica con ningún sitio real.
  - Dentro del juego, el camino del norte es el que va al Cusco: frase del agricultor `PCH_TALK_FARMER` y llegada del mensajero por el camino norte (alcance §2.2).
- Discrepancias entre fuentes: —
- Notas de representación:
  - El mapa es esquemático y no está a escala: no da distancias ni coordenadas.
  - Que la llacta quede al sur del Cusco es una reconstrucción (R) coherente con el juego, no un dato.
  - El relieve en «^» es un recurso gráfico (N): indica sierra, no montañas concretas.
  - No se marcan ríos, territorios, fronteras ni pueblos vecinos, para no afirmar geografía sin fuente ni adelantar la noticia.
- Estado de verificación: pendiente de firma. Falta que una persona compruebe que el mapa solo muestra lo descrito y firme ([hoja de verificación](hoja_verificacion_fichas.md) §9).

---

## Fuera del vertical slice

Fichas de elementos que se valoraron pero **no están en el juego**. No bloquean el cierre de la Fase 4, por decisión del responsable del proyecto del 2026-11-11 y según [ADR-0011](../../../docs/adr/0011-fichas-fuera-del-slice.md). Si alguno se incorpora, su ficha vuelve a la lista principal como pendiente y bloquea el cierre hasta que se verifique.

### PCH-014 — Llama / alpaca (opcional)
- Tipo: fauna
- Clasificación: A
- Uso en el juego: ninguno; el elemento no está en el vertical slice
- Fuentes (identificadas; pendiente de publicación): estudios de camélidos sudamericanos domésticos; falta referencia concreta.
- Discrepancias entre fuentes: —
- Notas de representación: si se incluye, sin aparejos de origen europeo.
- Estado de verificación: pendiente (no bloquea el cierre mientras el elemento siga fuera del juego). Referencia identificada y sin consultar: J. C. Wheeler, «Evolution and present situation of the South American Camelidae», *Biological Journal of the Linnean Society* 54(3): 271–295 (1995), DOI 10.1016/0024-4066(95)90021-7.
