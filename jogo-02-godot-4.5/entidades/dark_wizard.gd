extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

@onready var c_attack_1: CollisionShape2D = $collision / attacks / attack_1 / C_attack_1
@onready var c_attack_2: CollisionShape2D = $collision / attacks / attack_2 / C_attack_2


var speed = 75
@export var hp: int = 4
var max_hp = 4.0
var direction = 0

var see_player: bool = false
var alvo: CharacterBody2D = null

const potion = preload("res://small_potion.tscn")

var states: Enemy
enum Enemy{
    run, 
    attack_1, 
    attack_2, 
    hurt, 
    dead
}

func _ready() -> void :
    anim.play("idle")

func _physics_process(_delta: float) -> void :
    if not see_player:
        return
    else:
        match states:
            Enemy.run:
                run_state()
            Enemy.attack_1:
                attack_1_state()
            Enemy.attack_2:
                attack_2_state()
            Enemy.hurt:
                hurt_state()
            Enemy.dead:
                dead_state()
    move_and_slide()




func run_state():
    flip()
    var move: bool = false
    if abs(alvo.global_position.x - self.global_position.x) > 85:
        velocity.x = speed * direction
        move = true
    if abs(alvo.global_position.y - self.global_position.y) > 30:
        move = true
        var h_dir = 1 if alvo.global_position.y > self.global_position.y else -1
        velocity.y = speed * h_dir
    if not move:
        choice_attack()

func attack_1_state():
    if anim.frame == 3:
        c_attack_1.disabled = false
        c_attack_1.position = Vector2(direction * 56, -42)
    elif anim.frame == 5:
        c_attack_1.disabled = true
    if not anim.is_playing():
        go_to_run()

func attack_2_state():
    if anim.frame == 4:
        c_attack_2.position = Vector2(direction * 60, -36)
        c_attack_2.disabled = false
    elif anim.frame == 6:
        c_attack_2.disabled = true
    if not anim.is_playing():
        go_to_run()

func hurt_state():
    if not anim.is_playing():
        go_to_run()

func dead_state():
    if not anim.is_playing():
        var rng: int = randi_range(0, 100)
        if rng > 60:
            var pot = potion.instantiate()
            add_sibling(pot)
            pot.global_position = self.global_position
        queue_free()
        PlayerStats.score += 350


func go_to_run():
    anim.play("run")
    states = Enemy.run

func go_to_attack_1():
    anim.play("attack_1")
    states = Enemy.attack_1
    velocity = Vector2.ZERO

func go_to_attack_2():
    anim.play("attack_2")
    states = Enemy.attack_2
    velocity = Vector2.ZERO

func go_to_hurt():
    anim.play("hurt")
    states = Enemy.hurt
    velocity = Vector2.ZERO

func go_to_dead():
    anim.play("dead")
    states = Enemy.dead
    velocity = Vector2.ZERO




func flip():
    if (alvo.global_position.x - position.x) > 0:
        direction = 1
        anim.flip_h = false
    else:
        direction = -1
        anim.flip_h = true

func choice_attack():
    var rdm: int = randi_range(1, 2)
    if rdm == 1:
        go_to_attack_1()
    else:
        go_to_attack_2()


func _on_vision_area_entered(_area: Area2D) -> void :
    see_player = true
    alvo = get_tree().get_first_node_in_group("player")
    go_to_run()


func _on_hitbox_area_entered(_area: Area2D) -> void :
    alvo = get_tree().get_first_node_in_group("player")
    hp -= 1
    see_player = true
    if hp < max_hp / 2:
        speed = 300

    if hp > 0:
        go_to_hurt()
    else:
        go_to_dead()
