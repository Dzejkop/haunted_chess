extends Node3D

@export
var main_menu: Node

@export
var camera_dolly: Node

@export
var camera: Camera3D

@export
var overlay_panel: Control

@export
var piece_scenes: Dictionary[Piece.Kind, PackedScene]

@export
var pieces_container: Node3D

@export
var highlighter: Node3D

var selected_piece: Piece
var should_spawn_legal_moves: bool = false

var all_pieces: Array[Piece] = []

var turn_counter: int = 0
var local_player_starts: bool = true

func _ready():
	main_menu.connect("start_game", start_game)

func start_game():
	camera_dolly.is_active = true
	turn_counter = 0
	
	var pawn_scn := piece_scenes[Piece.Kind.PAWN]

	# Spawn player pawns
	for i in range(8):
		var new_piece: Piece = pawn_scn.instantiate()
		pieces_container.add_child(new_piece)
		var x := -7.0 + i * 2.0
		var z := 5.0
		new_piece.global_position = Vector3(x, 1.0, z)
		var board_pos = Vector2i(i, 1)
		new_piece.init(Piece.Player.Local, board_pos)
		all_pieces.append(new_piece)
		
func which_player_turn() -> Piece.Player:
	if turn_counter % 2 == 0:
		if local_player_starts:
			return Piece.Player.Local
		else:
			return Piece.Player.Remote
	else:
		if local_player_starts:
			return Piece.Player.Remote
		else:
			return Piece.Player.Local

func find_piece_at(x: int, y: int) -> Piece:
	for piece in all_pieces:
		if piece.board_pos.x == x && piece.board_pos.y == y:
			return piece

	return null

func _process(_delta):
	overlay_panel.visible = false

	pick_a_piece()
	update_highlighter()
	
	if should_spawn_legal_moves:
		spawn_legal_moves()

func pick_a_piece():
	var mouse_pos := get_viewport().get_mouse_position()

	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 100.0
	
	var space_rid = get_world_3d().space
	var space_state = PhysicsServer3D.space_get_direct_state(space_rid)
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)

	if not result.is_empty():
		overlay_panel.visible = true
		var label: Label = overlay_panel.get_node("VBoxContainer/Text")
		label.text = str(result.position)
		
		var piece: Piece = result.collider
		var label_name: Label = overlay_panel.get_node("VBoxContainer/Name")
		label_name.text = piece.get_piece_name()
		
		overlay_panel.position = mouse_pos
		
		if selected_piece != piece && Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			selected_piece = piece
			should_spawn_legal_moves = true

func update_highlighter():
	if not selected_piece:
		highlighter.visible = false
		return

	highlighter.visible = true
	highlighter.global_position = selected_piece.global_position

func spawn_legal_moves():
	if selected_piece.kind == Piece.Kind.PAWN:
		spawn_legal_pawn_moves()

func spawn_legal_pawn_moves():
	pass
