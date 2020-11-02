extends Node2D


onready var _explosion_animated_sprite: AnimatedSprite = $"./Explosion"
onready var _smoke_animated_sprite: AnimatedSprite = $"./Smoke"


func _on_Explosion_animation_finished():
	_explosion_animated_sprite.visible = false


func _ready():
	_smoke_animated_sprite.visible = false
	_explosion_animated_sprite.play()


func _on_Smoke_animation_finished():
	_smoke_animated_sprite.visible = false


func _on_SmokeStartTimer_timeout():
	_smoke_animated_sprite.visible = true
	_smoke_animated_sprite.play()
