# 01 — Visión y alcance

## 1. Visión

Memorias del Perú es una experiencia histórica en 3D. La etapa actual se concentra en **una campaña** —*Pachacútec — La defensa del Cusco*—, un **RPG histórico en primera persona** de tres actos ([ADR-0038](adr/0038-campana-rpg.md), [ADR-0039](adr/0039-tres-actos-y-gris.md)): la vida en la llacta, el camino al Cusco y la defensa. Las demás épocas de la historia peruana quedan como horizonte: cada campaña futura tendrá su propio documento de visión.

En la campaña 01 el jugador vive los acontecimientos asociados a Cusi Yupanqui y la amenaza chanca en el siglo XV: recorre entornos andinos, interactúa con habitantes, explora una llacta y participa en acontecimientos históricos.

## 2. Pilares de diseño

| Pilar | Significado práctico | Cómo se evalúa |
|---|---|---|
| Inmersión en primera persona | Cámara, movimiento y sonido coherentes con un cuerpo humano en altura andina | HUD mínimo y contextual: la indicación de interacción solo aparece al enfocar un objeto y la estamina solo cuando cambia o no está llena; nada fijo en pantalla de forma permanente. Head bobbing natural; transiciones suaves |
| Rigor histórico | Nada se presenta como hecho sin fuente | Cada elemento histórico tiene ficha en el registro de la campaña |
| Exploración libre | El entorno invita a recorrer, no a seguir un pasillo | Varias rutas en el vertical slice |
| Interacción contextualizada | Las acciones tienen sentido cultural (ofrendas, chicha, reciprocidad) | Cada interacción tiene justificación documental o narrativa declarada |
| Narrativa ambiental | El espacio cuenta la historia | Objetos, arquitectura y sonido transmiten contexto sin texto explicativo |
| Combate y progresión | Combate a distancia con armas andinas y progresión por habilidades, reputación y objetos, subordinados al relato | El combate no sustituye la exploración ni la decisión; el resultado histórico no cambia |
| Identidad visual andina | Paleta, materiales y luz propios de los Andes | Revisión de dirección artística por fase |

**Regla de desempate:** cuando dos pilares entran en conflicto, la coherencia histórica prevalece sobre la espectacularidad.

## 3. Público objetivo

- Jugadores de aventura/exploración en primera persona.
- Público interesado en historia andina (incluido uso educativo).
- Plataforma: PC de escritorio con teclado y ratón. El soporte de mando queda fuera del alcance inicial, pero el Input Map se diseña para permitirlo sin reescribir el jugador.

## 4. Alcance por versión

### Incluido en la campaña 01 (Fases 6–8)

- Controlador FPS: caminar, correr, cámara, head bobbing.
- Sistema de interacción genérico por `RayCast3D` y clase `Interactable`.
- Núcleo RPG: estado, habilidades, reputación, inventario, diálogo con opciones, diario, combate a distancia y puntos de control ([biblia de la campaña](../campaigns/01_pachacutec/documentation/biblia_campana.md)).
- Tres actos jugables: la llacta, el paso y el Cusco de 1438; 40–50 min en total.
- Entorno base: cielo físico, niebla, sol, perfiles de calidad gráfica.
- Llacta, paso y Cusco construidos con terreno, viviendas, caminos, vegetación, personajes, objetos interactuables y sonido ambiente.

### Explícitamente fuera de alcance hasta nuevo acuerdo

- Guardado completo, niveles y XP, loot aleatorio, magia y crafting profundo.
- Salto como mecánica de combate (la acción sigue reservada en el Input Map).
- Multijugador, consolas, móviles, VR.
- Localización a otros idiomas (los textos de jugador sí se centralizan desde la Fase 2 en tablas de traducción, ver docs/02 §7, para facilitarla después).
- Códice o enciclopedia histórica completa; la «Memoria» del diario no lo sustituye.
- Cambiar el resultado histórico de la defensa.

## 5. Definición de éxito

**Objetivo comprometido:** entregar la campaña 01 jugable de **40–50 minutos**, en tres actos, con todo su contenido histórico verificado y sin errores técnicos ([ADR-0039](adr/0039-tres-actos-y-gris.md)). La antología completa y las demás campañas siguen siendo la visión del proyecto, no un compromiso de esta etapa.

| # | Métrica | Umbral | Cómo se mide |
|---|---|---|---|
| 1 | Duración de la campaña | **40–50 min** en una partida completa de los tres actos ([ADR-0039](adr/0039-tres-actos-y-gris.md)) | Pasadas cronometradas del registro de sesión |
| 2 | Rendimiento | **Vinculante:** ≥ 30 FPS de media en perfil Bajo, 1080p, en el equipo de referencia con GPU integrada (docs/08 §4). ≥ 60 FPS en perfil Medio es objetivo recomendado y se verifica cuando exista el equipo de referencia con GPU dedicada | Recorrido fijo medido con `Performance` |
| 3 | Rigor histórico | 100 % del contenido histórico con ficha “verificado” | Registro histórico de la campaña |
| 4 | Estabilidad técnica | 0 errores en consola, 0 bloqueos de progreso | Pruebas automatizadas + sesiones de prueba |
| 5 | Comprensión del contexto | **No verificada** ([ADR-0031](adr/0031-validacion-por-el-autor.md)): se conserva la definición —6 jugadores ajenos al desarrollo, al menos 2/3— como objetivo recuperable; la validación actual es la del autor | Protocolo de autor de ADR-0031; datos reales de una demo pública con el registro de sesión |

La métrica 5 es la única que mide el valor para el público (incluido el educativo) y la única que queda **no verificada**: el proyecto no dispone de jugadores ajenos a quienes convocar, así que se sustituye por una validación de autor declarada y se deja la puerta abierta a recuperarla con una demo pública ([ADR-0031](adr/0031-validacion-por-el-autor.md)).

## 6. Horizonte posterior (visión, no compromiso)

Salvo la campaña 01, que ya tiene fases en [docs/05](05_plan_de_implementacion.md), nada de esta sección tiene fase ni se implementa sin un ADR que la convierta en fase con entregables y criterios.

| Línea | Idea | Condición para planificarla |
|---|---|---|
| Códice histórico | Consulta en el juego de las fichas del registro histórico, con su clasificación H/A/R/N | Registro de la campaña 01 verificado |
| Nuevas campañas | Otras épocas de la historia peruana | Campaña 01 publicada; cada campaña nueva tiene su propio documento de visión |

## 7. Glosario

| Término | Definición en este proyecto |
|---|---|
| Core | Sistemas compartidos por todas las campañas (`core/`) |
| Shared Assets | Recursos reutilizables sin lógica de campaña (`shared_assets/`) |
| Campaña | Contenido de una época: escenas, personajes, misiones (`campaigns/NN_nombre/`) |
| Vertical Slice | Porción pequeña pero completa y pulida del juego final |
| Llacta | Asentamiento/pueblo andino |
| Quero | Vaso ceremonial de madera. Forma quechua (*qiru* / *q'iru*) pendiente de verificar con la norma de la campaña (ver ficha PCH-004) |
| Chicha de jora | Bebida fermentada de maíz germinado (jora) |
| Inti | Sol; nombre de la `DirectionalLight3D` principal |
