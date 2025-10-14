class_name MoveMarker

extends Area3D

@export
var highlight: MeshInstance3D

enum Kind {
	Move,
}

var kind: Kind = Kind.Move
var target_pos: Vector2i = Vector2i.ZERO

func set_highlight(v: bool):
	highlight.visible = v
