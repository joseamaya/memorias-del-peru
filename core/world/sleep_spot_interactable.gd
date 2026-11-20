class_name SleepSpotInteractable
extends Interactable
## Lecho doméstico: dormir lleva el reloj a la mañana siguiente.
##
## No conoce la campaña. Pide el descanso al nodo del grupo
## `campaign_session`, que decide reloj, guardado y aviso; si no hay sesión
## (otras escenas o pruebas sin campaña), el lecho no se puede usar.
##
## La geometría la pone la sala: poyo bajo de piedra con estera de totora y
## manta doblada (PCH-041), no una cama con patas. Aquí solo se declara el
## volumen que se puede enfocar.

const SIZE: Vector3 = Vector3(2.2, 0.5, 2.0)
const TEXT_KEY: StringName = &"UI_SLEEP"
const SESSION_GROUP: StringName = &"campaign_session"
const SESSION_METHOD: StringName = &"rest_until_morning"


func _ready() -> void:
	add_to_group(&"sleep_spot")
	highlight_parent_if_empty = false
	_build_collider()
	_build_label()


## El lecho solo responde si hay una sesión de campaña que sepa descansar.
func is_available() -> bool:
	var session: Node = _session()
	return session != null and session.has_method(SESSION_METHOD)


func interact(_interactor: Node3D) -> void:
	var session: Node = _session()
	if session != null and session.has_method(SESSION_METHOD):
		session.call(SESSION_METHOD)


func get_interaction_text() -> String:
	return tr(String(TEXT_KEY))


## Tamaño del volumen que se puede enfocar. Lo comprueba la prueba de interiores
## para que el lecho no vuelva a crecer a una cama con patas.
func get_collider_size() -> Vector3:
	return SIZE


func _session() -> Node:
	if not is_inside_tree():
		return null
	return get_tree().get_first_node_in_group(SESSION_GROUP)


func _build_collider() -> void:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = "Body"
	var shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	body.add_child(shape)
	body.position = Vector3(0.0, SIZE.y * 0.5, 0.0)
	add_child(body)


func _build_label() -> void:
	var label: Label3D = Label3D.new()
	label.name = "Label"
	label.text = get_interaction_text()
	label.font_size = 32
	label.pixel_size = 0.004
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.position = Vector3(0.0, SIZE.y + 0.4, 0.0)
	add_child(label)
