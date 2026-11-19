# 07 — Convenciones históricas y artísticas

## 1. Principio

El proyecto no inventa reconstrucciones para presentarlas como hechos. Todo elemento histórico relevante tiene clasificación y referencia, y el proyecto distingue entre lo documentado y lo interpretado: para el equipo siempre (registro histórico) y para el jugador cuando sea pertinente (dentro del relato o, si se aprueba, en un códice histórico: ver docs/01 §6).

## 2. Clasificación obligatoria

| Código | Categoría | Definición | Requisito mínimo |
|---|---|---|---|
| **H** | Hecho histórico documentado | Afirmado en fuentes escritas (crónicas, documentos coloniales) | Cita de al menos una fuente, con obra y capítulo/página. Si las fuentes discrepan, se indica. |
| **A** | Evidencia arqueológica | Respaldado por registro material (excavaciones, piezas, sitios) | Referencia a publicación, sitio o colección |
| **R** | Reconstrucción interpretativa | Inferencia razonada a partir de H/A cuando falta información directa | Indicar en qué H/A se basa y qué se infiere |
| **N** | Licencia narrativa | Invención consciente al servicio del juego | Justificación de diseño; no debe contradecir H/A sin declararlo |

**Clasificación y verificación son independientes.** La clasificación dice *qué tipo* de afirmación es; el estado de verificación dice *si la cita ya se comprobó*. Una ficha puede crearse con su clasificación definitiva y una cita incompleta (sin capítulo/página): queda en estado **pendiente**, y el requisito mínimo de la tabla se exige para pasar a **verificado**. Las fichas pendientes bloquean el cierre del guion de la campaña (§3), no su creación.

Las crónicas coloniales se tratan como fuentes con sesgos (autor, informantes, fecha, intención). Un relato mítico o legendario recogido en una crónica (por ejemplo, intervención sobrenatural) se clasifica como **H** en cuanto a que *la tradición existe*, pero el suceso mostrado en el juego se clasifica como **N** o **R** según cómo se represente.

## 2.1. Clasificación geográfica

El mundo abierto exige distinguir la geografía documentada de la reconstrucción y de la ficción de escala. Cada región y cada sector declara:

| Código | Categoría | Definición | Requisito |
|---|---|---|---|
| **GD** | Geografía documentada | Ubicación, curso de agua, relieve o asentamiento atestiguado | Fuente cartográfica, histórica o arqueológica |
| **GR** | Reconstrucción aproximada | Forma inferida a partir de GD, con simplificación o compresión | Explicar qué se infiere y qué se comprime |
| **GN** | Ficción necesaria | Valle, paso, aldea o camino inventado para jugar | Justificación de diseño; no contradecir GD sin declararlo |

Reglas:

- La escala de juego se declara: una distancia comprimida no es una distancia histórica.
- Un mapa ficticio no se presenta como reconstrucción exacta, ni en el juego ni en la documentación.
- Cada sector tiene su ficha con clasificación, fuentes y decisiones de escala.
- Los elementos inventados que sostienen la historia (llacta, familia, paso) se registran como GN.
- La clasificación geográfica se revisa antes de construir el blockout y antes del arte final.

## 3. Registro histórico

Cada campaña mantiene `documentation/registro_historico.md` con una ficha por elemento:

```markdown
### <ID> — <Nombre>
- Tipo: personaje | lugar | arquitectura | vestimenta | objeto | arma | herramienta | alimento | evento | término
- Clasificación: H | A | R | N
- Uso en el juego: <escena/archivo>
- Fuentes: <autor, obra, año, capítulo/página>
- Discrepancias entre fuentes: <si las hay>
- Notas de representación: <qué se muestra y por qué>
- Estado de verificación: pendiente | verificado por <persona/fecha>
```

Ningún asset histórico entra en el juego sin ficha. Las fichas con estado “pendiente” se marcan como bloqueantes para cerrar el guion de la campaña. Las fichas de elementos que no están en el juego pueden figurar en una sección aparte del registro y no bloquean el cierre (ADR-0011).

## 4. Lista de control de anacronismos

Revisar antes de aprobar cualquier asset o escena:

- **Arquitectura:** técnicas, materiales y formas de la época y región (no aplicar soluciones de épocas posteriores ni coloniales).
- **Vestimenta:** prendas, textiles, tocados y distinciones de rango.
- **Armas:** solo armamento andino prehispánico; ausencia de metales o técnicas no disponibles.
- **Herramientas:** sin rueda funcional para transporte, sin animales de tiro europeos, sin hierro.
- **Alimentación:** solo especies andinas/americanas disponibles (nada de trigo, cebada, vacunos, cerdos, gallinas de origen euroasiático, etc.).
- **Fauna y flora:** sin especies introducidas tras 1532 (p. ej. eucaliptos en el paisaje).
- **Sonido:** el ambiente de la llacta es viento grabado en Atacama (Chile), sin aves, porque no se encontró una grabación libre con aves andinas identificadas; sustituyó el 2026-11-11 a una grabación con aves no andinas. El pututu suena con una caracola de tipo asiático. Los pasos del jugador y de los personajes son grabaciones de botas de montaña en tierra y en piedra, filtradas para suavizar el golpe, aunque los personajes llevan ojotas. Los tres son sustitutos declarados hasta contar con un registro propio del altiplano (declarado el de los pasos el 2026-11-12). La música de la introducción es música andina moderna, con zampoñas, cuerdas y percusión, generada con IA («Over The Andes», Pixabay). Es un **anacronismo declarado**: el responsable del proyecto la eligió el 2026-11-12 por su tono épico de apertura, aceptando que no corresponde al siglo XV (ADR-0028 y ADR-0029).
- **Organización social:** cargos, parentesco (ayllu), reciprocidad y jerarquías según fuentes.
- **Paisaje:** terrazas, caminos y asentamientos coherentes con la fecha representada.
- **Lenguaje y denominaciones:** términos quechuas con grafía consistente; evitar términos coloniales posteriores en boca de personajes.

## 5. Grafía y lenguaje

- Cada campaña define en su documentación la norma de escritura de términos indígenas (p. ej. alfabeto quechua oficial vs. grafía hispanizada tradicional) y la mantiene de forma consistente.
- Para nombres con forma hispanizada muy extendida (Cusco, Pachacútec) se puede usar esa forma en la interfaz y registrar la variante en quechua en la ficha.

## 6. Dirección artística

- Coherencia histórica antes que espectacularidad gratuita.
- Paleta basada en materiales reales: piedra andesita/caliza, adobe, ichu, madera, textiles con tintes naturales.
- Luz de altura: cielo de azul profundo, sombras nítidas, contraste fuerte al mediodía, amaneceres cálidos con niebla en valles.
- Referencias visuales (fotos de sitios, piezas de museo) se guardan con su fuente y licencia en `campaigns/<campaña>/documentation/referencias/`; no se incluyen en el juego imágenes sin licencia compatible.

## 7. Representación de la violencia y sensibilidad

Las campañas II y IV incluyen ejecuciones, represión y violencia de ocupación. La regla es la misma que la del resto del proyecto: se muestra la **consecuencia humana**, no el espectáculo.

| Caso | Cómo se representa | Qué no se muestra |
|---|---|---|
| Combate | Golpe, retroceso, caída; sin sangre ni desmembramientos | Heridas abiertas, agonía prolongada |
| Ejecución de un personaje histórico (campaña II) | El hecho, la fecha y la reacción de la comunidad; la cámara se retira antes | El suplicio, la mutilación, la participación del jugador |
| Represión y ocupación (campañas II y IV) | Requisas, desplazamiento, miedo, casas vacías, listas de ausentes | Violencia sexual explícita, tortura interactiva, sufrimiento infantil en pantalla |
| Muerte del protagonista | Recarga de la escena; el hecho histórico no cambia | Sufrimiento gratuito, muerte como castigo narrativo |
| Muerte de un personaje ficticio querido | El vacío que deja; el objeto o la casa que queda | Morbo, cuerpo expuesto |

Reglas complementarias:

- **El fuera de campo es una decisión, no un olvido.** Lo que se omite se declara en el expediente de la campaña.
- **Nada de triunfalismo sobre los vencidos.** La victoria tiene costo y se ve en la población.
- **La clasificación no cambia por ser violento:** un hecho documentado sigue siendo H; una escena creada para el juego, N.
- **Público:** cada campaña declara su público y su rating antes de escribir el guion; el objetivo es que el uso educativo siga siendo posible.
- **Duda razonable:** si una escena no puede mostrarse sin morbo, se cuenta por lo que deja. La decisión se anota en la bitácora.
