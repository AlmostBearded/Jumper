extends Node2D

export (String, FILE, "*.tscn") var _next_level_path

#func _ready():
#	$Canvas/LevelLabel.text = "Level %d" % (index + 1)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		reload_level()

func reload_level():
	call_deferred("_reload_level")

func _reload_level():
	print("Reload level")
	# NEVER do a scene change in the middle of function or process.
	# ALWAYS do it at idle time.
	get_tree().reload_current_scene()

func load_next_level():
	call_deferred("_load_next_level")

func _load_next_level():
	print("Load level %s" % _next_level_path)
	# NEVER do a scene change in the middle of function or process.
	# ALWAYS do it at idle time.
	get_tree().change_scene(_next_level_path)


## Signals

func _on_Goal_body_entered(body):
	if body == $Player:
		load_next_level()

func _on_DeathArea_body_entered(body):
	if body == $Player:
		reload_level()
