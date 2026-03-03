extends Node2D

@onready var archer_player: CharacterBody2D = $archer_player
@onready var animated_sprite_2d: AnimatedSprite2D = $archer_player / AnimatedSprite2D


func _ready() -> void :
    animated_sprite_2d.flip_h = true
