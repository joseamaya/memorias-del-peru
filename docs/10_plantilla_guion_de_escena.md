# 10 — Plantilla de guion de escena

- **Versión:** 1.0 — 2026-11-16
- **Ámbito:** cualquier campaña de *Memorias del Perú*
- **Marco:** [biblia narrativa](09_biblia_narrativa.md), [convenciones históricas](07_convenciones_historicas.md) y [estrategia de pruebas](06_estrategia_de_pruebas.md)
- **Uso:** se copia en `campaigns/<campaña>/documentation/guion_escenas.md` y se completa escena por escena.

## 1. Para qué sirve

La biblia fija **qué** cuenta una campaña. El guion de campaña fija **qué misiones** la sostienen. Este documento fija **cómo se juega y cómo se ve cada misión**: quién está, dónde, qué se dice, qué cámara lo encuadra, qué bandera se fija, qué consecuencia se lee y qué tiene que comprobar una prueba para darla por buena.

Sin este nivel, el código puede cumplir la estructura y fallar la escena: una casa en el lado equivocado, una cuenta que no cambia con el coste, un mensajero que solo existe en una tarjeta o un personaje que habla desde fuera de cuadro.

## 2. Jerarquía documental

| Nivel | Documento | Manda sobre |
|---|---|---|
| 1 | `docs/09_biblia_narrativa.md` | Antología, tono, reglas de guion |
| 2 | `biblia_campana.md` | Actos, elenco, sistemas, banderas y finales de la campaña |
| 3 | `guion_campana.md` | Misiones, objetivos, conflictos, claves de texto |
| 4 | **`guion_escenas.md`** (este formato) | Escena, bloqueo, cámara, textos, aceptación |
| 5 | Código y pruebas | Implementación de lo anterior |

Una escena no inventa canon: si necesita un cambio de misión, de bandera o de final, se actualiza primero el nivel 2 o 3 y se anota en la [bitácora](bitacora.md).

## 3. Cuándo se escribe

- **Campaña en desarrollo:** guion de escena completo, acto por acto, antes de dar el acto por cerrado.
- **Campaña futura:** solo estructura de actos y expediente histórico. No se escribe el guion de escena hasta que su etapa se abra, según `docs/09` §11.
- **Cambio de escena:** se actualiza la ficha y su criterio de aceptación en el mismo lote que el código.

## 4. Convenciones

| Elemento | Regla |
|---|---|
| ID de escena | `<acto>.<misión>`: `I.3`, `II.5`, `IV.2` |
| Nombre | El de la misión en la biblia de campaña |
| Lugar | Escena y punto concreto; no «la llacta» sino «la puerta de la casa del este» |
| Momento | Amanecer, mañana, tarde, noche; luz fría o cálida si importa |
| Personajes | Todos los que deben verse, aunque no hablen |
| Bloqueo | Dónde está cada uno y hacia dónde mira |
| Cámara | A quién enfoca el diálogo y qué debe quedar en cuadro |
| Textos | Claves de la tabla de localización; las líneas completas van en la tabla, no en el código |
| Decisiones | Opciones, condiciones y efecto |
| Banderas | Separar «fija» de «lee»; una bandera que se fija y nunca se lee es deuda |
| Consecuencias | Qué cambia en la escena siguiente o en el final |
| Aceptación | Comprobable por una prueba o por una captura; sin adjetivos |
| Ficha | PCH y clasificación H/A/R/N cuando haya contenido histórico |
| Estado | `Implementado`, `Parcial` o `Pendiente`, con la deuda concreta |

## 5. Ficha de escena

Copiar este bloque por cada escena:

```markdown
### <ID> · <Nombre>

**Lugar y momento:** ...
**Duración:** ... · **Estado:** Implementado / Parcial / Pendiente
**Objetivo narrativo:** ...
**Objetivo del jugador:** ...

**Presentes y bloqueo:**
- ...

**Cámara y sonido:**
- ...

**Textos:**
- `CLAVE`: línea o función.

**Decisiones:**
- ...

**Banderas:**
- Fija: ...
- Lee: ...

**Consecuencias:**
- ...

**Aceptación:**
- [ ] ...
- [ ] ...

**Ficha histórica:** PCH-... · clasificación
**Deuda:** ...
```

## 6. Ficha modelo

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

## 7. Matriz de banderas

| Bandera | Se fija en | Se lee en | Efecto | Prueba |
|---|---|---|---|---|
| `ejemplo` | I.3 | IV.3 | Abre una opción | `test_...` |

Reglas:

- Toda bandera del guion de campaña debe aparecer aquí.
- Si se fija y no se lee, se marca como **deuda** o se elimina.
- Si se lee y no se fija en ninguna escena, es un error de guion.

## 8. Matriz de finales

| Final | Condición | Texto | Variantes |
|---|---|---|---|
| Ejemplo | `bandera_a` y `bandera_b` | `PCH_FINAL_...` | ... |

Reglas:

- Las condiciones se escriben con banderas, no con impresiones.
- Cada final debe tener al menos una prueba que lo alcance.
- Si dos finales pueden cumplirse a la vez, el orden de prioridad se declara.

## 9. Ritmo y duración

| Acto | Duración objetivo | Duración medida | Estado |
|---|---|---|---|
| I | ... | ... | ... |

- La duración se mide con una partida humana, no con la pasada guionizada.
- La pasada guionizada sirve para revisar el arco, no para acreditar duración.

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
- [ ] Cada escena tiene lugar, momento, presentes y bloqueo.
- [ ] Cada escena tiene textos con clave, no literales en código.
- [ ] Cada decisión tiene bandera y consecuencia.
- [ ] Cada bandera que se fija se lee en alguna escena o está marcada como deuda.
- [ ] Cada final tiene condición y prueba.
- [ ] Cada escena tiene criterio de aceptación comprobable.
- [ ] La duración está medida o declarada como no verificada.
- [ ] El contenido histórico tiene ficha y clasificación.
- [ ] La bitácora registra el cambio.
