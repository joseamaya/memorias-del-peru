# 01 — Visión y alcance

## 1. Visión

Memorias del Perú es una experiencia histórica en 3D. La etapa actual se concentra en **una campaña** —*Pachacútec — La defensa del Cusco*— y en un modelo de **museo explorable**: un mundo que se recorre y se lee a través de estaciones históricas ([ADR-0034](adr/0034-una-campana-y-museo.md)). Las demás épocas de la historia peruana quedan como horizonte: cada campaña futura tendrá su propio documento de visión.

En la campaña 01 el jugador vive los acontecimientos asociados a Cusi Yupanqui y la amenaza chanca en el siglo XV: recorre entornos andinos, interactúa con habitantes, explora una llacta y participa en acontecimientos históricos.

## 2. Pilares de diseño

| Pilar | Significado práctico | Cómo se evalúa |
|---|---|---|
| Inmersión en primera persona | Cámara, movimiento y sonido coherentes con un cuerpo humano en altura andina | HUD mínimo y contextual: la indicación de interacción solo aparece al enfocar un objeto y la estamina solo cuando cambia o no está llena; nada fijo en pantalla de forma permanente. Head bobbing natural; transiciones suaves |
| Rigor histórico | Nada se presenta como hecho sin fuente | Cada elemento histórico tiene ficha en el registro de la campaña |
| Exploración libre | El entorno invita a recorrer, no a seguir un pasillo | Varias rutas en el vertical slice |
| Interacción contextualizada | Las acciones tienen sentido cultural (ofrendas, chicha, reciprocidad) | Cada interacción tiene justificación documental o narrativa declarada |
| Narrativa ambiental | El espacio cuenta la historia | Objetos, arquitectura y sonido transmiten contexto sin texto explicativo |
| Combate y progresión | Presentes, pero subordinados al relato | Fuera del vertical slice; ver horizonte posterior (§6) |
| Identidad visual andina | Paleta, materiales y luz propios de los Andes | Revisión de dirección artística por fase |

**Regla de desempate:** cuando dos pilares entran en conflicto, la coherencia histórica prevalece sobre la espectacularidad.

## 3. Público objetivo

- Jugadores de aventura/exploración en primera persona.
- Público interesado en historia andina (incluido uso educativo).
- Plataforma: PC de escritorio con teclado y ratón. El soporte de mando queda fuera del alcance inicial, pero el Input Map se diseña para permitirlo sin reescribir el jugador.

## 4. Alcance por versión

### Incluido hasta el Vertical Slice (Fases 1–4)

- Controlador FPS: caminar, correr, cámara, head bobbing.
- Sistema de interacción genérico por `RayCast3D` y clase `Interactable`.
- Estamina básica e indicaciones de interacción.
- Primera interacción: quero de chicha de jora.
- Entorno base: cielo físico, niebla, sol, perfiles de calidad gráfica.
- Una pequeña sección explorable de llacta con terreno, viviendas, caminos, vegetación, personajes, objetos interactuables y sonido ambiente.

### Explícitamente fuera de alcance hasta nuevo acuerdo

- Combate, inventario, diálogos ramificados y misiones (solo se documentan como puntos de extensión; no tienen fase en el plan y no se implementan sin un ADR que se la asigne, ver §6).
- Salto (acción reservada en el Input Map, sin lógica).
- Multijugador, consolas, móviles, VR.
- Localización a otros idiomas (los textos de jugador sí se centralizan desde la Fase 2 en tablas de traducción, ver docs/02 §7, para facilitarla después).
- Códice o enciclopedia histórica dentro del juego (ver §6).

## 5. Definición de éxito

**Objetivo comprometido:** entregar un vertical slice jugable de 2–3 minutos de la campaña 01 ([ADR-0033](adr/0033-duracion-del-slice.md)), con todo su contenido histórico verificado y sin errores técnicos. La antología completa y las campañas de 10–15 minutos son la visión del proyecto, no un compromiso de esta etapa.

| # | Métrica | Umbral | Cómo se mide |
|---|---|---|---|
| 1 | Duración del vertical slice | **2–3 min** de mediana en ruta directa ([ADR-0033](adr/0033-duracion-del-slice.md)); la campaña completa mantiene el horizonte de 10–15 min | Pasadas cronometradas del registro de sesión |
| 2 | Rendimiento | **Vinculante:** ≥ 30 FPS de media en perfil Bajo, 1080p, en el equipo de referencia con GPU integrada (docs/08 §4). ≥ 60 FPS en perfil Medio es objetivo recomendado y se verifica cuando exista el equipo de referencia con GPU dedicada | Recorrido fijo medido con `Performance` |
| 3 | Rigor histórico | 100 % del contenido histórico con ficha “verificado” | Registro histórico de la campaña |
| 4 | Estabilidad técnica | 0 errores en consola, 0 bloqueos de progreso | Pruebas automatizadas + sesiones de prueba |
| 5 | Comprensión del contexto | **No verificada** ([ADR-0031](adr/0031-validacion-por-el-autor.md)): se conserva la definición —6 jugadores ajenos al desarrollo, al menos 2/3— como objetivo recuperable; la validación actual es la del autor | Protocolo de autor de ADR-0031; datos reales de una demo pública con el registro de sesión |

La métrica 5 es la única que mide el valor para el público (incluido el educativo) y la única que queda **no verificada**: el proyecto no dispone de jugadores ajenos a quienes convocar, así que se sustituye por una validación de autor declarada y se deja la puerta abierta a recuperarla con una demo pública ([ADR-0031](adr/0031-validacion-por-el-autor.md)).

## 6. Horizonte posterior (visión, no compromiso)

Nada de esta sección tiene fase en el plan ni se implementa sin un ADR que la convierta en fase con entregables y criterios.

| Línea | Idea | Condición para planificarla |
|---|---|---|
| Combate y progresión | Combate cuerpo a cuerpo con armas andinas y progresión ligada al relato | Vertical slice cerrado y evaluado |
| Diálogo, inventario, misiones | Sistemas de Core ya previstos como puntos de extensión (docs/02 §6) | Necesidad concreta de una campaña |
| Códice histórico | Consulta en el juego de las fichas del registro histórico, con su clasificación H/A/R/N | Registro de la campaña 01 verificado |
| Campaña 01 completa | De la vida en la llacta a la defensa del Cusco | Vertical slice aprobado |
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
