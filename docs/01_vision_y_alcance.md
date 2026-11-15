# 01 — Visión y alcance

## 1. Visión

Memorias del Perú es una **antología de cuatro campañas históricas independientes**, definidas en la [biblia narrativa general](09_biblia_narrativa.md). Cada campaña se juega como un **RPG histórico en primera persona**: exploración, interacción, decisiones y combate al servicio de una reconstrucción rigurosa.

La campaña en desarrollo es **Pachacútec — El despertar del Sol**, en cinco actos y con una duración objetivo de **40–50 minutos**. El jugador es Rumi, un joven de una llacta del valle del Cusco: vive la llegada de la noticia chanca, cruza el paso con la comitiva, participa en la defensa del Cusco y vuelve a una casa que ya no es la misma.

Las demás campañas —Túpac Amaru II, la independencia y la Campaña de la Breña— quedan como horizonte: cada una tendrá su expediente histórico y su guion antes de construir nada.

## 2. Pilares de diseño

| Pilar | Significado práctico | Cómo se evalúa |
|---|---|---|
| Inmersión en primera persona | Cámara, movimiento y sonido coherentes con un cuerpo humano en altura andina | HUD mínimo y contextual; head bobbing natural; transiciones suaves |
| Rigor histórico | Nada se presenta como hecho sin fuente | Cada elemento histórico tiene ficha verificada en el registro de la campaña |
| Exploración libre | El entorno invita a recorrer, no a seguir un pasillo | Varias rutas y atajos en cada mapa |
| Interacción contextualizada | Las acciones tienen sentido cultural (ofrendas, chicha, reciprocidad) | Cada interacción tiene justificación documental o narrativa declarada |
| Narrativa ambiental | El espacio cuenta la historia | Objetos, arquitectura y sonido transmiten contexto sin texto explicativo |
| Combate y progresión | Combate con armas andinas y progresión por habilidades, reputación y objetos, subordinados al relato | El combate no sustituye la exploración ni la decisión; el resultado histórico no cambia |
| Identidad visual andina | Paleta, materiales y luz propios de los Andes | Revisión de dirección artística por acto |

**Regla de desempate:** cuando dos pilares entran en conflicto, la coherencia histórica prevalece sobre la espectacularidad.

## 3. Público objetivo

- Jugadores de aventura/exploración en primera persona.
- Público interesado en historia andina (incluido uso educativo).
- Plataforma: PC de escritorio con teclado y ratón. El soporte de mando queda fuera del alcance inicial, pero el Input Map se diseña para permitirlo sin reescribir el jugador.

## 4. Alcance de la campaña 01

### Incluido

- Controlador FPS: caminar, correr, cámara, head bobbing.
- Sistema de interacción genérico por `RayCast3D` y clase `Interactable`.
- Núcleo RPG: estado, habilidades, reputación, inventario, diálogo con opciones, diario, combate a distancia y puntos de control.
- Cinco actos jugables: la llacta, el paso, el Cusco de 1438, la posguerra y la nueva era.
- Entorno base: cielo físico, niebla, sol y perfiles de calidad gráfica.
- Llacta, paso y Cusco con terreno, viviendas, caminos, vegetación, personajes, objetos interactuables y sonido ambiente.

### Fuera de alcance hasta nuevo acuerdo

- Guardado completo en disco, niveles y XP, loot aleatorio, magia y crafting profundo.
- Salto como mecánica de combate (la acción sigue reservada en el Input Map).
- Multijugador, consolas, móviles, VR.
- Localización a otros idiomas (los textos se centralizan en tablas de traducción).
- Códice o enciclopedia histórica completa; la «Memoria» del diario no lo sustituye.
- Cambiar el resultado histórico de la defensa.
- Las campañas II–IV.

## 5. Definición de éxito

**Objetivo comprometido:** entregar la campaña 01 jugable de principio a fin, con los cinco actos, todo su contenido histórico verificado y sin errores técnicos.

| # | Métrica | Umbral | Cómo se mide |
|---|---|---|---|
| 1 | Duración de la campaña | **40–50 min** | Pasadas cronometradas del registro de sesión |
| 2 | Rendimiento | **Vinculante:** ≥ 30 FPS de media en perfil Bajo, salida a 1080p, en el equipo de referencia con GPU integrada (docs/08 §4). **Comprometido:** ≥ 60 FPS de media en perfil Medio en la misma GPU integrada | Recorrido fijo medido con `Performance` |
| 3 | Rigor histórico | 100 % del contenido histórico con ficha “verificado” | Registro histórico de la campaña |
| 4 | Estabilidad técnica | 0 errores en consola, 0 bloqueos de progreso | Pruebas automatizadas + sesiones de prueba |
| 5 | Coherencia con la biblia | 100 % de los actos superan la checklist de la biblia de la campaña §13 | Revisión de diseño y partida guionizada |

La métrica 5 sustituye a la validación con jugadores externos: el diseño se valida contra la biblia. La comprensión por parte del público queda como objetivo futuro, con el registro de sesión como base.

## 6. Horizonte posterior (visión, no compromiso)

Nada de esta sección tiene fase ni se implementa sin que se abra una fase con entregables y criterios.

| Línea | Idea | Condición para planificarla |
|---|---|---|
| Códice histórico | Consulta en el juego de las fichas del registro histórico, con su clasificación H/A/R/N | Registro de la campaña 01 verificado |
| Nuevas campañas | Las campañas II–IV de la [biblia narrativa](09_biblia_narrativa.md) | Campaña 01 publicada; expediente histórico de la campaña aprobado antes de escribir su guion |

## 7. Glosario

| Término | Definición en este proyecto |
|---|---|
| Core | Sistemas compartidos por todas las campañas (`core/`) |
| Shared Assets | Recursos reutilizables sin lógica de campaña (`shared_assets/`) |
| Campaña | Contenido de una época: escenas, personajes, misiones (`campaigns/NN_nombre/`) |
| Acto | Unidad dramática de una campaña; la campaña 01 tiene cinco |
| Expediente | Dossier histórico de una campaña antes de escribir su guion (docs/09 §9) |
| Llacta | Asentamiento/pueblo andino |
| Quero | Vaso ceremonial de madera. Forma quechua (*qiru* / *q'iru*) pendiente de verificar con la norma de la campaña (ver ficha PCH-004) |
| Chicha de jora | Bebida fermentada de maíz germinado (jora) |
| Inti | Sol; nombre de la `DirectionalLight3D` principal |
