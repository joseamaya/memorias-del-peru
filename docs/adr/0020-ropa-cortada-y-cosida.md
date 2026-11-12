# ADR-0020 — Ropa cortada y cosida, con caída en la postura de reposo

- Estado: Aceptado
- Fecha: 2026-11-12
- Matiza: [ADR-0016](0016-personajes-realistas-makehuman.md) (ropa generada sobre el cuerpo) y [ADR-0018](0018-ropa-textiles-caida-y-muelles.md) (caída simulada y textiles)

## Contexto

El responsable del proyecto dijo que partes de la ropa se veían muy mal y pidió modelarla con Blender. En capturas de cerca en el juego se vio la causa: la ropa salía de **deformar el cuerpo**. La parte alta de cada prenda era la piel separada unos centímetros, y el resto eran tubos y cajas.

| Prenda | Defecto |
|---|---|
| Unku | Caja rígida, con hombreras cuadradas y sin caída |
| Manto | Tabla plana colgada de un hombro, que flotaba por delante |
| Lliclla | Jersey de cartón, con los hombros cuadrados |
| Q'ipi | Huevo blanco sin textura ni ataduras |
| Chuspa | Tarjeta plana, con una correa que se separaba del cuerpo |
| Tela en general | Trama de arpillera y un «hilo» pintado que le daba aspecto de mantel de cuadros |

El responsable eligió:

- patrones cosidos;
- hasta 4000 triángulos más por personaje;
- una textura de lana CC0 descargada;
- las fichas como referencia.

## Decisión

### 1. Prendas cortadas como en el telar (`pch_people.py`)

- **Unku** (`tube_garment`):
  - un paño rectangular doblado sobre los hombros, con abertura para la cabeza, cosido a los lados y con sisas;
  - el borde alto sigue la pendiente de cada hombro;
  - un poco de vuelo hacia el bajo siembra los pliegues.
- **Anacu:**
  - el mismo paño, más ancho y hasta el tobillo, cosido bajo los brazos;
  - se sujeta con dos tirantes a los hombros;
  - la tela de la cintura encoge en la simulación, como si la ciñera la faja, y la faja se pone encima de la tela ya ceñida.
- **Lliclla y manto** (`shawl`):
  - un paño echado sobre los hombros que rodea el cuello por detrás;
  - sus dos esquinas quedan prendidas (tupu) o anudadas bajo las clavículas.
- **Q'ipi y chuspa** (`soft_bag`):
  - bolsas de tela llena, de caras abombadas y con arrugas en las esquinas;
  - el bulto se apoya en la espalda;
  - las correas se tienden sobre la ropa ya hecha, con rayos desde delante, desde detrás o desde arriba, y se anudan al pecho.
- **Textil:** cada paño guarda las coordenadas de su patrón (anchura y altura colgado recto). Las franjas y los motivos siguen a la tela al plegarse, en lugar de quedar a una altura fija del mundo.

### 2. Caída en la postura de reposo

1. Cada paño cae con la simulación de tela de Blender en tres tramos: quieto con los brazos en A, mientras los brazos bajan 36° y otra vez quieto.
2. El manto y la lliclla se echan sobre los hombros ya con los brazos abajo y los antebrazos estirados, colgando casi rectos, y caen sobre el cuerpo y la prenda de debajo.
3. Con los brazos abajo, cada vértice toma los pesos del cuerpo en esa postura, suavizados sobre la malla. La malla se devuelve a la pose de reposo del esqueleto invirtiendo el skinning lineal. En el juego, con los brazos bajados, la tela queda como cayó.
4. **Reglas de pesos:**
   - **Bajo de la falda:** sigue a los muslos (unku 0,65, anacu 0,6, tejedora 0,9).
   - **Unku sobre el hombro:** sigue al brazo; por debajo de la sisa, sigue al tronco.
   - **Manto:** por detrás cuelga de los huesos de muelle de ADR-0018.
5. **Ajustes de la simulación**, hallados en pruebas:
   - **Masa y holgura:** masa pequeña por vértice en los paños echados (con más, la tela estira y el paño resbala espalda abajo) y 1 cm de holgura sobre la piel.
   - **Manto:** colisión consigo mismo y rigidez de lana gruesa.
   - **Lliclla:** sin colisión consigo misma y con menos rozamiento; si no, se arruga sobre los hombros.

### 3. Piel tapada

- Se quitan las caras del cuerpo que el unku o el anacu tapan siempre: el tronco y los muslos, desde 12 cm sobre el bajo hasta la sisa, sin brazos ni cuello.
- Una cara se quita solo si un rayo desde ella hacia fuera choca con la prenda.
- Así, al andar, la pierna no asoma a través de la tela, y hay menos triángulos.

### 4. Tejido de lana

- La capa 4 de las texturas de detalle (tejido) pasa de Hessian 230 (arpillera) a **Fabric031** de ambientCG, «large weave wool», con licencia CC0 1.0 (`shared_assets/textures/LICENSE.md`).
- En la ropa se repite cada 33 cm (`SurfaceMaterials.CLOTH_SCALE` = 3).
- La variación de hilo pintada en el textil se reduce a la mitad y pierde las estrías cada 3 píxeles.

## Consecuencias

- **Aspecto:**
  - El unku cuelga de los hombros con pliegues suaves.
  - El manto y la lliclla caen como mantos de verdad, con su cenefa siguiendo el borde.
  - El bulto parece un fardo atado.
- **Coste:** se mide en [docs/08](../08_entorno_y_rendimiento.md). La ropa gana triángulos y el cuerpo pierde los de la piel tapada.
- **Generación:** cada personaje tarda más, porque se hacen dos o tres simulaciones de tela.
- **Pose de reposo:** la ropa se ve deformada en la pose en A, que no aparece en el juego. Todas las animaciones llevan los brazos abajo.
- **Límites:**
  - Las prendas no se simulan en el juego: los pliegues son los de la postura de reposo, y la tela sigue al esqueleto.
  - En gestos amplios de brazos, el borde del manto puede atravesar un poco el antebrazo.
- **Interpretación:** las formas de las prendas siguen las fichas PCH-010, PCH-017 y PCH-018 (rectángulos de telar, sin cortes a medida). Las medidas exactas y la forma de anudar son reconstrucción (R).
