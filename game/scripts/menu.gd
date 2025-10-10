extends Control

signal start_game

func _ready():
	$"VBoxContainer/vsCpu".connect("button_up", hide_self)
	$"VBoxContainer/MatchMaking".connect("button_up", hide_self)
	$"VBoxContainer/InviteOpponent".connect("button_up", hide_self)

func hide_self():
	visible = false
	start_game.emit()
