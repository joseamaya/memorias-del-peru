class_name ItemDefinition
extends Resource
## Definición de un objeto del RPG. No es una instancia: el inventario guarda
## referencias a estas definiciones y su cantidad.
##
## Los textos no viven aquí: [member name_key] y [member description_key] son
## claves de la tabla de localización y la UI las traduce con `tr()`.

enum Category {
	CONSUMABLE,
	AMMO,
	EQUIPMENT,
	TOOL,
	QUEST,
}

enum Slot {
	NONE,
	MAIN_HAND,
	OFF_HAND,
	GARMENT,
}

## Identificador estable y único del objeto (por ejemplo, `&"coca"`).
@export var id: StringName = &""
## Clave de localización del nombre.
@export var name_key: StringName = &""
## Clave de localización de la descripción.
@export var description_key: StringName = &""
## Categoría de uso.
@export var category: Category = Category.CONSUMABLE
## Hueco de equipo, solo para [constant Category.EQUIPMENT].
@export var slot: Slot = Slot.NONE
## Cuántos caben en un hueco. 1 significa que no se apila.
@export_range(1, 99, 1) var max_stack: int = 1
## Salud que restaura al consumirse.
@export_range(0.0, 100.0, 1.0) var health_restore: float = 0.0
## Aliento que restaura al consumirse.
@export_range(0.0, 100.0, 1.0) var stamina_restore: float = 0.0
## Cambio de ánimo al consumirse; puede ser negativo.
@export_range(-100.0, 100.0, 1.0) var morale_change: float = 0.0


## Indica si el objeto se puede consumir.
func is_consumable() -> bool:
	return category == Category.CONSUMABLE


## Indica si el objeto se puede equipar.
func is_equipment() -> bool:
	return category == Category.EQUIPMENT
