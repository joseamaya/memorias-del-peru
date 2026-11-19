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
| 3 | `biblia_campana.md` | Fases, elenco, sistemas, banderas y finales de la campaña |
| 4 | `documentation/mundo/` | Geografía, sectores, rutas, POI y fases |
| 5 | `guion_campana.md` | Misiones, objetivos, conflictos, claves de texto |
| 6 | **`guion_escenas.md`** (este formato) | Escena, bloqueo, cámara, textos, aceptación |
| 7 | Código y pruebas | Implementación de lo anterior |

Una escena no inventa canon: si necesita un cambio de misión, de bandera, de sector o de final, se actualiza primero el nivel 3–5 y se anota en la [bitácora](bitacora.md).

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

## 6. Ficha modelo (histórica, versión lineal)

> Este ejemplo pertenece a la versión lineal de la campaña 01 y se conserva como referencia de nivel de detalle. En el mundo abierto, la misma escena se declara como escena de mundo en la plaza de la llacta, con rutina interrumpida y estado persistente.

### I.3 · La duda

**Lugar y momento:** llacta, plaza, junto al fuego · mañana.  
**Duración:** 1–2 min · **Estado:** Parcial (el punto está a unos metros del fuego).  
**Objetivo narrativo:** presentar la división entre Puma y Asto antes de la noticia.  
**Objetivo del jugador:** escuchar y tomar partido.

**Presentes y bloqueo:**
- Puma, de pie, frente al curaca.
- Asto, curaca, de frente a Puma.
- Rumi, a un lado, dentro del punto de interacción.

**Cámara y sonido:**
- La cámara enfoca a Puma al abrir el diálogo.
- Fuego y viento de fondo; sin música.

**Textos:**
- `PCH_TALK_DUDA`: «Escuchar la discusión».
- `PCH_DUDA_INTRO`, `PCH_DUDA_PUMA`, `PCH_DUDA_CURACA`, `PCH_DUDA_SILENCE`.
- Respuestas `PCH_DUDA_*_ANSWER`.

**Decisiones:**
- Apoyar a Puma, apoyar al curaca o callar.

**Banderas:**
- Fija: `apoyo_puma`, `apoyo_curaca` o `apoyo_silencio`.
- Lee: ninguna.

**Consecuencias:**
- Reputación de llacta y Cusco.
- Opción de reconciliación y variante de silencio en IV.3.

**Aceptación:**
- [ ] El punto abre una sola conversación.
- [ ] Hay tres opciones y cada una fija su bandera.
- [ ] La cámara mira a Puma, que es el primer parlamento.
- [ ] La duda es opcional y no bloquea la asamblea.

**Ficha histórica:** PCH-001, PCH-015 · H (tradición) / N.  
**Deuda:** el punto está a unos metros del fuego; acercarlo o mover a los personajes.

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
