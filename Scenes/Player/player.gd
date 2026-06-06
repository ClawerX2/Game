extends CharacterBody3D

@export var cam: Camera3D
@export var SPEED: float = 5
@export var JUMP_VELOCITY: float = 4.5
@export var mouse_sense: float = 10.0

const MIN_PITCH = -90.0
const MAX_PITCH = 90.0

#Можно считать это трением - чем больше, тем реще персонаж будет стартовать и останавливаться
const FRIC_WEIGHT = 4 

var mov_dir: Vector3 = Vector3.ZERO

#Если находимся в прыжке
func _handle_air(delta: float) -> void:
	velocity += get_gravity() * delta
	velocity += mov_dir * SPEED * delta
	velocity = velocity.limit_length(SPEED)
	
#Если идем по земле
func _handle_ground(delta: float) -> void:
	velocity = lerp(velocity, mov_dir * SPEED, delta * SPEED * FRIC_WEIGHT)

#Крутим камеру
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sense)
		cam.rotate_x(-event.relative.y * mouse_sense)
		cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(MIN_PITCH), deg_to_rad(MAX_PITCH))

#Обработка движения каждый тик физического движка (60 раз в секунду)
func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("MoveL", "MoveR", "MoveF", "MoveB")
	mov_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		_handle_ground(delta)
		if Input.is_action_just_pressed("Jmp"):
			velocity.y = JUMP_VELOCITY
	else:
		_handle_air(delta)
		
	move_and_slide()
