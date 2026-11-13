# Alcance del Vertical Slice — Campaña 01: Pachacútec

- Estado: **Aprobado (v4.14)** — 2026-11-13; sustituye a la v4.13
- Fecha: 2026-11-10
- Precondición de: Fase 4 ([docs/05](../../../docs/05_plan_de_implementacion.md))
- Registro histórico: [registro_historico.md](registro_historico.md)
- Decisiones técnicas: [ADR-0006](../../../docs/adr/0006-secuencia-narrativa-por-subtitulos.md), [ADR-0007](../../../docs/adr/0007-evento-del-mensajero.md), [ADR-0008](../../../docs/adr/0008-disponibilidad-de-interactuables.md), [ADR-0009](../../../docs/adr/0009-duracion-y-disparo-del-slice.md), [ADR-0010](../../../docs/adr/0010-modelos-generados-con-blender.md), [ADR-0012](../../../docs/adr/0012-ajustes-tras-el-primer-piloto.md), [ADR-0013](../../../docs/adr/0013-ritmo-orientacion-y-cierre.md) [ADR-0014](../../../docs/adr/0014-texturas-de-detalle-triplanares.md) [ADR-0015](../../../docs/adr/0015-personajes-con-esqueleto.md) [ADR-0016](../../../docs/adr/0016-personajes-realistas-makehuman.md) y [ADR-0017](../../../docs/adr/0017-cabezas-rocketbox.md)

## 0. Historial de versiones

| Versión | Cambio |
|---|---|
| v1 | Primera propuesta, aprobada el 2026-11-10. Incompleta como precondición: sin cuestionario, criterio de corrección ni reclutamiento; el pututu era el único disparador del evento. |
| v2 | Añade el protocolo de prueba completo, la secuencia con disparo garantizado, los personajes que faltaban, el reparto de textos, la estimación de duración y el cambio de “chasqui” a “mensajero”. |
| v3 | Disparo por reloj, pututu disponible solo en la llamada, aviso de la llamada, habitantes que no parten, casas fuera de los caminos, camino norte y mirador, y duración ajustada a 5–8 min. |
| v3.1 | Define cuándo empieza y termina una sesión para medir la duración (§9.2). Aprobada por el responsable del proyecto el 2026-11-11. |
| v3.2 | Aplica [ADR-0010](../../../docs/adr/0010-modelos-generados-con-blender.md): Blender 5.x y modelos generados por script (§7 y §7.1). Cambio de herramienta; no altera el contenido ni el protocolo. |
| v3.3 | Personajes estáticos, sin rig ni animación, para el piloto y las sesiones (§5, §6.1 y §7.1). El rig queda para después del piloto si las sesiones muestran que el desplazamiento sin animación distrae. Aprobada por el responsable del proyecto el 2026-11-11. |
| v3.4 | Aplica [ADR-0012](../../../docs/adr/0012-ajustes-tras-el-primer-piloto.md) tras el primer piloto: subtítulos con tiempo de lectura y en cola, rótulo de lugar, nueva apertura, mensajero a los 120 s con señal intermedia, «Hablar» con seis personajes y vecinos que pasean. Aprobada por el responsable del proyecto el 2026-11-11. |
| v3.5 | Aplica [ADR-0013](../../../docs/adr/0013-ritmo-orientacion-y-cierre.md): mensajero a los 75 s que espera al jugador (como tarde a los 150 s, con aviso), vecino que recibe en el camino sur, tarjeta de fin con reinicio y balanceo de piernas. Aprobada por el responsable del proyecto el 2026-11-11. |
| v3.6 | Aplica [ADR-0014](../../../docs/adr/0014-texturas-de-detalle-triplanares.md): texturas de detalle CC0 en proyección triplanar para modelos, terreno, muros y campos; la plaza y los caminos se pintan en el terreno con borde irregular; *tonemap* AgX. Aprobada por el responsable del proyecto el 2026-11-11. |
| v3.7 | Aplica [ADR-0015](../../../docs/adr/0015-personajes-con-esqueleto.md): personajes con esqueleto y animaciones generadas (reposo, paseo, carrera, gestos, agotamiento, tejer arrodillada y trabajar con la chaquitaclla), mirada hacia el jugador y comitiva al paso. Añade vida y sonido: viento en el ichu y la queñua, pasos de los personajes y golpes del telar y de la chaquitaclla (§5, §6.1 y §6.3). Pedida por el responsable del proyecto el 2026-11-12. |
| v3.8 | Aplica [ADR-0016](../../../docs/adr/0016-personajes-realistas-makehuman.md): personajes realistas con cuerpos de MakeHuman (CC0), ropa andina propia ajustada al cuerpo y captura de movimiento de CMU (§5 y §6.1). Pedida por el responsable del proyecto el 2026-11-12, tras las quejas de los jugadores sobre el aspecto de los personajes. |
| v3.9 | Aplica [ADR-0017](../../../docs/adr/0017-cabezas-rocketbox.md): cabezas de la Microsoft Rocketbox Avatar Library (MIT) sobre los cuerpos de MakeHuman; tres vecinas distintas en lugar de tres copias (§5 y §6.1). Pedida por el responsable del proyecto el 2026-11-12. |
| v4.0 | Ropa más realista (§5): textiles con diseño propio (franjas, zigzag escalonado, rombos de gradas y t'oqapu en las autoridades) a la altura real de cada prenda, caída de la tela simulada en Blender y manto que se mece con huesos de muelle (`SpringBoneSimulator3D`). Pedida por el responsable del proyecto el 2026-11-12. |
| v4.1 | Aplica [ADR-0019](../../../docs/adr/0019-movimiento-natural-de-personajes.md): pies sin patinar, arranque, frenada y giro progresivos, orientación corregida de las tomas, gestos con movimiento y reposo variado (§5). Pedida por el responsable del proyecto el 2026-11-12. |
| v4.2 | Brazos y piernas revisados ([ADR-0018](../../../docs/adr/0018-ropa-textiles-caida-y-muelles.md) §4):
- la falda del anacu se mece entera, sin partirse al andar;
- el agricultor cierra la mano sobre la chaquitaclla;
- la tejedora llega con las manos al telar, cuyo extremo sube a su regazo;
- las ojotas tienen la forma del pie;
- la ropa se dibuja por las dos caras.

Pedida por el responsable del proyecto el 2026-11-12. |
| v4.3 | Aplica [ADR-0020](../../../docs/adr/0020-ropa-cortada-y-cosida.md): ropa cortada y cosida como paños de telar (unku, anacu, lliclla, manto, q'ipi y chuspa), caída simulada con los brazos bajados, sin piel que asome bajo la tela, y tejido de lana CC0 de ambientCG en lugar de arpillera (§5). Pedida por el responsable del proyecto el 2026-11-12. |
| v4.4 | Aplica [ADR-0021](../../../docs/adr/0021-construcciones-de-pirca.md): casas, terrazas y poyos de pirca de piedra tosca; casas con talud, enlucido desconchado, puerta baja con dintel de palos, techo de ichu con mechones, tierra pisada alrededor, tercera variante y giro respecto a la plaza; dos corrales de pirca seca (PCH-021) (§6.1 y §7). Pedida por el responsable del proyecto el 2026-11-12. |
| v4.5 | Aplica [ADR-0023](../../../docs/adr/0023-introduccion-del-slice.md): introducción de tres tarjetas antes de tomar el control, que sitúa al jugador sin adelantar la noticia; sustituye al rótulo de lugar y época; el reloj del mensajero espera a que termine; ficha PCH-022 (§2.2, §6.4, §8, §9.2 y §10). Pedida y aprobada por el responsable del proyecto el 2026-11-12. |
| v4.6 | Aplica [ADR-0024](../../../docs/adr/0024-titulo-nota-historica-y-controles.md): pantalla de título de `core/` («Memorias del Perú» · «Una mañana en la llacta», Comenzar y Salir) como escena principal; nota histórica como primera tarjeta de la introducción; controles en pantalla 8 s al tomar el control (§2.2, §6.4, §9.2 y §10). Pedida por el responsable del proyecto el 2026-11-12. |
| v4.7 | Aplica [ADR-0025](../../../docs/adr/0025-imagenes-de-la-introduccion.md): imágenes de fondo en la introducción. La nota sigue sobre negro; los Andes y la llacta se ven con tomas del propio juego, y la última termina en los ojos del jugador; el valle del Cusco se explica con un mapa propio (PCH-023) (§2.2, §6.4 y §8). Pedida y aprobada por el responsable del proyecto el 2026-11-12. |
| v4.8 | Aplica [ADR-0026](../../../docs/adr/0026-cierre-corto-y-mensajero.md), tras la prueba del responsable del proyecto: el mensajero parte con la comitiva hacia el Cusco, y la tarjeta de fin llega unos 8 s después de «La llacta queda en silencio…», sin esperar a que el grupo salga de la vista (§2.2, §5, §9.2 y §10). Aprobada el 2026-11-12. |
| v4.9 | Aplica [ADR-0027](../../../docs/adr/0027-musica-de-la-introduccion.md): música de la introducción, compuesta con notas de quena CC0, un bordón y una tinya sintetizados; se funde al tomar el control (§6.3). Pedida por el responsable del proyecto el 2026-11-12. |
| v4.10 | Aplica [ADR-0028](../../../docs/adr/0028-musica-epica-de-la-introduccion.md): la música de la introducción pasa a ser los primeros 44 s de «Atlas • Bolivia» (Pixabay, sikuri épico generado con IA), anacronismo declarado; sustituye a la pieza de quena de la v4.9 (§6.3). Elegida por el responsable del proyecto el 2026-11-12. |
| v4.11 | Aplica [ADR-0029](../../../docs/adr/0029-tema-de-apertura.md): la música de la introducción pasa a ser un montaje de 40 s de «Over The Andes» (Pixabay, tema principal andino generado con IA), con entrada suave, clímax y final real; sustituye a «Atlas • Bolivia» (§6.3). Elegida por el responsable del proyecto el 2026-11-12. |
| v4.12 | Corrección tras la prueba del responsable del proyecto: al dejar la ofrenda aparece un atado visible de coca y maíz sobre la losa, y el grupo se reúne en un anillo apretado alrededor del mensajero desde que llega, en lugar de quedar disperso por la plaza (§2.2, §4, §5 y §6.1). Pedida el 2026-11-12. |
| v4.13 | Pase de realismo visual y de promoción: captura en perfil Alto con HUD limpio, nubes altas procedurales, cordillera lejana de dos capas, niebla volumétrica corregida y luz más cálida; el perfil Bajo sigue por encima de 30 FPS (§3, §6.2 y §8). Pedida el 2026-11-13. |
| v4.14 | Pase de personajes y viviendas: manos en primera persona para beber, ofrecer y tocar el pututu; piel más cálida con subsuperficie y ropa con más detalle; puertas de tablones y escalón de piedra en las casas, con paja más envejecida (§4, §5 y §6.1). Pedida el 2026-11-13. |

## 1. Objetivo

Entregar una experiencia jugable de **5–8 minutos** en una llacta andina del siglo XV, con dos rutas de exploración, tres interactuables de tipos distintos, dos NPC con presencia y un evento narrativo completo. El vertical slice debe poder jugarse de principio a fin, sin bloqueos, dentro del presupuesto de rendimiento y con todo el contenido histórico registrado.

Objetivos medibles tomados de [docs/05](../../../docs/05_plan_de_implementacion.md) Fase 4:

| Aspecto | Objetivo |
|---|---|
| Duración | 5–8 min de mediana para un jugador que explora sin prisa (ADR-0009) |
| Espacio | Llacta de ~150 × 150 m explorables |
| Viviendas | 6–8 |
| Rutas | Al menos 2 entre el inicio y el punto narrativo final |
| Interactuables | Mínimo 3 de tipos distintos, incluido el quero |
| Personajes | Mínimo 2 NPC con presencia |
| Narrativa | 1 evento con inicio y cierre |
| Sonido | Ambiente de exteriores y efectos de interacción |
| Comprensión | ≥ 4 de 6 jugadores explican quién amenaza el Cusco y qué hace la élite |

## 2. Premisa y secuencia narrativa

El jugador es un habitante joven de una llacta del valle, sin nombre ni retrato canónico. La experiencia transcurre durante la mañana en que llega la noticia del avance chanca sobre el Cusco.

### 2.1 Qué debe entender el jugador

La métrica 5 se cumple si el jugador puede decir, con sus palabras:

1. **Quién amenaza:** los chancas marchan sobre el Cusco.
2. **Qué hace la élite:** el inca y su heredero han salido de la ciudad; la defensa la asume Cusi Yupanqui, que llama a los ayllus.

“La élite” son, en este relato, **el inca gobernante y su heredero**, no el curaca local. El curaca y los hombres principales de la llacta **parten hacia el Cusco para sumarse a la defensa**: no huyen. El guion debe impedir la lectura contraria.

La noticia se presenta como lo que dice el mensajero. La tradición recoge versiones divergentes (Garcilaso atribuye la victoria a Inca Viracocha); el juego no las resuelve.

### 2.2 Secuencia y disparo

La secuencia se gobierna con una máquina de estados ([ADR-0007](../../../docs/adr/0007-evento-del-mensajero.md)) y un disparo por reloj ([ADR-0009](../../../docs/adr/0009-duracion-y-disparo-del-slice.md)). La noticia cierra la sesión: el jugador explora primero y el mensajero llega a media mañana.

| Fase | Entra cuando | Ocurre | Subtítulo |
|---|---|---|---|
| título | se lanza el juego | pantalla de título de `core/` con Comenzar y Salir (ADR-0024) | — |
| introducción | se pulsa Comenzar | cuatro tarjetas (ADR-0023, ADR-0024 y ADR-0025): la nota histórica sobre negro; los Andes y la llacta sobre tomas del juego; el valle del Cusco sobre un mapa propio; el jugador no se mueve y el reloj del mensajero no corre; `E` pasa a la siguiente | «Esta historia se basa en crónicas coloniales…» / «Los Andes, siglo XV.» / «En el valle del Cusco gobiernan los incas…» / «Tú vives en una llacta…» |
| `IDLE` | termina la introducción | un vecino recibe al jugador en el camino sur; el mensajero espera fuera del camino norte; los vecinos pasean; se puede hablar con seis personajes | “Hoy se espera a un mensajero del Cusco…”; al acercarse al vecino, “¡Llegas a tiempo!…”; a los 45 s, “El sol ya está alto…”; a los 75 s, si el jugador no está en la plaza, “Desde la plaza llaman a la gente…” |
| `ARRIVAL` | pasan 75 s **y** el jugador está en la plaza, o 150 s en total | el mensajero corre hasta la plaza; los vecinos dejan el paseo y el grupo se acerca al punto de reunión | — |
| `MESSAGE` | el mensajero llega | el mensajero se detiene y el grupo termina de formar un anillo a su alrededor; el curaca y los principales escuchan | “¡Los chancas marchan sobre el Cusco!…” / “Cusi Yupanqui llama a los ayllus.” |
| `CALL` | termina `MESSAGE` | **el pututu se arma**; si el jugador no lo toca en 60 s, lo toca el curaca | “Los hombres esperan. El pututu puede convocar.” |
| `DEPARTURE` | suena el pututu | el mensajero, el curaca y los principales parten por el camino norte; los vecinos se quedan (v4.8) | “El curaca y los hombres principales parten hacia el Cusco.” / “La llacta queda en silencio…” |
| `DONE` | 8 s después de «La llacta queda en silencio…» (v4.8) | la tarjeta de fin se funde mientras la comitiva se aleja; al llegar al camino norte desaparece | «Fin del fragmento» · «R para volver a empezar · Esc para salir» |

Reglas:

- **Antes de `CALL` el pututu no está disponible**: no se enfoca, no muestra acción y no se gasta ([ADR-0008](../../../docs/adr/0008-disponibilidad-de-interactuables.md)). Así ningún toque temprano puede dejar la llamada sin respuesta.
- El curaca usa `force_play()`: aunque el pututu llegue gastado por cualquier vía, el evento termina.
- El subtítulo de la noticia se repite una vez si el jugador entra en la plaza durante `MESSAGE` o `CALL` (caso del disparo por espera agotada).
- El cierre es corto: unos 8 s después del último subtítulo, un fundido muestra la tarjeta de fin, y R reinicia y Esc sale (v4.8, ADR-0026). Antes la tarjeta llegaba unos 60 s después (v3.5, ADR-0013), y en la prueba ese hueco dejaba al jugador sin saber qué hacer.
- No hay diálogo ramificado ni sistema de misiones. Cualquier texto con opciones requiere un ADR.

## 3. Mapa y rutas

```text
                 camino norte (mensajero)
                          |
   terrazas este ---- plaza central ---- viviendas oeste
                          |
                 camino sur (inicio)
```

- **Inicio:** camino sur, con la llacta a la vista.
- **Ruta baja:** camino sur → viviendas oeste → telar → plaza.
- **Ruta alta:** camino sur → terrazas este → rampas → mirador → plaza.
- **Punto final:** plaza; la comitiva sale por el camino norte.
- **Campo:** lomas suaves de hasta 1,3 m fuera del núcleo de la llacta, a partir de unos 30 m del centro, que no tocan la plaza, las casas, las terrazas ni los caminos.
- **Bordes:** cresta rocosa con colisión a ~70 m del centro, sin caída al vacío. En el bloqueo, el terreno sube ~11 m entre 61 y 73 m con una pendiente no transitable y deja un paso abierto en el camino norte; los muros a 70 m quedan como respaldo.
- **Horizonte (v4.13):** sobre la cresta, una cordillera lejana de dos capas de siluetas y una cúpula de nubes altas procedurales. Son visuales, sin colisión, y dan profundidad y escala al valle.
- **Viviendas:** 8 módulos rectangulares de piedra con mortero de barro y techumbre de ichu, en dos variantes como mínimo, agrupados al oeste (3), al este (3) y al norte (2). **Ninguna casa ocupa el eje de un camino**: los cuatro caminos quedan libres.
- **Corrales (v4.4):** dos corrales bajos de pirca seca en las afueras del oeste y el noroeste, fuera de los caminos (PCH-021).
- **Plaza:** tierra apisonada, con el pututu, el quero y el adoratorio de ofrenda.
- **Terrazas:** tres niveles agrícolas con muro de contención de piedra seca (malla procedural `StoneWall`; PCH-008), tierra de cultivo con surcos encima y un corredor central de rampas transitables, de color camino. El agricultor está junto a la rampa de la primera terraza.
- **Mirador:** cornisa superior de la terraza este, al final de la ruta alta.
- **Vegetación:** ichu y queñua; prohibido el eucalipto y cualquier especie posterior a 1532.

## 4. Interactuables

| Objeto | Tipo | Comportamiento | Efecto |
|---|---|---|---|
| Quero de chicha | Consumible | Inclinación, sonido, restauración de estamina | +35 de estamina; sin límite de usos; 10 s de espera entre usos; mano en primera persona |
| Ofrenda a la Pachamama | Ofrenda | El jugador deja una ofrenda en el adoratorio | Aparece el atado de coca y maíz sobre la losa; respuesta sonora; un solo uso por partida; mano en primera persona |
| Pututu | Instrumento | El jugador lo hace sonar | Convoca la reunión y abre el cierre; un solo uso por partida; mano en primera persona |

Reglas:

- Ningún interactuable conoce la UI ni el evento: todos usan el contrato de `Interactable` y emiten señales.
- El estado de un solo uso es un `bool` en memoria; no hay guardado en esta fase.

## 5. Personajes

| Personaje | Papel | Presencia | Ficha |
|---|---|---|---|
| Tejedora | Mujer adulta que trabaja el telar junto a una vivienda | Idle de tejido; gira la cabeza hacia el jugador si está cerca | PCH-010, PCH-018 |
| Agricultor | Hombre que trabaja en las terrazas | Idle de trabajo; se detiene y mira al mensajero | PCH-008, PCH-018 |
| Mensajero | Quillis-cachi fugitivo que trae la noticia por el camino norte | Entra corriendo y agotado, se detiene en la plaza y habla con gestos; tras el pututu guía a la comitiva de vuelta al Cusco (v4.8) | PCH-011 |
| Curaca | Autoridad local que recibe la noticia y convoca | Sale de su casa, se acerca al mensajero; toca el pututu si el jugador no lo hace | PCH-017 |
| Hombre principal 1 | Acompaña al curaca | Converge, escucha y parte con el grupo | PCH-017, PCH-018 |
| Hombre principal 2 | Acompaña al curaca | Converge, escucha y parte con el grupo | PCH-017, PCH-018 |
| Habitantes (3) | Vecinos que interrumpen sus tareas | Se reúnen alrededor del mensajero durante el evento y **se quedan** cuando la comitiva parte | PCH-018 |

**Manos del jugador (v4.14).** El jugador ve una mano y un antebrazo en primera persona con manga de unku y piel cálida; entra en cuadro al beber, dejar la ofrenda o tocar el pututu y se retira. Es una reconstrucción (R): un recurso genérico, sin retrato ni joyas, coherente con PCH-018.

**Personajes realistas (v3.8, [ADR-0016](../../../docs/adr/0016-personajes-realistas-makehuman.md)).**

- Los genera `assets/blender/pch_people.py` con el complemento MPFB2 de MakeHuman.
- **Cuerpo:** humano con cara, manos y esqueleto, de complexión baja y robusta. La piel está teñida a un moreno de la sierra y el pelo es negro: interpretación declarada (PCH-018).
- **Ropa andina propia** (unku, anacu con faja, lliclla con tupu, manto, tocados, chuspa, ojotas y bulto) ajustada al cuerpo.
- **Movimiento:** captura real de CMU para reposo, paseo, carrera, gestos y trabajo, con la postura corregida: espalda más recta, cabeza estable y nivelada, dedos relajados.
- **Cara:** boca cerrada y ojos castaños.
- **Cabezas (v3.9, [ADR-0017](../../../docs/adr/0017-cabezas-rocketbox.md)):** de la Rocketbox Avatar Library, de calidad de artista, con la piel igualada al cuerpo. Los peinados son los de cada avatar.
- **Variedad:** los tres vecinos son tres mujeres distintas (`pch_npc_villager`, `_b` y `_c`).
- **Textiles (v4.0):** cada personaje lleva una textura de tela pintada por el generador, con trama de hilo:
  - **Unku:** franjas en la cintura y zigzag escalonado en el bajo. Las autoridades llevan además un cinturón de t'oqapu.
  - **Anacu:** franjas en el bajo; la faja, con rombos de gradas.
  - **Lliclla:** franjas y bandas decoradas.
  - **Manto:** franjas en el borde inferior.
  - **Cinta:** zigzag. **Paño:** a rayas.
  - Los diseños son reconstrucción (R) a partir de las piezas de PCH-010, PCH-017 y PCH-018.
- **Movimiento natural (v4.1, [ADR-0019](../../../docs/adr/0019-movimiento-natural-de-personajes.md)):**
  - Los pies no patinan al caminar ni al correr.
  - Los personajes arrancan, frenan y giran poco a poco, y no caminan de lado.
  - Al hablar gesticulan con los brazos.
  - Quietos, alternan dos reposos distintos.
- **Caída y movimiento (v4.0):** la falda, el manto y el borde de la lliclla caen por su peso (simulación de tela en Blender, horneada en el modelo). El manto se mece al caminar con tres cadenas de muelle que chocan con la cadera y el pecho.
- **Ropa cortada y cosida (v4.3, [ADR-0020](../../../docs/adr/0020-ropa-cortada-y-cosida.md)):**
  - Cada prenda es un paño de telar que cae sobre el cuerpo con los brazos bajados: el unku y el anacu doblados sobre los hombros y cosidos a los lados, y la lliclla y el manto echados sobre los hombros, prendidos o anudados al pecho.
  - El bulto del mensajero es un fardo de tela atado al pecho, y la chuspa, una bolsa llena.
  - La piel que la ropa tapa se quita, para que no asome al andar.
  - El tejido es lana (Fabric031, CC0) en lugar de arpillera.

Lo que sigue de la v3.7 (ADR-0015) se mantiene, ahora con estos cuerpos y estos movimientos. Cada personaje tiene esqueleto y animaciones:

- **Todos:** respiran en reposo, caminan o corren según la velocidad, sin que patinen los pies, y giran la cabeza hacia el jugador cuando está cerca.
- **Tejedora:** teje **arrodillada** en el extremo del telar de cintura, como en el dibujo 80 de Guamán Poma (PCH-010, R). Al hablar no se aparta del telar: solo gira la cabeza.
- **Agricultor:** hinca y levanta la chaquitaclla; al hablar la deja y se vuelve hacia el jugador.
- **Mensajero:** entra corriendo, recobra el aliento agotado y cuenta la noticia con gestos.
- **Curaca:** gesticula durante la llamada.
- **Vecinos y curaca:** acompañan su frase de «Hablar» con gestos.
- **Comitiva:** el mensajero, el curaca y los hombres principales caminan a 1,8 m/s; el mensajero va con ellos al paso, ya sin correr (v4.8).

**Conversaciones y paseo (v3.4).** Antes de la noticia, la tejedora, el agricultor, el curaca y los tres vecinos tienen «Hablar»: cada uno dice una sola frase, sin opciones, y se gira hacia el jugador. Los tres vecinos pasean despacio entre la plaza y las casas, y se detienen y se vuelven hacia el mensajero cuando llega.

La tejedora y el agricultor son los dos NPC con presencia que exige el objetivo. El resto forma parte del evento: solo el curaca y los dos hombres principales parten; los vecinos permanecen en la plaza, como dice el cierre.

## 6. Assets

### 6.1 Modelos y arquitectura

| Asset | Formato | Origen | Licencia | Ficha |
|---|---|---|---|---|
| Kit modular de vivienda (2 variantes) | `.glb` | Blender, autoría propia | Propia | PCH-007 |
| Plaza y caminos | Malla procedural / `.glb` | Godot o Blender | Propia | PCH-016 |
| Terrazas y muros de contención | Malla procedural / `.glb` | Godot o Blender | Propia | PCH-008 |
| Adoratorio de ofrenda y atado de coca y maíz | `.glb` | Blender | Propia | PCH-012 |
| Pututu | `.glb` | Blender | Propia | PCH-009 |
| Telar | `.glb` | Blender | Propia | PCH-010 |
| Quero | `.glb` | Blender | Propia | PCH-004 |
| Cuerpo base de habitante (tejedora, agricultor, mensajero, habitantes) | `.glb` con esqueleto, ropa y animaciones (v3.8, ADR-0016) | Blender + MPFB2 (`pch_people.py`) | Cuerpo, piel, ojos y pelo de MakeHuman (CC0); ropa propia; captura de CMU (uso libre) | PCH-018 |
| Variante de curaca y hombres principales | `.glb` | Blender + MPFB2 (`pch_people.py`) | Como el cuerpo base | PCH-017 |
| Cabezas de los personajes | Dentro de cada `.glb` | Microsoft Rocketbox Avatar Library (ADR-0017) | MIT (aviso en `assets/models/LICENSE.md`) | PCH-018 |
| Ichu y queñua | Mallas o billboards | Blender / procedural | Propia | PCH-013 |
| Cántaros de estilo Killke | `.glb` | Blender (generador) | Propia | PCH-019 |
| Haces de leña de queñua | `.glb` | Blender (generador) | Propia | PCH-020 |
| Poyos de pirca y corrales de piedra seca | `.glb` / malla procedural | Blender (generador) / Godot | Propia | PCH-007, PCH-021 |
| Llama o alpaca (opcional; no incluida, fuera del slice desde el 2026-11-11) | `.glb` | Blender | Propia | PCH-014 |

### 6.2 Materiales y texturas

- Piedra andesita/caliza, adobe, madera, ichu, textiles con tintes naturales.
- Nubes altas procedurales (shader propio, sin texturas externas) y cordillera lejana de siluetas (malla procedural).
- Texturas de 1K o 2K; sin imágenes de terceros sin licencia compatible.
- Materiales compartidos en `shared_assets/materials/`.
- **Hecho en v3.6** ([ADR-0014](../../../docs/adr/0014-texturas-de-detalle-triplanares.md)):
  - Nueve texturas CC0 de Poly Haven a 1K (piedra, barro, paja, madera, tejido, hierba, tierra, roca y suelo de cultivo), registradas en [shared_assets/textures/LICENSE.md](../../../shared_assets/textures/LICENSE.md).
  - Un shader triplanar las aplica como detalle sobre la paleta: el color sigue siendo el de las fichas.
  - La plaza y los caminos se pintan en el terreno con borde irregular, en lugar de losas.
  - El ichu, la cerámica, la piel y los objetos pequeños siguen con color plano.
- **Hecho en v3.7:** el mismo shader mece con el viento el ichu y la copa de la queñua. La ráfaga es lenta y variable, y sube a la vez el volumen del ambiente de viento (`LlactaWind`).

### 6.3 Audio

| Sonido | Uso | Origen | Licencia |
|---|---|---|---|
| Viento de altura | Ambiente continuo en bucle | `ambiente_viento_andes.ogg`: viento en Atacama (Chile), felix.blume, Freesound 156414 | CC0 |
| Aves andinas | Ambiente | sin grabación CC0 con aves andinas identificadas; el ambiente actual no lleva aves | — |
| Pasos en tierra y piedra | Jugador | `pasos_tierra_01–03.wav` (Freesound 352870) y `pasos_piedra_01–03.wav` (Freesound 521590), procesados | CC0 |
| Quero | Interacción | `quero_bebida.wav`: sorbo y trago, Freesound 320139 | CC0 |
| Pututu | Interacción y evento | `pututu_caracola.wav`: «Snailhorn», Ohrwurm, Freesound 64830 (caracola de tipo asiático; no hay pututu andino en CC0) | CC0 |
| Ofrenda | Interacción | `ofrenda_grano.wav`: grano vertido, Freesound 556974 | CC0 |
| Pasos de los personajes | Personajes al caminar o correr, en 3D (v3.7) | Los mismos `pasos_tierra_01–03.wav` del jugador | CC0 |
| Telar | Golpe del batán de la tejedora, en 3D (v3.7) | `telar_golpe.wav`: síntesis propia | Propia |
| Chaquitaclla | Golpe del agricultor al hincarla, en 3D (v3.7) | `pasos_tierra_02.wav` a 0,62 de velocidad | CC0 |
| Murmullo de plaza | Evento: de la noticia a la llamada | `murmullo_plaza.wav`: murmullo de hombres, Freesound 480808, filtrado y en bucle | CC0 |
| Música de la introducción | Desde la nota histórica hasta tomar el control; se funde en 3 s (v4.11) | `musica_intro_over_the_andes.ogg`: montaje de 40 s de «Over The Andes», u_98673jp944, Pixabay; generada con IA | Pixabay Content License |

Todas son sustitutos declarados (2026-11-11). La versión definitiva prefiere grabaciones propias en la sierra.

- Toda pieza se registra en `shared_assets/audio/LICENSE.md` con autor, URL, licencia y fecha de descarga.
- Si una fuente exige cuenta para descargar, se pide al responsable del proyecto y no se sustituye por material de licencia dudosa.
- Sin voces en esta fase.

### 6.4 Textos

| Clave | Cuándo | Texto |
|---|---|---|
| `UI_GAME_TITLE` · `PCH_CAMPAIGN_SUBTITLE` | pantalla de título | Memorias del Perú · Una mañana en la llacta |
| `PCH_INTRO_NOTE` | introducción, nota histórica (ADR-0024) | Esta historia se basa en crónicas coloniales y en la arqueología. Algunos elementos son reconstrucción o licencia narrativa. |
| `PCH_INTRO_1` | introducción, tarjeta 1 | Los Andes, siglo XV. |
| `PCH_MAP_CUSCO` · `PCH_MAP_LLACTA` · `PCH_MAP_NORTH` | mapa de la tarjeta 2 (ADR-0025) | Cusco · Tu llacta · N |
| `PCH_INTRO_2` | introducción, tarjeta 2 | En el valle del Cusco gobiernan los incas. Todavía no son un imperio: son el señorío más fuerte de la región. |
| `PCH_INTRO_3` | introducción, tarjeta 3 | Tú vives en una llacta, una pequeña aldea de la sierra cerca del Cusco. Hoy se esperan noticias. |
| `PCH_INTRO_HINT` | al pie de las tarjetas | E para continuar |
| `PCH_NARR_OPENING` | al empezar | Hoy se espera a un mensajero del Cusco. Mientras llega, recorre la llacta y habla con su gente. |
| `PCH_NARR_GREET` | al acercarse al vecino del camino sur | ¡Llegas a tiempo! Ven a la plaza: hoy esperamos noticias del Cusco. |
| `PCH_NARR_WAIT` | a los 45 s, si no ha llegado | El sol ya está alto. Por el camino del norte todavía no viene nadie. |
| `PCH_NARR_GATHER` | a los 75 s, si el jugador no está en la plaza | Desde la plaza llaman a la gente: el mensajero está por llegar. |
| `PCH_NARR_NEWS_1` | llega el mensajero | ¡Los chancas marchan sobre el Cusco! El inca y su heredero han salido de la ciudad. |
| `PCH_NARR_NEWS_2` | tras la anterior | Cusi Yupanqui llama a los ayllus. |
| `PCH_NARR_CALL` | empieza la llamada | Los hombres esperan. El pututu puede convocar. |
| `PCH_NARR_CLOSING_1` | parte el grupo | El curaca y los hombres principales parten hacia el Cusco. |
| `PCH_NARR_CLOSING_2` | tras la anterior | La llacta queda en silencio. Solo queda el viento. |
| `PCH_END_TITLE` | tarjeta de fin | Fin del fragmento |

Frases de «Hablar» (licencia narrativa, N; la mención de Andahuaylas se apoya en PCH-003). Revisadas y aprobadas por el responsable del proyecto el 2026-11-11:

| Clave | Personaje | Texto |
|---|---|---|
| `PCH_TALK_WEAVER` | Tejedora | Tejo esta manta para el curaca. Dicen que hoy llega alguien del Cusco; ojalá traiga buenas noticias. |
| `PCH_TALK_FARMER` | Agricultor | Las terrazas ya están listas para sembrar. Desde aquí arriba se ve el camino del norte, el que va al Cusco. |
| `PCH_TALK_CURACA` | Curaca | Espero noticias del Cusco. Quédate cerca de la plaza. |
| `PCH_TALK_VILLAGER_1` | Habitante 1 | Somos un ayllu pequeño. Cuando el Cusco llama, los hombres van con el curaca. |
| `PCH_TALK_VILLAGER_2` | Habitante 2 | Los viajeros hablan de los chancas, allá por Andahuaylas. Dicen que cada vez son más. |
| `PCH_TALK_VILLAGER_3` | Habitante 3 | El curaca no se mueve de la plaza. Él será el primero en oír lo que traiga el mensajero. |

Cada subtítulo dura al menos su tiempo de lectura (largo ÷ 13 caracteres por segundo + 1,5 s, con un mínimo de 4 s) y espera su turno si hay otro a la vista (ADR-0012).

## 7. Pipeline de assets

- **Blender 5.x** para modelos, rigging y animación ([ADR-0010](../../../docs/adr/0010-modelos-generados-con-blender.md); sustituye a la 4.x LTS). Los modelos se generan con el script versionado `assets/blender/pch_models.py`.
- Exportación a **glTF 2.0 binario (`.glb`)**; no se importan `.blend`.
- 1 unidad = 1 metro; transformaciones aplicadas; origen en los pies para personajes.
- Nombres `snake_case` con prefijo `pch_` (`pch_house_a.glb`, `pch_npc_weaver.glb`).
- LOD automático de Godot; `visibility_range` para vegetación.
- Colisión: mallas `-col` o `create_trimesh_shape()` para estáticos; cápsula para NPC.
- Sin addons de Blender ni de Godot sin ADR.
- Si un asset no está listo, se usa un bloqueo declarado como placeholder; no se presenta como definitivo.

### 7.1 Dónde entra cada modelo

Los `.glb` se guardan en `campaigns/01_pachacutec/assets/models/`. Cada bloqueo tiene un hueco (`ModelSlot`, [docs/02](../../../docs/02_arquitectura.md) §5) que carga el primer archivo existente de su lista y oculta el bloqueo; sin archivo, el bloqueo sigue. Basta con añadir el archivo e importarlo (`godot --headless --path . --import`).

| Bloqueo | Archivos, en orden de preferencia | Origen del modelo | Estado |
|---|---|---|---|
| Viviendas (se alternan) | `pch_house_a.glb` / `pch_house_b.glb` / `pch_house_c.glb` | Base de la vivienda, mirando a la plaza por −Z; con colisión propia (`-convcolonly` o `-col`) | Generadas (R) |
| Poyo del quero y del pututu | `pch_pedestal.glb` | Base del poyo; la colisión es la caja del bloqueo | Generado (R) |
| Tejedora, agricultor, mensajero | `pch_npc_weaver.glb`, `pch_npc_farmer.glb`, `pch_npc_messenger.glb` → `pch_npc_commoner.glb` | Pies | Generados, estáticos (R) |
| Habitantes 1–3 | `pch_npc_villager.glb` → `pch_npc_commoner.glb` | Pies | Generados, estáticos (R); los tres comparten modelo |
| Curaca / hombres principales | `pch_npc_curaca.glb` / `pch_npc_principal.glb` → `pch_npc_authority.glb` | Pies | Generados, estáticos (R) |
| Quero, pututu, adoratorio | `pch_quero.glb`, `pch_pututu.glb`, `pch_offering_shrine.glb` | Base del objeto | Generados (R) |
| Telar (sin bloqueo) | `pch_loom.glb` | Extremo de la tejedora; el telar se extiende hacia +Z de Godot hasta la estaca | Generado (R) |
| Props de las viviendas (sin bloqueo) | `pch_prop_jar.glb`, `pch_prop_firewood.glb` | Base; delante del muro frontal, a los lados de la puerta | Generados (R) |
| Vegetación (sin bloqueo) | `pch_ichu_a.glb`, `pch_ichu_b.glb`; `pch_quenua_a.glb`, `pch_quenua_b.glb` | Base de la mata o del tronco; un único objeto por archivo, porque se repite con `MultiMesh` | Generados (R) |

La vegetación la reparte `scripts/world/vegetation.gd` (`LlactaVegetation`): unas 3 100 matas de ichu en bloques de 22 m que se ocultan a 50 m y no proyectan sombra, y 24 queñuas en cuatro bosquecillos junto a la cresta, con colisión en el tronco. El reparto es determinista y deja libres la plaza, los caminos, las casas, las terrazas y el rincón de la tejedora.

«Generado» significa producido por `pch_models.py` (ADR-0010): low-poly con colores planos, sustituible por un modelo hecho a mano que cumpla las mismas reglas. Cada modelo se exporta como una sola malla visible, sin material y con el color por vértice, para dibujarse con una llamada; `ModelSlot` activa ese color al cargarlo. Los personajes cuelgan su hueco del cuerpo del bloqueo y heredan su balanceo de reposo. Un modelo hecho a mano puede traer materiales propios. La forma concreta de cada modelo es una reconstrucción (R) según su ficha.

Reglas que comprueba `test_model_files_valid` en cada archivo:
- nombre `pch_*.glb` en `snake_case` y ningún `.blend`;
- tamaño entre 0,05 y 20 m;
- base del modelo a menos de 5 cm del origen;
- escalas aplicadas;
- colisión propia en las viviendas;
- personajes de 1,2 a 2,1 m y sin colisión, porque se usa la cápsula de la escena.

Los personajes conservan siempre la cápsula de colisión del bloqueo, y los objetos su colisión de interacción.

**Orientación.** Los personajes y las viviendas se orientan con `look_at`, que apunta el eje −Z de Godot. El exportador glTF de Blender convierte el frente habitual de Blender (−Y, vista frontal) en +Z de Godot, así que los personajes y las fachadas deben modelarse **mirando hacia +Y en Blender** (vista trasera). Si un modelo aparece de espaldas, es esto.

## 8. Registro histórico

Antes del cierre de la Fase 4, todo elemento debe tener ficha en estado **verificado** ([docs/07](../../../docs/07_convenciones_historicas.md) §3).

| ID | Elemento | Clasificación | Estado |
|---|---|---|---|
| PCH-004 | Quero | A / R | verificado (A), 2026-11-11 |
| PCH-005 | Chicha de jora | H / A | verificado (H / A), 2026-11-11 |
| PCH-006 | Llacta / asentamiento | A / R | verificado (A / R), 2026-11-11 (comprobación del agente) |
| PCH-007 | Vivienda rural de piedra y barro | A / R | verificado (A / R), 2026-11-11 (comprobación del agente) |
| PCH-008 | Terraza agrícola | A | verificado (A), 2026-11-11 (comprobación del agente) |
| PCH-009 | Pututu | A / H | verificado (A / H), 2026-11-11 (rehecho) |
| PCH-010 | Telar y textil | A / R | verificado (A), 2026-11-11 |
| PCH-011 | Mensajero (no chasqui) | H / R | verificado (H), 2026-11-11 |
| PCH-012 | Ofrenda a la Pachamama | H / R | verificado (H / R), 2026-11-11 |
| PCH-013 | Ichu y queñua | A | verificado (A), 2026-11-11 |
| PCH-014 | Llama / alpaca (opcional) | A | fuera del slice: no está en el juego (2026-11-11) |
| PCH-015 | Evento: la noticia chanca | H (tradición) / N | verificado (H), 2026-11-11 |
| PCH-016 | Plaza y caminos | A / R / N | verificado (A / R / N), 2026-11-11 (comprobación del agente) |
| PCH-017 | Curaca y hombres principales | H / R | verificado (H / R), 2026-11-11 (comprobación del agente) |
| PCH-018 | Vestimenta y apariencia del habitante común | R | verificado (R), 2026-11-11 |
| PCH-019 | Cerámica doméstica (cántaros) | A / R | verificado (A / R), 2026-11-11 (comprobación del agente) |
| PCH-020 | Leña de queñua | R | verificado (R), 2026-11-11 (comprobación del agente) |
| PCH-021 | Corral de pirca seca | R | verificado (R), 2026-11-12 |
| PCH-022 | El Cusco antes de la expansión inca | A / R | verificado (A / R), 2026-11-12 |
| PCH-023 | Mapa de la introducción | R / N | verificado (R / N), 2026-11-12 |

“Verificado” exige la cita completa del requisito de su clasificación y la firma de una persona con la edición a la vista. Las siete fichas marcadas «comprobación del agente» las firmó el responsable del proyecto el 2026-11-11 sobre la comprobación en línea del agente, sin consultar él mismo las ediciones ([hoja de verificación](hoja_verificacion_fichas.md) §5). Las páginas de la traducción de 2007 tomadas de su índice publicado no cuentan como cita.

## 9. Protocolo de prueba

### 9.1 Muestra y reclutamiento

- **Mínimo 6 personas**, mayores de edad, **ajenas al desarrollo**: no han visto el juego ni participado en su diseño.
- Al menos **2 sin interés previo** en historia andina, para no medir solo a un público motivado.
- Reclutamiento por invitación directa fuera del círculo del equipo (conocidos de terceros, estudiantes, familiares no implicados). Se registran como **P1–P6**, sin nombres.
- Se excluye a quien haya leído este documento.

### 9.2 Sesión

| Paso | Duración | Qué ocurre |
|---|---|---|
| Consentimiento | 2 min | Se explica que se cronometra y se toman notas anónimas; puede abandonar en cualquier momento |
| Controles | 2 min | Solo movimiento, cámara e interacción; **no se explica la historia** |
| Juego | 5–8 min | El facilitador observa en silencio |
| Cuestionario | 5 min | Cinco preguntas abiertas, sin opciones |

El facilitador solo responde dudas de **controles**. Si hay un bloqueo técnico, lo anota y no ayuda con el contenido.

**Medición de la duración.** El juego no tiene pantalla final, así que la duración de una sesión se mide así:

- **Inicio:** aparece la primera tarjeta de la introducción, cuando la persona pulsa Comenzar en la pantalla de título tras la explicación de controles (v4.6; antes, el primer movimiento). Se anota también el momento en que termina la introducción.
- **Fin:** lo primero que ocurra de lo siguiente: la persona dice que ha terminado; aparece la tarjeta «Fin del fragmento» (v4.8; antes, 60 s tras el subtítulo de cierre); se llega a 12 min.
- Se anota también el momento del subtítulo de cierre, para separar el tiempo de la historia del de exploración libre.

El procedimiento completo está en [guion_facilitador.md](guion_facilitador.md).

### 9.3 Cuestionario

Se lee en voz alta y se anota la respuesta literal:

1. ¿Quién amenaza al Cusco en la historia que has visto?
2. ¿Qué han hecho el inca y su heredero?
3. ¿Qué hacen el curaca y los hombres de la llacta?
4. ¿Qué hiciste en la plaza y para qué servía cada cosa?
5. ¿Qué te ha quedado claro y qué no?

### 9.4 Criterio de corrección

Solo puntúan las preguntas **1 y 2**; las demás son diagnóstico.

| Pregunta | Se considera correcta si… | No se considera correcta si… |
|---|---|---|
| 1 | Nombra a los chancas (o “chanka”) como quienes amenazan el Cusco | Dice solo “un pueblo enemigo”, “los malos” o no lo sabe |
| 2 | Dice que el inca y su heredero abandonaron, salieron o huyeron de la ciudad | Confunde a la élite con el curaca, o dice que el curaca huye |

Se supera el cuestionario si **ambas** respuestas son correctas.

- Dos evaluadores puntúan por separado sobre la transcripción literal.
- Si discrepan, una tercera persona decide.
- Si la discrepancia persiste, la sesión cuenta como **no superada**.
- Éxito de la métrica 5: **≥ 4 de 6** sesiones superadas.

### 9.5 Registro

- Tabla anónima con: código, duración, respuestas literales, puntuación de cada evaluador, incidencias técnicas y observaciones.
- Se guarda en `documentation/sesiones/` cuando exista la primera sesión.
- Sin datos personales, sin grabaciones de vídeo, sin audio.

### 9.6 Criterios de estabilidad

- Cero errores en consola durante las sesiones.
- Cero bloqueos de progreso: el evento termina aunque el jugador no toque el pututu.
- Toda incidencia se reproduce y se corrige antes de cerrar la fase.

## 10. Duración estimada

La llacta se cruza en 43 s a velocidad de caminata (3,5 m/s), así que la duración depende de cuánto explore el jugador antes de la noticia. Dos escenarios medidos sobre el mapa actual:

| Momento | Directo (min) | Explorador (min) |
|---|---|---|
| Título e introducción (cuatro tarjetas, v4.6) | 0,5 | 0,6 |
| Apertura y entrada por el camino sur | 0,5 | 1,0 |
| Viviendas oeste y telar | 0,5 | 2,0 |
| Terrazas, rampas y mirador | 0,5 | 2,0 |
| Quero y ofrenda | 0,5 | 1,0 |
| Conversaciones y espera hasta la noticia (v3.5: mensajero a los 75 s, que espera al jugador) | 0,5 | 0,0 |
| Evento: llegada, noticia, llamada y partida | 1,5 | 1,5 |
| **Total** | **4,5** | **8,1** |

Con el reloj de 75 s que espera al jugador (v3.5), la mediana esperada queda en **4–6 minutos** (unos 30 s más con la introducción de la v4.6, y unos 50 s menos con el cierre corto de la v4.8, que ya no espera 60 s tras el último subtítulo): quien explora ve el evento al llegar a la plaza, como tarde a los 150 s. Si la prueba con seis personas queda por debajo de 5 min, la corrección es añadir contenido (dos hitos opcionales con texto breve), no alargar la espera. Si supera los 8, se acorta el reloj.

## 11. Rendimiento

- Objetivo vinculante: ≥ 30 FPS de media en perfil Bajo, 1080p, en la referencia con GPU integrada.
- Objetivo recomendado: ≥ 60 FPS en perfil Medio en la referencia con GPU dedicada, cuando exista.
- Remedir con el recorrido fijo de `tests/measure_performance.gd` al añadir casas, NPC, vegetación y audio.
- No se optimiza sin medir.

## 12. Fuera de alcance

- Combate, inventario, diálogos ramificados, misiones y guardado.
- Códice o enciclopedia dentro del juego.
- Multijugador, consolas, móviles y VR.
- Localización a otros idiomas.
- Campañas adicionales.

## 13. Aprobación

- [x] El equipo revisa y aprueba esta revisión 3.
- [x] Se confirma el disparo por reloj y la disponibilidad del pututu solo en la llamada.
- [x] Se confirma la duración objetivo de 5–8 min (ADR-0009).
- [x] Se confirma el reparto de textos, incluido el aviso de la llamada.
- [x] Se confirman la salida por el camino norte y la permanencia de los vecinos.
- [x] Se confirma la medición de la duración de §9.2 (v3.1, 2026-11-11).
- [x] Se confirman los personajes estáticos para el piloto y las sesiones (v3.3, 2026-11-11).
- [x] Se confirman los ajustes del primer piloto (v3.4, ADR-0012, 2026-11-11).
- [x] Se confirman el ritmo, el primer paso, la tarjeta de fin y el balanceo de piernas (v3.5, ADR-0013, 2026-11-11).

Aprobada el 2026-11-10. La precondición de la Fase 4 está marcada en [docs/05](../../../docs/05_plan_de_implementacion.md) y la fase sigue en curso.
