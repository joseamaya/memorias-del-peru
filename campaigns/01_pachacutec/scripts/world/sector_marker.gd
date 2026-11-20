class_name CampaignSectorMarker
extends Node3D
## Marcador de blockout de un sector de la campaña 01.
##
## La escena del sector se coloca en su posición mundial; este nodo busca el
## terreno regional para apoyar el marcador y la etiqueta. No es contenido
## definitivo: sirve para validar streaming, escala y presupuesto.

@export var sector_id: StringName = &""
@export var display_name: String = ""
@export var classification: String = ""
@export var color: Color = Color.WHITE


func _ready() -> void:
	var ground: float = 0.0
	var region: CampaignRegion = (
		get_tree().get_first_node_in_group(&"campaign_region") as CampaignRegion
	)
	if region != null:
		ground = region.height_at(global_position.x, global_position.z)
	var marker: MeshInstance3D = MeshInstance3D.new()
	marker.name = "SectorMarker"
	marker.set_meta(&"blockout_kind", "SectorMarker")
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = 5.0
	mesh.bottom_radius = 9.0
	mesh.height = 24.0
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	mesh.material = material
	marker.mesh = mesh
	marker.position = Vector3(0.0, ground + 12.0, 0.0)
	add_child(marker)
	var label: Label3D = Label3D.new()
	label.text = "%s · %s" % [display_name, classification]
	label.font_size = 96
	label.pixel_size = 0.22
	label.outline_size = 20
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.position = Vector3(0.0, ground + 32.0, 0.0)
	add_child(label)
