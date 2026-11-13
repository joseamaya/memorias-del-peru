extends RefCounted
## Comprueba el diálogo: líneas, condiciones, efectos, opciones de una sola vez
## y cierre (ADR-0038).


func _node(node_id: StringName, text_key: StringName, next_id: StringName = &"end") -> DialogueNode:
	var node: DialogueNode = DialogueNode.new()
	node.id = node_id
	node.speaker_key = &"PCH_NPC"
	node.text_key = text_key
	node.next_id = next_id
	return node


func _choice(text_key: StringName, next_id: StringName) -> DialogueChoice:
	var choice: DialogueChoice = DialogueChoice.new()
	choice.text_key = text_key
	choice.next_id = next_id
	return choice


func _condition(kind: DialogueCondition.Kind, key: StringName, minimum: int = 1) -> DialogueCondition:
	var condition: DialogueCondition = DialogueCondition.new()
	condition.kind = kind
	condition.key = key
	condition.minimum = minimum
	return condition


func _effect(kind: DialogueEffect.Kind, key: StringName, amount: int = 1) -> DialogueEffect:
	var effect: DialogueEffect = DialogueEffect.new()
	effect.kind = kind
	effect.key = key
	effect.amount = amount
	return effect


func _graph(nodes: Array[DialogueNode]) -> DialogueGraph:
	var graph: DialogueGraph = DialogueGraph.new()
	graph.entry_id = &"start"
	graph.nodes = nodes
	return graph


func test_dialogue_linear() -> bool:
	var first: DialogueNode = _node(&"start", &"LINE_ONE", &"second")
	var second: DialogueNode = _node(&"second", &"LINE_TWO", &"end")
	var graph: DialogueGraph = _graph([first, second])
	var runner: DialogueRunner = DialogueRunner.new()
	var lines: Array[StringName] = []
	var finished: Array[bool] = [false]
	runner.line_shown.connect(func(_speaker: StringName, text: StringName) -> void: lines.append(text))
	runner.finished.connect(func() -> void: finished[0] = true)
	var ok: bool = runner.start(graph)
	ok = ok and lines == [&"LINE_ONE"]
	ok = ok and runner.advance()
	ok = ok and lines == [&"LINE_ONE", &"LINE_TWO"]
	ok = ok and runner.advance()
	ok = ok and finished[0] and not runner.is_active()
	runner.free()
	return ok


func test_dialogue_conditions() -> bool:
	var start: DialogueNode = _node(&"start", &"LINE", &"end")
	var always: DialogueChoice = _choice(&"OPT_ALWAYS", &"end")
	var flag_choice: DialogueChoice = _choice(&"OPT_FLAG", &"end")
	var flag_condition: DialogueCondition = _condition(DialogueCondition.Kind.FLAG, &"vio_mensajero")
	var flag_conditions: Array[DialogueCondition] = [flag_condition]
	flag_choice.conditions = flag_conditions
	var skill_choice: DialogueChoice = _choice(&"OPT_SKILL", &"end")
	var skill_condition: DialogueCondition = _condition(DialogueCondition.Kind.SKILL, &"honda")
	var skill_conditions: Array[DialogueCondition] = [skill_condition]
	skill_choice.conditions = skill_conditions
	var choices: Array[DialogueChoice] = [always, flag_choice, skill_choice]
	start.choices = choices
	var graph: DialogueGraph = _graph([start])
	var character: CharacterState = CharacterState.new()
	var runner: DialogueRunner = DialogueRunner.new()
	runner.character = character
	var ok: bool = runner.start(graph)
	ok = ok and runner.get_visible_choice_text_keys() == [&"OPT_ALWAYS"]
	character.register_skill_use(&"honda", 3)
	runner.set_flag(&"vio_mensajero", 1)
	runner.start(graph)
	ok = ok and runner.get_visible_choice_text_keys() == [&"OPT_ALWAYS", &"OPT_FLAG", &"OPT_SKILL"]
	character.free()
	runner.free()
	return ok


func test_dialogue_choice_effects() -> bool:
	var start: DialogueNode = _node(&"start", &"LINE", &"end")
	var choice: DialogueChoice = _choice(&"OPT", &"end")
	var flag_effect: DialogueEffect = _effect(DialogueEffect.Kind.SET_FLAG, &"acepto", 1)
	var reputation_effect: DialogueEffect = _effect(DialogueEffect.Kind.REPUTATION, &"", 1)
	reputation_effect.group = &"llacta"
	var effects: Array[DialogueEffect] = [flag_effect, reputation_effect]
	choice.effects = effects
	var choices: Array[DialogueChoice] = [choice]
	start.choices = choices
	var graph: DialogueGraph = _graph([start])
	var character: CharacterState = CharacterState.new()
	var runner: DialogueRunner = DialogueRunner.new()
	runner.character = character
	var ok: bool = runner.start(graph)
	ok = ok and runner.choose(0)
	ok = ok and runner.has_flag(&"acepto")
	ok = ok and character.get_reputation(&"llacta") == 1
	character.free()
	runner.free()
	return ok


func test_dialogue_item_condition_and_effect() -> bool:
	var start: DialogueNode = _node(&"start", &"LINE", &"end")
	var choice: DialogueChoice = _choice(&"OPT", &"end")
	var condition: DialogueCondition = _condition(DialogueCondition.Kind.ITEM, &"coca")
	var conditions: Array[DialogueCondition] = [condition]
	choice.conditions = conditions
	var effect: DialogueEffect = _effect(DialogueEffect.Kind.ITEM_REMOVE, &"coca", 1)
	var effects: Array[DialogueEffect] = [effect]
	choice.effects = effects
	var choices: Array[DialogueChoice] = [choice]
	start.choices = choices
	var graph: DialogueGraph = _graph([start])
	var inventory: Inventory = Inventory.new()
	var item: ItemDefinition = ItemDefinition.new()
	item.id = &"coca"
	item.max_stack = 3
	inventory.add(item, 1)
	var runner: DialogueRunner = DialogueRunner.new()
	runner.inventory = inventory
	var ok: bool = runner.start(graph)
	ok = ok and runner.get_visible_choice_text_keys() == [&"OPT"]
	ok = ok and runner.choose(0)
	ok = ok and not inventory.has(&"coca")
	runner.free()
	inventory.free()
	return ok


func test_dialogue_choice_once() -> bool:
	var start: DialogueNode = _node(&"start", &"LINE", &"end")
	var ask: DialogueChoice = _choice(&"OPT_ASK", &"answer")
	ask.once = true
	var ask_choices: Array[DialogueChoice] = [ask]
	start.choices = ask_choices
	var answer: DialogueNode = _node(&"answer", &"ANSWER", &"start")
	var graph: DialogueGraph = _graph([start, answer])
	var runner: DialogueRunner = DialogueRunner.new()
	var ok: bool = runner.start(graph)
	ok = ok and runner.choose(0)
	ok = ok and runner.get_current_node().id == &"answer"
	ok = ok and runner.advance()
	ok = ok and runner.get_current_node().id == &"start"
	ok = ok and runner.get_visible_choice_text_keys().is_empty()
	ok = ok and runner.advance()
	ok = ok and not runner.is_active()
	runner.free()
	return ok


func test_dialogue_rejects_unknown_entry() -> bool:
	var runner: DialogueRunner = DialogueRunner.new()
	var graph: DialogueGraph = _graph([])
	var ok: bool = not runner.start(graph)
	ok = ok and not runner.start(null)
	runner.free()
	return ok


func test_dialogue_item_add_and_negated_condition() -> bool:
	var start: DialogueNode = _node(&"start", &"LINE", &"end")
	var choice: DialogueChoice = _choice(&"OPT", &"end")
	var condition: DialogueCondition = _condition(DialogueCondition.Kind.ITEM, &"coca")
	condition.negate = true
	var conditions: Array[DialogueCondition] = [condition]
	choice.conditions = conditions
	var item: ItemDefinition = ItemDefinition.new()
	item.id = &"coca"
	item.max_stack = 3
	var effect: DialogueEffect = DialogueEffect.new()
	effect.kind = DialogueEffect.Kind.ITEM_ADD
	effect.item = item
	effect.amount = 1
	var effects: Array[DialogueEffect] = [effect]
	choice.effects = effects
	var choices: Array[DialogueChoice] = [choice]
	start.choices = choices
	var graph: DialogueGraph = _graph([start])
	var inventory: Inventory = Inventory.new()
	var runner: DialogueRunner = DialogueRunner.new()
	runner.inventory = inventory
	var ok: bool = runner.start(graph)
	ok = ok and runner.choose(0)
	ok = ok and inventory.count(&"coca") == 1
	runner.start(graph)
	ok = ok and runner.get_visible_choice_text_keys().is_empty()
	runner.free()
	inventory.free()
	return ok
