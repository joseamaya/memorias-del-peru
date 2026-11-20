# Prueba humana del blockout — F2

- **Versión:** 0.2 — 2026-11-20
- **Ámbito:** recorrido a pie del blockout regional de la campaña 01.
- **Estado:** protocolo listo; el veredicto es del responsable.
- **Manda:** [docs/13](../../../../docs/13_pipeline_de_escenarios.md) en el pipeline, [docs/06](../../../../docs/06_estrategia_de_pruebas.md) §4.1 en la validación visual y la [ficha de F2](../../../../docs/fases/F2-geografia-y-blockout.md) en los criterios de fase.

## 1. Qué se prueba

Que el territorio se pueda **recorrer a pie**, a escala humana, sin bloqueos, sin pantallas de carga y sin que el blockout prometa algo que no existe. No se evalúa arte, materiales, NPC, interiores, combate ni interfaz: eso pertenece a F3 y fases posteriores.

El recorrido comprueba:

1. **Escala:** casas, puertas, plazas, caminos y pendientes se leen a 1,70 m.
2. **Continuidad:** se puede ir de la llacta al Cusco y al oeste sin quedar atrapado.
3. **Colisión:** el terreno sostiene al jugador; las casas y pircas bloquean; no se atraviesan volúmenes ni se cae al vacío.
4. **Streaming:** los sectores cargan y descargan a su alrededor sin tirones visibles ni pantallas.
5. **Lectura del territorio:** cada sector se reconoce por silueta y función; el camino lleva a algo.
6. **Cámaras de revisión:** `H` muestra la etiqueta más cercana y `T` alterna la vista cenital; no son la cámara de juego.

## 2. Preparación

Requisitos:

- Godot 4.7.2, Forward+, perfil **Medio**.
- Ventana a 1920 × 1080 o 1280 × 720; vsync libre.
- Estado de campaña limpio. Si se guardó una partida de prueba, borrar la ranura o usar otro nombre.
- No hace falta habilitar Terrain3D ni Cyclops en el editor: los addons ya están instalados y el blockout se carga convertido.

```bash
godot --headless --path . --import
godot --path . --resolution 1920x1080 \
    res://campaigns/01_pachacutec/scenes/world/region_world.tscn
```

El jugador aparece en R1, en el camino de entrada a la llacta, mirando a la plaza.

Controles:

| Acción | Tecla |
|---|---|
| Andar | W A S D |
| Correr | Shift izquierdo |
| Mirar | Ratón |
| Etiqueta de POI más cercana | H |
| Vista cenital de revisión | T |
| Salir | Cerrar la ventana |

`Esc` no abre un menú: el blockout no tiene pausa y la escena lo ignora.

## 3. Cómo orientarte sin brújula

El blockout no tiene brújula ni mapa en pantalla. La orientación sale del terreno y del camino:

```text
                         CUESTA ARRIBA
              quebrada → paso → frontera
                       \       /
                        \     /
              [ PLAZA DE LA LLACTA ]
                  /             \
    manantial, telar,             CUSCO
    corral, huerto               CUESTA ABAJO
```

Reglas:

1. **La plaza de la llacta es el centro.** Todas las dudas se resuelven volviendo a ella.
2. **Cuesta abajo = Cusco.** El camino se ensancha, pasa junto a las terrazas y termina en la plaza grande del Cusco, con el Coricancha y el mercado.
3. **Cuesta arriba = quebrada → paso → frontera.** El camino sube, pasa junto al arroyo y el salto de agua, luego el zigzag y la nieve, y después el bofedal y el campamento.
4. **Alrededor de la plaza = vida de la llacta:** manantial, telar, corral, huerto y fogón.
5. **`H`:** muestra la etiqueta del POI más cercano. Úsalo para confirmar dónde estás.
6. **`T`:** vista cenital de revisión. Sirve para orientarte, no para caminar; pulsa otra vez para volver a la vista normal.
7. **Río y acequias:** el río es la cinta azul **ancha** que cruza el valle; las acequias son canales **estrechos** junto a la llacta y el Cusco. Si ves una línea azul fina, es una acequia; el río es el que tiene orilla de tierra.
8. **Marcadores de revisión:** los conos verdes solo existen en el modo de revisión (`first_person = false`). En la partida a pie no deben verse ni tapar el camino.
9. **Terrazas y plataformas:** si una terraza tiene cara vertical, no se atraviesa. La plataforma del Coricancha se sube por su rampa; el borde no se cruza.

Al aparecer: **la plaza está delante**; el Cusco queda **a tu espalda, cuesta abajo**; la quebrada, **al otro lado de la plaza, cuesta arriba**.

## 4. Ruta A — Núcleo (20–30 min)

Objetivo: validar la llacta (S3), las afueras (S2) y el Cusco (S1).

1. **Aparición:** camina recto hasta la plaza. No gires. Comprueba la escala de una puerta frente a tu personaje.
2. **Plaza de la llacta:** rodéala. Comprueba el borde y que no hay un muro invisible. Usa `H` para reconocer los POI.
3. **Alrededor de la plaza:** manantial, telar, corral y huerto. Vuelve a la plaza al terminar.
4. **Cusco:** vuelve por el mismo camino por el que llegaste, date la vuelta y sigue **cuesta abajo**. Pasa junto a las terrazas; al llegar, busca la plaza grande, el Coricancha y el mercado. Si el camino se acerca al río, es la variante del río y también lleva al Cusco.
5. **Regreso:** vuelve por el mismo camino o por el camino del río (junto al agua). Anota si el atajo se lee o si te pierdes.

Si te desvías y no ves la plaza, `T` y vuelve a la cinta marrón del camino.

## 5. Ruta B — Región completa (30–40 min, opcional)

Objetivo: validar además la quebrada (S4), el paso (S5) y la frontera (S6).

1. **Desde la plaza, toma el camino que sube**, dejando el Cusco a tu espalda.
2. **Quebrada alta:** sigue el arroyo. Verás terrazas de papa, queñua, salto de agua, cueva y cantera.
3. **Paso:** continúa por el zigzag. Verás nieve, el refugio de pirca, el mirador y el altar.
4. **Frontera:** baja al bofedal. Verás el tambo, las marcas de piedra, el campamento, el puesto y el campo de batalla.
5. **Vuelta:** por el mismo camino o por la ruta oculta si la encuentras. Comprueba que la vuelta no depende de un marcador.

Si el tiempo no alcanza, la ruta A es la mínima para aprobar el blockout; la ruta B se puede repetir en otra sesión.

## 6. Mapa de bolsillo

| Destino | Desde la plaza | Qué ves | Etiqueta `H` |
|---|---|---|---|
| Cusco (S1/S2) | el camino que baja y se ensancha | terrazas, plaza grande, Coricancha, mercado | POI-17, POI-18, POI-19 |
| Quebrada (S4) | el camino que sube | arroyo, salto, queñua, terrazas de papa | POI-10, POI-11, POI-13, POI-14, POI-25 |
| Paso (S5) | sigue el camino de la quebrada | zigzag, nieve, refugio, mirador, altar | POI-23, POI-24, POI-30 |
| Frontera (S6) | sigue el paso y baja | bofedal, tambo, marcas, campamento, campo | POI-26, POI-27, POI-28, POI-29 |
| Llacta (S3) | rodea la plaza | manantial, telar, corral, huerto, fogón | POI-01 a POI-08, POI-10 |

Tiempos aproximados: plaza en 1–2 min desde la aparición; Cusco en 10–15 min desde la plaza; quebrada en 12–15 min; paso y frontera, 20–30 min más. Son referencias, no cronómetros.

## 7. Qué mirar en cada sector

| Sector | Qué debe leerse | Qué invalida la aprobación |
|---|---|---|
| S3 Llacta | Plaza, casas, manantial, telar, corral y huerto; el camino como espina | Una casa tapa la salida, el jugador atraviesa un volumen o la plaza encierra la cámara |
| S2 Afueras | Terrazas, vado y transición urbano-rural | El camino se corta, flota o no lleva a ningún sitio |
| S1 Cusco | Plaza, Coricancha, ayllus, mercado y talleres; densidad urbana | Callejones impracticables, escala de recinto irreconocible, repetición de casas sin jerarquía |
| S4 Quebrada | Pendiente, agua, cueva y cantera; densidad baja | El agua o la pendiente bloquean sin alternativa; la cueva no se puede visitar |
| S5 Paso | Zigzag, refugio, mirador y altar; cuello de botella | El zigzag no se puede subir o el mirador no mira al valle |
| S6 Frontera | Bofedal, tambo, campamento, puesto y campo; conflicto | El campamento no se lee, el bofedal no se puede cruzar o el límite natural no se entiende |

Comprobar también:

- **Horizonte:** las cumbres y el fondo no prometen un lugar recorrible.
- **Siluetas:** S1, S3 y S5 se distinguen desde lejos.
- **Caminos:** salen de la plaza, llevan a un POI y no hay decorado a menos de 3 m.
- **Streaming:** al cruzar de sector no aparece una pantalla, no se vacía el mundo y no hay un tirón largo.
- **Rescate:** si se fuerza una caída, el jugador vuelve al punto de aparición.

## 8. Si te pierdes

1. Detente y pulsa `T`.
2. Busca la cinta marrón del camino y la plaza de la llacta.
3. Vuelve a la plaza.
4. Pulsa `H`: la etiqueta más cercana te dice dónde estás.
5. Si sigues perdido: cuesta abajo es Cusco; cuesta arriba es quebrada, paso y frontera.

## 9. Registro de incidencias

Anotar una fila por incidencia. Sin captura, la incidencia se puede reproducir pero no se puede defender.

| # | Sector | Hora | Tipo | Severidad | Qué pasó | Dónde | Evidencia |
|---|---|---|---|---|---|---|---|
| 1 |  |  | bloqueo / colisión / escala / streaming / lectura | bloqueante / mayor / menor |  | referencia visual (plaza, camino, POI) | captura o vídeo |

Severidades:

- **Bloqueante:** impide terminar la ruta o atravesar un sector.
- **Mayor:** rompe la lectura del territorio o la escala, pero se puede seguir.
- **Menor:** detalle de blockout que no impide jugar.

## 10. Evidencia

Capturas de trabajo (van a `build/evidencia/`, ignorado por Git):

```bash
godot --path . --resolution 1280x720 res://tests/scenes/capture_player.tscn
godot --path . --resolution 1280x720 res://tests/scenes/capture_region.tscn
godot --path . --resolution 1280x720 res://tests/scenes/capture_review.tscn
godot --path . --resolution 1280x720 res://tests/scenes/capture_llacta_blockout.tscn
godot --path . --resolution 1280x720 res://tests/scenes/capture_cusco_blockout.tscn
godot --path . --resolution 1280x720 res://tests/scenes/capture_west.tscn
```

Tomas mínimas:

1. Aparición en R1.
2. Plaza de la llacta desde el camino.
3. Cusco desde la entrada y el Coricancha.
4. Quebrada, paso y frontera desde el camino.
5. Vista cenital de la región.

Las capturas aprobadas se copian a `documentation/img/f2_blockout/` y se enlazan desde la ficha de F2. Las de trabajo pueden quedar en `build/`.

## 11. Veredicto

El responsable marca una casilla y firma:

- [ ] **Aprobado:** el blockout se puede usar como base de F3.
- [ ] **Aprobado con cambios:** se corrige la lista de incidencias y se repite solo la ruta afectada.
- [ ] **Rechazado:** el territorio no se lee o no se recorre; se replantea antes de producir arte.

| Campo | Valor |
|---|---|
| Fecha |  |
| Perfil y resolución |  |
| Ruta recorrida | A / B |
| Duración real |  |
| Incidencias bloqueantes |  |
| Incidencias mayores |  |
| Incidencias menores |  |
| Veredicto |  |
| Observaciones |  |

## 12. Fuera de alcance

No se evalúan en esta prueba: materiales y texturas definitivas, arquitectura final, interiores transitables, NPC y rutinas, multitud, inventario, interacción, combate, audio, clima, día/noche ni interfaz de diario/mapa. El blockout usa volúmenes grises y etiquetas de revisión a propósito.

## 13. Criterio de cierre de F2

F2 se cierra cuando la ruta A (o la B) se completa sin incidencias bloqueantes, las mayores están corregidas o aceptadas por el responsable y el veredicto queda registrado en la [ficha de F2](../../../../docs/fases/F2-geografia-y-blockout.md) y en la [bitácora](../../../../docs/bitacora.md).
