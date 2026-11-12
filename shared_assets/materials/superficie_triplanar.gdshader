// Superficie con texturas de detalle en proyección triplanar (alcance §6.2).
//
// Las texturas viven en dos Texture2DArray (shared_assets/textures): detalle de
// color relativo a su media (×0,5) con la rugosidad en alfa, y normales en
// convención OpenGL. El color final es el color por vértice (o el tinte)
// multiplicado por el detalle, así que la paleta de cada modelo se conserva.
//
// Capa elegida por:
// - fixed_layer >= 0: una capa fija (terreno, muros, cajas).
// - fixed_layer < 0: la clase de superficie del modelo, guardada en UV.x por el
//   generador de Blender (capa + 1; 0 = sin textura).
// El terreno añade una capa de pendiente (steep_layer) y otra superpuesta en
// rectángulos con borde irregular (overlay_layer: plaza y caminos).
// La vegetación se mece con el viento (wind_bend > 0): el desplazamiento crece
// con el cuadrado de la altura, así que la base de la mata o el tronco no se
// mueve.
shader_type spatial;

#include "res://shared_assets/materials/superficie_comun.gdshaderinc"
