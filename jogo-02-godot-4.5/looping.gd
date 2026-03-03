extends Node2D
@onready var c_entrada: CollisionShape2D = $entrada / C_entrada
@onready var timer: Timer = $entrada / Timer

@export
var distancia: int



func _on_entrada_body_entered(body: Node2D) -> void :
    body.global_position.x = body.global_position.x - distancia
    if timer.is_stopped():
        timer.start()



func _on_timer_timeout() -> void :
    c_entrada.disabled = true
    await get_tree().create_timer(1.2).timeout
    c_entrada.disabled = false
