# Alcance del Vertical Slice — Campaña 01: Pachacútec

- Estado: **Propuesto** — pendiente de aprobación
- Fecha: 2026-11-10
- Precondición de: Fase 4 ([docs/05](../../../docs/05_plan_de_implementacion.md))
- Registro histórico: [registro_historico.md](registro_historico.md)

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

## 2. Premisa y evento narrativo

El jugador es un habitante joven de una llacta del valle, sin nombre ni retrato canónico. La experiencia transcurre durante la mañana en que llega la noticia del avance chanca sobre el Cusco.

Secuencia narrativa:

1. **Apertura:** la llacta amanece. El jugador puede recorrer el camino sur, la plaza y las terrazas.
2. **La noticia:** un chasqui entra por el camino norte y se detiene en la plaza. Los habitantes interrumpen sus tareas y se reúnen.
3. **La respuesta:** el curaca y los hombres principales se preparan para partir. El jugador puede participar con tres acciones: beber del quero, dejar una ofrenda y hacer sonar el pututu para convocar la reunión.
4. **Cierre:** el grupo abandona la llacta por el camino norte. La experiencia termina con la plaza vacía y el viento.

No hay diálogo ramificado ni sistema de misiones en esta fase. La información se transmite con animaciones, posición de personajes, sonido y textos breves de interacción. Cualquier diálogo con opciones requiere un ADR.

## 3. Mapa y rutas

Esquema provisional. El terreno procedural actual se ajustará para dejar una meseta plana para la llacta y laderas para las terrazas.

```text
                 camino norte (chasqui)
                          |
   terrazas este ---- plaza central ---- viviendas oeste
                          |
                 camino sur (inicio)
```

- **Inicio:** camino sur, con la llacta a la vista.
- **Ruta baja:** camino sur → viviendas oeste → plaza.
- **Ruta alta:** camino sur → terrazas este → mirador → plaza.
- **Punto final:** plaza, junto al pututu.
- **Bordes:** límite físico a ~70 m del centro. Se decide entre muro invisible con indicio visual (cresta del terreno) o caída asumida. Propuesta: cresta rocosa con colisión, sin caída al vacío.
- **Viviendas:** 6–8 módulos rectangulares de piedra y adobe con techumbre de ichu, distribuidos alrededor de la plaza. Dos variantes como mínimo.
- **Plaza:** superficie de tierra apisonada, con el pututu, el quero y el lugar de ofrenda.
- **Terrazas:** tres niveles agrícolas en la ladera este, con muro de contención.
- **Vegetación:** ichu y queñua; prohibido el eucalipto y cualquier especie introducida después de 1532.

Coordenadas y medidas exactas se fijarán al construir la escena; el mapa de este documento es la referencia de diseño.

## 4. Interactuables

| Objeto | Tipo | Comportamiento | Efecto |
|---|---|---|---|
| Quero de chicha | Consumible | Ya implementado: inclinación, sonido, restauración de estamina | +35 de estamina |
| Ofrenda a la Pachamama | Ofrenda | El jugador deja una pequeña ofrenda en un adoratorio | Respuesta visual y sonora; marca que el gesto se realizó |
| Pututu | Instrumento | El jugador lo hace sonar | Convoca a los habitantes y dispara el evento |

Reglas:

- El quero tiene **tiempo de espera de 10 s** entre usos para que no anule la estamina. No tiene límite de usos.
- La ofrenda y el pututu son de un solo uso por partida.
- Ningún interactuable conoce la UI; todos usan el contrato de `Interactable`.

## 5. Personajes

| Personaje | Papel | Presencia |
|---|---|---|
| Tejedora | Mujer adulta que trabaja el telar junto a una vivienda | Animación idle de tejido; gira la cabeza hacia el jugador si está cerca |
| Agricultor | Hombre que trabaja en las terrazas | Animación idle de trabajo; se detiene y mira al chasqui durante el evento |
| Chasqui | Mensajero que llega por el camino norte | Entrada corriendo, se detiene en la plaza y entrega la noticia mediante gesto |

La tejedora y el agricultor son los dos NPC con presencia. El chasqui forma parte del evento y no cuenta para ese mínimo.

## 6. Assets

### 6.1 Modelos y arquitectura

| Asset | Formato | Origen | Licencia | Ficha |
|---|---|---|---|---|
| Kit modular de vivienda inca (2 variantes) | `.glb` | Blender, autoría propia | Propia | PCH-007 |
| Plaza y caminos | Malla procedural / `.glb` | Godot o Blender | Propia | PCH-016 |
| Terrazas y muros de contención | Malla procedural / `.glb` | Godot o Blender | Propia | PCH-008 |
| Adoratorio de ofrenda | `.glb` | Blender | Propia | PCH-012 |
| Pututu | `.glb` | Blender | Propia | PCH-009 |
| Telar | `.glb` | Blender | Propia | PCH-010 |
| Quero (sustituir el cilindro actual) | `.glb` | Blender | Propia | PCH-004 |
| NPC tejedora, agricultor y chasqui | `.glb` riggeado | Blender | Propia | PCH-011, PCH-017 |
| Ichu y queñua | Mallas o billboards | Blender / procedural | Propia | PCH-013 |
| Llama o alpaca (opcional) | `.glb` | Blender | Propia | PCH-014 |

### 6.2 Materiales y texturas

- Piedra andesita/caliza, adobe, madera, ichu, textiles con tintes naturales.
- Texturas de 1K o 2K; sin imágenes de terceros sin licencia compatible.
- Materiales compartidos en `shared_assets/materials/`.

### 6.3 Audio

| Sonido | Uso | Origen |
|---|---|---|
| Viento de altura | Ambiente continuo | Grabación propia o CC0 |
| Aves andinas | Ambiente | Grabación propia o CC0 |
| Pasos en tierra y piedra | Jugador | Propio |
| Quero | Interacción | Placeholder actual, sustituir |
| Pututu | Interacción | Propio o CC0 |
| Murmullo de plaza | Evento | Propio |

Sin voces en esta fase. Los textos de interacción se centralizan en las tablas CSV.

### 6.4 Animaciones

- Idle de tejedora, agricultor y chasqui.
- Entrada corriendo del chasqui.
- Gesto de entrega de la noticia.
- Inclinación del quero y respuesta de la ofrenda.
- Sin animaciones de combate.

## 7. Pipeline de assets

- **Blender 4.x LTS** para modelos, rigging y animación.
- Exportación a **glTF 2.0 binario (`.glb`)**; no se importan `.blend` directamente.
- 1 unidad = 1 metro; transformaciones aplicadas; origen en los pies para personajes.
- Nombres `snake_case` con prefijo `pch_` (`pch_house_a.glb`, `pch_npc_weaver.glb`).
- LOD automático de Godot para mallas; `visibility_range` para vegetación.
- Colisión: mallas `-col` o `create_trimesh_shape()` para estáticos; cápsula para NPC.
- Sin addons de Blender ni de Godot sin ADR.
- Si un asset no está listo, se usa un bloqueo declarado como placeholder; no se presenta como definitivo.

## 8. Registro histórico

Antes del cierre de la Fase 4, todo elemento debe tener ficha en estado **verificado**. Fichas nuevas propuestas:

| ID | Elemento | Clasificación provisional |
|---|---|---|
| PCH-006 | Llacta / asentamiento | A / R |
| PCH-007 | Vivienda inca | A / R |
| PCH-008 | Terraza agrícola | A |
| PCH-009 | Pututu | A / H |
| PCH-010 | Telar y textil | A / R |
| PCH-011 | Chasqui | H |
| PCH-012 | Ofrenda a la Pachamama | H / R |
| PCH-013 | Ichu y queñua | A |
| PCH-014 | Llama / alpaca | A |
| PCH-015 | Evento: la noticia chanca | H (tradición) / N |
| PCH-016 | Plaza y caminos | A / R |
| PCH-017 | Curaca y autoridad local | H / R |

PCH-004 (quero) y PCH-005 (chicha) siguen pendientes de verificación con edición y página. No se puede cerrar la Fase 4 con fichas pendientes.

## 9. Protocolo de prueba

- **Muestra:** mínimo 6 personas ajenas al desarrollo.
- **Sesión:** 20 minutos por persona; consentimiento; juego de 10–15 minutos; cuestionario breve.
- **Duración:** mediana entre 10 y 15 minutos.
- **Comprensión:** al menos 4 de 6 (2/3) explican con sus palabras quién amenaza el Cusco y qué hace la élite.
- **Estabilidad:** sin bloqueos de progreso ni errores en consola.
- **Registro:** tabla anónima con duración, respuestas y observaciones; sin datos personales.
- **Criterio de corrección del cuestionario:** se define en este documento antes de la primera sesión; las respuestas se evalúan por dos personas.

## 10. Rendimiento

- Objetivo vinculante: ≥ 30 FPS de media en perfil Bajo, 1080p, en la referencia con GPU integrada.
- Objetivo recomendado: ≥ 60 FPS en perfil Medio en la referencia con GPU dedicada, cuando exista.
- Remedir con el recorrido fijo de `tests/measure_performance.gd` al añadir casas, NPC y vegetación.
- No se optimiza sin medir.

## 11. Fuera de alcance

- Combate, inventario, diálogos ramificados, misiones y guardado.
- Códice o enciclopedia dentro del juego.
- Multijugador, consolas, móviles y VR.
- Localización a otros idiomas.
- Campañas adicionales.

## 12. Aprobación

- [ ] El equipo revisa y aprueba este documento.
- [ ] Se confirman las decisiones de bordes del mundo y tiempo de espera del quero.
- [ ] Se confirma el pipeline de Blender/glTF.
- [ ] Se aprueba el protocolo de prueba.

Al aprobarse, se marca la precondición de la Fase 4 en [docs/05](../../../docs/05_plan_de_implementacion.md) y se abre la fase.
