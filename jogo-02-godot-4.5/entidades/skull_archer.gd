extends CharacterBody2D

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D


@onready var C_attack_1: CollisionShape2D = $collision / comb_attack / C_attack_1 / CollisionShape2D
@onready var C_attack_2: CollisionShape2D = $collision / comb_attack / C_attack_2 / CollisionShape2D
@onready var C_attack_3: CollisionShape2D = $collision / comb_attack / C_attack_3 / CollisionShape2D

@onready var arrow_position_1: Node2D = $arrow_position_1
@onready var arrow_position_2: Node2D = $arrow_position_2


const SPEED = 200.0
var direction = 0

@export var hp: int = 3
var max_hp = 4

var comb_attack: int = 1
const arrow = preload("res://skull_arrow.tscn")
var can_shot: bool = true
var see_player: bool = false
var alvo: CharacterBody2D = null


var states: Enemy
enum Enemy{
    walk, 
    run, 
    attack_1, 
    attack_2, 
    attack_3, 
    shot_1, 
    shot_2, 
    evasion, 
    hurt, 
    dead
    }

func _ready() -> void :
    anim_sprite.play("idle")


func _physics_process(_delta: float) -> void :
    if not see_player:
        pass
    else:
        match states:
            Enemy.walk:
                walk_state()
            Enemy.attack_1:
                attack_1_state()
            Enemy.attack_2:
                attack_2_state()
            Enemy.attack_3:
                attack_3_state()
            Enemy.shot_1:
                shot_1_state()
            Enemy.shot_2:
                shot_2_state()
            Enemy.evasion:
                evasion_state()
            Enemy.hurt:
                hurt_state()
            Enemy.dead:
                dead_state()


    move_and_slide()


func walk_state():
    var h_dir: int
    if alvo.global_position.y - global_position.y > 0:
        h_dir = 1
    else:
        h_dir = -1
    velocity.y = h_dir * SPEED
    flip()
    if abs(alvo.global_position.x - global_position.x) > 900:
        velocity.x = SPEED * direction
    elif abs(alvo.global_position.y - global_position.y) > 100:
        velocity.y = h_dir * SPEED * 0.5
    else:
        choice_attack()

func run_state():
    flip()
    velocity.x = SPEED * direction * -2

func attack_1_state():
    C_attack_1.position = Vector2(direction * 17, -7)
    if anim_sprite.frame == 3:
        C_attack_1.disabled = false
    elif anim_sprite.frame == 4:
        C_attack_1.disabled = true
        flip()
        go_to_attack_2()

func attack_2_state():
    C_attack_2.position = Vector2(direction * 17.5, 0.5)
    if anim_sprite.frame == 2:
        C_attack_2.disabled = false
    elif anim_sprite.frame == 3:
        C_attack_2.disabled = true
        flip()
        go_to_attack_3()

func attack_3_state():
    C_attack_3.position = Vector2(direction * 19.5, -17.5)
    if anim_sprite.frame == 0:
        C_attack_3.disabled = false
    elif anim_sprite.frame == 2:
        C_attack_3.disabled = true
        flip()
        go_to_evasion()

func shot_1_state():
    if anim_sprite.frame == 12 and can_shot:
        can_shot = false
        var new_arrow = arrow.instantiate()
        add_sibling(new_arrow)
        if anim_sprite.flip_h == false:
            new_arrow.position = arrow_position_1.global_position
            new_arrow.get_direction(1)
        else:
            new_arrow.position = arrow_position_1.global_position - Vector2(64, 0)
            new_arrow.get_direction(-1)
    if not anim_sprite.is_playing():
        go_to_evasion()

func shot_2_state():
    if anim_sprite.frame == 5 and can_shot:
        can_shot = false
        var new_arrow = arrow.instantiate()
        add_sibling(new_arrow)
        if anim_sprite.flip_h == false:
            new_arrow.position = arrow_position_2.global_position
            new_arrow.get_direction(1)
        else:
            new_arrow.position = arrow_position_2.global_position - Vector2(64, 0)
            new_arrow.get_direction(-1)
    if not anim_sprite.is_playing():
        go_to_evasion()

func evasion_state():
    can_shot = true
    if anim_sprite.frame == 2:
        velocity.x = direction * -1 * SPEED
    if not anim_sprite.is_playing():
        if abs(alvo.global_position.y - global_position.y) > 100:
            go_to_walk()
        elif abs(alvo.global_position.x - global_position.x) > 80:
            choice_shot_attack()
        else:
            go_to_attack_1()

func hurt_state():
    if not anim_sprite.is_playing():
        go_to_evasion()

func dead_state():
    if not anim_sprite.is_playing():
        PlayerStats.score += 200
        queue_free()



func go_to_walk():
    states = Enemy.walk
    anim_sprite.play("walk")


func go_to_attack_1():
    states = Enemy.attack_1
    anim_sprite.play("attack_1")
    velocity = Vector2.ZERO

func go_to_attack_2():
    states = Enemy.attack_2
    anim_sprite.play("attack_2")
    velocity = Vector2.ZERO

func go_to_attack_3():
    states = Enemy.attack_3
    anim_sprite.play("attack_3")
    velocity = Vector2.ZERO

func go_to_shot_1():
    states = Enemy.shot_1
    anim_sprite.play("long_attack_1")
    velocity = Vector2.ZERO

func go_to_shot_2():
    states = Enemy.shot_2
    anim_sprite.play("long_attack_2")
    velocity = Vector2.ZERO

func go_to_evasion():
    velocity.x = direction * -2 * direction
    anim_sprite.play("evasion")
    states = Enemy.evasion
    flip()

func go_to_hurt():
    states = Enemy.hurt
    anim_sprite.play("hurt")
    velocity = Vector2.ZERO

func go_to_dead():
    states = Enemy.dead
    anim_sprite.play("dead")
    velocity = Vector2.ZERO





func flip():
    if (alvo.global_position.x - position.x) > 0:
        direction = 1
        anim_sprite.flip_h = false
    else:
        direction = -1
        anim_sprite.flip_h = true

func choice_attack():
    var rdm = randi_range(1, 3)
    match rdm:
        1:
            go_to_attack_1()
        2:
            go_to_shot_1()
        3:
            go_to_shot_2()

func choice_shot_attack():
    var rdm = randi_range(1, 2)
    match rdm:
        1:
            go_to_shot_1()
            return
        2:
            go_to_shot_2()
            return

func _on_vision_area_entered(_area: Area2D) -> void :
    see_player = true
    alvo = get_tree().get_first_node_in_group("player")
    go_to_walk()


func _on_hitbox_area_entered(_area: Area2D) -> void :
    alvo = get_tree().get_first_node_in_group("player")
    see_player = true
    hp -= 1
    if hp > 0:
        go_to_hurt()
    else:
        go_to_dead()
