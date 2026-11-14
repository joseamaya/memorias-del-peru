# ADR-0016 — Personajes realistas con MakeHuman (MPFB2) y captura de movimiento de CMU

- Estado: Reemplazado por ADR-0042
- Fecha: 2026-11-12
- Sustituye: en [ADR-0015](0015-personajes-con-esqueleto.md), el cuerpo construido con primitivas y las animaciones procedurales. Se mantiene el contrato de `NpcActor` (animaciones por nombre y mirada).
- Matiza: [ADR-0010](0010-modelos-generados-con-blender.md). Los personajes siguen generándose por script en Blender, pero con el complemento MPFB2 y sus recursos.

## Contexto

Con el esqueleto de ADR-0015, los personajes se mueven, pero siguen viéndose como muñecos: cilindros por brazos, cabeza de diez caras, manos como bolas y ningún rasgo facial. Los jugadores del piloto se quejan de que no se ven realistas. Un generador hecho de primitivas no llega a parecer humano por mucho que se pula.

El 2026-11-12, el responsable del proyecto eligió:

- cuerpos de MakeHuman;
- ropa andina propia;
- captura de movimiento real de CMU.

También autorizó las descargas.

## Opciones consideradas

1. **Mejorar el generador de primitivas.** Rechazada: la mejora sería visible, pero los personajes seguirían siendo estilizados.
2. **Artista 3D o personajes escaneados comprados.** Rechazada por ahora: queda fuera del alcance de los agentes y del presupuesto de la fase. Sigue siendo el camino hacia el fotorrealismo.
3. **MakeHuman (MPFB2) con ropa propia y captura de CMU.** Aceptada.

## Decisión

### Herramienta y recursos

- **MPFB2 2.0.18**, complemento oficial de MakeHuman para Blender: https://extensions.blender.org/add-ons/mpfb/ (SHA-256 `c075b3e9…2dad`).
  - Su código es GPL v3. Se usa solo como herramienta, no se distribuye con el juego y no entra en el repositorio.
  - Se instala en un directorio de usuario de Blender aparte (`BLENDER_USER_RESOURCES`).
- **Recursos del sistema de MakeHuman** (`makehuman_system_assets_cc0.zip`): https://static.makehumancommunity.org/assets/assetpacks/makehuman_system_assets.html.
  - Cada archivo usado declara «explicitly released as CC0 in september 2020».
  - Se usan: malla base, mallas *proxy* de juego (`male1591`, `female1605`), pieles, ojos, cejas y pelo (`short02`, `braid01`).
  - Lo que el juego necesita queda dentro de los `.glb`: mallas, pesos y texturas reducidas. Los recursos originales no se versionan.
- **CMU Graphics Lab Motion Capture Database**, http://mocap.cs.cmu.edu/, cuya portada dice «This dataset of motions is free for all uses».
  - Se usan los archivos originales ASF/AMC, no conversiones de terceros, cuya licencia solo consta de segunda mano.
  - Se acredita la fuente en `LICENSE.md` aunque no se exija.

### Generación (`assets/blender/pch_people.py`)

1. **Cuerpo.**
   - MPFB2 crea el cuerpo con macros por personaje: sexo, edad, complexión y estatura baja y robusta.
   - Esqueleto `cmu_mb` de MPFB2, cuyos huesos coinciden con los del esqueleto de CMU.
   - Malla *proxy* de juego, de unos 3000 triángulos.
2. **Piel y pelo.**
   - La textura de piel se tiñe hacia un moreno andino sobre la de MakeHuman, conservando su detalle.
   - El pelo se tiñe de negro.
   - La apariencia es una interpretación declarada (PCH-018): no hay retratos auténticos.
3. **Ropa andina propia**, generada sobre el cuerpo: unku, anacu con faja, lliclla con tupu, manto, tocados, chuspa, ojotas, bulto y chaquitaclla.
   - Cada prenda sigue las secciones del cuerpo y toma sus pesos del cuerpo más cercano. La falda sigue en parte a los muslos.
   - Los colores salen de la paleta de las fichas.
   - El tejido tiene coordenadas propias (UV2), para que la textura no resbale al moverse.
4. **Animaciones.**
   - Un importador ASF/AMC propio lee la captura.
   - La traslada al esqueleto `cmu_mb` alineando cada hueso desde la pose de reposo de CMU a la del cuerpo.
   - Se recorta un ciclo de cada toma y se hornea a 30 fps en pistas NLA con los nombres de ADR-0015: `idle`, `walk`, `run`, `talk`, `tired`, `weave` y `work`.

### En Godot

- Cada personaje es un `Skeleton3D` con varias mallas: cuerpo, ojos, cejas, pelo y ropa.
- La piel, los ojos y el pelo usan el material importado. El pelo y las cejas recortan por alfa, sin mezcla, para no tener problemas de orden.
- La ropa usa el shader de superficie con tejido por UV2.
- `NpcActor` no cambia de contrato. La mirada usa el hueso `Head`.

### Corrección tras la primera revisión (2026-11-12)

El responsable del proyecto dijo que los personajes «parecen zombis». En las capturas de cerca se veían estas causas, todas corregidas en `pch_people.py`:

| Causa | Corrección |
|---|---|
| Cabeza caída e inclinada a un lado | El cuello inclinado de MakeHuman se sumaba a la captura. Ahora cuello y cabeza siguen sobre todo al pecho (conservan el 30 % del movimiento de la toma) y la cara se nivela: se quita el 75 % del cabeceo y del alabeo. |
| Tronco encorvado | La columna se endereza un 40 % hacia su relación de reposo. |
| Reposo agachado o con pasos | Las tomas 140_06 (en guardia) y 141_20 (con pasos) se sustituyen por los primeros seis segundos de la 82_08 («stand still»). |
| Boca entreabierta que dejaba ver los dientes | Se cierra con objetivos de boca de MakeHuman. Dientes y lengua se quitan, porque asomaban a través de los labios. |
| Iris rojizo | Se oscurece a castaño; el blanco del ojo se aclara. Los ojos y la piel tienen brillo propio en Godot. |
| Dedos abiertos y rígidos | Curvatura relajada fija. |
| Hombros del unku rasgados, con la piel asomando | Sisa con corte vertical limpio que cubre todo el hombro, y borde alisado. |

## Consecuencias

- Personajes con anatomía, cara, manos y ropa con volumen. Su aspecto pasa de figura geométrica a realista de juego independiente; no es fotorrealista.
- **Generar los personajes requiere instalar MPFB2 y sus recursos.** El procedimiento queda en la cabecera de `pch_people.py`. Los modelos que no son personajes siguen saliendo de `pch_models.py` sin complementos.
- **Más peso por personaje:** entre 8900 y 10 600 triángulos y 6–7 mallas, frente a unos 1200 triángulos y una malla.
  - Las texturas van embebidas en WebP (1K) y Godot las importa como Basis Universal, sin extraer archivos sueltos.
  - Los 8 `.glb` suman 6,6 MB.
- **Rendimiento:** en la GPU integrada de referencia, la diferencia con el commit anterior queda dentro del ruido de la medición (docs/08). El objetivo vinculante se sigue cumpliendo con margen.
- **Datos de ritmo:** la velocidad de cada ciclo y el instante de los golpes de trabajo viajan en los «extras» glTF del esqueleto (claves `pch_*`), y `NpcActor` los lee del metadato `extras`.
- **Pelo:** las mujeres llevan pelo largo suelto (`long01`). La trenza de MakeHuman (`braid01`) trae un flequillo moderno que tapa un ojo. Es una desviación declarada respecto a las trenzas de PCH-018.
- La captura de CMU no tiene ninguna toma de tejer arrodillada ni con chaquitaclla:
  - **Tejer:** se compone el cuerpo arrodillado de una toma (23_03) con los brazos de la toma de coser (79_05).
  - **Trabajar:** sale de la toma de cavar (79_04).
  - Las dos son reconstrucciones (R) del gesto.
