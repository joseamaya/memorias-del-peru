# Alcance del Vertical Slice — Campaña 01: Pachacútec

- Estado: **Propuesto (v2)** — pendiente de aprobación; sustituye a la v1
- Fecha: 2026-11-10
- Precondición de: Fase 4 ([docs/05](../../../docs/05_plan_de_implementacion.md))
- Registro histórico: [registro_historico.md](registro_historico.md)
- Decisiones técnicas: [ADR-0006](../../../docs/adr/0006-secuencia-narrativa-por-subtitulos.md) y [ADR-0007](../../../docs/adr/0007-evento-del-mensajero.md)

## 0. Historial de versiones

| Versión | Cambio |
|---|---|
| v1 | Primera propuesta, aprobada el 2026-11-10. Incompleta como precondición: sin cuestionario, criterio de corrección ni reclutamiento; el pututu era el único disparador del evento. |
| v2 | Añade el protocolo de prueba completo, la secuencia con disparo garantizado, los personajes que faltaban, el reparto de textos, la estimación de duración y el cambio de “chasqui” a “mensajero”. |

## 1. Objetivo

Entregar una experiencia jugable de **10–15 minutos** en una llacta andina del siglo XV, con dos rutas de exploración, tres interactuables de tipos distintos, dos NPC con presencia y un evento narrativo completo. El vertical slice debe poder jugarse de principio a fin, sin bloqueos, dentro del presupuesto de rendimiento y con todo el contenido histórico registrado.

Objetivos medibles tomados de [docs/05](../../../docs/05_plan_de_implementacion.md) Fase 4:

| Aspecto | Objetivo |
|---|---|
| Duración | 10–15 min de mediana para un jugador que explora sin prisa |
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

La secuencia se gobierna con una máquina de estados ([ADR-0007](../../../docs/adr/0007-evento-del-mensajero.md)). El evento **no depende del pututu**: empieza cuando el jugador entra en la plaza o, si no entra, al agotarse un tiempo máximo.

| Fase | Entra cuando | Ocurre | Subtítulo |
|---|---|---|---|
| `IDLE` | inicio | el mensajero espera fuera del camino norte | — |
| `ARRIVAL` | el jugador entra en 22 m de la plaza **o** pasan 120 s | el mensajero corre hasta la plaza; los demás giran hacia él | — |
| `MESSAGE` | el mensajero llega | el curaca y dos hombres principales convergen; aviso del pututu | “¡Los chancas marchan sobre el Cusco! El inca y su heredero han salido de la ciudad.” / “Cusi Yupanqui llama a los ayllus.” |
| `CALL` | termina `MESSAGE` | el jugador puede tocar el pututu; si no lo hace en 60 s, lo toca el curaca | — |
| `DEPARTURE` | suena el pututu | el grupo parte hacia el norte; el mensajero se queda | “El curaca y los hombres principales parten hacia el Cusco.” / “La llacta queda en silencio. Solo queda el viento.” |
| `DONE` | el grupo sale del área | la plaza queda vacía; el jugador sigue libre | — |

Reglas:

- El subtítulo de apertura se muestra al empezar a jugar: “Una llacta del valle. Siglo XV. La mañana empieza como cualquier otra.”
- El subtítulo de la noticia se repite una vez si el jugador entra en la plaza durante `MESSAGE` o `CALL`.
- El pututu conserva su papel: convoca la reunión y abre el cierre. Es opcional para terminar.
- El final no muestra créditos ni fundido: la plaza vacía y el viento son el cierre.
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
- **Ruta alta:** camino sur → terrazas este → mirador → plaza.
- **Punto final:** plaza, junto al pututu.
- **Bordes:** cresta rocosa con colisión a ~70 m del centro, sin caída al vacío.
- **Viviendas:** 6–8 módulos rectangulares de piedra con mortero de barro y techumbre de ichu, en dos variantes como mínimo.
- **Plaza:** tierra apisonada, con el pututu, el quero y el adoratorio de ofrenda.
- **Terrazas:** tres niveles agrícolas con muro de contención y escalones transitables.
- **Vegetación:** ichu y queñua; prohibido el eucalipto y cualquier especie posterior a 1532.

## 4. Interactuables

| Objeto | Tipo | Comportamiento | Efecto |
|---|---|---|---|
| Quero de chicha | Consumible | Inclinación, sonido, restauración de estamina | +35 de estamina; sin límite de usos; 10 s de espera entre usos |
| Ofrenda a la Pachamama | Ofrenda | El jugador deja una ofrenda en el adoratorio | Respuesta visual y sonora; un solo uso por partida |
| Pututu | Instrumento | El jugador lo hace sonar | Convoca la reunión y abre el cierre; un solo uso por partida |

Reglas:

- Ningún interactuable conoce la UI ni el evento: todos usan el contrato de `Interactable` y emiten señales.
- El estado de un solo uso es un `bool` en memoria; no hay guardado en esta fase.

## 5. Personajes

| Personaje | Papel | Presencia | Ficha |
|---|---|---|---|
| Tejedora | Mujer adulta que trabaja el telar junto a una vivienda | Idle de tejido; gira la cabeza hacia el jugador si está cerca | PCH-010, PCH-018 |
| Agricultor | Hombre que trabaja en las terrazas | Idle de trabajo; se detiene y mira al mensajero | PCH-008, PCH-018 |
| Mensajero | Quillis-cachi fugitivo que trae la noticia por el camino norte | Entra corriendo y agotado, se detiene en la plaza y habla con gestos | PCH-011 |
| Curaca | Autoridad local que recibe la noticia y convoca | Sale de su casa, se acerca al mensajero; toca el pututu si el jugador no lo hace | PCH-017 |
| Hombre principal 1 | Acompaña al curaca | Converge, escucha y parte con el grupo | PCH-017, PCH-018 |
| Hombre principal 2 | Acompaña al curaca | Converge, escucha y parte con el grupo | PCH-017, PCH-018 |
| Habitantes (3) | Vecinos que interrumpen sus tareas | Se reúnen alrededor de la plaza durante el evento | PCH-018 |

La tejedora y el agricultor son los dos NPC con presencia que exige el objetivo. El resto forma parte del evento.

## 6. Assets

### 6.1 Modelos y arquitectura

| Asset | Formato | Origen | Licencia | Ficha |
|---|---|---|---|---|
| Kit modular de vivienda (2 variantes) | `.glb` | Blender, autoría propia | Propia | PCH-007 |
| Plaza y caminos | Malla procedural / `.glb` | Godot o Blender | Propia | PCH-016 |
| Terrazas y muros de contención | Malla procedural / `.glb` | Godot o Blender | Propia | PCH-008 |
| Adoratorio de ofrenda | `.glb` | Blender | Propia | PCH-012 |
| Pututu | `.glb` | Blender | Propia | PCH-009 |
| Telar | `.glb` | Blender | Propia | PCH-010 |
| Quero | `.glb` | Blender | Propia | PCH-004 |
| Cuerpo base de habitante (tejedora, agricultor, mensajero, habitantes) | `.glb` riggeado | Blender | Propia | PCH-018 |
| Variante de curaca y hombres principales | `.glb` | Blender, variante del cuerpo base | Propia | PCH-017 |
| Ichu y queñua | Mallas o billboards | Blender / procedural | Propia | PCH-013 |
| Llama o alpaca (opcional) | `.glb` | Blender | Propia | PCH-014 |

### 6.2 Materiales y texturas

- Piedra andesita/caliza, adobe, madera, ichu, textiles con tintes naturales.
- Texturas de 1K o 2K; sin imágenes de terceros sin licencia compatible.
- Materiales compartidos en `shared_assets/materials/`.

### 6.3 Audio

| Sonido | Uso | Origen | Licencia |
|---|---|---|---|
| Viento de altura | Ambiente continuo en bucle | “Howling Wind Ambience”, DBlover (Freesound 405601) o equivalente | CC0 |
| Aves andinas | Ambiente | por elegir en OpenGameArt / Wikimedia Commons | CC0 / dominio público |
| Pasos en tierra y piedra | Jugador | por elegir, CC0 | CC0 |
| Quero | Interacción | placeholder actual | Propia |
| Pututu | Interacción y evento | “Snailhorn”, Ohrwurm (Freesound) o equivalente | CC0 |
| Ofrenda | Interacción | por elegir, CC0 | CC0 |
| Murmullo de plaza | Evento | por elegir o grabar | Propia |

- Toda pieza se registra en `shared_assets/audio/LICENSE.md` con autor, URL, licencia y fecha de descarga.
- Si una fuente exige cuenta para descargar, se pide al responsable del proyecto y no se sustituye por material de licencia dudosa.
- Sin voces en esta fase.

### 6.4 Textos

| Clave | Cuándo | Texto |
|---|---|---|
| `PCH_NARR_OPENING` | al empezar | Una llacta del valle. Siglo XV. La mañana empieza como cualquier otra. |
| `PCH_NARR_NEWS_1` | llega el mensajero | ¡Los chancas marchan sobre el Cusco! El inca y su heredero han salido de la ciudad. |
| `PCH_NARR_NEWS_2` | tras la anterior | Cusi Yupanqui llama a los ayllus. |
| `PCH_NARR_CLOSING_1` | parte el grupo | El curaca y los hombres principales parten hacia el Cusco. |
| `PCH_NARR_CLOSING_2` | tras la anterior | La llacta queda en silencio. Solo queda el viento. |

## 7. Pipeline de assets

- **Blender 4.x LTS** para modelos, rigging y animación.
- Exportación a **glTF 2.0 binario (`.glb`)**; no se importan `.blend`.
- 1 unidad = 1 metro; transformaciones aplicadas; origen en los pies para personajes.
- Nombres `snake_case` con prefijo `pch_` (`pch_house_a.glb`, `pch_npc_weaver.glb`).
- LOD automático de Godot; `visibility_range` para vegetación.
- Colisión: mallas `-col` o `create_trimesh_shape()` para estáticos; cápsula para NPC.
- Sin addons de Blender ni de Godot sin ADR.
- Si un asset no está listo, se usa un bloqueo declarado como placeholder; no se presenta como definitivo.

## 8. Registro histórico

Antes del cierre de la Fase 4, todo elemento debe tener ficha en estado **verificado** ([docs/07](../../../docs/07_convenciones_historicas.md) §3).

| ID | Elemento | Clasificación | Estado |
|---|---|---|---|
| PCH-004 | Quero | A / R | pendiente |
| PCH-005 | Chicha de jora | H / A | pendiente |
| PCH-006 | Llacta / asentamiento | A / R | pendiente |
| PCH-007 | Vivienda rural de piedra y barro | A / R | pendiente |
| PCH-008 | Terraza agrícola | A | pendiente |
| PCH-009 | Pututu | A / H | verificado |
| PCH-010 | Telar y textil | A / R | pendiente |
| PCH-011 | Mensajero (no chasqui) | H / R | verificado |
| PCH-012 | Ofrenda a la Pachamama | H / R | pendiente |
| PCH-013 | Ichu y queñua | A | pendiente |
| PCH-014 | Llama / alpaca (opcional) | A | pendiente |
| PCH-015 | Evento: la noticia chanca | H (tradición) / N | verificado |
| PCH-016 | Plaza y caminos | A / R | pendiente |
| PCH-017 | Curaca y hombres principales | H / R | pendiente |
| PCH-018 | Vestimenta y apariencia del habitante común | R | pendiente |

“Verificado” exige la cita completa del requisito de su clasificación. Las fichas pendientes están identificadas con sus fuentes, pero les falta edición, página o publicación comprobada.

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
| Juego | 10–15 min | El facilitador observa en silencio |
| Cuestionario | 5 min | Cinco preguntas abiertas, sin opciones |

El facilitador solo responde dudas de **controles**. Si hay un bloqueo técnico, lo anota y no ayuda con el contenido.

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

Estimación para un jugador que explora sin prisa, a velocidad de caminata (3,5 m/s):

| Momento | Minutos |
|---|---|
| Apertura y camino sur | 1,5 |
| Ruta baja: viviendas oeste y telar | 2,0 |
| Ruta alta: terrazas y mirador | 2,5 |
| Interacciones de la plaza (quero, ofrenda) | 2,0 |
| Evento del mensajero y reunión | 2,5 |
| Partida y cierre | 1,5 |
| Margen de contemplación y recorrido libre | 2,0 |
| **Total** | **14,0** |

Riesgo: si la mediana real queda por debajo de 10 min, la corrección es añadir dos miradores con un subtítulo breve, no más sistemas.

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

- [ ] El equipo revisa y aprueba esta revisión 2.
- [ ] Se confirma el disparo del evento por llegada a la plaza con respaldo temporal.
- [ ] Se confirma el reparto de textos y la definición de “la élite”.
- [ ] Se confirma el protocolo de prueba y el criterio de corrección.
- [ ] Se confirman los personajes añadidos y el cambio de “chasqui” a “mensajero”.

Al aprobarse, se marca la precondición de la Fase 4 en [docs/05](../../../docs/05_plan_de_implementacion.md) y se reanuda la fase.
