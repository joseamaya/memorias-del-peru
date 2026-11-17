class_name StaticMeshBatch
extends Node3D
## Fusiona las mallas estáticas hijas en una sola malla por material o tinte.
##
## Las casas del Cusco y de la llacta comparten modelos y materiales, pero cada
## instancia es un [MeshInstance3D] propio: el renderer paga una llamada de
## dibujo (y otra de sombra) por casa y por prop. Este nodo hornea las mallas
## visibles en el espacio del lote, las agrupa por material/tinte y oculta los
## originales. Las colisiones no se tocan: siguen en sus cuerpos estáticos.
##
## Se usa como padre de las casas (`Houses`). No fusiona MultiMeshes, mallas con
## esqueleto ni nada invisible; en el servidor Dummy no hace nada.

## Nodo de destino de las mallas fusionadas; si es nulo, se usa este nodo.
@export var target: Node3D = null


func _ready() -> void:
	# Las casas y sus props se añaden después de este nodo; el deferred corre al
	# final del fotograma, cuando los ModelSlot ya cargaron sus GLB.
	call_deferred("_merge")


func _merge() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var groups: Dictionary[String, Dictionary] = {}
	for node: Node in find_children("*", "MeshInstance3D", true, false):
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue
		if not mesh_instance.is_visible_in_tree():
			continue
		if mesh_instance.name.contains("convcol"):
			continue
		# Las mallas con skin no son estáticas: se dejan como están para no
		# romper el skinning.
		if mesh_instance.skin != null:
			continue
		var material: Material = mesh_instance.material_override
		if material == null and mesh_instance.mesh.get_surface_count() > 0:
			material = mesh_instance.mesh.surface_get_material(0)
		var key: String = _group_key(material, mesh_instance.mesh)
		if not groups.has(key):
			var fresh: Array[MeshInstance3D] = []
			groups[key] = {"material": material, "meshes": fresh}
		var entry: Dictionary = groups[key]
		var meshes: Array = entry["meshes"]
		meshes.append(mesh_instance)
	var parent: Node3D = target if target != null else self
	for key: String in groups:
		var entry: Dictionary = groups[key]
		var meshes: Array = entry["meshes"]
		if meshes.is_empty():
			continue
		var surface: SurfaceTool = SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		for mesh_instance: MeshInstance3D in meshes:
			var local: Transform3D = parent.global_transform.affine_inverse() * mesh_instance.global_transform
			for index: int in range(mesh_instance.mesh.get_surface_count()):
				surface.append_from(mesh_instance.mesh, index, local)
		var merged: ArrayMesh = surface.commit()
		if merged == null or merged.get_surface_count() == 0:
			continue
		var output: MeshInstance3D = MeshInstance3D.new()
		output.name = "Merged_%s" % key.replace(":", "_").replace(".", "_")
		output.mesh = merged
		var group_material: Material = entry["material"]
		output.material_override = group_material
		output.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		parent.add_child(output)
		for mesh_instance: MeshInstance3D in meshes:
			mesh_instance.visible = false


## Clave de agrupación: el tinte del shader si existe, o el material compartido.
## La superficie importa porque [SurfaceTool] necesita formatos compatibles.
static func _group_key(material: Material, mesh: Mesh) -> String:
	var key: String = "none"
	if material is ShaderMaterial:
		var tint: Variant = (material as ShaderMaterial).get_shader_parameter("tint")
		if tint != null:
			key = "tint:%s" % str(tint)
		else:
			key = "mat:%d" % material.get_instance_id()
	elif material != null:
		key = "mat:%d" % material.get_instance_id()
	var array_mesh: ArrayMesh = mesh as ArrayMesh
	if array_mesh != null and array_mesh.get_surface_count() > 0:
		key += ":%d" % (array_mesh.surface_get_format(0) & Mesh.ARRAY_FORMAT_COLOR)
	return key
