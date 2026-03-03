extends Area2D




func _on_area_entered(_area: Area2D) -> void :
    if PlayerStats.player_hp < PlayerStats.player_hp_max:
        PlayerStats.player_hp += 1
    else:
        pass
    queue_free()
