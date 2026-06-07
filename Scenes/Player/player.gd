extends CharacterBody3D

@export var cam: Camera3D
@export var SPEED: float = 5
@export var JUMP_VELOCITY: float = 4.5
@export var mouse_sense: float = 10.0

@onready var stand_col  = $StandCollision
@onready var crouch_col = $CrouchCollision
@onready var ceiling_ray: RayCast3D = $RayCast3D

const MIN_PITCH = -90.0
const MAX_PITCH = 90.0

#Можно считать это трением - чем больше, тем реще персонаж будет стартовать и останавливаться
const FRIC_WEIGHT = 4 

const TO_CROUCH_SPEED = 10

const head_pos: Vector3 = Vector3(0, 0.5, 0)
const crouch_pos: Vector3 = Vector3(0, 0.0, 0)

var speed_coeff = 1

var mov_dir: Vector3 = Vector3.ZERO
var menu: bool = false

func _calc_speed_coeff() -> float:
	if Input.is_action_pressed("Ctrl") or ceiling_ray.is_colliding():
		return 0.5
	elif Input.is_action_pressed("Shift"):
		return 1.3
	else:
		return 1.0


#Если находимся в прыжке
func _handle_air(delta: float) -> void:
	velocity += get_gravity() * delta
	velocity += mov_dir * SPEED * delta
	velocity = velocity.limit_length(SPEED)
	
	
#Если идем по земле
func _handle_ground(delta: float) -> void:
	velocity = lerp(velocity, mov_dir * SPEED * speed_coeff, delta * SPEED * FRIC_WEIGHT)
	
	
	
func _crouch(delta: float, is_crouch: bool) -> void:
	if is_crouch:
		speed_coeff = 0.5
		stand_col.disabled  = true
		crouch_col.disabled = false
		cam.position = lerp(cam.position, crouch_pos, delta*TO_CROUCH_SPEED)
	elif not ceiling_ray.is_colliding():
		speed_coeff = 1
		stand_col.disabled  = false
		crouch_col.disabled = true
		cam.position = lerp(cam.position, head_pos, delta*TO_CROUCH_SPEED)
		
	

#Крутим камеру
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not menu:
		rotate_y(-event.relative.x * mouse_sense)
		cam.rotate_x(-event.relative.y * mouse_sense)
		cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(MIN_PITCH), deg_to_rad(MAX_PITCH))
	
	var is_esc_pressed = event.is_action_pressed("Esc")
	if is_esc_pressed:
		menu = not menu
		
	if menu:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED



#Обработка движения каждый тик физического движка (60 раз в секунду)
func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("MoveL", "MoveR", "MoveF", "MoveB")
	mov_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	speed_coeff = _calc_speed_coeff()
	
	if is_on_floor():
		_handle_ground(delta)
		if Input.is_action_just_pressed("Jmp") and not ceiling_ray.is_colliding():
			velocity.y = JUMP_VELOCITY
	else:
		_handle_air(delta)

		
	var is_ctrl_pressed = Input.is_action_pressed("Ctrl")
	_crouch(delta, is_ctrl_pressed)

	move_and_slide()
	
	
	
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	crouch_col.disabled = true
	stand_col.disabled = false
	
