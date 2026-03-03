extends Area2D

func _on_body_entered(body: Node2D) -> void :
    aplica_damage(body)
    pass

func aplica_damage(alvo):
    if alvo.is_in_group("enemy"):
        pass
