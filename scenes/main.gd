## Main - Entry point scene that loads the game
extends Node


func _ready() -> void:
	# Load and instantiate the RunRoot scene
	var run_root_scene: PackedScene = load("res://scenes/run/run_root.tscn")
	if run_root_scene:
		var run_root: Node = run_root_scene.instantiate()
		add_child(run_root)
	else:
		push_error("Failed to load RunRoot scene")
