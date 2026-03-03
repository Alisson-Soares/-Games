extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $mapa / Grimm / AnimatedSprite2D
@onready var grimm: Area2D = $mapa / Grimm
@onready var level_end: CollisionShape2D = $mapa / level_end / CollisionShape2D
@onready var portal: TileMapLayer = $mapa / portal


func _on_area_2d_area_entered(_area: Area2D) -> void :
    animated_sprite_2d.play("idle")
    PlayerStats.player_hp_max = 10
    PlayerStats.player_hp = PlayerStats.player_hp_max
    level_end.set_deferred("disabled", false)
    portal.visible = true
    await animated_sprite_2d.animation_finished
    grimm.queue_free()
    PlayerStats.score += 1500
