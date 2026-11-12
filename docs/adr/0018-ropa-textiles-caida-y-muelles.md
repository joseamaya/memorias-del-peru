# ADR-0018 — Ropa: textiles con diseño, caída simulada y manto con muelles

- Estado: Aceptado
- Fecha: 2026-11-12
- Matiza: [ADR-0016](0016-personajes-realistas-makehuman.md) (ropa generada sobre el cuerpo)

## Contexto

Con las cabezas de Rocketbox (ADR-0017), la ropa pasó a ser lo que más delataba a los personajes:

- telas de un solo color con franjas lisas;
- forma rígida, sin caída;
- el manto y la falda se movían pegados al cuerpo.

El 2026-11-12, el responsable del proyecto pidió mejorarla y aprobó tres pasos: textiles, caída de la tela y movimiento.

## Decisión

### 1. Textiles con diseño

`pch_people.py` pinta una textura de tela por personaje (`paint_textile`), con una columna por prenda: unku o anacu, faja, lliclla, manto, tocado y bolsa.

- Los motivos se colocan a la **altura real** de cada prenda en metros: bajo, cintura, hombros.
- Motivos: franjas, zigzag escalonado, rombos de gradas, t'oqapu (solo autoridades) y una trama de hilo.
- La ropa guarda en UV1 sus coordenadas en metros (vuelta al cuerpo y altura) y en UV0.y la prenda.
- El textil viaja en el glTF como color base del material `pch_cloth`. En Godot, `SurfaceMaterials.textile_cloth_material` lo pasa al shader de superficie, que elige la columna y repite el dibujo cada 0,3 m alrededor del cuerpo.
- Los diseños son reconstrucción (R): motivos geométricos inspirados en las piezas de PCH-010, PCH-017 y PCH-018, sin copiar ninguna pieza concreta.

### 2. Caída simulada

- Antes de exportar, la falda, el manto y el borde de la lliclla caen por su peso con la simulación de tela de Blender, con la parte alta de cada prenda sujeta y colisión con el cuerpo. La forma resultante se queda en la malla.
- La falda gana vuelo y resolución para que la tela sobrante forme pliegues.
- En el juego no cuesta nada.

### 3. Manto con muelles

- El generador añade tres cadenas de dos huesos detrás de la espalda (`Cape_L/C/R_1` y `_2`), del hombro a la rodilla, y les da el peso del manto por altura y lado.
- `NpcActor` crea un `SpringBoneSimulator3D` (API nativa de Godot 4.7) con esas cadenas y cápsulas de colisión en la cadera y el pecho. El manto se mece con la inercia del cuerpo.
- **Faldas:** no llevan muelles. Siguen a los muslos como hasta ahora, porque con muelles atravesarían las piernas al caminar y al arrodillarse.

### 4. Revisión de brazos y piernas (2026-11-12)

- **Faldas:**
  - El bajo del anacu ya no sigue a los muslos en un 75 %, lo que la partía en dos perneras al andar. Ahora es un 38 %, con más vuelo, para que se mezca entera sin que asomen las piernas.
  - El unku sigue a los muslos en un 20 %.
  - La tejedora, arrodillada, sigue a los muslos en un 90 %, para que la falda caiga sobre el regazo.
- **Ojotas:** suela con la silueta del pie (talón redondo, más ancha en el metatarso) y tiras finas: una en V desde entre los dedos y otra alrededor del talón.
- **Manos:** el agricultor cierra la mano derecha sobre la chaquitaclla, que pasa por el puño.
- **Tejedora:** brazos hacia abajo y hacia delante, hasta el telar. El extremo del telar sube a la altura de su regazo (0,3 m) y queda más cerca de ella.
- **Doble cara:** la ropa usa `superficie_tela.gdshader`, el mismo código de superficie (`superficie_comun.gdshaderinc`) dibujado por las dos caras, para que se vean el reverso de la tela y las tiras finas.
- **Signo corregido:** el gesto de agotamiento y la postura de tejer inclinaban el tronco hacia atrás.

## Consecuencias

- La ropa pasa de colores planos a textiles andinos con trama, con caída y con un manto que se mueve.
- **Peso:** una textura de textil por personaje, de 768 × 1024 en WebP (unos 430 píxeles por metro; a 1536 × 2048 la memoria de vídeo subía unos 62 MB). Seis huesos más en los personajes con manto, y una simulación de muelles por personaje con manto.
- **Revisión:** los nuevos motivos se anotan en PCH-017 y PCH-018 y deben revisarse con la firma del responsable.
- **Generación más lenta:** la simulación de tela añade unos segundos por personaje.
