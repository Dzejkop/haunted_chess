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
	Local,
	Remote
}

const KIND_NAME: Dictionary = {
	Kind.PAWN: "Pawn"
}

@export
var kind: Kind 

var board_pos: Vector2i = Vector2i.ZERO

var player

func init(player_value: Player, board_pos_value: Vector2i):
	self.player = player_value
	self.board_pos = board_pos_value

func get_piece_name():
	return KIND_NAME[kind]
	

func get_legal_moves():
	pass

func get_pawn_legal_moves():
	pass
