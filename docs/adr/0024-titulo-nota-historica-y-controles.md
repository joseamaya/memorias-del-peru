# ADR-0024 — Pantalla de título, nota histórica y controles en pantalla

- Estado: Aceptado (pedido por el responsable del proyecto el 2026-11-12; textos pendientes de su aprobación, ver Consecuencias)
- Fecha: 2026-11-12
- Amplía: [ADR-0023](0023-introduccion-del-slice.md) (introducción del slice)
- Aplica: [docs/05](../05_plan_de_implementacion.md), «Escena principal»: la escena principal pasa a ser una escena de `core/`

## Contexto

Tras ADR-0023, el juego arranca directamente en las tarjetas de la introducción. Se comparó el arranque con juegos parecidos (2026-11-12):

- **Attentat 1942** (juego educativo hecho con historiadores): pantalla de título y prólogo que expone el contexto histórico real en el que se apoya la ficción.
- **Never Alone (Kisima Ingitchuna):** menú sencillo y un narrador de la comunidad que abre la historia.
- **Assassin's Creed:** aviso inicial de que la obra se inspira en hechos y personajes históricos.
- **Gone Home:** los controles de caminar y mirar aparecen en pantalla al empezar, sin tutorial.
- Consejo general de diseño: la pantalla de título fija el tono, pero quien juega por primera vez no debe pasar por varias capas de menús.

Faltan tres piezas habituales:

1. el nombre del juego;
2. una nota sobre la base histórica, que docs/07 §1 ya pide («distingue entre lo documentado y lo interpretado… para el jugador cuando sea pertinente»);
3. los controles, que hoy solo explica el facilitador en las sesiones.

## Opciones consideradas

1. **Menú completo** (opciones, créditos, selector de campañas). Rechazada: el selector y las opciones no los necesita el slice y serían sistemas de fases futuras (AGENTS.md §3).
2. **Título como tarjeta más de la introducción**, sin escena de menú. Rechazada: el título seguiría dentro de la campaña, y docs/05 ya prevé que el punto de entrada sea una escena de `core/`.
3. **Pantalla de título mínima en `core/`** (Comenzar y Salir), nota histórica como primera tarjeta y controles en el HUD al tomar el control. Aceptada.

## Decisión

### 1. Pantalla de título (`core/ui/title_screen.tscn`)

- Muestra el nombre del juego, el subtítulo de la campaña y dos botones: **Comenzar** y **Salir**. Comenzar tiene el foco, así que Intro también empieza.
- Es la escena principal (`application/run/main_scene`), como prevé docs/05.
- **Sin dependencia de `campaigns/`:** la campaña se describe con un recurso `CampaignInfo` (clase de `core/`), con su escena de entrada y la clave de su subtítulo. La pantalla de título lee la ruta de ese recurso del ajuste de proyecto `memorias/campaign/first`. Cambiar de campaña es configuración, no código.
- Esc en la pantalla de título no pausa nada. Salir pasa por `GameManager.request_quit()`.
- Al pulsar Comenzar se cambia a la escena de la campaña, que es entonces la escena principal: la introducción de ADR-0023 se muestra igual que antes. R al final sigue reiniciando el fragmento, no vuelve al título.

### 2. Nota histórica

Es la primera tarjeta de la introducción, antes de las tres de ADR-0023:

| Clave | Texto | Clasificación |
|---|---|---|
| `PCH_INTRO_NOTE` | Esta historia se basa en crónicas coloniales y en la arqueología. Algunos elementos son reconstrucción o licencia narrativa. | N (texto de diseño; aplica docs/07 §1) |

### 3. Controles en pantalla

- Al terminar la introducción, el HUD muestra durante 8 s, con fundidos, la clave de `core/` `UI_CONTROLS_HINT`: «WASD moverse · Ratón mirar · Mayús correr · Espacio saltar · E interactuar · Esc pausa».
- Se queda en el HUD de `core/`, que no conoce la campaña; la campaña solo decide cuándo mostrarlo.

### 4. Textos de la pantalla de título

| Clave | Dónde | Texto |
|---|---|---|
| `UI_GAME_TITLE` | `core/` | Memorias del Perú |
| `UI_START` | `core/` | Comenzar |
| `UI_QUIT` | `core/` | Salir |
| `PCH_CAMPAIGN_SUBTITLE` | campaña | Una mañana en la llacta |

El subtítulo no nombra a Pachacútec ni a los chancas, para no acercar al jugador a las preguntas 1 y 2 del cuestionario (alcance §9.3).

## Consecuencias

- **docs/05:** la tabla «Escena principal» se cumple con la pantalla de título. El sandbox sigue disponible como escena de prueba.
- **Pruebas:**
  - `test_main_scene_is_world` pasa a `test_main_scene_is_title`: la escena principal es la de `core/` y la campaña configurada lleva al mundo base;
  - pantalla de título (textos traducidos, foco en Comenzar, recurso de campaña válido);
  - ayuda de controles en el HUD (aparece y se oculta);
  - introducción con cuatro tarjetas, sin palabras que adelanten la noticia, y controles a la vista al terminar.
- **Alcance v4.6** (§2.2, §6.4 y §10) y **guion del facilitador**: la sesión empieza en la pantalla de título. El facilitador explica los controles como hasta ahora, y la persona pulsa Comenzar.
- **Duración:** la nota suma unos 10 s a la introducción.
- **Textos:** el responsable del proyecto debe aprobar la nota histórica, el subtítulo y la línea de controles. Si cambian, basta con editar las tablas de localización.
