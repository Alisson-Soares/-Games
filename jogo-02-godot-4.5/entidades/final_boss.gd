extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $anim_sprite

@onready var c_attack_1: CollisionShape2D = $collision / attack_1 / c_attack_1
@onready var c_attack_2: CollisionShape2D = $collision / attack_2 / c_attack_2
@onready var c_attack_3: CollisionShape2D = $collision / attack_3 / c_attack_3
@onready var c_parry: CollisionShape2D = $collision / parry / c_parry
@onready var c_hitbox: CollisionShape2D = $collision / Hitbox / c_hitbox

@onready var t_parry: Timer = $timer / parry




var speed = 8000.0
var velocity_modify: float = 1.65
var dir: int = 0

var hp = 15
var hp_max = 15

var is_attacking = false
var can_attack = true
var can_parry = true

var states: enemy
var alvo: CharacterBody2D = null

enum enemy{
    walk, 
    run, 
    attack_1, 
    attack_2, 
    attack_3, 
    parry, 
    hurt, 
    dead
}

func _ready() -> void :
    states = enemy.walk
    anim.play("walk")

func _physics_process(delta: float) -> void :

    if not is_instance_valid(alvo):
        alvo = get_tree().get_first_node_in_group("player")
    else:
        match states:
            enemy.walk:
                walk_state(delta)
            enemy.run:
                run_state(delta)
            enemy.attack_1:
                attack_1_state()
            enemy.attack_2:
                attack_2_state()
            enemy.attack_3:
                attack_3_state()
            enemy.parry:
                parry_state()
            enemy.hurt:
                hurt_state()
            enemy.dead:
                dead_state()
        flip()
    move_and_slide()


func walk_state(delta: float):
    var dist = abs(alvo.global_position.x - self.global_position.x)
    if dist > 60 and dist < 100:

        var dy: = alvo.global_position.y - global_position.y
        var v_dir: = 0
        if abs(dy) > 1:
            v_dir = 1 if dy > 0 else -1

        velocity.x = dir * speed * delta
        velocity.y = v_dir * speed * delta
    elif dist <= 60:
        choice_attack()
    else:
        go_to_run()


func run_state(delta: float):
    var dist = abs(alvo.global_position.x - self.global_position.x)
    if dist > 64:
        var dy: = alvo.global_position.y - global_position.y
        var v_dir: = 0
        if abs(dy) > 1:
            v_dir = 1 if dy > 0 else -1

        velocity.x = dir * speed * delta * velocity_modify
        velocity.y = v_dir * speed * delta
    else:
        choice_attack()


func attack_1_state():
    match anim.frame:
        2:
            c_attack_1.disabled = false
            c_attack_1.position = Vector2(dir * 26, -11)
        3:
            c_attack_1.disabled = true
            if abs(alvo.global_position.x - self.global_position.x) < 70 and can_parry:
                go_to_parry()
            elif abs(alvo.global_position.x - self.global_position.x) < 70:
                choice_attack()
            else:
                go_to_walk()


func attack_2_state():
    match anim.frame:
        3:
            c_attack_2.disabled = false
            c_attack_2.position = Vector2(dir * 31, 4.5)
        4:
            c_attack_2.disabled = true
            if abs(alvo.global_position.x - self.global_position.x) < 70 and can_parry:
                go_to_parry()
            elif abs(alvo.global_position.x - self.global_position.x) < 70:
                choice_attack()
            else:
                go_to_walk()

func attack_3_state():
    match anim.frame:
        2:
            c_attack_3.disabled = false
            c_attack_3.position = Vector2(dir * 30, -15)
        3:
            c_attack_3.disabled = true
            if abs(alvo.global_position.x - self.global_position.x) < 70 and can_parry:
                go_to_parry()
            elif abs(alvo.global_position.x - self.global_position.x) < 70:
                choice_attack()
            else:
                go_to_walk()

func parry_state():
    if not anim.is_playing():
        c_hitbox.disabled = false
        go_to_walk()

func hurt_state():
    if not anim.is_playing():
        go_to_walk()


func dead_state():
    if not anim.is_playing():
        queue_free()
        PlayerStats.score += 2000



func go_to_walk():
    anim.play("walk")
    states = enemy.walk

func go_to_run():
    anim.play("run")
    states = enemy.run

func go_to_attack_1():
    velocity = Vector2.ZERO
    anim.play("attack_1")
    states = enemy.attack_1

func go_to_attack_2():
    velocity = Vector2.ZERO
    anim.play("attack_2")
    states = enemy.attack_2

func go_to_attack_3():
    velocity = Vector2.ZERO
    anim.play("attack_3")
    states = enemy.attack_3

func go_to_parry():
    anim.play("parry")
    t_parry.start()
    can_parry = false
    velocity = Vector2.ZERO
    states = enemy.parry
    c_hitbox.disabled = true

func go_to_hurt():
    velocity = Vector2.ZERO
    anim.play("hurt")
    states = enemy.hurt

func go_to_dead():
    velocity = Vector2.ZERO
    anim.play("dead")
    states = enemy.dead
    t_parry.stop()
    c_hitbox.set_deferred("disabled", true)



func choice_attack():
    var rng = randi_range(0, 100)
    if rng > 65:
        go_to_attack_1()
    elif rng > 40:
        go_to_attack_2()
    else:
        go_to_attack_3()

func flip():
    if alvo.global_position.x < self.global_position.x:
        dir = -1
    else:
        dir = 1
    anim.flip_h = dir < 0


func _on_parry_timeout() -> void :
    can_parry = true
    c_parry.disabled = true


func _on_hitbox_area_entered(_area: Area2D) -> void :
    c_attack_1.set_deferred("disabled", true)
    c_attack_2.set_deferred("disabled", true)
    c_attack_3.set_deferred("disabled", true)
    hp -= 1
    if anim.animation == "parry":
        go_to_parry()
    else:
        if hp > 0:
            go_to_hurt()
        else:
            go_to_dead()
