# Guion de escenas — Campaña 01: El despertar del Sol

- **Versión:** 2.0 — 2026-11-18
- **Estado:** arco jugable con blockout y materiales propios; acto I con flujo de pasos visible y entrenamiento de honda.
- **Marco:** [guion de campaña](guion_campana.md), [biblia de campaña](biblia_campana.md), [plantilla](../../../docs/10_plantilla_guion_de_escena.md).
- **Uso:** este documento manda sobre la puesta en escena. Las claves de texto viven en `localization/pachacutec_texts.csv`; las banderas, en `CampaignState`.

## 0. Cómo leer

Cada ficha declara lugar, momento, duración, estado, objetivos, personajes presentes, bloqueo, cámara, textos, decisiones, banderas, consecuencias, aceptación y ficha histórica.

- **Implementado:** la escena existe y cumple su aceptación.
- **Implementado con deuda:** cumple el beat principal, pero tiene una deuda declarada.
- **Parcial:** falta un beat o una consecuencia.
- **Pendiente:** no existe o no se puede jugar.
- **Cumplimiento:** `Sí`, `Sí, con deuda de sistema` o `No`.

La aceptación es el contrato de la escena: si una prueba o una captura no puede verificarla, la escena no está cerrada.

## 1. Mapa de escenas

| ID | Escena | Acto | Duración | Estado | Cumplimiento |
|---|---|---|---|---|---|
| I.1 | La mañana | I | 3 min | Implementado | Sí |
| I.2 | Los cuatro encargos | I | 4 min | Implementado | Sí |
| I.3 | La duda | I | 1 min | Implementado | Sí |
| I.4 | El mensajero | I | 1 min | Implementado | Sí |
| I.5 | La asamblea | I | 1 min | Implementado | Sí |
| II.1 | La marcha | II | 1,5 min | Implementado | Sí |
| II.2 | El campamento | II | 2,5 min | Implementado | Sí |
| II.3 | La emboscada | II | 3 min | Implementado | Sí |
| II.4 | La llegada | II | 1,5 min | Implementado | Sí |
| II.5 | La ciudad dividida | II | 2,5 min | Implementado | Sí |
| II.6 | La víspera | II | 1,5 min | Implementado | Sí |
| III.1 | La entrada | III | 4 min | Implementado | Sí |
| III.2 | La trampa | III | 2 min | Implementado | Sí |
| III.3 | El costo | III | 2 min | Implementado | Sí |
| III.4 | La contraofensiva | III | 1 min | Implementado | Sí |
| IV.1 | El regreso | IV | 2 min | Implementado | Sí |
| IV.2 | Las cuentas | IV | 3 min | Implementado | Sí |
| IV.3 | La asamblea | IV | 3 min | Implementado | Sí |
| IV.4 | La noticia | IV | 1 min | Implementado | Sí |
| V.1 | La obra | V | 3,5 min | Implementado | Sí |
| V.2 | El nombre | V | 1 min | Implementado | Sí |
| V.3 | El cierre | V | 1,5 min | Implementado | Sí |

**Resultado:** 22/22 escenas implementadas y **22/22 sin deuda de escena**. El combate y el HUD se cerraron en 4.7. **0 parciales.**

**Total objetivo:** 43–50 min. **Medido:** pendiente de partida humana. La suma de las 22 fichas da 46,5 min y la pasada guionizada dura 1:58; ninguna de las dos sustituye a una partida real. El protocolo y el resumen automático están listos en [docs/06 §4](../../../docs/06_estrategia_de_pruebas.md): `godot --path . -- --session PCH-DUR-1` y `python3 tools/session_duration.py PCH-DUR-1`.

---

# Acto I — La casa que se vacía

## I.1 · La mañana

**Lugar y momento:** llacta del valle; casa de Rumi al este de la plaza, plaza y caminos · amanecer.  
**Duración:** 3 min · **Estado:** Implementado.  
**Objetivo narrativo:** presentar el mundo, la familia y la amenaza.  
**Objetivo del jugador:** hablar con su madre y practicar la honda en la plaza.

**Presentes y bloqueo:**
- Rumi, en el punto de aparición.
- Madre y hermano, junto al umbral de House04, al este.
- Sisa, en el borde de la plaza.
- Curaca, Puma y su hijo, junto al fuego y la plaza.
- Tejedora y agricultor, en sus puestos de trabajo.

**Cámara y sonido:**
- Tarjetas de apertura: subtítulo, época, mundo, nota histórica y control.
- Subtítulo `PCH_NARR_OPENING` al terminar.
- Viento de altura y pasos de tierra.

**Textos:**
- `PCH_CAMPAIGN_SUBTITLE`, `PCH_INTRO_1`, `PCH_INTRO_2`, `PCH_INTRO_3`, `PCH_INTRO_NOTE`, `PCH_INTRO_HINT`.
- `PCH_NARR_OPENING`.
- `PCH_TALK_MADRE`: pide ayuda con el maíz, retiene al hermano y manda practicar la honda.
- `PCH_TALK_HERMANO`: quiere ir al Cusco.
- `PCH_TALK_SISA`: conoce el paso.
- `PCH_TALK_PUMA`, `PCH_TALK_HIJO_PUMA`, `PCH_TALK_CURACA`.
- `PCH_OBJ_MORNING`, `PCH_OBJ_TRAIN`, `PCH_TRAIN_AIM`, `PCH_TRAIN_HIT`, `PCH_TRAIN_MISS`, `PCH_TRAIN_FAR`.
- `PCH_NOTICE_TRAINING`; marcadores `PCH_MARK_MOTHER` y `PCH_MARK_TRAINING`.

**Decisiones:** ninguna; la primera tarea fija el oficio en I.2.

**Banderas:**
- Fija: `intro_vista`.
- Lee: ninguna.

**Consecuencias:**
- Diario con el encargo `encargos`.
- Objetivo visible «La mañana: habla con tu madre» y marcador sobre la madre.
- Al hablar con ella, el objetivo pasa a «Practica la honda (0/3)» y el blanco de paja aparece en la plaza.
- Tres aciertos de honda cierran la mañana y abren los encargos.

**Aceptación:**
- [ ] La introducción se muestra una vez por campaña y se pasa con E.
- [ ] El primer objetivo nombra a la madre y su marcador se ve en el mundo.
- [ ] La madre pide ayuda, menciona al hermano y manda practicar la honda.
- [ ] El blanco de honda aparece en la plaza y pide tres aciertos con la vista y el clic.
- [ ] La lista de los cuatro encargos no aparece hasta I.2.
- [ ] Sisa dice que conoce el paso.
- [ ] La casa de Rumi está al este de la plaza.
- [ ] No hay combate ni HUD de combate.

**Capturas:** [la mañana](img/acto_i/acto_i_01_manana.png) · [la honda](img/acto_i/acto_i_02_honda.png).

**Ficha histórica:** PCH-007, PCH-016, PCH-038 · R / N.  
**Deuda:** ninguna de escena.

## I.2 · Los cuatro encargos

**Lugar y momento:** plaza, manantial, terrazas, telar y corral · mañana.  
**Duración:** 4 min · **Estado:** Implementado.  
**Objetivo narrativo:** que los recursos sean reales y el oficio importe.  
**Objetivo del jugador:** completar tres de los cuatro encargos.

**Presentes y bloqueo:**
- Tejedora en el telar.
- Agricultor en la terraza.
- Curaca cerca de la plaza.
- Cuatro puntos de tarea: agua en el manantial del este, maíz al oeste, telar junto a la tejedora, pirca al noroeste.
- El camino de tierra con borde de piedra lleva a cada punto; el borde de pirca de la plaza deja cuatro entradas.

**Cámara y sonido:**
- Sin diálogo de cámara; el jugador se acerca y usa E.
- El HUD muestra «Completa 3 de los 4 encargos (n/3)» y la lista `Encargos (n/3)`.
- Sonido de pasos y ambiente.

**Textos:**
- `PCH_TASK_AGUA`, `PCH_TASK_MAIZ`, `PCH_TASK_TELAR`, `PCH_TASK_PIRCA`.
- `PCH_TASK_*_DONE`, `PCH_TASK_DONE`.
- `PCH_Q_AGUA_*`, `PCH_Q_MAIZ_*`, `PCH_Q_TELAR_*`, `PCH_Q_PIRCA_*`.
- `PCH_OFICIO_AGUA/MAIZ/TELAR/PIRCA`, `PCH_OFICIO_NONE`.
- `PCH_OBJ_ENCARGOS`, `PCH_TASKS_TITLE`, `PCH_HINT_JOURNAL`, `PCH_NOTICE_TASKS`.
- Marcadores de los cuatro puntos con su `PCH_TASK_*`.

**Decisiones:**
- Qué tres tareas completar; el orden es libre.
- La primera tarea completada fija el oficio.

**Banderas:**
- Fija: `oficio` (agua/maiz/telar/pirca), objetos `agua`, `maiz`, `manta`, `cuerda`.
- Lee: ninguna.

**Consecuencias:**
- Al tercer encargo se completa `encargos` y se abre la duda; el mensajero llega después de la duda.
- El cuarto encargo puede hacerse durante la duda o dejarse; no devuelve el flujo al paso anterior.
- El recurso que falte no aparece en el campamento.
- El oficio abre la preparación del Cusco y marca una obra en V.1.

**Aceptación:**
- [ ] Hay cuatro puntos y se puede completar cualquiera.
- [ ] La primera tarea fija el oficio y da +1 rango en su habilidad.
- [ ] Cada tarea entrega su objeto real.
- [ ] El agua se recoge en el manantial y la acequia se ve junto a la pileta.
- [ ] Los caminos a los cuatro encargos se leen sin abrir el diario.
- [ ] El HUD muestra los cuatro encargos, cuántos importan y el contador.
- [ ] Al tercer encargo se completa `encargos` y el flujo pasa a la duda.
- [ ] El cuarto encargo puede hacerse después o dejarse sin rebobinar.

**Capturas:** [los encargos](img/acto_i/acto_i_03_encargos.png) · [un encargo hecho](img/acto_i/acto_i_04_encargo_hecho.png).

**Ficha histórica:** PCH-004, 005, 010, 019, 021, 038 · H / A / R.  
**Deuda:** ninguna funcional.

## I.3 · La duda

**Lugar y momento:** plaza, junto al fuego · mañana, tras los encargos.  
**Duración:** 1 min · **Estado:** Implementado.  
**Objetivo narrativo:** presentar las divisiones políticas antes de la noticia.  
**Objetivo del jugador:** escuchar y tomar partido.

**Presentes y bloqueo:**
- Puma y Asto, frente a frente.
- Rumi, en el punto de interacción.
- El fuego queda junto al punto de interacción.

**Cámara y sonido:**
- La cámara enfoca a Puma, primer parlamento.
- Fuego y viento; sin música.

**Textos:**
- `PCH_TALK_DUDA`, `PCH_DUDA_INTRO`.
- `PCH_DUDA_PUMA`, `PCH_DUDA_CURACA`, `PCH_DUDA_SILENCE`.
- `PCH_DUDA_*_ANSWER`.
- `PCH_OBJ_DUDA`, `PCH_NOTICE_MESSENGER`; marcador `PCH_MARK_DOUBT`.

**Decisiones:**
- Apoyar a Puma, apoyar al curaca o callar.

**Banderas:**
- Fija: `apoyo_puma`, `apoyo_curaca` o `apoyo_silencio`.
- Lee: ninguna.

**Consecuencias:**
- Reputación de llacta y Cusco.
- Opción de reconciliación y variante de silencio en IV.3.
- Al terminar, el mensajero llega a la plaza.

**Aceptación:**
- [ ] Hay tres opciones y cada una fija su bandera.
- [ ] La conversación se abre una sola vez.
- [ ] La cámara mira a Puma, que es el primer parlamento.
- [ ] La duda es obligatoria y abre el paso al mensajero.
- [ ] Apoyar a Puma baja la reputación ante el Cusco y puede costar un aliado en III.

**Ficha histórica:** PCH-001, PCH-015 · H (tradición) / N.  
**Deuda:** ninguna de escena.

## I.4 · El mensajero

**Lugar y momento:** plaza, junto al fuego · mañana, tras la duda.  
**Duración:** 1 min · **Estado:** Implementado.  
**Objetivo narrativo:** convertir la noticia en una decisión.  
**Objetivo del jugador:** escuchar y dar agua o maíz, o no dar nada.

**Presentes y bloqueo:**
- Mensajero en el borde de la plaza, mirando al jugador.
- Curaca cerca.
- Rumi, en el punto de conversación.

**Cámara y sonido:**
- La cámara enfoca al mensajero.
- Viento; sin música.

**Textos:**
- `PCH_TALK_MESSENGER`, `PCH_MSG_INTRO`.
- `PCH_MSG_WATER`, `PCH_MSG_MAIZE`, `PCH_MSG_LISTEN`.
- `PCH_MSG_*_ANSWER`, `PCH_MSG_AGAIN`.
- `PCH_OBJ_MESSENGER`, `PCH_OBJ_ASAMBLEA`, `PCH_NOTICE_ASSEMBLY`.
- Marcador `PCH_MARK_MESSENGER`.

**Decisiones:**
- Dar agua, dar maíz o escuchar sin dar nada.
- Las opciones de dar están condicionadas por el objeto.

**Banderas:**
- Fija: `noticia_chanca`; `mensajero_ayudado` si da agua o maíz.
- Lee: `agua`, `maiz`.

**Consecuencias:**
- El objeto se consume.
- Reputación de llacta +1 si ayuda.
- `mensajero_ayudado` abre el aviso del arroyo en II.3.
- Objetivo de asamblea.

**Aceptación:**
- [ ] El mensajero aparece al terminar la duda y no antes.
- [ ] Su marcador se ve sobre el punto de conversación.
- [ ] Las opciones de dar solo se muestran si hay objeto.
- [ ] Dar consume el objeto.
- [ ] La conversación no se repite.
- [ ] La cámara enfoca al mensajero.

**Ficha histórica:** PCH-011, PCH-015 · H (tradición) / N.  
**Deuda:** ninguna funcional.

## I.5 · La asamblea

**Lugar y momento:** plaza · mediodía.  
**Duración:** 1 min · **Estado:** Implementado.  
**Objetivo narrativo:** que Rumi se ofrezca y la llacta responda.  
**Objetivo del jugador:** elegir cómo responder al curaca.

**Presentes y bloqueo:**
- Curaca en el centro.
- Madre, hermano, Sisa, Puma y su hijo, en arco alrededor de la plaza.
- Rumi, en el punto de interacción.

**Cámara y sonido:**
- La cámara enfoca al curaca.
- Viento; sin música.

**Textos:**
- `PCH_ASM_ASK`, `PCH_ASM_GO`, `PCH_ASM_TOGETHER`, `PCH_ASM_DOUBT`.
- `PCH_ASM_*_ANSWER`.
- `PCH_NARR_CLOSING_1`, `PCH_NARR_CLOSING_2`.
- `PCH_END_TITLE`, `PCH_END_HINT`.

**Decisiones:**
- «Voy yo», «Iré con vosotros», «No sé si sirvo».

**Banderas:**
- Fija: `ofrecio`, `confianza_sisa` (2 / 1 / 0).
- Lee: `noticia_chanca`.

**Consecuencias:**
- La columna sale al amanecer: tres figuras en el camino del norte.
- Tarjeta de fin con las dos líneas de cierre.
- Paso al acto II.

**Aceptación:**
- [ ] La asamblea se abre al volver a la plaza tras la noticia.
- [ ] Hay tres opciones y cada una fija `confianza_sisa`.
- [ ] La familia y Puma están presentes y miran al centro.
- [ ] La columna aparece en el camino del norte.
- [ ] La tarjeta de fin muestra el cierre y E pasa al paso.

**Ficha histórica:** reconstrucción del ayllu y la reciprocidad · R.  
**Deuda:** ninguna funcional.

---

# Acto II — El paso y la ciudad dividida

## II.1 · La marcha

**Lugar y momento:** paso de montaña, inicio sur · tarde.  
**Duración:** 1,5 min · **Estado:** Implementado.  
**Objetivo narrativo:** presentar el camino y la relación con Sisa.  
**Objetivo del jugador:** escuchar a Sisa o seguir en silencio.

**Presentes y bloqueo:**
- Sisa, a un lado del camino.
- Curaca, agricultor y mensajero en el campamento, más adelante.
- Rumi, en el punto de conversación.

**Cámara y sonido:**
- La cámara enfoca a Sisa.
- Viento de paso; sin música.

**Textos:**
- `PCH_PASO_TALK_SISA`, `PCH_PASO_MARCH_INTRO`.
- `PCH_PASO_MARCH_LISTEN`, `PCH_PASO_MARCH_SILENT`.
- `PCH_PASO_MARCH_*_ANSWER`.

**Decisiones:**
- Escuchar su consejo o seguir en silencio.

**Banderas:**
- Fija: `marcha_sisa` (+1 confianza, +Monte). El silencio no fija bandera: es una no-acción.
- Lee: `confianza_sisa`.

**Consecuencias:**
- Confianza para reclutar a los jóvenes en II.5.

**Aceptación:**
- [ ] Hay dos opciones y cada una deja su bandera.
- [ ] Escuchar sube `confianza_sisa` y Monte.
- [ ] La conversación se abre una sola vez.

**Ficha histórica:** PCH-026 · R.  
**Deuda:** ninguna de escena.

## II.2 · El campamento

**Lugar y momento:** paso, campamento junto al fuego · noche.  
**Duración:** 2,5 min · **Estado:** Implementado.  
**Objetivo narrativo:** que los recursos del acto I importen.  
**Objetivo del jugador:** descansar, beber, comer, cubrirse, compartir coca o seguir de noche.

**Presentes y bloqueo:**
- Curaca, agricultor y mensajero alrededor del fuego.
- Rumi, en el punto de conversación.

**Cámara y sonido:**
- La cámara enfoca al curaca.
- Fuego, viento y silencio de la columna.

**Textos:**
- `PCH_CAMP_TALK`, `PCH_CAMP_INTRO`, `PCH_CAMP_MORE`, `PCH_CAMP_MORE_TEXT`.
- `PCH_PASO_WATER`, `PCH_PASO_MAIZE`, `PCH_PASO_MANTA`.
- `PCH_CAMP_REST`, `PCH_CAMP_PUSH`, `PCH_CAMP_COCA`.
- `PCH_PASO_*_DONE`, `PCH_CAMP_*_DONE`, `PCH_DLG_LEAVE`.

**Decisiones:**
- Beber agua, comer maíz, usar la manta, descansar, compartir coca o seguir de noche.
- Las opciones de recurso están condicionadas por el inventario.

**Banderas:**
- Fija: `agua_bebida`, `maiz_comido`, `manta_usada`, `descanso`, `marcha_nocturna`, `coca_compartida`.
- Lee: `agua`, `maiz`, `manta`, `coca`.

**Consecuencias:**
- Agua: salud y aliento.
- Maíz: ánimo.
- Manta: ánimo.
- Descanso: salud.
- Coca: confianza de Sisa.
- Marcha nocturna: ánimo −5.
- Punto de control al abrir el campamento.

**Aceptación:**
- [ ] Las seis opciones y la salida caben en dos páginas; «Más opciones» no oculta coca ni salida.
- [ ] Beber y comer consumen el objeto.
- [ ] Compartir coca consume coca y sube la confianza.
- [ ] «Otro día será» cierra el diálogo.
- [ ] El descanso cura y no consume recurso.

**Ficha histórica:** PCH-028 · R.  
**Deuda:** ninguna de escena.

## II.3 · La emboscada

**Lugar y momento:** paso, corredor y arroyo · tarde.  
**Duración:** 3 min · **Estado:** Implementado.  
**Objetivo narrativo:** primer combate y primera información del enemigo.  
**Objetivo del jugador:** combatir, cruzar en sigilo o distraer; después decidir sobre Anca, el maíz y el explorador.

**Presentes y bloqueo:**
- Cuatro exploradores chancas en el corredor.
- Punto de sigilo en la orilla del arroyo.
- Punto de distracción al este.
- Curaca en la resolución.

**Cámara y sonido:**
- Sin diálogo hasta la resolución; tambor de combate.
- La cámara enfoca al curaca en las decisiones posteriores.

**Textos:**
- `PCH_PASO_TALK_SNEAK`, `PCH_PASO_TALK_DISTRACT`.
- `PCH_PASO_WARNED`, `PCH_PASO_SNEAK`, `PCH_PASO_SNEAK_FAIL`, `PCH_PASO_SNEAK_INFO`.
- `PCH_PASO_DISTRACT`, `PCH_PASO_DISTRACT_CUERDA`.
- `PCH_PASO_AMBUSH`, `PCH_PASO_CLEAR`, `PCH_PASO_SILENT_END`.
- `PCH_AFTER_INTRO`, `PCH_AFTER_CARRY`, `PCH_AFTER_LEAVE`, `PCH_AFTER_*_COST`.
- `PCH_AFTER_MAIZE`, `PCH_AFTER_KEEP`, `PCH_AFTER_ABANDON`, `PCH_AFTER_MAIZE_*`.
- `PCH_AFTER_SCOUT`, `PCH_AFTER_SPARE`, `PCH_AFTER_LEAVE_SCOUT`, `PCH_AFTER_SPARED`.

**Decisiones:**
- Combatir, sigilo o distracción.
- Cargar o dejar a Anca.
- Conservar o abandonar el maíz.
- Perdonar o ignorar al explorador.

**Banderas:**
- Fija: `paso_cruzado`, `mensaje_chanca`, `herido_salvado`/`herido_dejado`, `carga_anca`, `maiz_guardado`/`maiz_abandonado`, `scout_spared`.
- Lee: `monte`, `mensajero_ayudado`, `agua`, `coca`, `cuerda`.

**Consecuencias:**
- Cargar a Anca: aliento máximo 75 durante todo el acto II.
- Dejar a Anca: consume agua y coca, baja reputación y ánimo.
- Conservar el maíz: abre a los ayllus en II.5.
- Abandonarlo: aligera la marcha y cierra esa puerta.
- Perdonar al explorador: línea en III.4 y cuenta en IV.2.
- `mensaje_chanca` abre al curaca vecino en II.5.

**Aceptación:**
- [ ] Hay cuatro exploradores y tres vías de resolución.
- [ ] El sigilo exige Monte ≥ 2 o el aviso del mensajero.
- [ ] La distracción consume la cuerda si está.
- [ ] Dejar a Anca exige y consume agua y coca.
- [ ] Cargar a Anca reduce el aliento máximo y se mantiene al reaparecer.
- [ ] Cruzar el paso activa la emboscada aunque se rodee el disparador.
- [ ] Las decisiones de Anca, maíz y explorador se encadenan.

**Ficha histórica:** PCH-024, 030, 036 · R / N.  
**Deuda:** ninguna de escena. El combate con porra y escudo es deuda de sistema (III.1).

## II.4 · La llegada

**Lugar y momento:** Cusco, entrada de la plaza · noche.  
**Duración:** 1,5 min · **Estado:** Implementado.  
**Objetivo narrativo:** entregar el mensaje y ver a Cusi.  
**Objetivo del jugador:** hablar con Cusi en la entrada.

**Presentes y bloqueo:**
- Cusi en la puerta de la plaza, luego en el santuario.
- Multitud de refugiados.
- Rumi, en el punto de llegada.

**Cámara y sonido:**
- La cámara enfoca a Cusi.
- Murmullo de plaza y viento.

**Textos:**
- `PCH_CIUDAD_ARRIVAL`, `PCH_CIUDAD_TALK_MESSAGE`, `PCH_CIUDAD_MESSAGE_INTRO`.
- `PCH_CIUDAD_MESSAGE_DELIVER`, `PCH_CIUDAD_MESSAGE_ANSWER`, `PCH_CIUDAD_MESSAGE_AGAIN`.
- `PCH_OBJ_RECRUIT`.

**Decisiones:**
- Entregar el mensaje o dejarlo para después.

**Banderas:**
- Fija: `mensaje_entregado`; reputación de Cusco +1.
- Lee: `noticia_chanca`.

**Consecuencias:**
- Cusi se traslada al santuario.
- Se abre el reclutamiento.
- La preparación exige el mensaje entregado.

**Aceptación:**
- [ ] Cusi recibe en la puerta y se traslada al santuario al terminar.
- [ ] Entregar sube la reputación del Cusco.
- [ ] El objetivo cambia a reclutar.
- [ ] No se puede preparar antes de entregar.

**Ficha histórica:** PCH-022, 027 · R.  
**Deuda:** ninguna funcional.

## II.5 · La ciudad dividida

**Lugar y momento:** Cusco, plaza · noche.  
**Duración:** 2,5 min · **Estado:** Implementado.  
**Objetivo narrativo:** reclutar y preparar la defensa.  
**Objetivo del jugador:** reunir aliados y hacer su preparación.

**Presentes y bloqueo:**
- Ayllus, curaca vecino y jóvenes en tres puntos de reclutamiento.
- Cusi en el santuario.
- Cuatro puestos de preparación con su prop visible.

**Cámara y sonido:**
- La cámara enfoca a cada grupo al hablar.
- Murmullo de plaza; sin música.

**Textos:**
- `PCH_CIUDAD_TALK_AYLLUS/CURACA/YOUTH`, `PCH_CIUDAD_*_INTRO`.
- `PCH_CIUDAD_RECRUIT_ASK/JOIN/REFUSE`, `PCH_CIUDAD_ALREADY`.
- `PCH_PREP_MURO/MAIZ/AGUA/HONDAS`, `PCH_PREP_DONE`, `PCH_PREP_NO_OFICIO`, `PCH_PREP_ALREADY`, `PCH_PREP_FIRST`.
- `PCH_OBJ_DEFENSE`.

**Decisiones:**
- Reclutar a los tres grupos o prescindir de alguno.
- Elegir la preparación que corresponde al oficio.

**Banderas:**
- Fija: `aliado_0`, `aliado_1`, `aliado_2`, `preparacion_hecha`, `preparacion_<oficio>`.
- Lee: `maiz_guardado`, reputación de Cusco, `mensaje_chanca`, Palabra, `confianza_sisa`, `oficio`, `mensaje_entregado`.

**Consecuencias:**
- Aliados 0–3.
- Menos enemigos por oleada.
- El oficio abre su preparación.
- El número de aliados pesa en III.1, III.3 y IV.3.

**Aceptación:**
- [ ] Ayllus: maíz guardado o reputación Cusco ≥ 1.
- [ ] Curaca: información del paso o Palabra ≥ 2, con reputación ≥ 1.
- [ ] Jóvenes: confianza de Sisa ≥ 1.
- [ ] Hay cuatro puestos de preparación y solo el oficio elegido responde.
- [ ] La preparación se puede hacer una vez.
- [ ] Cusi solo inicia la defensa después de la trampa.

**Ficha histórica:** PCH-017 · R.  
**Deuda:** ninguna funcional.

## II.6 · La víspera

**Lugar y momento:** Cusco, plaza, junto al muro · noche.  
**Duración:** 1,5 min · **Estado:** Implementado.  
**Objetivo narrativo:** el miedo y la Memoria.  
**Objetivo del jugador:** escuchar la leyenda, dejar una ofrenda o dormir.

**Presentes y bloqueo:**
- Viejo de la plaza junto al muro.
- Rumi, en el punto de conversación.

**Cámara y sonido:**
- La cámara enfoca al viejo.
- Murmullo lejano; sin música.

**Textos:**
- `PCH_CIUDAD_TALK_VESPERA`, `PCH_NPC_ELDER`, `PCH_VESPERA_INTRO`.
- `PCH_VESPERA_LISTEN`, `PCH_VESPERA_TALE`, `PCH_VESPERA_CLOSE`, `PCH_VESPERA_AGAIN`.
- `PCH_VESPERA_OFFER`, `PCH_VESPERA_OFFER_DONE`, `PCH_VESPERA_SLEEP`, `PCH_VESPERA_SLEEP_DONE`.
- `PCH_ST_PURURAUCAS_*`.

**Decisiones:**
- Escuchar, ofrendar coca, dormir o irse.

**Banderas:**
- Fija: `mem_pururaucas`, `ofrenda_hecha`, `descanso_cusco`.
- Lee: `coca`.

**Consecuencias:**
- Memoria de los pururaucas con sello N.
- Ofrenda: ánimo +10 y consume coca.
- Dormir: salud +15 y aliento +20.

**Aceptación:**
- [ ] La leyenda se cuenta como creencia, no como hecho.
- [ ] La ofrenda consume coca.
- [ ] Dormir restaura salud y aliento.
- [ ] La Memoria queda en el diario con fuente.

**Ficha histórica:** PCH-031, 012 · H (tradición) / N.  
**Deuda:** ninguna funcional.

---

# Acto III — La guerra de los chancas

## III.1 · La entrada

**Lugar y momento:** Cusco, plaza · día siguiente.  
**Duración:** 4 min · **Estado:** Implementado.  
**Objetivo narrativo:** sostener la plaza.  
**Objetivo del jugador:** sobrevivir a tres oleadas.

**Presentes y bloqueo:**
- Cusi en el santuario.
- Aliados en la plaza.
- Chancas entrando por el sur.
- Multitud retirándose a las casas.

**Cámara y sonido:**
- Tambor de batalla; sin diálogo durante las oleadas.
- **HUD:** viñeta de salud, respiración y munición en la mano; sin barra fija de estado.

**Textos:**
- `PCH_CIUDAD_DEFENSE`, `PCH_CIUDAD_WAVE`, `PCH_CIUDAD_STATUS`.
- `PCH_OBJ_HOLD`, `PCH_Q_DEFENSA_TITLE/BODY`.

**Decisiones:**
- Cómo combatir; no hay elección narrativa hasta la trampa.

**Banderas:**
- Fija: `defensa_iniciada`.
- Lee: `aliado_0/1/2`, `preparacion_hecha`, `paso_cruzado`.

**Consecuencias:**
- Tres oleadas; el número de enemigos baja con aliados, preparación y paso.
- La multitud se retira.

**Aceptación:**
- [ ] Hay tres oleadas.
- [ ] El número de enemigos responde a aliados, preparación y `paso_cruzado`.
- [ ] Los aliados y Cusi están presentes.
- [ ] La multitud se retira al empezar.
- [ ] La defensa no empieza sin `trampa_resuelta`.

**Ficha histórica:** PCH-029 · H (tradición).  
**Deuda:** ninguna.

## III.2 · La trampa

**Lugar y momento:** Cusco, santuario · antes de la defensa.  
**Duración:** 2 min · **Estado:** Implementado.  
**Objetivo narrativo:** elegir entre proteger el recinto o llevar la orden.  
**Objetivo del jugador:** decidir antes de la defensa.

**Presentes y bloqueo:**
- Curaca vecino junto al santuario.
- Rumi, en el punto de conversación.

**Cámara y sonido:**
- La cámara enfoca al curaca vecino.
- Murmullo de plaza; sin música.

**Textos:**
- `PCH_CIUDAD_TRAP`, `PCH_CIUDAD_TRAP_INTRO`.
- `PCH_CIUDAD_TRAP_PROTECT`, `PCH_CIUDAD_TRAP_ORDER`.
- `PCH_CIUDAD_TRAP_*_ANSWER`, `PCH_CIUDAD_TRAP_AGAIN`.
- `PCH_CIUDAD_TRAP_FIRST`.

**Decisiones:**
- Proteger el santuario o llevar la orden a Cusi.

**Banderas:**
- Fija: `santuario_protegido` u `orden_llevada`; `trampa_resuelta`.
- Lee: ninguna.

**Consecuencias:**
- Variante del epílogo de III.4.
- Variante del cierre de V.3.
- Cusi no inicia la defensa sin la decisión.

**Aceptación:**
- [ ] Hay dos opciones excluyentes.
- [ ] Cada una fija su bandera y `trampa_resuelta`.
- [ ] La decisión se toma una vez.
- [ ] Cusi bloquea la defensa si falta.
- [ ] El epílogo recoge la variante.

**Ficha histórica:** PCH-027, 029 · R / H (tradición).  
**Deuda:** ninguna funcional.

## III.3 · El costo

**Lugar y momento:** Cusco, plaza · final de la defensa.  
**Duración:** 2 min · **Estado:** Implementado.  
**Objetivo narrativo:** que la victoria tenga un precio con nombre.  
**Objetivo del jugador:** seguir luchando hasta el final.

**Presentes y bloqueo:**
- Anca si fue cargado; el hijo de Puma si los jóvenes se unieron y hay menos de dos aliados.
- Cusi y los aliados.
- Rumi en la plaza.

**Cámara y sonido:**
- Sin diálogo; subtítulo de la caída y animación de muerte.
- Tambor de batalla.

**Textos:**
- `PCH_CIUDAD_COST_ANCA`, `PCH_CIUDAD_COST_JOVEN`, `PCH_CIUDAD_NO_COST`.
- `PCH_CIUDAD_EPILOGUE`, `PCH_CIUDAD_EPILOGUE_*`.

**Decisiones:**
- No hay elección directa; el coste depende de II.3 y II.5.

**Banderas:**
- Fija: `costo_anca`, `costo_joven` o `sin_costo`.
- Lee: `herido_salvado`, `aliado_2`, `aliados`.

**Consecuencias:**
- Anca cae si fue cargado.
- El hijo de Puma cae si los jóvenes se unieron y los aliados son menos de dos.
- Si no, nadie con nombre cae.
- Ánimo −15 si hay coste.
- Línea en IV.2, IV.3 y V.3.

**Aceptación:**
- [ ] Las tres ramas son alcanzables.
- [ ] El defensor con nombre cae visualmente.
- [ ] El nombre queda en el epílogo.
- [ ] La rama `sin_costo` no inventa una muerte.
- [ ] El coste se lee en IV.2.

**Ficha histórica:** PCH-029 · H (tradición) / N.  
**Deuda:** ninguna de escena.

## III.4 · La contraofensiva

**Lugar y momento:** Cusco, plaza · final de la batalla.  
**Duración:** 1 min · **Estado:** Implementado.  
**Objetivo narrativo:** la victoria no es del jugador.  
**Objetivo del jugador:** leer el cierre y volver a la llacta.

**Presentes y bloqueo:**
- Cusi y los aliados en la plaza.
- Rumi, en la plaza.

**Cámara y sonido:**
- Tarjeta de fin; sin diálogo.
- Tambor que se apaga.

**Textos:**
- `PCH_CIUDAD_COUNTER`, `PCH_CIUDAD_EPILOGUE`.
- `PCH_CIUDAD_EPILOGUE_SANCTUARY/ORDER/MAIZE/SPARED`.
- `PCH_CIUDAD_END_TITLE`, `PCH_CIUDAD_END_HINT`.

**Decisiones:** ninguna.

**Banderas:**
- Fija: ninguna nueva.
- Lee: `santuario_protegido`, `orden_llevada`, `maiz_guardado`, `scout_spared`, `costo_*`.

**Consecuencias:**
- Tarjeta con el epílogo completo.
- Paso al acto IV.

**Aceptación:**
- [ ] La tarjeta reúne las variantes de trampa, maíz, explorador y coste.
- [ ] E pasa a la llacta.
- [ ] La victoria no cambia el resultado histórico.

**Ficha histórica:** PCH-002 · H (tradición).  
**Deuda:** ninguna funcional.

---

# Acto IV — El precio de la victoria

## IV.1 · El regreso

**Lugar y momento:** llacta, plaza · posguerra, luz fría.  
**Duración:** 2 min · **Estado:** Implementado.  
**Objetivo narrativo:** volver y mirar.  
**Objetivo del jugador:** recorrer la llacta.

**Presentes y bloqueo:**
- Madre y hermano junto a la casa.
- Sisa, Puma, su hijo (si vive), tejedora y agricultor.
- Dos heridos junto a los muros caídos.
- Anca si fue dejado y sobrevivió.
- Rumi en la plaza.

**Cámara y sonido:**
- Subtítulo de regreso; sin diálogo.
- Viento; sin música.

**Textos:**
- `PCH_ACT4_RETURN`, `PCH_OBJ_ACCOUNTS`, `PCH_Q_CUENTAS_TITLE/BODY`.

**Decisiones:** ninguna.

**Banderas:**
- Fija: ninguna.
- Lee: `herido_dejado`, `costo_anca`, `costo_joven`.

**Consecuencias:**
- Fuego apagado, cuatro muros caídos, paño en la casa de Rumi.
- Cuentas abiertas.

**Aceptación:**
- [ ] La luz es fría y el fuego está apagado.
- [ ] Hay cuatro ruinas y dos heridos visibles.
- [ ] La casa de Rumi tiene el paño de ausencia.
- [ ] La familia está junto a la casa.

**Ficha histórica:** PCH-032 · R.  
**Deuda:** ninguna de escena.

## IV.2 · Las cuentas

**Lugar y momento:** llacta, tres casas: este, oeste y sur · posguerra.  
**Duración:** 3 min · **Estado:** Implementado.  
**Objetivo narrativo:** saber quién volvió.  
**Objetivo del jugador:** visitar tres casas.

**Presentes y bloqueo:**
- Casa del este: House05, paño de ausencia.
- Casa del oeste: House01, paño de ausencia.
- Casa del sur: House08, paño de ausencia.
- Anca, si fue dejado, cerca de la plaza.

**Cámara y sonido:**
- Sin cámara de diálogo; subtítulo al llamar.
- Viento; sin música.

**Textos:**
- `PCH_ACCOUNT_1`, `PCH_ACCOUNT_2`, `PCH_ACCOUNT_3`.
- `PCH_ACCOUNT_1_TEXT`, `PCH_ACCOUNT_2_TEXT`, `PCH_ACCOUNT_2_TEXT_SPARED`.
- `PCH_ACCOUNT_3_TEXT`, `PCH_ACCOUNT_3_TEXT_ANCA`, `PCH_ACCOUNT_3_TEXT_NO_COST`.
- `PCH_ACCOUNT_DONE`, `PCH_OBJ_ASSEMBLY`.

**Decisiones:** ninguna; el orden es libre.

**Banderas:**
- Fija: ninguna; completa el diario `cuentas`.
- Lee: `costo_anca`, `costo_joven`, `sin_costo`, `scout_spared`, `herido_dejado`.

**Consecuencias:**
- La casa del sur cambia según el coste.
- La casa del este cambia si perdonaste al explorador.
- Punto de control al completar las tres.
- Se abre la asamblea.

**Aceptación:**
- [ ] Hay tres casas reales y cada una tiene su paño.
- [ ] La cuenta del sur distingue Anca, el hijo de Puma y sin coste.
- [ ] La cuenta del este distingue al explorador perdonado.
- [ ] Anca aparece si fue dejado y sobrevivió.
- [ ] Al tercer punto se guarda el control y se abre la asamblea.

**Ficha histórica:** PCH-032 · R.  
**Deuda:** ninguna de escena. Anca testifica al abrir la asamblea de IV.3.

## IV.3 · La asamblea

**Lugar y momento:** llacta, plaza · posguerra.  
**Duración:** 3 min · **Estado:** Implementado.  
**Objetivo narrativo:** hablar o callar ante Puma y los ayllus.  
**Objetivo del jugador:** elegir cómo responder.

**Presentes y bloqueo:**
- Puma en el centro.
- Madre, hermano, Sisa, curaca, curaca vecino y ayllus alrededor.
- Anca, si fue dejado, se adelanta a testificar.
- Rumi, en el punto de interacción.

**Cámara y sonido:**
- La cámara enfoca a Anca si testifica; luego a Puma y a cada hablante.
- Viento; sin música.

**Textos:**
- `PCH_ASM4_ASK`, `PCH_ASM4_ASK_ANCA`, `PCH_ASM4_ASK_JOVEN`, `PCH_ASM4_ASK_MANY`.
- `PCH_ASM4_ANCA_TESTIMONY`.
- `PCH_ASM4_SPEAK`, `PCH_ASM4_RECONCILE`, `PCH_ASM4_PALABRA`, `PCH_ASM4_SILENCE`.
- `PCH_ASM4_MORE`, `PCH_ASM4_MORE_TEXT`, `PCH_ASM4_MAIZE`, `PCH_ASM4_CURACA`.
- `PCH_ASM4_VECINO`, `PCH_ASM4_VECINO_ANSWER`.
- `PCH_ASM4_*_ANSWER`, `PCH_ASM4_SPEAK_ANCA/JOVEN`.

**Decisiones:**
- Hablar por los que no volvieron.
- Reconocer lo que Puma perdió (si apoyaste a Puma o hubo coste).
- Hablar con Palabra ≥ 2.
- Callar.
- Segunda página: ofrecer el maíz, dejar mediar al curaca, escuchar al curaca vecino o callar.

**Banderas:**
- Fija: `hablo_en_asamblea`, `asamblea_silencio`, `puma_reconciliado`, `maiz_repartido`.
- Lee: `costo_anca`, `costo_joven`, `aliados`, `apoyo_puma`, `apoyo_curaca`, `apoyo_silencio`, `maiz_guardado`, Palabra.

**Consecuencias:**
- `puma_reconciliado` abre el final «llena».
- `asamblea_silencio` con coste abre el final «vacía».
- El número de aliados cambia la apertura.
- La variante de silencio cambia si ya callaste en I.3.
- `maiz_repartido` se lee en el cierre de V.3.

**Aceptación:**
- [ ] La apertura cambia con el coste y con los aliados.
- [ ] La reconciliación no ofrece una línea que contradiga la muerte del hijo.
- [ ] La segunda página tiene maíz, curaca, curaca vecino y silencio.
- [ ] El maíz guardado habilita su opción.
- [ ] La asamblea se abre al completar las cuentas.
- [ ] Puma, la familia y el curaca vecino están presentes.
- [ ] Anca testifica al abrir si fue dejado y sobrevivió.
- [ ] El curaca vecino interviene en el diálogo.

**Ficha histórica:** PCH-032 · R.  
**Deuda:** ninguna de escena.

## IV.4 · La noticia

**Lugar y momento:** llacta, plaza · posguerra.  
**Duración:** 1 min · **Estado:** Implementado.  
**Objetivo narrativo:** cerrar el orden antiguo.  
**Objetivo del jugador:** escuchar.

**Presentes y bloqueo:**
- Mensajero del Cusco en la plaza.
- Rumi y la familia alrededor.

**Cámara y sonido:**
- Sin diálogo; subtítulo y tarjeta.
- Viento; sin música.

**Textos:**
- `PCH_ASM4_NEWS`, `PCH_END4_TITLE`, `PCH_END4_HINT`.

**Decisiones:** ninguna.

**Banderas:**
- Fija: `viracocha_muerto`.
- Lee: ninguna.

**Consecuencias:**
- Paso al acto V.

**Aceptación:**
- [ ] El mensajero aparece en la plaza.
- [ ] La tarjeta dice que Viracocha murió fuera de escena.
- [ ] E pasa a la llacta en obra.

**Ficha histórica:** PCH-033 · H (tradición) / R.  
**Deuda:** ninguna de escena; la noticia va en la tarjeta, como fija el guion de campaña.

---

# Acto V — El nombre nuevo

## V.1 · La obra

**Lugar y momento:** llacta en obra · mañana.  
**Duración:** 3,5 min · **Estado:** Implementado.  
**Objetivo narrativo:** reconstruir con las manos.  
**Objetivo del jugador:** completar las cinco obras.

**Presentes y bloqueo:**
- Madre y hermano junto a la casa.
- Sisa, Puma y su hijo si vive.
- Anca si fue dejado.
- Rumi, en los cinco puntos de obra.

**Cámara y sonido:**
- Sin diálogo; subtítulo al completar cada obra.
- Viento y pasos; sin música.

**Textos:**
- `PCH_REBUILD_PIRCA`, `PCH_REBUILD_TERRAZA`, `PCH_REBUILD_ACEQUIA`, `PCH_REBUILD_TELAR`, `PCH_REBUILD_CASA`.
- `PCH_REBUILD_*_DONE`, `PCH_REBUILD_DONE`, `PCH_REBUILD_OWN`, `PCH_REBUILD_ALLIES`.
- `PCH_OBJ_REBUILD`.

**Decisiones:**
- Orden de las obras.
- La obra que coincide con el oficio deja marca propia.

**Banderas:**
- Fija: `casa_reconstruida`, `obra_oficio`.
- Lee: `oficio`, `herido_dejado`, `costo_anca`.

**Consecuencias:**
- Cada obra deja una pieza visible.
- La casa de Rumi pierde el paño y gana umbral y luz.
- Al completar cinco se cierra la campaña.

**Aceptación:**
- [ ] Hay cinco obras y se pueden hacer en cualquier orden.
- [ ] Cada obra deja una pieza visible.
- [ ] La obra del oficio deja `obra_oficio`.
- [ ] La casa se repara con umbral y luz.
- [ ] No hay combate.

**Ficha histórica:** PCH-035 · R.  
**Deuda:** ninguna de escena.

## V.2 · El nombre

**Lugar y momento:** llacta, puerta de la casa · mediodía.  
**Duración:** 1 min · **Estado:** Implementado.  
**Objetivo narrativo:** escuchar la noticia del nombre.  
**Objetivo del jugador:** terminar la obra y leer.

**Presentes y bloqueo:**
- Mensajero del Cusco junto al umbral.
- Familia alrededor.
- Rumi, en la puerta.

**Cámara y sonido:**
- La cámara mira la casa y la familia.
- Viento; sin música.

**Textos:**
- `PCH_END5_NAME`, `PCH_END5_NO_NEWS`, `PCH_END5_MESSENGER`.

**Decisiones:** ninguna.

**Banderas:**
- Fija: ninguna.
- Lee: `viracocha_muerto`.

**Consecuencias:**
- La tarjeta presenta el nombre como tradición.
- El mensajero aparece aunque la noticia vaya en la tarjeta.

**Aceptación:**
- [ ] El mensajero está en el umbral.
- [ ] El nombre se presenta como tradición, no como decreto.
- [ ] Si falta la noticia de Viracocha, la tarjeta lo declara.

**Ficha histórica:** PCH-034 · H (tradición) / N.  
**Deuda:** ninguna de escena; el nombre va en la tarjeta, como fija el guion de campaña.

## V.3 · El cierre

**Lugar y momento:** llacta, umbral de la casa · mediodía.  
**Duración:** 1,5 min · **Estado:** Implementado.  
**Objetivo narrativo:** despedir la campaña.  
**Objetivo del jugador:** leer el cierre.

**Presentes y bloqueo:**
- Madre, hermano, Sisa, Puma, el hijo si vive y Anca si fue dejado, en arco frente a la puerta.
- Mensajero a un lado.
- Rumi, frente a la casa.

**Cámara y sonido:**
- La cámara mira la casa y la familia.
- Viento; sin música.

**Textos:**
- `PCH_FINAL_LLENA`, `PCH_FINAL_EN_PIE`, `PCH_FINAL_VACIA`.
- `PCH_FINAL_CASA`, `PCH_FINAL_OFICIO`, `PCH_FINAL_SANTUARIO`, `PCH_FINAL_ORDEN`.
- `PCH_END5_FAMILY`, `PCH_END5_TITLE`, `PCH_END5_HINT`.

**Decisiones:** las de los actos anteriores.

**Banderas:**
- Fija: ninguna.
- Lee: `herido_dejado`, `puma_reconciliado`, `asamblea_silencio`, `costo_anca`, `costo_joven`, `viracocha_muerto`, `casa_reconstruida`, `obra_oficio`, `santuario_protegido`, `orden_llevada`.

**Consecuencias:**
- Final «llena», «en pie» o «vacía».
- La tarjeta añade casa, oficio, santuario/orden y familia.
- E vuelve al título.

**Aceptación:**
- [ ] «Llena» exige Anca dejado y Puma reconciliado.
- [ ] «Vacía» exige silencio y un coste con nombre.
- [ ] «En pie» cubre el resto.
- [ ] La tarjeta no desborda ni tapa el título o la pista.
- [ ] La familia está en el umbral.
- [ ] El final no cambia el resultado histórico.

**Ficha histórica:** PCH-034 · H (tradición) / N.  
**Deuda:** ninguna de escena; la familia se reúne y el cierre va en la tarjeta, como fija el guion de campaña.

---

## 7. Matriz de banderas

| Bandera | Se fija en | Se lee en | Efecto | Prueba |
|---|---|---|---|---|
| `intro_vista` | I.1 | I.1 | La intro se muestra una vez | `test_llacta_loads` |
| `oficio` | I.2 | II.5, V.1 | Prepara el Cusco y marca una obra | `test_campaign_progress`, `test_campaign_bible` |
| `agua`, `maiz`, `manta`, `cuerda` | I.2 | II.2, II.3 | Recursos del campamento y la emboscada | `test_campaign_progress`, `test_camp_dialogue` |
| `apoyo_puma`, `apoyo_curaca`, `apoyo_silencio` | I.3 | IV.3 | Reconciliación y variante de silencio | `test_post_acts` |
| `noticia_chanca` | I.4 | I.5 | Abre la asamblea | `test_assembly` |
| `mensajero_ayudado` | I.4 | II.3 | Aviso del arroyo | `test_paso_sneak` |
| `ofrecio` | I.5 | — (registro) | Registro de la asamblea; el paso no lo consulta | `test_assembly` |
| `confianza_sisa` | I.5, II.1, II.2 | II.5, V.3 | Jóvenes y variante de Sisa | `test_assembly`, `arc_playthrough` |
| `marcha_sisa` | II.1 | II.5 | Confianza de Sisa | `arc_playthrough` |
| `descanso`, `agua_bebida`, `maiz_comido`, `manta_usada`, `marcha_nocturna`, `coca_compartida` | II.2 | II.2 | Salud, aliento, ánimo y confianza | `test_camp_dialogue` |
| `mensaje_chanca` | II.3 | II.5 | Abre al curaca vecino | `test_paso_sneak` |
| `paso_cruzado` | II.3 | III.1 | Una oleada con un enemigo menos | `arc_playthrough` |
| `herido_salvado` / `herido_dejado` | II.3 | III.3, IV.2, V.3 | Coste de Anca y final | `test_act_three_cost`, `test_campaign_bible` |
| `carga_anca` | II.3 | II.3 | Aliento máximo 75 | `test_campaign_bible` |
| `maiz_guardado` / `maiz_abandonado` | II.3 | II.5, III.4, II.3 | Ayllus, epílogo y velocidad | `test_post_acts`, `test_campaign_bible` |
| `scout_spared` | II.3 | III.4, IV.2 | Epílogo y cuenta del este | `test_campaign_bible` |
| `mensaje_entregado` | II.4 | II.5 | Reputación y reclutamiento | `test_city_staging` |
| `aliado_0/1/2` | II.5 | III.1, III.3, IV.3 | Oleadas, coste y asamblea | `test_act_three_cost`, `test_post_acts` |
| `preparacion_hecha`, `preparacion_<oficio>` | II.5 | III.1 | Una oleada con un enemigo menos | `test_act_three_cost` |
| `mem_pururaucas`, `ofrenda_hecha`, `descanso_cusco` | II.6 | Diario, ánimo, salud | Memoria y descanso | `arc_playthrough` |
| `defensa_iniciada` | III.1 | — (registro) | Registro; el inicio usa `_defense_requested` | `test_act_three_cost` |
| `trampa_resuelta`, `santuario_protegido` / `orden_llevada` | III.2 | III.1, III.4, V.3 | Bloquea la defensa y cambia el cierre | `test_campaign_bible` |
| `costo_anca` / `costo_joven` / `sin_costo` | III.3 | IV.2, IV.3, V.3 | Cuentas, asamblea y final | `test_act_three_cost`, `test_campaign_bible` |
| `hablo_en_asamblea` / `asamblea_silencio` | IV.3 | IV.4, V.3 | Final y noticia | `test_post_acts` |
| `puma_reconciliado` | IV.3 | IV.3, V.3 | Final «llena» | `test_post_acts`, `test_campaign_bible` |
| `maiz_repartido` | IV.3 | V.3 | Línea del cierre: el maíz repartido mantuvo unida a la llacta | `test_campaign_bible` |
| `viracocha_muerto` | IV.4 | V.2, V.3 | Nombre y tarjeta final | `test_campaign_bible` |
| `casa_reconstruida` | V.1 | V.3 | Final y tarjeta | `test_post_acts` |
| `obra_oficio` | V.1 | V.3 | Marca del oficio en el cierre | `test_campaign_bible` |

## 8. Matriz de finales

| Final | Condición | Texto | Extras |
|---|---|---|---|
| La casa llena | `herido_dejado` y `puma_reconciliado` | `PCH_FINAL_LLENA` | Casa, oficio, santuario/orden, familia |
| La casa vacía | `asamblea_silencio` y (`costo_anca` o `costo_joven`) | `PCH_FINAL_VACIA` | Casa, oficio, santuario/orden, familia |
| La casa en pie | Cualquier otro caso | `PCH_FINAL_EN_PIE` | Casa, oficio, santuario/orden, familia |

Prioridad: primero «llena», después «vacía», después «en pie». La tarjeta añade el nombre (o su ausencia) y la línea de la familia.

## 9. Ritmo y duración

| Acto | Objetivo de la biblia | Suma de escenas | Medido |
|---|---|---|---|
| I | 8–9 min | 10 min | No verificado |
| II | 11–13 min | 12,5 min | No verificado |
| III | 9–10 min | 9 min | No verificado |
| IV | 9–11 min | 9 min | No verificado |
| V | 6–7 min | 6 min | No verificado |
| **Total** | **43–50 min** | **46,5 min** | **No verificado** |

La pasada guionizada de `build/partida_completa_actual.mp4` dura 1:58 y sirve para revisar el arco, no para acreditar duración.

## 10. Cobertura de pruebas

| Escena | Prueba principal |
|---|---|
| I.1 | `test_llacta_loads`, `test_campaign_bible::test_home_is_east_of_plaza` |
| I.2 | `test_act_one_tasks`, `test_campaign_progress` |
| I.3 | Cobertura indirecta en `arc_playthrough`; falta prueba específica |
| I.4 | `test_assembly` |
| I.5 | `test_assembly` |
| II.1 | `arc_playthrough`; falta prueba específica |
| II.2 | `test_camp_dialogue` |
| II.3 | `test_paso_sneak`, `test_campaign_bible::test_crossing_starts_ambush` |
| II.4 | `test_city_staging` |
| II.5 | `test_city_staging`, `arc_playthrough` |
| II.6 | `arc_playthrough`; falta prueba específica |
| III.1 | `test_act_three_cost`, `test_combat_loadout`, `test_hud_combat` |
| III.2 | `test_campaign_bible::test_trap_is_required_for_defense` |
| III.3 | `test_act_three_cost` |
| III.4 | `test_end_card_body` |
| IV.1 | `test_city_staging` |
| IV.2 | `test_city_staging`, `test_campaign_bible::test_south_account_follows_cost` |
| IV.3 | `test_post_acts`, `test_campaign_bible::test_anca_testifies_in_assembly`, `test_campaign_bible::test_vecino_intervenes_in_assembly` |
| IV.4 | `test_post_acts`, `test_end_card_body` |
| V.1 | `test_post_acts`, `test_campaign_bible::test_act_five_oficio_marks_work` |
| V.2 | `test_campaign_bible::test_final_card_reads_flags` |
| V.3 | `test_end_card_body`, `test_campaign_bible::test_puma_lines_without_cost` |

## 11. Deudas y pendientes

1. **Duración:** no hay partida humana cronometrada; la suma de escenas es una estimación.
2. **Arte y audio:** el arco usa blockout con materiales procedurales y modelos propios. El pase visual empezó por nubes, cordilleras y terreno; las montañas ya tienen volumen y la [guía visual](guia_visual.md) fija escala, formas y una paleta por acto. El elenco tiene reposo, habla, trabajo, caminar, correr y manto simulado, y la biblia excluye retratos y voces. Faltan texturas finas de roca, props de detalle y mezcla de audio.
3. **Verificación histórica:** PCH-032–036 tienen revisión documental del agente, no humana.

**Cerradas en v1.1:** I.3 (punto junto al fuego), II.1 (línea del inca que huyó), II.2 (descanso duplicado), II.3 (`distraccion_cuerda` y q'ipi), III.3 (coste en la última oleada), IV.3 (curaca vecino, Anca testifica, `maiz_repartido`), V.1 (verbos y habilidades del acto I) y los rótulos de nombre.

**Cerradas en v1.2:** combate con honda, porra y escudo; munición de piedras; viñeta de salud; respiración; sin barra fija de estado.

**Cerradas en v1.7:** rendimiento en Medio con la escena anterior a las cordilleras (Cusco 62,4 de mediana, escala 0,70).

**Cerradas en v1.8:** rendimiento final con las cordilleras, el shader aligerado y la escala 0,68; Cusco 63,6 de mediana y el resto por encima de 89.

**Cerradas en v1.9:** sensación de combate: fases de anticipación/activa/recuperación, parry de 0,15 s, bloqueo del 70 %, hitstop, golpe de cámara, destello, aviso enemigo y fichas de ataque (máximo dos a la vez).

## 12. Registro de cambios

| Versión | Fecha | Cambio |
|---|---|---|
| 1.0 | 2026-11-16 | Primera ficha de escenas de la campaña 01: 22 escenas, matriz de banderas, finales, duración y cobertura de pruebas. |
| 1.1 | 2026-11-16 | Se cierran las 7 escenas parciales y las deudas de escena: duda junto al fuego, línea del inca, campamento sin duplicado, coste en la última oleada, vecino y Anca en la asamblea, `maiz_repartido` en el cierre, verbos y habilidades de la obra, y rótulos de nombre. |
| 1.2 | 2026-11-16 | Se cierra la deuda de sistema de combate/HUD: honda, porra y escudo, munición de piedras, viñeta de salud, respiración y sin barra fija de estado. |
| 1.3 | 2026-11-16 | Se cierra el rendimiento en Medio: tres pasadas por acto y mediana ≥ 60 FPS, con la escala 3D al 0,70 y SSAO. La duración humana sigue pendiente. |
| 1.4 | 2026-11-16 | Pase visual parcial: nubes, cordilleras y terreno. La deuda de arte deja de describirse como «gris» y se concreta en animaciones, retratos, props y mezcla de audio. |
| 1.5 | 2026-11-16 | Cordilleras con volumen en la llacta y el Cusco mediante `DistantRange`: laderas, crestas, luz horneada y bruma por distancia. |
| 1.6 | 2026-11-16 | Estratos de roca y nieve en las cumbres altas; la deuda de arte se concreta en texturas finas y audio. |
| 1.7 | 2026-11-16 | Se reabre el rendimiento: la tanda con cordilleras da Cusco 59,4 de mediana. Se aligera el shader y la escala de Medio baja a 0,68; falta la medición final. |
| 1.8 | 2026-11-16 | Rendimiento final cerrado: Cusco 63,6 FPS de mediana (63,2 en la peor pasada) y los demás actos por encima de 89, con SSAO y escala 0,68. |
| 1.9 | 2026-11-16 | Pase de sensación de combate y guía visual: fases del golpe, parry, hitstop, cámara, telegrafía, fichas de ataque y paletas por acto. |
