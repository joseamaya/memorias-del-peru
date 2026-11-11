# Registro histórico — Campaña 01: Pachacútec

Formato y reglas en [docs/07_convenciones_historicas.md](../../../docs/07_convenciones_historicas.md). Ningún elemento entra en el Vertical Slice con estado “pendiente”.

Las fichas en estado “pendiente” tienen clasificación definitiva pero citas incompletas (falta edición, capítulo o página). Para pasar a “verificado” deben cumplir el requisito mínimo de su clasificación (docs/07 §2).

---

### PCH-001 — Cusi Yupanqui / Pachacútec
- Tipo: personaje
- Clasificación: H (existencia y papel en la tradición); detalles de su vida: según fuente
- Uso en el juego: por definir
- Fuentes: Betanzos, *Suma y narración de los Incas* (1551); Sarmiento de Gamboa, *Historia de los Incas* (1572), caps. 26–28 (pp. 104–114, trad. Bauer y Smith, University of Texas Press, 2007); Cieza de León, *El señorío de los Incas*; Rostworowski, *Pachacútec Inca Yupanqui* (1953)
- Discrepancias entre fuentes: Garcilaso atribuye la victoria sobre los chancas a Inca Viracocha. Falta su cita con capítulo y página para cerrar esta ficha.
- Notas de representación: no mostrar retratos “auténticos”; toda apariencia física es R
- Estado de verificación: pendiente

### PCH-002 — Guerra chanca y defensa del Cusco
- Tipo: evento
- Clasificación: H (tradición narrada) / A (debate sobre escala, ver PCH-003)
- Uso en el juego: eje narrativo de la campaña
- Fuentes: ver PCH-001
- Discrepancias entre fuentes: protagonista, desarrollo de batallas y fecha
- Notas de representación: presentar la versión elegida como versión de cronistas. Las versiones alternativas se mencionan dentro del relato (p. ej. personajes que cuentan la historia de forma distinta) o en material de apoyo fuera del juego; en el códice histórico solo si este se aprueba (docs/01 §6)
- Estado de verificación: pendiente

### PCH-003 — Los chancas (chanka)
- Tipo: pueblo / organización política
- Clasificación: H (mención en crónicas) / A (investigación arqueológica en Andahuaylas)
- Uso en el juego: antagonista colectivo
- Variantes del nombre: *chanca* (forma hispanizada, usada en la interfaz según docs/07 §5); *chanka* (grafía usada en la bibliografía arqueológica reciente y más cercana a la escritura quechua actual)
- Fuentes: crónicas citadas en PCH-001; Brian S. Bauer, Lucas C. Kellett y Miriam Aráoz Silva, *The Chanka: Archaeological Research in Andahuaylas (Apurimac), Peru*, Cotsen Institute of Archaeology Press, Monografía 68, 2010
- Discrepancias entre fuentes: la arqueología sugiere una organización menos centralizada que la descrita por los cronistas
- Notas de representación: evitar caricatura como “bárbaros”; mostrar pueblo con cultura propia
- Estado de verificación: pendiente

### PCH-004 — Quero
- Tipo: objeto
- Clasificación: A (piezas en colecciones) / R (decoración específica)
- Uso en el juego: `campaigns/01_pachacutec/scenes/objects/quero_chicha.tscn` (Fase 2); modelo `pch_quero.glb` (R: perfil abocinado con bandas incisas de zigzag)
- Variantes del nombre: *quero* (forma hispanizada, interfaz). Forma quechua por verificar: aparecen *qiru* y *q'iru* en distintas fuentes; hay que confirmar cuál corresponde al vaso y cuál a otro significado (se ha señalado que *q'iru* podría significar “madera/leña”) según el diccionario de referencia que adopte la campaña
- Fuentes (identificadas; pendiente de verificación de edición y página):
  - The Metropolitan Museum of Art, *Kero*, cultura inca, siglo XV–inicios del XVI, madera (¿escallonia?), objeto 1994.35.11. https://www.metmuseum.org/art/collection/search/316839
  - Museo Pachacamac, *Qero* MD-00863, Horizonte Tardío (1470–1533), madera tallada e incisa, procedencia Pirámide con rampa 7.
  - ICOM, *Kero Inca, madera*, Museo Regional de Cusco: describe la diferencia entre el kero inca de decoración incisa y el colonial policromo.
- Discrepancias entre fuentes: —
- Notas de representación: preferir decoración incisa geométrica; uso en pares en contextos de reciprocidad
- Estado de verificación: pendiente

### PCH-005 — Chicha de jora
- Tipo: alimento / bebida
- Clasificación: H / A
- Uso en el juego: interacción del quero; recupera estamina (la mecánica de estamina es N)
- Fuentes (identificadas; pendiente de verificación de edición y página):
  - Juan de Betanzos, *Suma y narración de los Incas* (1551).
  - Pedro Cieza de León, *El señorío de los Incas*.
  - Inca Garcilaso de la Vega, *Comentarios reales* (1609).
  - Craig Morris y Donald Thompson, *Huánuco Pampa: An Inca City and Its Hinterland* (1985): producción y consumo de chicha en contextos estatales incas.
- Discrepancias entre fuentes: —
- Notas de representación: bebida de maíz fermentado vinculada a reciprocidad y ritual; su efecto en el juego es una licencia mecánica
- Estado de verificación: pendiente

### PCH-006 — Llacta / asentamiento
- Tipo: lugar
- Clasificación: A (asentamientos excavados) / R (esta llacta concreta)
- Uso en el juego: escena completa `mundo_base.tscn`
- Fuentes (identificadas; pendiente de página): Craig Morris y Donald Thompson, *Huánuco Pampa: An Inca City and its Hinterland* (Thames and Hudson, 1985); John Hyslop, *Inka Settlement Planning* (University of Texas Press, 1990).
- Discrepancias entre fuentes: —
- Notas de representación: la llacta del juego no se identifica con ningún sitio real ni recibe nombre propio. Los conjuntos excavados de la sierra son en su mayoría imperiales o administrativos; una llacta rural anterior a la expansión se reconstruye por analogía y se declara como tal.
- Estado de verificación: pendiente

### PCH-007 — Vivienda rural de piedra y barro
- Tipo: arquitectura
- Clasificación: A / R
- Uso en el juego: `Llacta/Houses` en `mundo_base.tscn`; modelos `pch_house_a.glb` y `pch_house_b.glb` (R: planta rectangular de pirka con mortero de barro, puerta trapezoidal en el muro largo, hastiales de piedra y techo de ichu a dos aguas)
- Fuentes (identificadas; pendiente de página): Morris y Thompson, *Huánuco Pampa* (1985): casas rectangulares de **pirka**, muros dobles de piedra de campo con relleno de ripio y barro y nichos trapezoidales; Vincent R. Lee, «Inca Architecture and Building Methods», *Andean Past* (2016), sobre «pirca» de piedra de campo con mortero de arcilla.
- Discrepancias entre fuentes: —
- Notas de representación: se descarta la sillería imperial fina, anacrónica para una llacta rural anterior a la expansión. Huánuco Pampa es un centro imperial: sirve de analogía constructiva, no de prueba directa del tipo de vivienda representado.
- Estado de verificación: pendiente

### PCH-008 — Terraza agrícola
- Tipo: arquitectura
- Clasificación: A
- Uso en el juego: `Llacta/Terraces` en `mundo_base.tscn`
- Fuentes (identificadas; pendiente de página): Robin A. Donkin, *Agricultural Terracing in the Aboriginal New World* (University of Arizona Press, 1979); Ann Kendall, *Aspects of Inca Architecture* (BAR, 1985).
- Discrepancias entre fuentes: —
- Notas de representación: tres niveles con muro de contención de piedra. Los escalones de acceso son una licencia de diseño para que el jugador pueda recorrerlas; no se documentan en un sitio concreto.
- Estado de verificación: pendiente

### PCH-009 — Pututu
- Tipo: instrumento
- Clasificación: A (piezas en colecciones) / H (su uso anunciando la llegada)
- Uso en el juego: `campaigns/01_pachacutec/scenes/objects/pututu.tscn`; modelo `pch_pututu.glb` (R: caracola con labio rosado sobre una piedra)
- Fuentes: Museo Larco, ficha ML002220, «Ceremonial Trumpet or Pututo», sala 9, vitrina 114: caracola *Strombus*, Perú, 1–1532 d. C., usada como trompeta ceremonial. Guamán Poma de Ayala, *Nueva corónica y buen gobierno* (c. 1615), grabado «Hatun chasqui, churo mullo chasqui» (folio por confirmar).
- Discrepancias entre fuentes: —
- Notas de representación: se representa la versión de caracola marina, anterior a los cuernos de vacuno introducidos tras 1532. La forma exacta es una reconstrucción (R).
- Estado de verificación: **verificado (A)** — la ficha de colección del Museo Larco se consultó en línea el 2026-11-10. La afirmación H sobre su uso por los chasquis sigue pendiente de folio.

### PCH-010 — Telar y textil
- Tipo: herramienta / vestimenta
- Clasificación: A / R
- Uso en el juego: telar de la tejedora en `Llacta/NPCs/Tejedora`; modelo `pch_loom.glb` (R: telar de cintura atado a una estaca, con rombos escalonados en el tejido)
- Fuentes (identificadas; pendiente de página): piezas textiles incas en colecciones públicas (falta ficha concreta); John V. Murra, *La organización económica del estado inca* (1978), sobre producción textil y reciprocidad.
- Discrepancias entre fuentes: —
- Notas de representación: telar de cintura, fibras de camélido y algodón, tintes naturales; el motivo geométrico concreto es una reconstrucción (R).
- Estado de verificación: pendiente

### PCH-011 — Mensajero (no chasqui)
- Tipo: personaje
- Clasificación: H / R
- Uso en el juego: `mundo_base.tscn` (`Llacta/NPCs/Mensajero`) y `messenger_event.gd`; modelo `pch_npc_messenger.glb` (R: unku de viaje sin insignias, paño en la cabeza, chuspa y bulto atado a la espalda)
- Fuentes (identificadas; pendiente de comprobación con la edición a la vista):
  - Pedro Sarmiento de Gamboa, *Historia de los Incas* (1572), cap. 27 «The Chancas attack Cuzco» (trad. Bauer y Smith, University of Texas Press, 2007): un **quillis-cachi** huye del campamento chanca y da la noticia en el Cusco. El rango de páginas (107–111) procede del índice publicado por la editorial; **no se han leído esas páginas**, así que no cuentan como verificación.
  - Inca Garcilaso de la Vega, *Comentarios reales*, I parte, lib. VI, cap. VII «Postas y correos, y los despachos que llevaban» (texto leído en edición digital). El capítulo describe el sistema de postas; **no se afirma** que lo feche en el reinado de Pachacútec. Que el libro VI trate de ese reinado no basta para fechar la institución.
- Discrepancias entre fuentes: las crónicas no coinciden en quién da la alarma ni en su nombre.
- Notas de representación: en el juego es **mensajero**, no chasqui. Llamarlo chasqui en una llacta anterior a la expansión sería anacrónico: la institución de postas se documenta para el Estado imperial. Ropa de viaje, sin insignias estatales; llega agotado.
- Estado de verificación: **pendiente** — requiere que una persona contraste el capítulo 27 de Sarmiento con la edición en papel y confirme la fecha de la institución en Garcilaso.

### PCH-012 — Ofrenda a la Pachamama
- Tipo: objeto / ritual
- Clasificación: H / R
- Uso en el juego: `campaigns/01_pachacutec/scenes/objects/ofrenda_pachamama.tscn`; modelo `pch_offering_shrine.glb` (R: plataforma baja de piedra con losa, plato de maíz, mazorca y hojas de coca)
- Fuentes (identificadas; pendiente de capítulo y página): Polo de Ondegardo, *Informaciones acerca de la religión y gobierno de los incas*; Pedro Cieza de León, *El señorío de los Incas*; Guamán Poma de Ayala, *Nueva corónica*.
- Discrepancias entre fuentes: —
- Notas de representación: ofrenda de alimentos y hojas de coca en un adoratorio bajo; la forma del adoratorio es una reconstrucción (R). El gesto se representa como acto de reciprocidad, no como pago.
- Estado de verificación: pendiente

### PCH-013 — Ichu y queñua
- Tipo: flora
- Clasificación: A
- Uso en el juego: vegetación del terreno; modelos `pch_ichu_a.glb`, `pch_ichu_b.glb` (R: matas de hojas finas y pajizas) y `pch_quenua_a.glb`, `pch_quenua_b.glb` (R: varios troncos retorcidos de corteza rojiza y follaje menudo), repartidos por `vegetation.gd`. Las terrazas quedan sin vegetación por ahora
- Fuentes (identificadas; pendiente de publicación): *Stipa ichu* (ichu) y *Polylepis* (queñua) en la flora altoandina; falta la referencia botánica concreta.
- Discrepancias entre fuentes: —
- Notas de representación: solo especies presentes antes de 1532. Prohibidos el eucalipto y cualquier especie introducida.
- Estado de verificación: pendiente

### PCH-014 — Llama / alpaca (opcional)
- Tipo: fauna
- Clasificación: A
- Uso en el juego: opcional; no incluida en el bloqueo actual
- Fuentes (identificadas; pendiente de publicación): estudios de camélidos sudamericanos domésticos; falta referencia concreta.
- Discrepancias entre fuentes: —
- Notas de representación: si se incluye, sin aparejos de origen europeo.
- Estado de verificación: pendiente

### PCH-015 — Evento: la noticia chanca
- Tipo: evento
- Clasificación: H (tradición) / N (puesta en escena)
- Uso en el juego: `messenger_event.gd` y textos `PCH_NARR_*`
- Fuentes (identificadas; pendiente de comprobación con la edición a la vista):
  - Sarmiento de Gamboa, *Historia de los Incas*, caps. 26–28 (trad. Bauer y Smith, 2007): el rango de páginas procede del índice de la editorial, no de la lectura.
  - Betanzos, *Suma y narración de los Incas*, I parte: **capítulo por confirmar**. La referencia al capítulo 13 proviene de una cita de terceros y no se ha comprobado; otras lecturas sitúan la guerra chanca en los capítulos 6–10.
  - J. J. Huertas Vallejos, «Los Chancas: proceso disturbativo en los Andes», *Historia y Cultura* 20.
- Discrepancias entre fuentes: Garcilaso atribuye la victoria a Inca Viracocha; la huida del inca y su heredero aparece con matices distintos en Betanzos y Sarmiento.
- Notas de representación: el guion sigue la versión de Betanzos y Sarmiento y la presenta como lo que dice el mensajero, no como verdad única. No se escenifica la batalla: el juego termina cuando la llacta responde. La llegada a la plaza, la reunión y la partida son puesta en escena (N).
- Estado de verificación: **pendiente** — requiere edición en papel. La ficha se apoya por ahora en el texto leído de Sarmiento, no en la paginación.

### PCH-016 — Plaza y caminos
- Tipo: lugar
- Clasificación: A / R
- Uso en el juego: `Llacta/Plaza`, `Llacta/PathSouth`, `Llacta/PathEast`, `Llacta/PathWest`
- Fuentes (identificadas; pendiente de página): Morris y Thompson, *Huánuco Pampa* (1985), sobre la plaza y el ushnu; John Hyslop, *The Inka Road System* (Academic Press, 1984).
- Discrepancias entre fuentes: —
- Notas de representación: la plaza de tierra apisonada y los caminos de tierra son reconstrucción (R). No se incluye ushnu: no está documentado para una llacta de este tamaño.
- Estado de verificación: pendiente

### PCH-017 — Curaca y hombres principales
- Tipo: personaje / organización social
- Clasificación: H / R
- Uso en el juego: `Llacta/NPCs/Curaca`, `Llacta/NPCs/Principal1`, `Llacta/NPCs/Principal2`; modelos `pch_npc_curaca.glb`, `pch_npc_principal.glb` y `pch_npc_authority.glb` (R: unku con franja ajedrezada, manto teñido y cinta en la cabeza como distintivos discretos; sin vara ni orejeras, que serían coloniales o imperiales)
- Fuentes (identificadas; pendiente de capítulo y página): María Rostworowski, *Curacas y sucesiones: costa norte* (1961) y *Señoríos indígenas de Lima y Canta* (1978); Sarmiento de Gamboa, *Historia de los Incas*, cap. 27 (Inca Yupanqui convoca a los curacas).
- Discrepancias entre fuentes: —
- Notas de representación: el curaca y los hombres principales **parten hacia el Cusco para sumarse a la defensa**; el guion debe impedir la lectura de huida. Distintivos de autoridad discretos (R).
- Estado de verificación: pendiente

### PCH-018 — Vestimenta y apariencia del habitante común
- Tipo: vestimenta
- Clasificación: R (a partir de A)
- Uso en el juego: tejedora, agricultor, mensajero y habitantes; modelos `pch_npc_weaver.glb` y `pch_npc_villager.glb` (R: anacu con faja, lliclla con franjas sujeta con tupu, trenzas), `pch_npc_farmer.glb` (R: unku, manto, paño en la cabeza, chuspa y chaquitaclla) y `pch_npc_commoner.glb` (R: unku, manto y chuspa). Ojotas en todos
- Fuentes (identificadas; pendiente de ficha y página): piezas textiles arqueológicas en colecciones públicas; Guamán Poma de Ayala, *Nueva corónica* (c. 1615), dibujos de habitantes (posteriores a la conquista: se usan solo como indicio, no como modelo directo).
- Discrepancias entre fuentes: —
- Notas de representación: sin retratos “auténticos”; variantes de color y de tocado para distinguir oficios; sin prendas ni elementos coloniales. La apariencia es interpretación declarada.
- Estado de verificación: pendiente
