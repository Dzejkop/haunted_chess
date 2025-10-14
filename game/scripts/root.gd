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
var pieces_container: Node3D

@export
var highlighter: Node3D

@export_category("Packed scenes")
@export
var piece_scenes: Dictionary[Piece.Kind, PackedScene]
@export
var move_marker_scn: PackedScene

# ---- State Variables ----

var selected_piece: Piece
var should_spawn_legal_moves: bool = false

var all_pieces: Array[Piece] = []

var move_markers: Array[MoveMarker] = []

var turn_counter: int = 0
var local_player: Piece.Player = Piece.Player.White

func _ready():
	main_menu.connect("start_game", start_game)

func start_game():
	camera_dolly.is_active = true
	turn_counter = 0
	
	var white_player := Piece.Player.White
	var black_player := Piece.Player.Black

	# Spawn player pawns
	for i in range(8):
		spawn_piece(Piece.Kind.PAWN, Vector2i(i, 1), white_player)
	
	# Spawn other pieces
	spawn_piece(Piece.Kind.KING, Vector2i(3, 0), white_player)
	spawn_piece(Piece.Kind.QUEEN, Vector2i(4, 0), white_player)
	
	spawn_piece(Piece.Kind.TOWER, Vector2i(0, 0), white_player)
	spawn_piece(Piece.Kind.TOWER, Vector2i(7, 0), white_player)
	
	spawn_piece(Piece.Kind.KNIGHT, Vector2i(1, 0), white_player)
	spawn_piece(Piece.Kind.KNIGHT, Vector2i(6, 0), white_player)
	
	spawn_piece(Piece.Kind.ROOK, Vector2i(2, 0), white_player)
	spawn_piece(Piece.Kind.ROOK, Vector2i(5, 0), white_player)

	# Spawn player pawns
	for i in range(8):
		spawn_piece(Piece.Kind.PAWN, Vector2i(i, 6), black_player)
	
	# Spawn other pieces
	spawn_piece(Piece.Kind.KING, Vector2i(3, 7), black_player)
	spawn_piece(Piece.Kind.QUEEN, Vector2i(4, 7), black_player)
	
	spawn_piece(Piece.Kind.TOWER, Vector2i(0, 7), black_player)
	spawn_piece(Piece.Kind.TOWER, Vector2i(7, 7), black_player)
	
	spawn_piece(Piece.Kind.KNIGHT, Vector2i(1, 7), black_player)
	spawn_piece(Piece.Kind.KNIGHT, Vector2i(6, 7), black_player)
	
	spawn_piece(Piece.Kind.ROOK, Vector2i(2, 7), black_player)
	spawn_piece(Piece.Kind.ROOK, Vector2i(5, 7), black_player)

func spawn_piece(kind: Piece.Kind, board_pos: Vector2i, player: Piece.Player):
		var piece_scn := piece_scenes[kind]

		var new_piece: Piece = piece_scn.instantiate()
		pieces_container.add_child(new_piece)
		var p := board2world3(board_pos)
		new_piece.global_position = p
		new_piece.init(player, board_pos)
		all_pieces.append(new_piece)

func which_player_turn() -> Piece.Player:
	if turn_counter % 2 == 0:
		return Piece.Player.White
	else:
		return Piece.Player.Black

func find_piece_at(pos: Vector2i) -> Piece:
	for piece in all_pieces:
		if piece.board_pos.x == pos.x && piece.board_pos.y == pos.y:
			return piece

	return null

func _process(_delta):
	overlay_panel.visible = false
	should_spawn_legal_moves = false
	
	for marker in move_markers:
		marker.set_highlight(false)

	unselect()
	pick_a_piece()
	update_highlighter()
	
	if should_spawn_legal_moves:
		spawn_legal_moves()

func unselect():
	if Input.is_action_just_released("ui_cancel") or Input.is_action_just_released("deselect"):
		selected_piece = null
		despawn_markers()

func pick_a_piece():
	var mouse_pos := get_viewport().get_mouse_position()

	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 100.0
	
	var space_rid = get_world_3d().space
	var space_state = PhysicsServer3D.space_get_direct_state(space_rid)
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query)

	if not result.is_empty():
		if result.collider is Piece:
			overlay_panel.visible = true
			var label: Label = overlay_panel.get_node("VBoxContainer/Text")
			label.text = str(result.position)
		
			var piece: Piece = result.collider
			var label_name: Label = overlay_panel.get_node("VBoxContainer/Name")
			label_name.text = piece.get_piece_name()
			
			overlay_panel.position = mouse_pos
			
			if selected_piece != piece && Input.is_action_just_released("move"):
				selected_piece = piece
				should_spawn_legal_moves = true
		elif result.collider is MoveMarker:
			result.collider.set_highlight(true)

			if Input.is_action_just_released("move"):
				execute_move(result.collider)
		else:
			print("unknown item")
			
func execute_move(marker: MoveMarker):
	turn_counter += 1
	selected_piece.num_moves += 1
	
	selected_piece.board_pos = marker.target_pos
	selected_piece.global_position = board2world3(selected_piece.board_pos)
	
	selected_piece = null
	despawn_markers()

func update_highlighter():
	if not selected_piece:
		highlighter.visible = false
		return

	highlighter.visible = true
	highlighter.global_position = selected_piece.global_position

func spawn_legal_moves():
	despawn_markers()
	if selected_piece.kind == Piece.Kind.PAWN:
		spawn_legal_pawn_moves()
	if selected_piece.kind == Piece.Kind.KING:
		spawn_legal_king_moves()
	if selected_piece.kind == Piece.Kind.QUEEN:
		spawn_legal_queen_moves()
	if selected_piece.kind == Piece.Kind.TOWER:
		spawn_legal_tower_moves()
	if selected_piece.kind == Piece.Kind.KNIGHT:
		spawn_legal_knight_moves()
	if selected_piece.kind == Piece.Kind.ROOK:
		spawn_legal_rook_moves()

func despawn_markers():
	for marker in move_markers:
		marker.queue_free()
	move_markers = []

func spawn_legal_pawn_moves():
	var dir := selected_piece.player_dir()
	if selected_piece.num_moves == 0:
		spawn_legal_movement_move(selected_piece.board_pos + dir * 2)
	spawn_legal_movement_move(selected_piece.board_pos + dir)

func spawn_legal_king_moves():
	for x in [-1, 0, 1]:
		for y in [-1, 0, 1]:
			if x == 0 and y == 0:
				continue
				
			var move_pos = Vector2i(x, y) + selected_piece.board_pos
			if not is_legal_pos(move_pos):
				continue
			
			if is_occupied_by_piece_of(move_pos, selected_piece.player):
				continue

			spawn_legal_movement_move(move_pos)

func spawn_legal_queen_moves():
	var all_dirs = []
	for x in [-1, 0, 1]:
		for y in [-1, 0, 1]:
			if x == 0 and y == 0:
				continue
			all_dirs.append(Vector2i(x, y))
			
	for dir in all_dirs:
		for i in range(1, 8):
			var move_pos = selected_piece.board_pos + dir * i
			if not is_legal_pos(move_pos):
				break
			if is_occupied_by_piece_of(move_pos, selected_piece.player):
				break
			spawn_legal_movement_move(move_pos)

func spawn_legal_tower_moves():
	var all_dirs = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
			
	for dir in all_dirs:
		for i in range(1, 8):
			var move_pos = selected_piece.board_pos + dir * i
			if not is_legal_pos(move_pos):
				break
			if is_occupied_by_piece_of(move_pos, selected_piece.player):
				break
			spawn_legal_movement_move(move_pos)

func spawn_legal_knight_moves():
	var all_dirs = [
		Vector2i(2, 1),
		Vector2i(2, -1),
		Vector2i(1, 2),
		Vector2i(1, -2),
		Vector2i(-1, 2),
		Vector2i(-1, -2),
		Vector2i(-2, -1),
		Vector2i(-2, 1),
	]

	for dir in all_dirs:
		var move_pos = selected_piece.board_pos + dir
		if not is_legal_pos(move_pos):
			continue
		if is_occupied_by_piece_of(move_pos, selected_piece.player):
			continue
		spawn_legal_movement_move(move_pos)
			
func spawn_legal_rook_moves():
	var all_dirs = [
		Vector2i(1, 1), 
		Vector2i(1, -1), 
		Vector2i(-1, -1), 
		Vector2i(-1, 1)
	]

	for dir in all_dirs:
		for i in range(1, 8):
			var move_pos = selected_piece.board_pos + dir * i
			if not is_legal_pos(move_pos):
				break
			if is_occupied_by_piece_of(move_pos, selected_piece.player):
				break
			spawn_legal_movement_move(move_pos)

func spawn_legal_movement_move(pos: Vector2i):
	var arrow_marker: MoveMarker = move_marker_scn.instantiate()
	add_child(arrow_marker)
	
	arrow_marker.global_position = board2world3(pos)
	arrow_marker.target_pos = pos
	
	move_markers.append(arrow_marker)

func board2world(pos: Vector2i) -> Vector2:
	return Vector2(-7.0 + pos.x * 2.0, -7.0 + pos.y * 2.0)
	
func board2world3(pos: Vector2i) -> Vector3:
	var p := board2world(pos)
	return Vector3(p.x, 1.0, p.y)
	
func is_occupied_by_piece_of(pos: Vector2i, player: Piece.Player) -> bool:
	var piece_at = find_piece_at(pos)
	if not piece_at:
		return false
	return piece_at.player == player

func is_legal_pos(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < 8 and pos.y >= 0 and pos.y < 8
