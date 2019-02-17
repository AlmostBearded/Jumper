extends Area2D

#export (String, FILE, "*.tscn") var next_level

#func _ready():
#	connect("body_entered", self, "_on_body_entered")
#
#func _on_body_entered(body):
#	if body.is_in_group("players"):
#		get_tree().change_scene(next_level)