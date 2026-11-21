# Prueba humana de la vertical slice — F3

- **Versión:** 1.0 — 2026-11-21
- **Ámbito:** la slice de la campaña 01, de la mañana del arrabal a la batalla de Carmenca.
- **Duración prevista:** 30–45 min reales.
- **Estado:** protocolo listo; la pasada y el veredicto son del responsable.
- **Manda:** [docs/06](../../../docs/06_estrategia_de_pruebas.md) §4.1–4.2 en la validación visual y de mundo abierto, y la [ficha de F3](../../../docs/fases/F3-vertical-slice.md) en los criterios de fase.

## 1. Qué se prueba

Que la slice **se juega**: que el arrabal se entiende sin marcadores, que los encargos y las secundarias tienen consecuencia, que la defensa se prepara con lo que se hizo antes y que la batalla se puede completar. No se evalúa arte final, equilibrio fino ni audio definitivo: eso pertenece a F4.

Lo que se comprueba:

1. **Orientación sin marcadores:** el diario, los NPC y los puntos de referencia bastan para encontrar cada sitio.
2. **Misión:** las tres etapas avanzan con lo que se hace en el mundo y no se atascan.
3. **Secundarias:** el turno del agua cambia conversaciones; la manta llega a la batalla.
4. **Descubrimiento:** el mirador de Carmenca se encuentra sin etiqueta y queda en el diario.
5. **Defensa:** las obras se construyen solo después de decidir quedarse y se leen en la batalla.
6. **Batalla:** tres oleadas, aliados, derrota que reinicia la oleada y estandarte como cierre.
7. **Persistencia:** dormir guarda; cargar conserva hora, posición, misión, diario, obras y NPC.
8. **Día y noche:** la luz cambia sin saltos y la antorcha se enciende al caer el sol.
9. **Rendimiento percibido:** sin tirones al cargar sectores ni en mitad de la oleada.

## 2. Preparación

Requisitos:

- Godot 4.7.2, Forward+, perfil **Medio** (el juego arranca así por defecto).
- Ventana a 1920 × 1080 o 1280 × 720, vsync libre.
- **Partida limpia.** «Continuar» toma la ranura automática del último guardado; si existe una partida de prueba anterior, se empieza con «Comenzar», que reinicia mundo, reloj y banderas.

```bash
godot --headless --path . --import
godot --path . --resolution 1920x1080 \
    res://campaigns/01_pachacutec/scenes/world/region_world.tscn
```

El jugador aparece en la plaza del arrabal de Chocos-chacona, a las 8:00, mirando a la plaza del Cusco.

Controles:

| Acción | Tecla |
|---|---|
| Andar | W A S D |
| Correr | Shift izquierdo |
| Saltar | Espacio |
| Hablar / interactuar / construir | E |
| Diario | J (Esc también lo cierra) |
| Atacar / cargar el golpe | Clic izquierdo |
| Bloquear / parar con el escudo | Clic derecho |
| Honda · porra · escudo | 1 · 2 · 3 |
| Salir | Cerrar la ventana |

`Esc` no abre un menú de pausa: solo cierra el diario.

Durante la prueba conviene anotar la hora del reloj en cada bloque: **1 hora de juego son 2 minutos reales**, y la partida empieza a las 8:00, así que el sol se pone hacia el minuto 20 de la sesión y la antorcha aparece de noche.

## 3. Recorrido cronometrado

| Min | Bloque | Qué se hace | Qué debe pasar |
|---|---|---|---|
| 0–4 | Arrabal y casa | Recorrer la plaza, entrar en «Tu casa», mirar el lecho y salir. | Puertas legibles; el interior se abre y se cierra sin teletransportes; la mano de interacción no tapa la vista. |
| 4–10 | Los tres encargos | Hablar con la curáca Chanan Cury Coca; aceptar agua, lana y maíz; cumplirlos en la pila, el atado del taller y el saco de los depósitos. | Cada encargo se acepta hablando y se cumple en su punto; la curáca cambia de conversación al terminar; el diario suma la etapa. |
| 10–16 | Secundarias | Volver a la molendera con el agua y decidir el turno (molienda, chacra o turnos). Llevar la lana a la tejedora y tejer la manta en el telar. | Las dos conversaciones cambian según lo decidido; la manta queda colgada y visible; el diario guarda una memoria por cada hilo. |
| 16–20 | La partida | Hablar otra vez con la curáca y decidir quedarse; mirar la columna de vecinos que sale al oeste. | Se cierra la etapa 1, se abre la 2, el aviso de la partida aparece una vez y la ciudad queda en fase de guerra. |
| 20–27 | El mirador | Salir del arrabal hacia el oeste y buscar el montón de piedras sobre Carmenca; asomarse al campamento de tiendas. | El lugar se descubre por cercanía, sin etiqueta ni marcador; el HUD avisa una vez y el diario recibe la memoria. |
| 27–32 | La defensa | Construir obras en los accesos del arrabal (E sobre el foso abierto). | Antes de quedarse el foso no responde; después se cubre con ramas y púas, y sigue construido al volver. |
| 32–42 | Carmenca | Acercarse al campamento con la etapa 3; combatir las tres oleadas; dejarse vencer una vez y volver; tomar el estandarte. | Dos chancas atacan a la vez y ninguno atraviesa al jugador; los aliados pelean a tu lado; la derrota reinicia la oleada; el estandarte cierra la misión. |
| 42–45 | Cierre | Abrir el diario (J), volver a casa, dormir para guardar, salir y cargar con «Continuar». | El diario conserva las etapas y las memorias; al cargar se conservan hora, posición, misión, obras y NPC. |

Ruta de referencia —no es un marcador del juego, es una ayuda para la prueba—:

```text
        plaza del Cusco (este)
                │
   casa ── ARRABAL ── pila del agua
  curáca ── plaza ─── taller (telar, lana)
                │           │
          depósitos (maíz)  │
                │           │
        camino al oeste ────┴──► mirador de Carmenca ──► campamento chanca
```

## 4. Registro de la pasada

Se rellena durante o justo después de jugar. Una fila por bloque.

| Min | Bloque | Bien / regular / mal | Observación |
|---|---|---|---|
| 0–4 | Arrabal y casa | | |
| 4–10 | Los tres encargos | | |
| 10–16 | Secundarias | | |
| 16–20 | La partida | | |
| 20–27 | El mirador | | |
| 27–32 | La defensa | | |
| 32–42 | Carmenca | | |
| 42–45 | Cierre | | |

Incidencias (bloqueos, caídas, textos cortados, FPS, errores en consola):

| # | Min | Qué pasó | Dónde | Repetible |
|---|---|---|---|---|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |

**Duración real de la pasada:** ______ min · **Perfil:** ______ · **Hora de juego al terminar:** ______

## 5. Qué no se prueba aquí

- **Arte final:** casas, personajes, campamento, estandarte y obras son blockout; el arte llega en F4.
- **Equilibrio fino:** 4, 6 y 8 chancas con 60 de salud y 6 aliados son números de bloqueo. Los aliados no mueren en la slice.
- **Guardado en mitad de la batalla:** por diseño vuelve al inicio de la oleada; no es un fallo.
- **Sonido definitivo:** la música y los ambientes son sustitutos declarados ([docs/07](../../../docs/07_convenciones_historicas.md) §4).
- **Textos finales:** la tabla de localización es de trabajo; las correcciones de estilo van al cierre de F4.

## 6. Cómo se cierra

La pasada alimenta el [acta de cierre de F3](../../../docs/fases/F3-acta-de-cierre.md). El acta no se firma sin:

1. esta tabla rellena;
2. las incidencias repetibles anotadas con su bloque;
3. la decisión del responsable: **continuar**, **recortar** o **replantear** ([docs/05](../../../docs/05_plan_de_implementacion.md) §Fase 3).
