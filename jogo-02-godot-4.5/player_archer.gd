extends CharacterBody2D
@onready var animated_sprite2D = $AnimatedSprite2D
@onready var combo_timer = $ComboTimer
@onready var shot_timer = $Shottimer
@onready var short_attack_timer = $shortAttack
@onready var invunerable = $invunerable

@onready var attack_collision_1: CollisionShape2D = $attack_collision1 / player_attack1 / attack_collision
@onready var attack_collision_2: CollisionShape2D = $attack_collision1 / player_attack2 / attack_collision
@onready var attack_collision_3: CollisionShape2D = $attack_collision1 / player_attack3 / attack_collision

@onready var Hitbox: CollisionShape2D = $hitbox / CollisionShape2D

@onready var inicial_arrow_position = $InicialArrowPosition
const FLECHA = preload("res://scripts/flecha.tscn")

enum PlayerStates{
    idle, 
    walk, 
    run, 
    short_attack, 
    long_attack, 
    hurt, 
    dead
}

var status: PlayerStates
const SPEED = 300.0
var comb_counter = 1
var can_attack = true
var is_attacking = false
var can_long_attack = true
var dir_attack = 1


func _ready() -> void :

    go_to_idle()

func _physics_process(delta: float) -> void :
    PlayerStats.time += delta
    match status:
        PlayerStates.idle:
            idle_state()
        PlayerStates.walk:
            walk_state()
        PlayerStates.run:
            run_state()
        PlayerStates.short_attack:
            short_attack_state()
        PlayerStates.long_attack:
            long_attack_state()
        PlayerStates.hurt:
            hurt_state()
        PlayerStates.dead:
            dead_state()

    move_and_slide()

func idle_state():
    move()
    if velocity.x != 0 or velocity.y != 0:
        go_to_walk()
        return

    start_short_attack()
    start_long_attack()
    pass

func walk_state():
    move()
    if velocity.x == 0 and velocity.y == 0:
        go_to_idle()
        return

    start_short_attack()
    start_long_attack()

func run_state():
    move()
    if velocity.x == 0 and velocity.y == 0:
        go_to_idle()
        return

    start_short_attack()
    start_long_attack()

func hurt_state():
    animated_sprite2D.play("hurt")
    await animated_sprite2D.animation_finished
    go_to_idle()

func dead_state():
    animated_sprite2D.play("dead")
    Hitbox.disabled = true
    start_invulnerability()
    await animated_sprite2D.animation_finished
    PlayerStats.player_hp = PlayerStats.player_hp_max
    if is_inside_tree():
        get_tree().reload_current_scene()


func short_attack_state():
    active_attack_collision()
    await animated_sprite2D.animation_finished
    disable_attack_collision()
    if not Input.is_anything_pressed():
        go_to_idle()
        return
    else:
        move()
        go_to_walk()
        return

func long_attack_state():
    velocity = Vector2.ZERO
    if animated_sprite2D.frame == 11 and can_long_attack:
        can_long_attack = false
        var arrow = FLECHA.instantiate()
        add_sibling(arrow)

        if animated_sprite2D.flip_h == true:
            arrow.get_direction(-1)
            arrow.position = inicial_arrow_position.global_position - Vector2(72, -1)
        else:
            arrow.get_direction(1)
            arrow.position = inicial_arrow_position.global_position + Vector2(20, 1)

        is_attacking = false

    if shot_timer.is_stopped():
        if not Input.is_anything_pressed():
            go_to_idle()
        else:
            move()
            go_to_walk()
    pass

func go_to_idle():
    status = PlayerStates.idle
    animated_sprite2D.play("idle")

func go_to_walk():
    status = PlayerStates.walk
    animated_sprite2D.play("walk")

func go_to_run():
    status = PlayerStates.run
    animated_sprite2D.play("run")

func go_to_short_attack():
    status = PlayerStates.short_attack
    verifica_short_attack()

func go_to_long_attack():
    can_long_attack = true
    animated_sprite2D.play("attack_shot")
    status = PlayerStates.long_attack
    is_attacking = true
    shot_timer.start()
    velocity = Vector2.ZERO

func go_to_hurt():
    Hitbox.set_deferred("disabled", true)
    invunerable.start()
    velocity = Vector2.ZERO
    PlayerStats.player_hp -= 1
    if PlayerStats.player_hp > 0:


        status = PlayerStates.hurt
    else:
        go_to_dead()

func go_to_dead():
    velocity = Vector2.ZERO
    status = PlayerStates.dead


func move():
    var direction: = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    if direction:
            velocity = direction.normalized() * SPEED
    else:
            velocity = velocity.move_toward(Vector2.ZERO, SPEED)
    if velocity.x < 0:
        dir_attack = -1
        animated_sprite2D.flip_h = true
    elif velocity.x > 0:
        dir_attack = 1
        animated_sprite2D.flip_h = false

func start_invulnerability():
    Hitbox.disabled = true
    invunerable.start()



func start_short_attack():
    if Input.is_action_just_pressed("attack"):
        go_to_short_attack()

func start_long_attack():
    if Input.is_action_just_pressed("shot_attack"):
        go_to_long_attack()

func verifica_short_attack():
        velocity = Vector2.ZERO
        match comb_counter:
            1:
                animated_sprite2D.play("attack_1")
            2:
                animated_sprite2D.play("attack_2")
            3:
                animated_sprite2D.play("attack_3")
            _:
                comb_counter = 1
                animated_sprite2D.play("attack_1")
        comb_counter += 1
        combo_timer.start()

func active_attack_collision():
    if comb_counter == 2:
        if animated_sprite2D.frame == 3:
            attack_collision_1.position = Vector2(dir_attack * 34, -8)
            attack_collision_1.disabled = false
    elif comb_counter == 3:
        if animated_sprite2D.frame == 3:
            attack_collision_2.position = Vector2(dir_attack * 34, -16)
            attack_collision_2.disabled = false
    else:
        if animated_sprite2D.frame == 4:
            attack_collision_3.position = Vector2(dir_attack * 34, -3.5)
            attack_collision_3.disabled = false

func disable_attack_collision():
    attack_collision_1.disabled = true
    attack_collision_2.disabled = true
    attack_collision_3.disabled = true


func _on_combo_timer_timeout() -> void :
    can_attack = true
    comb_counter = 1
    is_attacking = false

func _on_animated_sprite_2d_animation_finished() -> void :
    is_attacking = false
    can_attack = true

func _on_shottimer_timeout() -> void :
    pass


func _on_hitbox_area_entered(_area: Area2D) -> void :
    PlayerStats.score -= 100
    go_to_hurt()


func _on_invunerable_timeout() -> void :
    Hitbox.disabled = false
