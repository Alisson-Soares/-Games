extends Node2D

@onready var player_cratera: TileMapLayer = $tile / player_cratera
@onready var spawn_boss_point: Node2D = $active_boos_battle / spawn_boss_point

@onready var jump_point: Node2D = $active_boos_battle / jump_point
var etapas_cutcene: int = -1

@onready var player: = get_tree().get_first_node_in_group("player")
@onready var anim: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
const boss = preload("res://entidades/dead_boss.tscn")

@onready var portal: TileMapLayer = $tile / portal
@onready var c_level_end: CollisionShape2D = $tile / level_end / CollisionShape2D


var is_running: bool = true
var h_dir = 0
var v_dir = 0
var can_swap: bool = true
func _ready() -> void :
    pass



func _process(_delta: float) -> void :
    if is_running:
        match etapas_cutcene:
            0:
                alinha_player()
            1:
                go_to_point()
            2:
                pause_moment()
            3:
                jump()
            4:
                queda()
            5:
                pos_queda()
            6:
                start_boss_battle()
            7:
                end_cutcene()
                print("fim")
            8:
                var spawn_boss = boss.instantiate()
                add_sibling(spawn_boss)
                spawn_boss.global_position = spawn_boss_point.global_position
                etapas_cutcene += 1
            _:
                player.set_physics_process(true)
                player.set_process_input(true)
    else:
        if get_tree().get_nodes_in_group("boss").size() == 0:
            c_level_end.disabled = false
            portal.visible = true

func alinha_player():
    player.global_position.x = int(player.global_position.x)
    player.global_position.y = int(player.global_position.y)
    etapas_cutcene += 1

func go_to_point():
    var diff = jump_point.global_position - player.global_position
    h_dir = sign(diff.x)
    v_dir = sign(diff.y)
    player.global_position.x += h_dir
    player.global_position.y += v_dir
    if abs(player.global_position.x - jump_point.global_position.x) < 2:
        player.global_position.x = jump_point.global_position.x
    elif abs(player.global_position.y - jump_point.global_position.y) < 2:
        player.global_position.y = jump_point.global_position.y
    if abs(jump_point.global_position - player.global_position) <= Vector2(0, 0):
        etapas_cutcene += 1

func pause_moment():
    anim.play("idle")
    if can_swap:
        swap_with_timer(0.5)

func jump():
    anim.play("jump1")
    if anim.frame > 2:
        calcular_pulo()
    if can_swap:
        swap_with_timer(0.6)

func queda():
    player.global_position.y += 6
    if can_swap:
        swap_with_timer(1.9)

func pos_queda():
    anim.play("jump2")
    player_cratera.visible = true
    swap_with_timer(0.2)

func start_boss_battle():
    anim.play("idle")
    etapas_cutcene += 1

func end_cutcene():
    player.set_physics_process(true)
    player.set_process_input(true)

    is_running = false
    etapas_cutcene = 10

func calcular_pulo():
    if abs(jump_point.global_position.y - player.global_position.y) < 40:
        player.global_position.y += -1
    else:
        player.global_position.y += 0.8

    player.global_position.x += 4

func swap_with_timer(t: float):
    can_swap = false
    await get_tree().create_timer(t).timeout
    etapas_cutcene += 1
    can_swap = true

func restart_fase():
    if PlayerStats.player_hp == 0:
        get_tree().reload_current_scene()
    elif get_tree().get_nodes_in_group("boss").size() == 0:
        for enemy in get_tree().get_nodes_in_group("enemy"):
            enemy.queue_free()

func _on_start_animation_area_entered(_area: Area2D) -> void :
    player.set_physics_process(false)
    player.set_process_input(false)
    is_running = true
    anim.play("walk")
    etapas_cutcene = 1
