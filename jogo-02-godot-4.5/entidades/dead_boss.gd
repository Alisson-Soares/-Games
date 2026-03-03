extends CharacterBody2D

@onready var anim_sprite: AnimatedSprite2D = $anim_sprite
@onready var anim_efect: AnimatedSprite2D = $anim_efect

@onready var c_attack_1: CollisionShape2D = $collisions / attacks / attack_1 / c_attack_1
@onready var c_attack_2: CollisionShape2D = $collisions / attacks / attack_2 / c_attack_2

@onready var c_hitbox: CollisionShape2D = $collisions / Hitbox / C_hitbox

@onready var t_attack: Timer = $timers / t_attack
@onready var t_spawn: Timer = $timers / t_spawn
@onready var invunerable: Timer = $timers / invunerable

const boss_summon = preload("res://boss_summon.tscn")
const master_key = preload("res://key.tscn")



const SPEED = 75.0
var direction = 0

@export var hp: float = 15.0

var t_tp: float = 4

var alvo: CharacterBody2D = null

var h_dir = 0

var spawn_dist: int = 1
var can_spawn: bool = true
var can_attack = true
var total_spawn: int = 3

var delay_attack: float = 3
var delay_spawn: float = 3


var states: Enemy
enum Enemy{
    start_boss, 
    attack_1, 
    despair, 
    appears, 
    summon, 
    hurt, 
    dead, 
    change
}



func _ready() -> void :
    alvo = get_tree().get_first_node_in_group("player")
    anim_efect.play("despair")
    anim_sprite.play("")
    states = Enemy.start_boss



func _physics_process(_delta: float) -> void :
    if not is_instance_valid(alvo):
        alvo = get_tree().get_first_node_in_group("player")
    else:
        match states:
            Enemy.start_boss:
                start_boss_battle()
            Enemy.attack_1:
                attack_1_state()
            Enemy.despair:
                despair()
            Enemy.appears:
                appears_state()
            Enemy.summon:
                summon_state()
            Enemy.hurt:
                hurt_state()
            Enemy.dead:
                dead_state()
            Enemy.change:
                change_state()
        flip()
        player_alive()



func start_boss_battle():
    if anim_efect.frame == 4:
        anim_sprite.play("idle")
    if not anim_efect.is_playing():
        go_to_summon()

func attack_1_state():
    var dir = 1 if anim_sprite.flip_h == false else -1
    match anim_sprite.frame:
        2:
            c_attack_1.disabled = false
            c_attack_1.position = Vector2(44 * dir, -12)
        4:
            c_attack_1.disabled = true
        9:
            c_attack_2.disabled = false
            c_attack_2.position = Vector2(19 * dir, 16)
        11:
            c_attack_2.disabled = true
        12:
            anim_sprite.play("idle")
            t_attack.start()
            can_attack = false
            go_to_despair()

func despair():
    if anim_efect.frame == 3:
        anim_sprite.play("void")
    elif anim_efect.frame == 6:
        anim_efect.play("void")
        go_to_appears()

func appears_state():
    if anim_efect.frame == 3 and anim_efect.animation == "despair":
        go_to_attack_1()

func summon_state():
    if can_spawn:
        can_spawn = false
        for i in range(total_spawn - 1):
            var spawner = boss_summon.instantiate()
            add_sibling(spawner)
            spawner.global_position = spawn_zone()
        go_to_despair()


func hurt_state():
    if not anim_sprite.is_playing():
        if hp == 8 or hp == 4:
            go_to_change()
        else:
            go_to_summon()


func dead_state():
    if not anim_sprite.is_playing():
        PlayerStats.score += 2500
        spawn_key()

func change_state():
    if not anim_efect.is_playing():
        go_to_despair()



func go_to_attack_1():
    anim_efect.play("void")
    anim_sprite.play("attack_1")
    states = Enemy.attack_1


func go_to_despair():
    anim_efect.play("despair")
    states = Enemy.despair

func go_to_appears():
    anim_efect.play("despair")
    teleport_boss()
    states = Enemy.appears

func go_to_summon():
    anim_efect.play("void")
    anim_sprite.play("summon")
    states = Enemy.summon
    can_spawn = true

func go_to_hurt():
    anim_efect.play("void")
    anim_sprite.play("hurt")
    states = Enemy.hurt
    c_hitbox.set_deferred("disabled", true)
    invunerable.start()


func go_to_dead():
    anim_efect.play("void")
    anim_sprite.play("dead")
    states = Enemy.dead

func go_to_change():
    states = Enemy.change
    anim_sprite.play("idle")
    anim_efect.play("change")
    delay_spawn /= 2
    spawn_dist *= 2
    delay_attack /= 2
    total_spawn *= 2
    t_spawn.wait_time = delay_spawn
    t_attack.wait_time = delay_attack



func flip():
    var diff = alvo.global_position - self.global_position
    anim_sprite.flip_h = true if sign(diff.x) < 0 else false

func spawn_zone():
    var rng = randi_range(20, 50)
    var rng1 = randi_range(20, 50)
    rng1 *= spawn_dist
    if rng % 2 == 0:
        return global_position + Vector2(rng, rng1)
    else:
        return global_position - Vector2(rng, rng1)

func teleport_boss():
    var rng = randi_range(20, 40)
    if rng % 2 == 0:
        self.global_position = alvo.global_position + Vector2(rng, 0)
    else:
        self.global_position = alvo.global_position - Vector2(rng, 0)


func _on_hitbox_area_entered(_area: Area2D) -> void :
    hp -= 1
    print("boss hp:", hp)
    if hp > 0:
        go_to_hurt()
    else:
        go_to_dead()

func player_alive():
    if PlayerStats.player_hp <= 0:
        queue_free()

func spawn_key():
    var key = master_key.instantiate()
    add_sibling(key)
    key.global_position = self.global_position
    queue_free()

func _on_invunerable_timeout() -> void :
    c_hitbox.set_deferred("disabled", false)
