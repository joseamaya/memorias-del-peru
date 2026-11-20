# 10 — Plantilla de escena de mundo y secuencia controlada

- **Versión:** 2.0 — 2026-11-19
- **Ámbito:** cualquier campaña de *Memorias del Perú*
- **Marco:** [biblia narrativa](09_biblia_narrativa.md), [GDD de mundo](11_diseno_de_mundo.md), [convenciones históricas](07_convenciones_historicas.md) y [estrategia de pruebas](06_estrategia_de_pruebas.md)
- **Uso:** se copia en `campaigns/<campaña>/documentation/mundo/escenas.md` o en el guion de la campaña, y se completa escena por escena.

## 1. Para qué sirve

La biblia fija **qué** cuenta una campaña. El GDD fija **cómo se habita el mundo**. Este documento fija **cómo se juega y cómo se ve cada escena**: dónde ocurre, en qué sector y hora, quién está, qué se dice, qué cámara lo encuadra, qué estado del mundo cambia, qué consecuencia se lee y qué tiene que comprobar una prueba para darla por buena.

Hay dos tipos de escena:

1. **Escena de mundo:** ocurre dentro del territorio, sin cargar un nivel ni quitar el control. El jugador puede llegar por varios caminos, ignorarla o volver después. Es la forma principal.
2. **Secuencia controlada:** ocurre en el mismo mundo o en un espacio acotado, con control limitado del jugador: asamblea, batalla, sueño, clímax. Se usa solo cuando la puesta en escena lo exige.

Sin este nivel, el código puede cumplir la estructura y fallar la escena: una casa en el lado equivocado, una cuenta que no cambia con el coste, un mensajero que solo existe en una tarjeta o un personaje que habla desde fuera de cuadro.

## 2. Jerarquía documental

| Nivel | Documento | Manda sobre |
|---|---|---|
| 1 | `docs/09_biblia_narrativa.md` | Antología, tono, reglas de guion |
| 2 | `docs/11_diseno_de_mundo.md` | Región, sectores, bucle, NPC y sistemas |
| 3 | `documentation/mundo/` | Geografía, sectores, rutas, POI y fases |
| 4 | Guion de campaña (por escribir) | Misiones, objetivos, conflictos, claves de texto |
| 5 | **Guion de escena** (este formato) | Escena, bloqueo, cámara, textos y aceptación |
| 6 | Código y pruebas | Implementación de lo anterior |

La campaña rediseñada no tiene aún guion de campaña ni de escenas: el nivel 4 se escribe antes que el 5, y una escena no inventa canon. Si necesita un cambio de misión, de sector o de final, se actualiza primero el nivel 3–4 y se anota en la [bitácora](bitacora.md).

## 3. Cuándo se escribe

- **Campaña en desarrollo:** guion de escena completo, fase por fase, antes de dar la fase por cerrada. Cada escena declara si es de mundo o controlada.
- **Campaña futura:** solo estructura, expediente histórico y dossier geográfico. No se escribe el guion de escena hasta que su etapa se abra, según `docs/09` §11.
- **Cambio de escena:** se actualiza la ficha y su criterio de aceptación en el mismo lote que el código.

## 4. Convenciones

| Elemento | Regla |
|---|---|
| ID de escena | `<fase>.<misión>` o `<sector>.<escena>`: `F1.3`, `S3.manantial` |
| Nombre | El de la misión o el lugar en la biblia/dossier |
| Tipo | Escena de mundo / secuencia controlada |
| Lugar | Sector y punto concreto; no «la llacta» sino «la puerta de la casa del este» |
| Momento | Día y franja; amanecer, mañana, tarde, noche; clima si importa |
| Personajes | Todos los que deben verse, aunque no hablen; su rutina y ancla |
| Bloqueo | Dónde está cada uno y hacia dónde mira; qué rutina se interrumpe |
| Cámara | A quién enfoca el diálogo y qué debe quedar en cuadro |
| Textos | Claves de la tabla de localización; las líneas completas van en la tabla, no en el código |
| Decisiones | Opciones, condiciones y efecto |
| Estado del mundo | Banderas, IDs, fase histórica, descubrimientos y cambios físicos |
| Consecuencias | Qué cambia en el mundo, en la relación o en la fase siguiente |
| Persistencia | Qué se guarda, con qué ID y cómo se recupera |
| Aceptación | Comprobable por una prueba o por una captura; sin adjetivos |
| Ficha | PCH y clasificación H/A/R/N; GD/GR/GN para el lugar |
| Estado | `Implementado`, `Parcial` o `Pendiente`, con la deuda concreta |

## 5. Ficha de escena

Copiar este bloque por cada escena:

```markdown
### <ID> · <Nombre>

**Tipo:** escena de mundo / secuencia controlada
**Sector y lugar:** ...
**Momento:** día ... · franja ... · clima ...
**Duración:** ... · **Estado:** Implementado / Parcial / Pendiente
**Objetivo narrativo:** ...
**Objetivo del jugador:** ...

**Presentes y bloqueo:**
- ... (NPC, rutina, ancla, interrupción)

**Cámara y sonido:**
- ...

**Textos:**
- `CLAVE`: línea o función.

**Decisiones:**
- ...

**Estado del mundo:**
- Fija: ...
- Lee: ...
- Descubrimientos: ...
- Cambio físico: ...

**Consecuencias:**
- ...

**Persistencia:**
- Se guarda: ...
- Se recupera: ...

**Aceptación:**
- [ ] ...
- [ ] ...

**Ficha histórica:** PCH-... · clasificación
**Clasificación geográfica:** GD / GR / GN
**Deuda:** ...
```

**Regla de escena de mundo:** si el jugador puede llegar por otro camino, ignorarla o volver después, la ficha debe declarar qué pasa en cada caso. Una escena de mundo no puede depender de que el jugador llegue en un orden exacto.

**Regla de secuencia controlada:** debe declarar qué se bloquea (movimiento, cámara, UI), cómo se entra, cómo se sale y qué estado del mundo deja. Si no hay una razón de puesta en escena, se resuelve como escena de mundo.

## 6. Ficha modelo

> Ejemplo genérico con el nivel de detalle que se exige. No describe una escena existente: la campaña rediseñada aún no tiene guion. Los nombres de personaje y las claves de texto se escriben al redactar la escena.

### F3 · La negativa del curaca

**Lugar y momento:** llacta vecina, plaza, junto a la casa del curaca · tarde.  
**Duración:** 2–3 min · **Estado:** parcial (el jugador puede llegar por el camino o por el atajo del río).  
**Objetivo narrativo:** cerrar la embajada con una negativa que el jugador ya sospecha.  
**Objetivo del jugador:** conseguir ayuda para la ciudad y volver con una respuesta.

**Presentes y bloqueo:**
- El curaca, en el umbral de su casa.
- Dos principales, sentados junto al fuego.
- El protagonista, dentro del punto de interacción.

**Cámara y sonido:**
- Cámara al curaca al abrir el diálogo.
- Fuego, viento y telar de fondo; sin música.

**Textos:**
- Claves por definir en la tabla de localización; ninguna cadena literal en código.

**Decisiones:**
- Insistir, ofrecer algo a cambio o aceptar la negativa y marcharse.

**Banderas:**
- Fija: `embajada_insistio`, `embajada_ofrecio` o `embajada_acepto`.
- Lee: `reputacion_cusco`.

**Consecuencias:**
- La negativa se mantiene en las tres ramas; cambia el trato y lo que la llacta hace después de la victoria.
- La llacta se suma al vencedor en la fase 4, con independencia de la rama.

**Aceptación:**
- [ ] El punto abre una sola conversación.
- [ ] Cada rama fija su bandera y ninguna bloquea el regreso.
- [ ] La negativa no depende de que el jugador llegue en un orden exacto.
- [ ] La escena deja el estado del mundo persistido.

**Ficha histórica:** la negativa de los curacas vecinos está en Betanzos y en Rostworowski; la embajada concreta es puesta en escena (H / N).  
**Deuda:** ninguna.

## 7. Matriz de estado del mundo

| ID | Tipo | Se fija en | Se lee en | Efecto | Persistencia | Prueba |
|---|---|---|---|---|---|---|
| `ejemplo` | Bandera | F1.3 | F4.3 | Abre una opción | Sí | `test_...` |
| `poi_mirador` | Descubrimiento | S4 | Diario/mapa | Registra el lugar | Sí | `test_...` |
| `corral_reparado` | Cambio físico | S3 | S3/S5 | Cambia el corral | Sí | `test_...` |

Reglas:

- Todo estado del guion debe aparecer aquí.
- Si se fija y no se lee, se marca como **deuda** o se elimina.
- Si se lee y no se fija en ninguna escena, es un error de guion.
- Todo estado que sobrevive a una escena declara su ID estable y su serialización.

## 8. Matriz de finales

| Final | Condición | Texto | Variantes |
|---|---|---|---|
| Ejemplo | `bandera_a` y `bandera_b` | `PCH_FINAL_...` | ... |

Reglas:

- Las condiciones se escriben con banderas, no con impresiones.
- Cada final debe tener al menos una prueba que lo alcance.
- Si dos finales pueden cumplirse a la vez, el orden de prioridad se declara.

## 9. Ritmo y duración

| Fase / sector | Duración objetivo | Duración medida | Estado |
|---|---|---|---|
| Fase 1 / S3 | ... | ... | ... |

- La duración se mide con una partida humana, no con la pasada guionizada.
- La pasada guionizada sirve para revisar el arco, no para acreditar duración.
- La duración de una escena de mundo incluye el tiempo de llegada y de salida; no se mide solo el diálogo.

## 10. Pruebas y aceptación

Cada escena debe tener al menos una comprobación:

- **Estructural:** nodos, puntos, textos y banderas.
- **De escena:** personajes presentes, cámara, bloqueo, ropa o prop.
- **De consecuencia:** la bandera se lee donde el guion dice.
- **Manual:** captura o prueba de humo cuando el arte o el audio son el criterio.

La tabla de pruebas de la campaña se actualiza en [docs/06](06_estrategia_de_pruebas.md).

## 11. Registro de cambios

| Versión | Fecha | Cambio |
|---|---|---|
| 1.0 | 2026-11-16 | Plantilla inicial. |

## 12. Checklist de revisión

- [ ] Cada misión del guion de campaña tiene su escena.
- [ ] Cada escena declara si es de mundo o controlada.
- [ ] Cada escena tiene sector, lugar, momento, presentes y bloqueo.
- [ ] Cada escena tiene textos con clave, no literales en código.
- [ ] Cada decisión tiene estado y consecuencia.
- [ ] Cada estado que se fija se lee en alguna escena o está marcado como deuda.
- [ ] Cada estado persistente declara su ID y su serialización.
- [ ] Cada final tiene condición y prueba.
- [ ] Cada escena tiene criterio de aceptación comprobable.
- [ ] La duración está medida o declarada como no verificada.
- [ ] El contenido histórico tiene ficha y clasificación; el lugar tiene GD/GR/GN.
- [ ] La escena de mundo funciona si el jugador llega por otro camino, la ignora o vuelve después.
- [ ] La bitácora registra el cambio.
