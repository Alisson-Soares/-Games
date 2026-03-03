extends CharacterBody2D
@onready var enemy_vision = $vision / CollisionShape2D

@onready var enemy_collision = $CollisionShape2D
@onready var animated_sprite = $AnimatedSprite2D
@onready var inicial_fireball = $inicial_fireball


@onready var ray_cast_d = $raycast / RayCastD
@onready var ray_cast_e = $raycast / RayCastE


@onready var T_attack_1 = $timer / attack1
@onready var T_attack_2 = $timer / attack2
@onready var T_fireball = $timer / fireball
@onready var T_super_attack = $timer / super_attack
@onready var T_run = $timer / run
@onready var T_slowed = $timer / slowed


@onready var cooldown_super_attack = $cooldown / cooldown_super_attack
@onready var cooldown_attack_1 = $cooldown / cooldown_attack_1
@onready var cooldown_attack_2 = $cooldown / cooldown_attack_2
@onready var cooldown_fireball = $cooldown / cooldown_fireball



@onready var C_attack_1 = $attack_collision / attack_1 / CollisionShape2D
@onready var C_attack_2 = $attack_collision / attack_2 / CollisionShape2D
@onready var C_super_attack = $attack_collision / super_attack / CollisionShape2D



const FIREBALL = preload("res://fireball.tscn")
const potion = preload("res://small_potion.tscn")
var alvo: CharacterBody2D = null
var status: STATE

const SPEED = 100.0
var speed_modify = 1
var direction = 1
var h_dir = 1
var enemy_hp = 5
var damage = 1
var see_player = false




var can_use_attack1 = true
var can_use_attack2 = true
var can_use_fireball = true
var can_use_super_attack = true


enum STATE{
    walk, 
    run, 
    attack1, 
    attack2, 
    fireball, 
    super_attack, 
    hurt, 
    dead
}

func _ready() -> void :
    animated_sprite.play("walk")
    status = STATE.walk


func _physics_process(_delta: float) -> void :
    if see_player == true:
        match status:
            STATE.walk:
                walk_state()
            STATE.run:
                run_state()
            STATE.attack1:
                attack1_state()
            STATE.attack2:
                attack2_state()
            STATE.fireball:
                fireball_state()
            STATE.super_attack:
                super_attack_state()
            STATE.hurt:
                hurt_state()
            STATE.dead:
                dead_state()
    else:
        move_n_flip()
    move_and_slide()








func walk_state():
    flip()
    velocity.x = SPEED * direction * speed_modify

    choice_attack()


func run_state():
    if direction == 1:
        animated_sprite.flip_h = false
    else:
        animated_sprite.flip_h = true
    h_dir = 1 if alvo.global_position > self.global_position else -1
    velocity.y = h_dir * SPEED
    velocity.x = direction * SPEED * 1.5 * speed_modify


func attack1_state():
    C_attack_1.position = Vector2(direction * 20, 0.5)
    if animated_sprite.frame == 2:
        C_attack_1.disabled = false
    if animated_sprite.frame == 3:
        disable_collision()

func attack2_state():
    C_attack_2.position = Vector2(direction * 26, 1.5)
    if animated_sprite.frame == 2:
        C_attack_2.disabled = false
    if animated_sprite.frame == 3:
        disable_collision()


func fireball_state():
    if can_use_fireball == true && animated_sprite.frame == 6:
        can_use_fireball = false
        var new_fire_ball = FIREBALL.instantiate()
        add_sibling(new_fire_ball)
        new_fire_ball.get_direction(direction)

        new_fire_ball.position = inicial_fireball.global_position


func super_attack_state():
    C_super_attack.position = Vector2(direction * 28.5, -5)
    if animated_sprite.frame == 5:
        C_super_attack.disabled = false
    if animated_sprite.frame == 11:
        disable_collision()


func hurt_state():
    velocity = Vector2.ZERO
    if not animated_sprite.is_playing():
        go_to_run_state()

func dead_state():
    velocity = Vector2.ZERO
    if not animated_sprite.is_playing():
        var rng: int = randi_range(0, 100)
        if rng > 70:
            var pot = potion.instantiate()
            add_sibling(pot)
            pot.global_position = self.global_position
            PlayerStats.score += 300
        queue_free()
    pass







func go_to_walk_state():
    status = STATE.walk
    animated_sprite.play("walk")


func go_to_run_state():
    T_run.start()
    status = STATE.run
    animated_sprite.play("run")
    if alvo.global_position.x - position.x > 0:
        direction = -1
    else:
        direction = 1


func go_to_attack1_state():
    cooldown_attack_1.start()
    T_attack_1.start()
    status = STATE.attack1
    can_use_attack1 = false
    animated_sprite.play("attack_1")
    velocity.x = 0


func go_to_attack2_state():
    cooldown_attack_2.start()
    T_attack_2.start()
    can_use_attack2 = false
    status = STATE.attack2
    animated_sprite.play("attack_2")
    velocity.x = 0


func go_to_fireball_state():
    cooldown_fireball.start()
    T_fireball.start()
    status = STATE.fireball
    animated_sprite.play("fire_ball")
    velocity.x = 0


func go_to_super_attack_state():
    cooldown_super_attack.start()
    T_super_attack.start()
    can_use_super_attack = false
    velocity.x = 0
    status = STATE.super_attack
    animated_sprite.play("super_attack")
    flip()


func go_to_hurt_state():
    status = STATE.hurt
    animated_sprite.play("hurt")
    T_slowed.start()
    modify_velocity(0.85)


func go_to_dead_state():
    status = STATE.dead
    animated_sprite.play("dead")
    T_attack_1.stop()
    T_attack_2.stop()
    T_fireball.stop()
    T_super_attack.stop()



func move_n_flip():
    if ray_cast_d.is_colliding():
        direction = -1
        animated_sprite.flip_h = true

    elif ray_cast_e.is_colliding():
        direction = 1
        animated_sprite.flip_h = false
    velocity.x = direction * SPEED

func flip():
    if (alvo.global_position.x - position.x) > 0:
        direction = 1
        animated_sprite.flip_h = false
        enemy_collision.position = Vector2(-7, 3)
    elif (alvo.global_position.x - position.x) < 0:
        direction = -1
        animated_sprite.flip_h = true
        enemy_collision.position = Vector2(-1, 3)

func modify_velocity(x: float):
    speed_modify = x

func choice_attack():
    if can_use_fireball == true and \
(alvo.global_position.x - position.x > 100 or \
alvo.global_position.x - position.x < -100):
        go_to_fireball_state()
    elif (alvo.global_position.x - position.x <= 100) and \
(alvo.global_position.x - position.x >= -100):

        if can_use_super_attack == true:
                go_to_super_attack_state()
        elif can_use_attack2 == true:
                go_to_attack2_state()
        elif can_use_attack1 == true:
            go_to_attack1_state()
        else:
            go_to_run_state()

func take_damage():
    enemy_hp -= PlayerStats.player_damage
    if enemy_hp <= 0:
        go_to_dead_state()
    else:
        go_to_hurt_state()

func _on_attack_1_timeout() -> void :
    go_to_walk_state()
    pass


func _on_attack_2_timeout() -> void :
    go_to_walk_state()
    pass


func _on_fireball_timeout() -> void :
    go_to_walk_state()
    pass


func _on_super_attack_timeout() -> void :
    go_to_walk_state()
    pass


func _on_run_timeout() -> void :
    go_to_walk_state()
    pass

func _on_slowed_timeout() -> void :
    speed_modify = 1
    pass

func disable_collision():
    C_attack_1.disabled = true
    C_attack_2.disabled = true
    C_super_attack.disabled = true


func _on_vision_body_entered(_body: CharacterBody2D) -> void :
    see_player = true
    alvo = get_tree().get_first_node_in_group("player")
    enemy_vision.queue_free()
    pass




func _on_cooldown_attack_1_timeout() -> void :
    can_use_attack1 = true



func _on_cooldown_attack_2_timeout() -> void :
    can_use_attack2 = true



func _on_cooldown_fireball_timeout() -> void :
    can_use_fireball = true



func _on_cooldown_super_attack_timeout() -> void :
    can_use_super_attack = true



func _on_hitbox_area_entered(_area: Area2D) -> void :
    take_damage()
    if not see_player:
        see_player = true
        alvo = get_tree().get_first_node_in_group("player")
        enemy_vision.queue_free()
