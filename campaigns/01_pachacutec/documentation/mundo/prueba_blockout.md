# Prueba humana del blockout — F2

- **Versión:** 0.1 — 2026-11-20
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

## 3. Rutas

### Ruta A — Núcleo (20–30 min)

Objetivo: validar S3, S2 y S1 y el camino principal.

1. **Aparición (S3):** mirar la plaza, las casas y el camino. Comprobar que la puerta de una casa y el jugador tienen la misma escala.
2. **Plaza de la llacta:** rodearla; comprobar el borde, las cuatro salidas y que no hay un muro invisible.
3. **Manantial, telar, corral y huerto:** recorrerlos sin atajos; comprobar que el terreno no tiene escalones que atrapen.
4. **R1 hacia el este (S2):** seguir el camino principal hasta las terrazas y el vado. Comprobar que el camino se apoya en el relieve y que no hay props a menos de 3 m.
5. **Cusco preimperial (S1):** entrar por la plaza, rodear el Coricancha, el mercado y los talleres. Comprobar la escala del recinto y de los callejones.
6. **Regreso:** volver por R3 (ruta del río) o por R1. Anotar si el atajo se lee o si se pierde.

### Ruta B — Región completa (30–40 min, opcional)

Objetivo: validar S4, S5 y S6 además de la ruta A.

1. Completar la ruta A hasta el Cusco.
2. Continuar al oeste por R2: **quebrada alta (S4)** — terrazas de papa, queñua, salto de agua, cueva y cantera.
3. Subir al **paso (S5)**: zigzag, refugio de pirca, mirador y altar.
4. Bajar a la **frontera chanca (S6)**: bofedal, tambo, marcas, campamento, puesto y campo de batalla.
5. Volver por R2 o por R5. Comprobar que la vuelta no depende de un marcador.

Si el tiempo no alcanza, la ruta A es la mínima para aprobar el blockout; la ruta B se puede repetir en otra sesión.

## 4. Qué mirar en cada sector

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

## 5. Registro de incidencias

Anotar una fila por incidencia. Sin captura, la incidencia se puede reproducir pero no se puede defender.

| # | Sector | Hora | Tipo | Severidad | Qué pasó | Dónde | Evidencia |
|---|---|---|---|---|---|---|---|
| 1 |  |  | bloqueo / colisión / escala / streaming / lectura | bloqueante / mayor / menor |  | coordenadas o referencia visual | captura o vídeo |

Severidades:

- **Bloqueante:** impide terminar la ruta o atravesar un sector.
- **Mayor:** rompe la lectura del territorio o la escala, pero se puede seguir.
- **Menor:** detalle de blockout que no impide jugar.

## 6. Evidencia

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
3. Cusco desde la entrada.
4. Quebrada, paso y frontera desde el camino.
5. Vista cenital de la región.

Las capturas aprobadas se copian a `documentation/img/f2_blockout/` y se enlazan desde la ficha de F2. Las de trabajo pueden quedar en `build/`.

## 7. Veredicto

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

## 8. Fuera de alcance

No se evalúan en esta prueba: materiales y texturas definitivas, arquitectura final, interiores transitables, NPC y rutinas, multitud, inventario, interacción, combate, audio, clima, día/noche ni interfaz de diario/mapa. El blockout usa volúmenes grises y etiquetas de revisión a propósito.

## 9. Criterio de cierre de F2

F2 se cierra cuando la ruta A (o la B) se completa sin incidencias bloqueantes, las mayores están corregidas o aceptadas por el responsable y el veredicto queda registrado en la [ficha de F2](../../../../docs/fases/F2-geografia-y-blockout.md) y en la [bitácora](../../../../docs/bitacora.md).
