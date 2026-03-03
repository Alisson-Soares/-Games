extends Node2D
var is_fight = true
var cutcene: int = 1
@onready var porta: Node2D = $tile_set / porta
@onready var spawn_commander: Node2D = $tile_set / spawn_commander

@onready var samurai_commander = preload("res://final_scene.tscn")
var commander

@onready var player: = get_tree().get_first_node_in_group("player")
@onready var anim: AnimatedSprite2D = player.get_node("AnimatedSprite2D")

@onready var fake_parede: TileMapLayer = $tile_set / fake_parede
@onready var camera_2d: Camera2D = $Camera2D



func _ready() -> void :
    player = get_tree().get_first_node_in_group("player")
    commander = samurai_commander.instantiate()
    add_sibling.call_deferred(commander)
    commander.global_position = Vector2(-10000, -10000)


func _process(delta: float) -> void :
    if get_tree().get_nodes_in_group("boss").size() == 0:
        match cutcene:
            1:
                lock_input()
            2:
                player_to_point(delta)
            3:
                pause_moment()
            4:
                commander_entred(delta)
            5:
                end_game()
            _:
                return
    print(cutcene)




func lock_input():
    anim.flip_h = false
    player.set_physics_process(false)
    player.set_process_input(false)
    cutcene += 1
    fake_parede.queue_free()
    camera_2d.limit_right = 980


func player_to_point(delta: float):
    anim.play("run")
    var diff = porta.global_position - player.global_position
    var h_dir = sign(diff.x)
    var v_dir = sign(diff.y)
    player.global_position.x += h_dir * delta * 200
    player.global_position.y += v_dir * delta * 60
    if abs(player.global_position.x - porta.global_position.x) < 2:
        player.global_position.x = porta.global_position.x
    elif abs(player.global_position.y - porta.global_position.y) < 2:
        player.global_position.y = porta.global_position.y
    if abs(porta.global_position - player.global_position) <= Vector2(0, 0):
        cutcene += 1



func pause_moment():
    if anim.animation == "run":
        anim.play("idle")
        await get_tree().create_timer(1.5).timeout
        commander.global_position = spawn_commander.global_position
        var anim2 = commander.get_node("AnimatedSprite2D")
        anim2.play("walk")
        cutcene += 1


func commander_entred(delta: float):
    var local = player.global_position - Vector2(200, 0)
    var v_dir = sign(local.y)
    var h_dir = sign(local.x)

    commander.global_position.x += h_dir * delta * 80
    commander.global_position.y += v_dir * delta * 40

    if abs(local.x - commander.global_position.x) < 2:
        commander.global_position.x = local.x
    if abs(local.y - commander.global_position.y) < 2:
        commander.global_position.y = local.y
    if abs(local - commander.global_position) == Vector2(0, 0):
        var anim2 = commander.get_node("AnimatedSprite2D")
        anim2.play("idle")
        anim.flip_h = true
        cutcene += 1
        await get_tree().create_timer(0.4).timeout
        anim2.play("parry")
        anim.play("attack_shot")

func end_game():
    cutcene += 1
    await get_tree().create_timer(1.2).timeout
    get_tree().change_scene_to_file("res://fases/creditos.tscn")
