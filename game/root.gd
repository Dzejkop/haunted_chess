extends Node3D

func _ready():
	$"MenuUi".connect("start_game", start_game)

func start_game():
	$"CameraDolly".is_active = true
