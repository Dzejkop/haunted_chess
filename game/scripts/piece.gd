class_name Piece

extends StaticBody3D

enum Kind {
	PAWN,
	KING, 
	QUEEN,
	KNIGHT,
	ROOK,
	TOWER,
	
	# Special piece kinds
	TURBO_PAWN,
	DISMOUNTED_KNIGHT,
	FAT_TOWER,
}

enum Player {
	White,
	Black
}

const KIND_NAME: Dictionary = {
	Kind.PAWN: "Pawn",
	Kind.KING: "King",
	Kind.QUEEN: "Queen",
	Kind.ROOK: "Rook",
	Kind.KNIGHT: "Knight",
	Kind.TOWER: "Tower"
}

@export
var kind: Kind 

## The position of this piece on the board
var board_pos: Vector2i = Vector2i.ZERO

## How many times this piece moves
var num_moves: int = 0

var player

func init(player_value: Player, board_pos_value: Vector2i):
	self.player = player_value
	self.board_pos = board_pos_value
	
func player_dir() -> Vector2i:
	if player == Player.White:
		return Vector2i(0, 1)
	else:
		return Vector2i(0, -1)

func get_piece_name():
	return KIND_NAME[kind]

func get_legal_moves():
	pass

func get_pawn_legal_moves():
	pass
