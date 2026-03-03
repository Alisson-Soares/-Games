extends CharacterBody2D

@onready var anim_sprite = $animations / AnimatedSprite2D
@onready var anim_efect = $animations / anim_efect

@onready var C_attack: CollisionShape2D = $collisions / attack / attack
@onready var C_dead: CollisionShape2D = $collisions / dead / dead_explosion

@onready var C_vision: Area2D = $collisions / vision

@onready var C_hitbox: Area2D = $collisions / Hitbox


@onready var T_tp: Timer = $timers / TP
@onready var T_take_damage: Timer = $timers / take_damage


var alvo: CharacterBody2D = null


var speed_modify = 300
var see_player = false
var direction = 0
var damage = 1
var hp = 6
var max_hp = 6
var can_tp = true
var can_appear = true




var status: STATE

enum STATE{
    idle, 
    run, 
    attack, 
    tp, 
    hurt, 
    pre_dead, 
    dead, 
    }


func _ready() -> void :
    anim_sprite.play("idle")


func _physics_process(_delta: float) -> void :

    if not see_player:
        if max_hp != hp:
            see_player = true
        else:
            idle()
    else:
        match status:
            STATE.idle:
                idle()
            STATE.run:
                run()
            STATE.tp:
                tp()
            STATE.attack:
                attack()
            STATE.hurt:
                hurt()
            STATE.dead:
                dead()
                return


        flip()
    move_and_slide()

func idle():
    pass
func run():
    if can_tp or abs(alvo.global_position.y - position.y) >= 150:
        go_to_tp()

    elif abs(alvo.global_position.x - position.x) < 75:
        go_to_attack()

    else:
        velocity.x = speed_modify * direction


func attack():
    velocity = Vector2.ZERO
    if anim_sprite.frame == 9:
        C_attack.disabled = false
        if direction == 1:
            C_attack.position = Vector2(37, -7)
        else:
            C_attack.position = Vector2(-37, -7)
    if anim_sprite.frame == 10:
        C_attack.disabled = true

    if anim_sprite.frame == 11:
        go_to_run()


func tp():
    velocity = Vector2.ZERO

    position.y = alvo.global_position.y
    if randomnumber() % 2:
        position.x = alvo.global_position.x - randomnumber()
    else:
            position.x = alvo.global_position.x + randomnumber()

    go_to_attack()


func hurt():
    if T_take_damage.is_stopped():
        go_to_run()
    pass

func dead():
    velocity = Vector2.ZERO
    anim_sprite.play("dead")
    if anim_sprite.frame == 12:
        C_dead.disabled = false
    if anim_sprite.frame == 21:
        queue_free()
        PlayerStats.score += 500




func go_to_idle():
    velocity = Vector2.ZERO
    anim_sprite.play("idle")
    idle()

func go_to_run():
    status = STATE.run
    anim_sprite.play("run")
    run()

func go_to_attack():
    status = STATE.attack
    anim_sprite.play("attack")
    attack()

func go_to_tp():
    can_tp = false
    T_tp.start()
    status = STATE.tp
    anim_efect.play("disappear")
    anim_sprite.play("invisible")


func go_to_hurt():
    hp = hp - PlayerStats.player_damage
    if hp <= 0:
        go_to_dead()
        return
    status = STATE.hurt
    anim_sprite.play("hurt")
    T_take_damage.start()
    print(hp)

func go_to_dead():
    anim_sprite.play("dead")
    status = STATE.dead


func randomnumber() -> int:
    var rng = RandomNumberGenerator.new()
    rng.randomize()
    return rng.randi_range(10, 50)


func flip():
    if (alvo.global_position.x - position.x) > 0:
        direction = 1
        anim_sprite.flip_h = false
    elif (alvo.global_position.x - position.x) < 0:
        direction = -1
        anim_sprite.flip_h = true


func _on_vision_body_entered(_body: Node2D) -> void :
    see_player = true
    alvo = get_tree().get_first_node_in_group("player")
    go_to_run()
    C_vision.queue_free()
    pass


func _on_anim_efect_animation_finished() -> void :
    if anim_efect.animation == "disappear":
        anim_efect.play("null")
    elif anim_efect.animation == "appear":
        anim_efect.play("null")

func _on_tp_timeout() -> void :
    can_tp = true


func _on_hitbox_area_entered(_area: Area2D) -> void :
    alvo = get_tree().get_first_node_in_group("player")
    go_to_hurt()


func _on_take_damage_timeout() -> void :
    pass
