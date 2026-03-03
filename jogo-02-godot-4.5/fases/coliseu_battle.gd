extends Node2D



@onready var close_arena: TileMapLayer = $arena / close_arena
@onready var portal: TileMapLayer = $arena / portal
@onready var C_start_coliseu: CollisionShape2D = $battle_active / CollisionShape2D
@onready var anim_portal: AnimatedSprite2D = $arena / Area2D / anim_portal
@onready var c_portal: CollisionShape2D = $arena / Area2D / C_portal
var player: CharacterBody2D = null

@onready var zone_1: Node2D = $spawn_zones / zone_1
@onready var zone_2: Node2D = $spawn_zones / zone_2
@onready var zone_3: Node2D = $spawn_zones / zone_3
@onready var zone_4: Node2D = $spawn_zones / zone_4
@onready var next_fase_portal: Node2D = $spawn_zones / next_fase_portal

var last_zone: int = -1
var last_zone2: int = -1

const knightmare = preload("res://entidades/knightmare knight.tscn")
const skull_warrior = preload("res://skull_knight.tscn")
const pyro_mage = preload("res://entidades/pyro_mage.tscn")
const skull_archer = preload("res://entidades/skull_archer.tscn")
const dark_mage = preload("res://entidades/dark_wizard.tscn")
const potion_cure = preload("res://potion.tscn")


var quant_enemy = 0
var wave = 1
var enemies_alives = 0
@export var max_waves: int = 2
var can_spawn: bool = true
var can_cure: bool = true

var see_player: bool = false

func _ready() -> void :
    player = get_tree().get_first_node_in_group("player")


func _process(_delta: float) -> void :
    if not see_player:
        return
    else:
        match wave:
            max_waves:
                open_portal()
                return
            1:
                wave_state()
            2:
                wave_2_state()
            3:
                wave_3_state()
            4:
                wave_4_state()
            5:
                wave_5_state()
            _:
                auto_wave()
        if get_tree().get_nodes_in_group("enemy").size() == 0 and wave != max_waves:
            swap_wave()


func wave_state():
    if quant_enemy < 1:
        var enemy = knightmare.instantiate()
        add_sibling(enemy)
        enemy.global_position = next_fase_portal.global_position
        quant_enemy += 1
        enemies_alives += 1

func wave_2_state():
    if can_spawn:
        for i in range(2):
            var enemy = skull_warrior.instantiate()
            add_sibling(enemy)
            enemy.global_position = choice_zone()

        var enemy2 = skull_archer.instantiate()
        add_sibling(enemy2)
        enemy2.global_position = choice_zone()
        can_spawn = false

func wave_3_state():
    if can_spawn:
        can_spawn = false
        for i in range(4):
            var enemy = skull_archer.instantiate()
            match i:
                0:
                    add_sibling(enemy)
                    enemy.global_position = zone_1.global_position
                1:
                    add_sibling(enemy)
                    enemy.global_position = zone_2.global_position
                2:
                    add_sibling(enemy)
                    enemy.global_position = zone_3.global_position
                3:
                    add_sibling(enemy)
                    enemy.global_position = zone_4.global_position

func wave_4_state():
    if can_spawn:
        can_spawn = false
        var pyro = pyro_mage.instantiate()
        add_sibling(pyro)
        pyro.global_position = choice_zone()
        var dark = dark_mage.instantiate()
        add_sibling(dark)
        dark.global_position = choice_zone()

func wave_5_state():
    if can_spawn:
        if can_cure:
            var cure = potion_cure.instantiate()
            add_sibling(cure)
            cure.global_position = next_fase_portal.global_position
            can_cure = false
        if PlayerStats.player_hp == PlayerStats.player_hp_max:
            can_spawn = false
            for i in range(1):
                var enemy = knightmare.instantiate()
                add_sibling(enemy)
                enemy.global_position = choice_zone()
            for i in range(2):
                var enemy = skull_archer.instantiate()
                add_sibling(enemy)
                enemy.global_position = choice_zone()


func auto_wave():
    if can_spawn:
        can_spawn = false
        var quant = randi_range(1, 4)
        for i in range(quant):
            var rdm = randi_range(1, 5)
            match rdm:
                1:
                    var enemy = skull_archer.instantiate()
                    add_sibling(enemy)
                    enemy.global_position = choice_zone()
                2:
                    var enemy = dark_mage.instantiate()
                    add_sibling(enemy)
                    enemy.global_position = choice_zone()
                3:
                    var enemy = pyro_mage.instantiate()
                    add_sibling(enemy)
                    enemy.global_position = choice_zone()
                4:
                    var enemy = skull_warrior.instantiate()
                    add_sibling(enemy)
                    enemy.global_position = choice_zone()
                5:
                    var enemy = knightmare.instantiate()
                    add_sibling(enemy)
                    enemy.global_position = choice_zone()

func open_portal():
    if can_spawn:
        can_spawn = false
        portal.visible = true
        c_portal.disabled = false

func swap_wave():
    quant_enemy = 0
    can_spawn = true
    wave += 1


func load_next_scene():
    get_tree().change_scene_to_file("res://fases/dead_boss_fight.tscn")

func choice_zone():
    var rdm_num = randi_range(1, 4)
    last_zone2 = last_zone
    while rdm_num == last_zone or rdm_num == last_zone2:
        rdm_num = randi_range(1, 4)
    last_zone = rdm_num
    match rdm_num:
        1:
            return zone_1.global_position
        2:
            return zone_2.global_position
        3:
            return zone_3.global_position
        4:
            return zone_4.global_position

func _on_battle_active_area_entered(_area: Area2D) -> void :
    see_player = true
    C_start_coliseu.queue_free()
    wave = 1
    close_arena.collision_enabled = true
    close_arena.visible = true


func _on_area_2d_area_entered(_area: Area2D) -> void :
    anim_portal.play("teleport")
    player.visible = false
    await anim_portal.animation_finished
    call_deferred("load_next_scene")
