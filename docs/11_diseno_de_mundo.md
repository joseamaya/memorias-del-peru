# 11 — Diseño de mundo abierto (GDD)

- **Versión:** 1.0 — 2026-11-19
- **Ámbito:** diseño del producto y de cada región; no fija fases ni pruebas.
- **Marco:** [visión](01_vision_y_alcance.md), [arquitectura](02_arquitectura.md), [biblia narrativa](09_biblia_narrativa.md), [campañas](12_campanas.md) y [pipeline](13_pipeline_de_escenarios.md).
- **Estado:** aprobada para F1–F2; los números de rendimiento y escala se validan en F1–F3.

## 1. Concepto

**Memorias del Perú** es una antología de cuatro RPG históricos de **mundo abierto regional** en primera persona. El jugador vive un periodo histórico desde la perspectiva de una persona común, en un territorio continuo que puede recorrer, habitar y recordar.

“Mundo abierto regional” no significa mapa gigante. Significa:

- Un territorio continuo con **2–4 km² de área densa** por campaña y hasta ~8 km² incluyendo wilderness.
- Una comunidad principal y varios núcleos secundarios.
- Caminos, campos, ríos, quebradas, montañas y zonas de conflicto.
- NPC con rutinas, oficios y memoria.
- Contenido principal y contenido que existe sin misión.
- Progresión personal, no poder militar.

El territorio y sus habitantes existen **más allá de la misión activa**. El jugador puede salir de su comunidad, tomar otro camino, encontrar a alguien, descubrir un lugar, participar en una actividad, conocer una historia y volver a casa.

## 2. Pilares y anti-pilares

| Pilar | Regla práctica |
|---|---|
| Territorio primero | Cada sector tiene una función, un contenido y una silueta reconocible |
| Vida cotidiana | Trabajo, comida, descanso, reciprocidad y relaciones tienen mecánica |
| Historia desde abajo | El protagonista no sustituye a los grandes personajes; el resultado histórico no cambia |
| Consecuencia y memoria | El mundo guarda y muestra lo que el jugador hizo |
| Densidad, no escala | Si un área no tiene nada que hacer o descubrir, se reduce |
| Legibilidad y rendimiento | 30 FPS en Bajo y 60 en Medio en la GPU integrada de referencia |

**Anti-pilares:** mapas enormes vacíos, marcadores flotantes como única guía, simulación compleja para todos los NPC, crafting profundo, loot aleatorio, niveles/XP, magia, cuatro campañas a la vez.

### 2.1. Decisiones cerradas

| Decisión | Valor aprobado |
|---|---|
| Duración | 6–8 h de historia principal; 8–12 h con contenido secundario |
| Región | 2–4 km² de área densa; hasta ~8 km² con wilderness |
| Campaña 01 | 3,5 × 2,5 km totales; seis sectores |
| Portada | Cuatro campañas visibles; solo la 01 jugable hasta su fase |
| Inventario | 16 huecos + 3 equipados + almacenamiento en casa |
| Habilidades | Honda, Mano, Palabra, Oficio y Monte, 0–5 por uso |
| Combate | Contextual, con opciones de disuasión y huida |
| Guardado | Completo, versionado y con autoguardado en hitos |
| Día/noche | Día de 48 min reales por defecto |
| Rendimiento | ≥ 30 FPS Bajo y ≥ 60 FPS Medio en UHD 770 |
| Campaña III | Ayacucho–Huanta–Cangallo como hipótesis principal, sujeta a expediente |
| Campaña IV | Mantaro; Huamachuco como epílogo narrado o secuencia final |
| Addons | Terrain3D y Cyclops solo tras spikes de F1 |

## 3. Bucles

### 3.1. Bucle de 1–3 minutos

Caminar, observar, orientarse, interactuar, conversar, trabajar, recoger, leer el diario.

### 3.2. Bucle de 20–40 minutos

Salir de la comunidad, recorrer un camino, llegar a un lugar, resolver un encargo o descubrir una historia, volver o acampar.

### 3.3. Bucle de sesión (45–90 minutos)

Un día de juego, una misión principal o dos secundarias, un descubrimiento, una actividad económica, descanso y guardado.

### 3.4. Bucle de campaña

Fases históricas que transforman el mismo territorio. La historia principal avanza; el mundo sigue ofreciendo vida cotidiana antes, durante y después del clímax.

## 4. Estructura del mundo

### 4.1. Escala

| Parámetro | Campaña 01 | Vertical slice |
|---|---|---|
| Región total | 3,5 × 2,5 km (8,75 km²) | 0,4–0,5 × 0,4–0,5 km (0,16–0,25 km²) |
| Área densa | 2–4 km² | 0,16–0,25 km² |
| Sector exterior | 256–512 m | 256 m |
| Tiempo de cruce | 25–35 min a pie; 12–18 min corriendo | 4–6 min a pie |
| POI | 20–30 | 6–8 |
| NPC persistentes | 60–100 | 20–30 |
| NPC ambiente | 80–150 | 20–40 |

### 4.2. Composición

```text
Región
├── Sectores exteriores (streaming)
│   ├── Núcleo urbano / comunidad principal
│   ├── Campos y terrazas
│   ├── Quebradas y recursos
│   ├── Paso / frontera
│   └── Zonas de conflicto
├── Interiores (carga aditiva)
├── Red de caminos
└── Fondo visual no recorrible (cordilleras, valles lejanos)
```

### 4.3. Reglas de composición

1. **El camino es la espina:** los caminos conectan comunidades, campos y pasos; no son decoración.
2. **Cada sector tiene una función:** residencial, agrícola, ritual, defensiva, de paso o de conflicto.
3. **Límites con significado:** ríos, pircas, acantilados, bosques, nieve, controles militares.
4. **Síntesis visual:** cada sector se reconoce desde lejos por silueta, color y sonido.
5. **Contenido antes que geometría:** no se construye terreno sin saber qué experiencias alberga.
6. **Densidad sobre extensión:** se recorta el área antes que el contenido.

### 4.4. Travesía

- Sin pantallas de carga entre sectores exteriores.
- Interiores con carga aditiva breve (< 0,5 s) y retorno a la puerta.
- Sin viaje rápido en la primera versión; las rutas conocidas son contenido.
- El jugador se orienta por hitos, caminos, indicaciones y el mapa del diario.
- El clima y la hora cambian el coste y el riesgo del viaje.

## 5. Tiempo y clima

| Parámetro | Propuesta |
|---|---|
| Escala | 1 hora de juego = 2 minutos reales (día = 48 min) |
| Amanecer / atardecer | Ventanas de luz y rutinas de NPC |
| Descanso | Dormir en casa, tambo o campamento; salta a la mañana |
| Clima | Claro, nublado, lluvia y niebla de altura; sin simulación meteorológica compleja |
| Consecuencia | Rutinas, visibilidad, caminos, ánimo y disponibilidad de recursos |

El reloj es un sistema de Core (`WorldClock`) y no conoce campañas. Las campañas declaran sus horarios y eventos.

## 6. Jugador

### 6.1. Movimiento y cámara

Se conserva `PlayerFPS`: caminar, correr, cámara, balanceo, pasos por superficie, interacción por rayo y encuadre de diálogo. Se añaden:

- Cansancio por terreno y altitud (sin barra de hambre).
- Descanso y comida como recuperación de ánimo/aliento.
- Orientación y mapa del diario.
- Opciones de accesibilidad de cámara y movimiento.

### 6.2. Habilidades

| Habilidad | Uso | Desbloquea |
|---|---|---|
| Honda | Caza, disuasión, combate | Precisión, carga, alcance |
| Mano | Trabajo manual, artesanía, combate | Reparar, tejer, moldear, bloquear |
| Palabra | Negociar, mediar, persuadir | Opciones, rumores, asambleas |
| Oficio | Agricultura, construcción, oficios | Encargos, reparaciones, producción |
| Monte | Caminar, orientarse, cargar, esquivar | Rutas, clima, sigilo, resistencia |

- Progresión por uso, de 0 a 5.
- Sin XP global ni niveles.
- Las habilidades abren **acciones y opciones**, no solo números.
- El conocimiento del territorio se registra como descubrimientos, no como estadística.

### 6.3. Salud, aliento y ánimo

- Salud 0–100; sin regeneración automática en combate.
- Aliento para correr, cargar, bloquear y trabajar.
- Ánimo para diálogo, miedo y resistencia; baja con violencia, hambre y pérdida; sube con descanso, comida, comunidad y logros.
- Sin barras permanentes: viñeta, respiración, postura y sonido.

### 6.4. Inventario y economía

- 16 huecos + 3 equipados + almacenamiento en casa (`q'ipi`).
- Sin peso ni loot aleatorio.
- Trueque y reciprocidad; moneda solo cuando la época la justifica.
- Precios y disponibilidad dependen de estación, fase histórica y reputación.
- Los objetos tienen uso social y económico, no solo valor de combate.

### 6.5. Reputación y relaciones

- Reputación por comunidad/ayllu/facción, de −2 a +2.
- Relación individual con NPC nombrados, de 0 a 5.
- Las decisiones cambian acceso, precios, diálogo, ayuda y variantes de escena.
- La reputación no es una barra única: un aliado en la llacta puede ser un extraño en el Cusco.

### 6.6. Accesibilidad

- Subtítulos con tamaño, fondo y tiempo de lectura ajustables.
- Texto de interfaz escalable; contraste alto y alternativa al color.
- Sensibilidad de cámara, FOV, balanceo y movimiento reducido.
- Opción de guía de objetivo para quien no quiera orientarse por hitos.
- Remapeo de teclas y alternativa a mantener pulsado.
- Avisos visuales y sonoros para interacciones y peligro.
- Sin información esencial que dependa solo del color o del audio.
- Pausa real en todo momento, también en diálogos.

### 6.7. Ejemplo de progresión

El jugador empieza con Honda 0, Mano 1, Palabra 1, Oficio 1 y Monte 1. Acarrear agua y subir terrazas sube Monte; moler maíz y reparar una pirca suben Oficio; una conversación difícil sube Palabra. Las habilidades no dan niveles ni puntos: abren opciones de diálogo, trabajos, rutas y formas de resolver un encuentro. Un jugador puede terminar la campaña con Honda baja si evita el combate; el mundo debe permitirlo.

## 7. NPC

### 7.1. Niveles de simulación

| Nivel | Cantidad | Simulación | Persistencia |
|---|---|---|---|
| A — narrativos | 15–20 por región | Horario completo, navegación, interiores, diálogo, relaciones | Completa |
| B — comunidad | 40–60 | Horario por anclas, movimiento simple, sin diálogo profundo | Estado y ubicación |
| C — ambiente | 80–150 | Multitud, animación LOD, sin colisión lejana | Ninguna |

**Validado en F1:** el `NpcDirector` mantiene el presupuesto de 60 activos y 25 animados con histéresis; los tier B se descargan al alejarse y los narrativos no. La animación de F1 es un marcador hasta que lleguen los personajes de F2.

### 7.2. Rutinas

Cada NPC tier A/B declara:

- Casa, trabajo y anclas sociales.
- Horario por franjas: amanecer, mañana, mediodía, tarde, noche.
- Actividad: dormir, comer, trabajar, conversar, rezar, vigilar, viajar.
- Condiciones: día, clima, fase histórica, evento, relación.
- Excepciones: fiesta, mercado, alarma, duelo, guerra.

### 7.3. Reacciones

- Saludo y reconocimiento por nombre si la relación lo permite.
- Reacción a reputación, acontecimientos recientes y estado de misión.
- Comentarios breves (“bark”) con límite de frecuencia; no repetir en bucle.
- Miedo, evitación o ayuda según el contexto.
- Los NPC importantes recuerdan al jugador después de guardar/cargar.

### 7.4. Reglas de rendimiento

- 60 Hz solo para el jugador y los NPC cercanos.
- 1–10 Hz para lógica de horario y eventos.
- Fuera de sector: solo estado; al volver, se coloca en su ancla.
- Máximo de animados visibles y de sombras por sector, medido.
- La multitud no proyecta sombra completa ni usa diálogo profundo.

### 7.5. Ejemplo de horario

Un NPC narrativo puede tener:

| Franja | Ancla | Actividad | Condición |
|---|---|---|---|
| 05:00–07:00 | casa | despertar, desayunar | — |
| 07:00–12:00 | campo | trabajar | fase 0–1 |
| 12:00–14:00 | plaza | comer, conversar | — |
| 14:00–18:00 | campo | trabajar | fase 0–1 |
| 18:00–21:00 | casa | cenar, tejer | — |
| 21:00–05:00 | casa | dormir | — |

En fase de guerra, las franjas de campo se sustituyen por refugio o vigilancia. El horario se interrumpe por una secuencia controlada y se reanuda después; el NPC no desaparece ni reinicia su día.

## 8. Misiones y contenido

### 8.1. Tipos

| Tipo | Cantidad por campaña | Diseño |
|---|---|---|
| Historia principal | 12–16 | Fases históricas, decisiones, secuencias controladas |
| Historias secundarias | 15–20 | Nacen de personas y lugares; 10–20 min |
| Encargos cotidianos | 8–12 | Repetibles pero limitados; economía y reciprocidad |
| Descubrimientos | 20–30 | Sin marca previa; diario y mapa |
| Acontecimientos | 10–15 | Disparados por tiempo, lugar o bandera |

### 8.2. Reglas

- Ninguna misión es solo “ve a X y recoge Y”.
- Toda misión tiene contexto, conflicto, decisión y consecuencia.
- Las misiones principales no dependen de marcadores flotantes.
- Las indicaciones son de persona a persona, con hitos y rutas.
- El diario registra encargos, descubrimientos, personas, lugares y memoria histórica.
- Las secuencias controladas se reservan para asambleas, batallas, sueños y clímax.

### 8.3. Mapa y orientación

- Mapa diegético en el diario, dibujado al descubrir.
- Sin GPS ni iconos flotantes.
- Modo “guía” opcional para accesibilidad: resalta el objetivo activo, sin sustituir la exploración.
- La niebla de guerra no oculta el mundo: oculta nombres y detalles no descubiertos.

### 8.4. Contenido por fase (campaña 01)

| Fase | Principal | Secundarias | Encargos | POI nuevos | Acontecimientos |
|---|---|---|---|---|---|
| Paz | 3 | 5 | 8 | 10 | 3 |
| Noticia | 4 | 4 | 2 | 5 | 3 |
| Guerra | 3 | 3 | 1 | 4 | 2 |
| Posguerra | 3 | 4 | 1 | 4 | 2 |
| Obra | 2 | 3 | 1 | 2 | 1 |
| **Total** | **15** | **19** | **13** | **25** | **11** |

El catálogo de la campaña 01 tiene 30 POI; la columna «POI nuevos» cuenta los que se activan por primera vez en cada fase. Los números son objetivos de producción, no una cuota rígida. Si una fase no necesita una secundaria, se recorta antes que rellenarla. Los POI se reparten entre los seis sectores y no todos se marcan.

## 9. Combate

- Contextual y poco frecuente; no es el bucle principal.
- Honda, porra y escudo como base; opciones de disuasión, huida y no violencia.
- Enemigos con moral; sin barras flotantes.
- La guerra se representa desde la perspectiva de una persona común.
- Encuentros authored o disparados por el mundo; no spawn aleatorio por todas partes.
- El combate no cambia el resultado histórico.

## 10. Consecuencias y persistencia

| Estado | Se guarda | Ejemplo |
|---|---|---|
| Mundo | Fase histórica, hora, clima, banderas | `fase_guerra`, `dia_3`, `lluvia` |
| NPC | Vida, ubicación, relación, estado | `sisa_relacion_3`, `anca_herido` |
| Misiones | Etapa, decisiones, objetos | `mensajero_ayudado` |
| Descubrimientos | POI, nombres, rumores | `mirador_descubierto` |
| Mundo físico | Contenedores, puertas, reparaciones | `corral_reparado` |
| Jugador | Posición, inventario, habilidades, salud | `qipi_casa` |

- IDs estables, nunca rutas de nodo.
- Guardado versionado, escritura atómica y migraciones.
- Autoguardado al dormir, cambiar de fase o entrar/salir de un sector seguro.
- Guardado manual fuera de combate.

### 10.1. Experiencia de guardado

- Guardado manual desde la pausa, fuera de combate y de secuencias controladas.
- Autoguardado al dormir, al cambiar de fase y al entrar o salir de un sector seguro.
- Tres ranuras manuales + autoguardado por campaña.
- La pantalla de carga muestra lugar, día y hora, no una barra genérica.
- Si una partida no se puede cargar por versión, se conserva el archivo y se avisa; nunca se borra en silencio.
- El guardado no se usa para castigar: morir recarga el último punto seguro, no reinicia la campaña.

## 11. Interfaz

- HUD mínimo: interacción contextual, salud y aliento solo cuando importan, subtítulos y rótulo de lugar.
- Diario: encargos, descubrimientos, personas, lugares y memoria histórica.
- Mapa diegético; sin minimapa permanente.
- Pausa con opciones, guardado y accesibilidad.
- Textos legibles a 1080p; alto contraste; sin información que dependa solo del color.

### 11.1. Pantallas

| Pantalla | Contenido | Regla |
|---|---|---|
| Portada | Cuatro campañas, solo la 01 jugable | Las otras indican “en diseño” |
| Pausa | Continuar, guardar, opciones, salir | No hay menús anidados innecesarios |
| Diario | Encargos, descubrimientos, personas, lugares, memoria | Navegable con teclado y puntero |
| Mapa | Descubierto, sin GPS; modo guía opcional | No revela lo no visitado |
| Guardado | Ranuras, fecha, lugar, hora | Confirmación antes de sobrescribir |
| Opciones | Gráficos, audio, controles, accesibilidad | Cambios aplicados sin reiniciar |

## 12. Arte y audio

- Low poly detallado con luz de altura; piedra, adobe, ichu, tierra y tejido.
- Cada campaña tiene paleta, arquitectura, sonido y música propios.
- Nada de formas o materiales de otra época sin declararlo.
- Ambiente por región y hora; audio posicional para oficios y multitud.
- La música no tapa el ambiente; se usa en transiciones y momentos.
- Medir niveles antes de escuchar; sin clips ni efectos casi mudos.

### 12.1. Audio

- Ambiente por región, hora y clima: viento, agua, aves, mercado, taller.
- Pasos por superficie; el jugador y los NPC comparten bancos de sonido, no el mismo volumen.
- Audio posicional para oficios, animales y multitud; sin saturación.
- La música se usa en transiciones, clímax y cierre; no compite con el ambiente.
- Medir antes de escuchar: picos por debajo de −0,5 dBFS, sin clips ni efectos casi mudos.
- Los anacronismos sonoros se declaran en la ficha de la campaña.

## 13. Rendimiento

| Métrica | Presupuesto |
|---|---|
| FPS | ≥ 30 en Bajo; ≥ 60 en Medio, 1080p, UHD 770 |
| Draw calls por sector | ≤ 350 en el peor caso |
| Primitivas | ≤ 1,2 M |
| VRAM | ≤ 250 MB |
| NPC activos | ≤ 60; animados ≤ 25 |
| Distancia de sombras | 40–60 m, selectiva |
| Carga de sector | < 150 ms asíncrona |
| Hitch | < 50 ms |
| Memoria del proceso | ≤ 4 GB |

Los números son provisionales hasta F1. Se mide por sector, no por mapa completo.

## 14. Alcance y recortes

### 14.1. Incluido en la primera versión de la campaña 01

- Región total de 3,5 × 2,5 km, con 2–4 km² de área densa; seis sectores.
- Comunidad principal, Cusco preimperial, quebrada, paso y frontera.
- 15–20 NPC narrativos y 40–60 de comunidad.
- Historia principal de 12–16 misiones y 15–20 secundarias.
- 20–30 descubrimientos y 10–15 acontecimientos.
- Guardado, día/noche, clima básico, mapa y diario.
- Arte y audio coherentes con la guía visual.

### 14.2. Recortes, en orden

1. Región a 2 × 2 km.
2. Multitud ambiente y NPC tier C.
3. Interiores a 3 por comunidad.
4. Clima a claro/lluvia.
5. Combate a encuentros authored.
6. Viaje rápido eliminado.
7. Campañas II–IV solo documentadas.

### 14.3. Vertical slice (F3)

La primera demostración jugable no es la campaña completa. Debe incluir:

- 400–500 × 400–500 m de terreno natural.
- Una comunidad con 8–12 casas, plaza, 3 interiores y límite natural.
- 20–30 NPC, 8 nombrados, rutinas de mañana/tarde/noche.
- 1 misión principal de 3 etapas con consecuencia.
- 2 actividades secundarias y 1 descubrimiento no marcado.
- Ciclo día/noche, descanso y guardado/carga.
- Un cambio del jugador persistente (corral, acequia, puente o casa).
- 30–45 min de juego real, con contenido no principal.

## 15. Métricas de éxito

- 6–8 h de historia principal; 8–12 h con contenido secundario.
- 30/60 FPS y estabilidad dentro del presupuesto.
- 100 % del contenido histórico clasificado y verificado.
- El jugador describe una experiencia no principal y recuerda un lugar.
- El jugador puede volver a casa sin marcador.
- El mundo sigue vivo después del clímax.

## 16. Proceso de diseño de una región

1. Expediente histórico y geográfico.
2. Mapa conceptual y clasificación (documentado / aproximado / ficción).
3. Sectores, rutas, POI y experiencias.
4. Blockout a escala y recorrido a pie.
5. Arte, arquitectura y vegetación.
6. Población, rutinas y diálogo.
7. Misiones, actividades y descubrimientos.
8. Rendimiento, guardado y validación.

No se invierte el orden: **primero el lugar y sus experiencias; después la geometría y el arte**.
