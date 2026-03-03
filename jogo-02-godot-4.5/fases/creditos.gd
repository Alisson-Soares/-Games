extends Node2D

@onready var score_e_tempo_de_jogo: Label = $"score e tempo de jogo"

func _ready() -> void :

    var total_segundos = int(PlayerStats.time)
    var minutos = total_segundos / 60
    var segundos = total_segundos % 60

    score_e_tempo_de_jogo.text = "tempo jogado: " + str(minutos) + ":" + str(segundos).pad_zeros(2) + "\n" + "score: " + str(PlayerStats.score)

func _process(delta: float) -> void :
    if Input.is_action_just_pressed("ui_cancel"):
        get_tree().quit()
