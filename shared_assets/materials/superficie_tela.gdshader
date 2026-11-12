// Ropa de los personajes: el mismo shader de superficie, dibujado por las dos
// caras. La tela es fina y desde muchos ángulos se ve su reverso: el forro del
// manto, el interior de las faldas y las tiras de las ojotas.
shader_type spatial;
render_mode cull_disabled;

#include "res://shared_assets/materials/superficie_comun.gdshaderinc"
