# Biblia de la campaña 01 — Pachacútec: La defensa del Cusco

- Estado: **Aprobado (v1.0)** — 2026-11-13
- Sustituye al modelo de museo (ADR-0038) y fija los tres actos (ADR-0039)
- Crónica rectora: **Betanzos** (ADR-0040); Garcilaso y Pachacuti Yamqui, contraste y leyenda
- Documentos de apoyo: [registro histórico](registro_historico.md), [alcance del acto I](alcance_vertical_slice.md), [convenciones históricas](../../../docs/07_convenciones_historicas.md)

Este documento manda sobre el contenido de la campaña. El alcance del vertical
slice se conserva como referencia del acto I: mapa, assets y textos siguen
siendo válidos; su modelo de museo, no.

## 0. Resumen

RPG histórico en primera persona, en tres actos. La Fase 8 entrega 15–20 minutos de arco; el objetivo de 40–50 minutos queda para la fase de contenido. En
total. El jugador es un joven de una llacta del valle del Cusco. Vive la
mañana en que llega la noticia del avance chanca, cruza el paso con la comitiva
y llega al Cusco para la defensa. No sustituye a Cusi Yupanqui ni cambia el
resultado histórico: participa en él.

## 1. Premisa y arco

| Acto | Pregunta dramática | Respuesta |
|---|---|---|
| I. La llacta | ¿Qué haces cuando la noticia llega? | Cumples tus obligaciones y te ofreces a llevar la respuesta |
| II. El paso | ¿Hasta dónde estás dispuesto a llegar? | Cruzas el paso, sobrevives a la emboscada y eliges a quién cargas |
| III. El Cusco | ¿Quién acude cuando la ciudad llama? | Reclutas a los que puedes y sostienes la defensa |

La victoria es la de la tradición: Cusi Yupanqui asume la defensa y vence. El
juego lo presenta como versión de cronistas, con la discrepancia de Garcilaso
en la «Memoria» (PCH-002, PCH-015).

## 2. El jugador

Joven de la llacta, sin nombre canónico ni retrato. No hay creación de
personaje: **el primer encargo que completa fija su especialidad** y le da +1 en
la habilidad correspondiente, un objeto y una línea de diálogo distinta en el
acto II.

### 2.1 Los cuatro encargos y su habilidad

| Encargo | Habilidad | Objeto inicial |
|---|---|---|
| Agua del manantial | Monte | Cantimplora de calabaza |
| Maíz para moler | Oficio | Puñado de maíz |
| Lana y telar | Palabra | Ovillo de lana |
| Pirca del corral | Monte / Oficio | Cuerda de ichu |

El «oficio» es una bandera narrativa (`oficio_agua`, `oficio_maiz`,
`oficio_telar`, `oficio_pirca`), no una clase. No cierra opciones: cambia una
línea de diálogo y el objeto con el que empiezas el acto II.

### 2.2 El compañero

Otro joven de la llacta que se suma a la comitiva. Nombre y género pendientes
de la convención quechua (el diccionario de referencia sigue sin elegirse). Es
el hilo emocional: su confianza (`confianza_companero`, 0–2) se gana en el acto
I y se pierde o se gana en el acto II. En el acto III reúne a los jóvenes si la
confianza es alta.

## 3. Sistemas

### 3.1 Estado y habilidades

| Valor | Rango | Qué hace |
|---|---|---|
| Salud | 0–100 | A 0, punto de control. Sin barra fija: viñeta, respiración y paso |
| Aliento | 0–100 | Ya existe (`StaminaComponent`). Correr, cargar, honda |
| Ánimo | 0–100 | Afecta al pulso y a la moral del grupo; sube con chicha y descanso |

Habilidades, de 0 a 5, **suben por uso** (3, 8, 15, 24 y 35 usos):

| Habilidad | Uso | Efecto |
|---|---|---|
| Honda | Acertar con la honda | Precisión, tiempo de carga y daño |
| Mano | Golpear o bloquear | Daño y aguante del escudo |
| Palabra | Convencer en diálogo | Opciones y éxito al reclutar |
| Oficio | Reparar, moler, tejer | Encargos y objetos |
| Monte | Caminar, cargar, esquivar | Aliento, sigilo y carga |

### 3.2 Reputación

Tres grupos, de −2 a +2: **llacta**, **comitiva** y **Cusco**. Abre o cierra
opciones de diálogo y decide cuántos aliados acuden en el acto III. No se
muestra como número; se lee en el trato de los personajes.

### 3.3 Inventario

Ocho huecos y tres equipados (mano principal, mano torpe, prenda). Sin peso, sin
loot aleatorio. Los objetos de encargo no ocupan hueco.

| Objeto | Tipo | Efecto |
|---|---|---|
| Honda | Equipo | Arma a distancia; consume piedras |
| Porra | Equipo | Cuerpo a cuerpo |
| Escudo | Equipo | Bloqueo; consume aliento |
| Piedras | Munición | 12 por montón |
| Coca | Consumible | +25 aliento, −10 ánimo por el amargor |
| Chicha | Consumible | +20 ánimo, +10 salud |
| Maíz | Consumible | +15 salud |
| Agua | Consumible | +10 aliento |
| Hierbas | Consumible | +25 salud |
| Cuerda | Herramienta | Reparar, atar, descender |
| Q'ipi | Encargo | Carga de la comitiva; pesa en el aliento |
| Mensaje | Encargo | La respuesta de la llacta |

### 3.4 Diálogo

Nodos con 1–4 opciones; condiciones por bandera, objeto, habilidad o
reputación; efectos sobre banderas, reputación, objetos y encargos. Sin
retratos ni voces: la cámara sigue en primera persona y el NPC mira al jugador.
Los textos viven en las tablas de localización, nunca en el código.

### 3.5 Diario

Tecla **J**. Dos pestañas:

- **Encargos**: activos y cumplidos, sin marcadores en el mundo.
- **Memoria**: lo aprendido, con su sello H/A/R/N y su fuente. Aquí viven los
  nueve textos del museo, desbloqueados por diálogo, no por entrar en una zona.

### 3.6 Combate

| Arma | Alcance | Daño | Ritmo |
|---|---|---|---|
| Honda | 3–28 m | 18–32 según habilidad y carga | Carga 0,6–1,2 s; piedra |
| Porra | 1,6 m | 22–34 | Golpe y bloqueo; aliento |
| Escudo | — | Bloquea 70 % | Consume aliento; no ataca |

- Enemigos con **moral**: huyen por debajo de 25 y no se persigue.
- Salud enemiga: 60 (explorador) a 100 (guerrero).
- Sin sangre ni desmembramientos. Heridas: sangrado lento y paso más lento.
- Muerte: fundido y punto de control, conservando inventario y encargos.
- Sin HUD: el ánimo se oye en la respiración; la salud, en la viñeta; la
  munición, en la mano.

### 3.7 Puntos de control y selector de acto

- Punto de control al empezar cada acto y en la mitad del acto II y del III.
- `--act=1|2|3` y `--checkpoint=paso|ciudad` para desarrollo y pruebas.
- Sin guardado completo en esta etapa: el estado vive en memoria.

## 4. Acto I — La llacta

**Duración:** 12–15 min. **Mapa:** la llacta actual, con una casa abierta y
objetos de encargo. **Sin combate.**

### 4.1 Secuencia

| # | Beat | Qué ocurre | Sistemas |
|---|---|---|---|
| 1 | Despertar | La plaza vive. Un vecino saluda y explica el día | Diálogo, cámara |
| 2 | Los encargos | Cuatro tareas; hay que completar tres | Inventario, aliento, habilidades |
| 3 | El quero y la ofrenda | Opcionales: servir chicha, dejar coca y maíz | Reputación, ritual |
| 4 | El mensajero | Llega agotado; la noticia; el curaca llama a los principales | Evento existente + diálogo |
| 5 | La partida | El jugador se ofrece a llevar la respuesta; se forma la columna | Diálogo, transición |

### 4.2 Los encargos

| Encargo | Dónde | Qué se hace | Habilidad |
|---|---|---|---|
| Agua | Manantial al este | Dos viajes con el cántaro; el peso consume aliento | Monte |
| Maíz | Casa de las mujeres | Desgranar y moler al ritmo de la mano | Oficio |
| Telar | Telar de la tejedora | Traer lana y sostener el telar mientras se cruza la trama | Palabra / Oficio |
| Pirca | Corral del noroeste | Acarrear piedras y cerrar el hueco | Monte / Oficio |

- Al completar el primero: se fija el oficio, +1 a la habilidad y un objeto.
- Al completar el tercero: el mensajero llega.
- Cada encargo da +1 de reputación con la llacta y una entrada de Memoria.

### 4.3 El mensajero

Se reutiliza la máquina de estados actual (`MessengerEvent`) con dos cambios:

- El disparo deja de depender de las tarjetas: lo lanza el tercer encargo.
- Tras la noticia, el curaca pregunta quién llevará la respuesta. Todas las
  opciones llevan a ir, pero cambian la reputación:

| Opción | Efecto |
|---|---|
| «Voy yo» | +1 comitiva |
| «Iré con vosotros» | +1 llacta |
| «No sé si sirvo» | El curaca insiste; 0 |

### 4.4 Estado al cerrar

Banderas: `oficio_*`, `encargos_hechos` (0–4), `ofrecio` (bool), `bebio`
(bool), `reputacion_llacta`, `reputacion_comitiva`, `confianza_companero`.

### 4.5 Textos y fichas

Los nueve textos del museo se reparten: quero y chicha en la escena de la
bebida; ofrenda en el adoratorio; telar con la tejedora; vivienda con la
anciana; terraza con el agricultor; corral con el pastor; plaza con el curaca;
mirador con el mensajero. Fichas: PCH-004, 005, 007, 008, 010, 012, 016, 019,
021 y 022.

## 5. Acto II — El paso

**Duración:** 12–15 min. **Mapa nuevo:** paso de montaña de ~80 × 80 m, en
gris. **Primer combate.**

### 5.1 Secuencia

| # | Beat | Qué ocurre | Sistemas |
|---|---|---|---|
| 1 | La marcha | La columna sube; diálogo con el curaca y el compañero | Diálogo con condiciones |
| 2 | El campamento | Noche y frío. Descansar o seguir; compartir coca o chicha | Inventario, ánimo, aliento |
| 3 | La emboscada | Cuatro exploradores chancas cortan el paso | Combate con honda, sigilo |
| 4 | La consecuencia | Un hombre herido y la carga de maíz | Decisión con efecto |
| 5 | El Cusco al fondo | Desde la cresta se ve la ciudad | Transición |

### 5.2 El paso

- Sendero en zigzag, roquedales para cubrirse, un refugio de piedra abierto y
  un arroyo.
- El refugio y el sendero son reconstrucción (R): no se llama tambo ni se
  presenta como infraestructura imperial.
- En gris: terreno, rocas, queñua e ichu; sin arte nuevo.

### 5.3 La emboscada

- Cuatro exploradores chancas (salud 60, moral 80) con hondas y porras.
- El jugador puede:
  - **Combatir** desde las rocas; la honda es el arma principal.
  - **Esquivar** por la cornisa con Monte ≥ 2; evita el combate y pierde la carga.
  - **Distraer** con el q'ipi o una piedra; separa a dos enemigos.
- Un explorador herido puede ser **perdonado** (`scout_spared`): no cambia la
  batalla, pero sí una línea del acto III.
- Los enemigos huyen al bajar la moral; no se persigue.

### 5.4 La consecuencia

| Decisión | Efecto |
|---|---|
| Cargar al herido | −20 aliento al caminar; `herido_salvado`; aparece en el Cusco |
| Dejarlo con agua y coca | `herido_dejado`; −1 comitiva; no aparece |
| Conservar el maíz | Más lento; `maiz_guardado`; +1 aliado en el Cusco |
| Abandonar el maíz | Rápido; `maiz_abandonado`; sin aliado de los ayllus |

### 5.5 Estado al cerrar

Banderas: `paso_cruzado`, `scout_spared`, `herido_salvado` / `herido_dejado`,
`maiz_guardado` / `maiz_abandonado`, `descanso` (bool), `confianza_companero`.

### 5.6 Fichas

PCH-002 (guerra chanca), PCH-003 (los chancas), PCH-011 (mensajero). Nuevas:
armas andinas, coca, el paso y el refugio.

## 6. Acto III — El Cusco

**Duración:** 16–18 min. **Mapa nuevo:** Cusco de 1438, ~150 × 150 m, en gris.
**Batalla y cierre.**

### 6.1 El Cusco de 1438

No es la ciudad monumental, que es posterior a Pachacútec: es el centro de un
señorío en consolidación (PCH-022). Plaza grande de tierra apisonada, casas de
piedra y ichu, terrazas, un santuario modesto al sol (R) y un muro bajo. Se
construye con los constructores de la llacta a mayor escala.

### 6.2 Secuencia

| # | Beat | Qué ocurre | Sistemas |
|---|---|---|---|
| 1 | La llegada | Ciudad llena de refugiados y hombres. Se entrega la respuesta; aparece Cusi Yupanqui | Reputación, diálogo |
| 2 | La ciudad dividida | La élite ha huido. Hay que reclutar a tres grupos | Palabra, favores |
| 3 | La víspera | Noche: hablar con los tuyos, la leyenda de los pururaucas, ofrenda, dormir | Ritual, diálogo, cierre emocional |
| 4 | La defensa | Sostener la entrada, proteger el santuario, contraofensiva | Combate, aliados, moral |
| 5 | El epílogo | Victoria; variantes personales | Banderas |

### 6.3 El reclutamiento

| Grupo | Cómo se consigue | Aliado |
|---|---|---|
| Ayllus de la ciudad | Entregar el maíz guardado o reputación Cusco ≥ 1 | +1 |
| Curaca vecino | Palabra ≥ 2 y reputación ≥ 1; si no, se niega (PCH-017) | +1 |
| Jóvenes | `confianza_companero` ≥ 1 y el compañero vivo | +1 |

Cada aliado reduce una oleada o acorta la batalla. Con 0 aliados, la defensa es
posible pero dura más y el epílogo es más amargo.

### 6.4 La víspera y la leyenda

Antes de la defensa, una anciana o un veterano cuenta la historia de los
**pururaucas**: las piedras que se volvieron guerreros para salvar al Cusco. Es
una escena opcional de diálogo; el jugador puede escuchar y desbloquear
`mem_pururaucas` en la «Memoria».

- Fuente: Pachacuti Yamqui Salcamaygua, *Relación de antigüedades deste reyno del
  Pirú* (c. 1613), en *Tres relaciones de antigüedades peruanas*, Madrid, 1879,
  pp. 271–272; ficha PCH-031, **N / H (tradición)**, verificada.
- Se presenta como **lo que se cuenta**, no como un hecho. Ninguna piedra se
  transforma en pantalla ni cambia la batalla.
- La arenga de Cusi Yupanqui se parafrasea; la «Memoria» advierte que es
  elaboración literaria de las crónicas, no una transcripción.
- Si PCH-031 no se verifica, la escena se retira; no se inventa una versión.

### 6.5 La defensa

- **Fase 1 — la entrada:** dos oleadas de exploradores y un guerrero. El
  jugador sostiene con honda y piedras; los aliados cubren los flancos.
- **Fase 2 — el santuario:** los chancas rodean; el jugador elige entre
  proteger el santuario o llevar la orden que cierra la trampa. La elección
  cambia el epílogo, no la victoria.
- **Contraofensiva:** scripted; Cusi Yupanqui dirige. El jugador no lo sustituye.
- Sin aliados, las oleadas son más numerosas; con tres, la fase 1 termina antes.

### 6.6 Epílogo

La victoria es fija. Varían tres cosas:

| Bandera | Efecto en el epílogo |
|---|---|
| `herido_salvado` | El herido del paso vuelve a la llacta contigo |
| `companero_vivo` | El compañero aparece en la memoria final |
| `aliados` (0–3) | El texto de la asamblea cambia; con 3, el curaca vecino reconoce su error |

La Memoria cierra con la versión de Garcilaso y la nota de que la escala del
conflicto está debatida (PCH-002, PCH-003).

### 6.7 Fichas

PCH-001 (Cusi Yupanqui), PCH-002, PCH-003, PCH-022. Nuevas: Cusco de 1438,
armas, armadura, batalla, coca, chancas guerreros y PCH-031 (pururaucas,
leyenda N / H).

## 7. Elenco

| Personaje | Papel | Actos |
|---|---|---|
| El jugador | Joven de la llacta | I–III |
| El compañero | Vínculo emocional; recluta jóvenes | I–III |
| Curaca de la llacta | Autoridad local; parte al Cusco | I–III |
| Hombres principales | Comitiva | I–III |
| Tejedora, agricultor, pastor, anciana | Oficios y Memoria | I |
| Mensajero | La noticia | I |
| Cusi Yupanqui | Dirige la defensa; no es el jugador | III |
| Curaca vecino | Se niega a ayudar (PCH-017) | III |
| Exploradores y guerreros chancas | Antagonista colectivo, sin caricatura | II–III |

## 8. Objetos

Además de los de §3.3: cántaro, piedra de moler, lana, ovillo, cuerda de ichu,
q'ipi, mensaje, ofrenda de coca y maíz, hierbas, calabaza de agua.

## 9. Mapas

| Acto | Escenario | Estado inicial |
|---|---|---|
| I | Llacta actual | Existe; se abre una casa y se añaden objetos |
| II | Paso de montaña | Gris: terreno, rocas, sendero, refugio, arroyo |
| III | Cusco de 1438 | Gris: plaza, 12–15 casas, terrazas, santuario, muro |

## 10. Fichas históricas necesarias

| Ficha nueva | Clasificación | Nota |
|---|---|---|
| Armas andinas: honda, porra, escudo | A / R | Forma y uso documentados; la fabricación del juego es R |
| Armadura acolchada | A / R | Solo si se representa |
| El paso y el refugio de piedra | R | No es un tambo |
| El Cusco de 1438 | A / R | Amplía PCH-022 |
| La coca: masticar y compartir | A / R | Uso ritual y social |
| La batalla: representación | H / R | Versión de cronistas; escala debatida |
| Los chancas como guerreros | H / R | Sin caricatura |

Ninguna entra al juego sin estado «verificado».

## 11. Pruebas

| Nivel | Qué |
|---|---|
| Unitarias | Inventario, condiciones de diálogo, subida de habilidad, daño y moral, reputación |
| Por acto | Carga, objetivo principal, cero bloqueos, textos con clave |
| Del arco | Partida guionizada de los tres actos (~45 min), decisiones fijas |
| Rendimiento | Cusco con multitud y batalla |
| Histórico | Todas las fichas nuevas verificadas y citadas |
| Manual | Una partida completa del autor, cuestionario y umbrales de ADR-0031 |

## 12. Producción

| Fase | Contenido | Semanas |
|---|---|---|
| 6 | Núcleo RPG y acto I | 6–7 |
| 7 | Actos II y III en gris + arco jugable | 4–5 |
| 8 | Arte, audio, equilibrio y validación | 6–8 |

## 13. Fuera de alcance

- Guardado completo, multijugador, mando, VR, móviles.
- Niveles, XP, loot aleatorio, magia, crafting profundo.
- Diálogo con voz, retratos o árboles enormes.
- Combate a caballo, asedios a escala real, pururaucas como mecánica.
- Cambiar el resultado histórico.

## 14. Aprobación

Aprobado por el responsable del proyecto el 2026-11-13 como diseño de los tres
actos. Cualquier cambio de acto, sistema o final requiere otro ADR o una nueva
versión de este documento.
