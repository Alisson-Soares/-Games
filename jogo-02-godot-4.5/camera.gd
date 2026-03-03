extends Camera2D

@onready var hearts_node = $HeartsNode
@onready var heart_texture = preload("res://coracao_32x32.png")
var target: Node2D
var player_exist = false

func _ready() -> void :
    if not has_node("HeartsNode"):
        var node = Node2D.new()
        node.name = "HeartsNode"
        add_child(node)
        node.z_index = 20
        hearts_node = node
    pega_player()

func _process(_delta: float) -> void :
    if not player_exist:
        pega_player()
    else:
        if is_instance_valid(target):
            global_position = target.global_position
            update_hearts()

func update_hearts():

    for child in hearts_node.get_children():
        child.queue_free()


    for i in range(PlayerStats.player_hp):
        var sprite = Sprite2D.new()
        sprite.texture = heart_texture
        sprite.scale = Vector2(0.5, 0.5)
        hearts_node.add_child(sprite)


        var spacing = 12
        var total_hearts = PlayerStats.player_hp
        var heart_index = i


        var x_pos = (heart_index * spacing) - ((total_hearts - 1) * spacing / 2)

        sprite.position = Vector2(x_pos, -80)

func pega_player():
    target = get_tree().get_first_node_in_group("player")
    if target != null:
        player_exist = true
