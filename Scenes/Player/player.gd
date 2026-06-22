extends CharacterBody3D
class_name Player

@export var cam: Camera3D
@export var SPEED: float = 5
@export var JUMP_VELOCITY: float = 4.5
@export var mouse_sense: float = 10.0

@export var inventory: InventoryManager

@onready var stand_col  = $StandCollision
@onready var crouch_col = $CrouchCollision
@onready var ceiling_ray: RayCast3D = $CrouchRaycast
@onready var focus_ray: RayCast3D = %FocusRaycast
@onready var focus_panel: FocusPanel = $%InteractionPanel

const MIN_PITCH = -90.0
const MAX_PITCH = 90.0
const TO_CROUCH_SPEED = 10
const head_pos: Vector3 = Vector3(0, 0.5, 0)
const crouch_pos: Vector3 = Vector3(0, 0.0, 0)

#Можно считать это трением - чем больше, тем реще персонаж будет стартовать и останавливаться
const FRIC_WEIGHT = 4 

var speed_coeff = 1
var mov_dir: Vector3 = Vector3.ZERO
var menu: bool = false
var is_crouch: bool = false
var last_focused_obj: InteractionComponent = null
var hand_init_pos: Vector2

func _calc_speed_coeff() -> float:
	if Input.is_action_pressed("Ctrl") or ceiling_ray.is_colliding():
		return 0.5
	elif Input.is_action_pressed("Shift"):
		return 1.4
	else:
		return 1.0

#Если находимся в прыжке
func _handle_air(delta: float) -> void:
	velocity += get_gravity() * delta
	velocity += mov_dir * SPEED * _calc_speed_coeff() * delta
	velocity = velocity.limit_length(SPEED)


#Если идем по земле
func _handle_ground(delta: float) -> void:
	velocity = lerp(velocity, mov_dir * SPEED * speed_coeff, delta * SPEED * FRIC_WEIGHT)

func _unfocus_last_obj():
	focus_panel.visible = false
	if last_focused_obj == null: return
	last_focused_obj.reset_outline()
	last_focused_obj = null

func _get_obj_at_focus():
	if not focus_ray.is_colliding(): 
		_unfocus_last_obj()
		return
	
	var col = focus_ray.get_collider() as Node3D
	var new_focused_obj = null
	
	if col == null: return
	for child in col.get_children():
		if child is InteractionComponent:
			new_focused_obj = child
	if new_focused_obj == null: return
		
	if last_focused_obj != new_focused_obj:
		_unfocus_last_obj()
		last_focused_obj = new_focused_obj
		last_focused_obj.set_outline()
		focus_panel.setup(last_focused_obj)
		
	focus_panel.follow_obj_pos(cam.unproject_position(col.position))
	
#Обработка любых событий каждый игровой кадр (180 раз в сек. при 180 FPS)
func _process(delta: float) -> void:
	_get_obj_at_focus()
	if Input.is_action_just_pressed("Inventory"):
		inventory.inv_toggle()
	if Input.is_action_just_pressed("Interact"):
		if last_focused_obj == null: return
		last_focused_obj.interact(self)


#Обработка ввода игрока (включая движение мыши)
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sense)
		cam.rotate_x(-event.relative.y * mouse_sense)
		cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(MIN_PITCH), deg_to_rad(MAX_PITCH))

	var is_esc_pressed = event.is_action_pressed("Esc")
	if is_esc_pressed :
		menu = !menu
		if menu:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return
		
	for i in range(inventory.tb_slots_count):
		var action_name = "hotbar_" + str(i + 1)
		if event.is_action_pressed(action_name):
			inventory.select_from_toolbar(i)
			return # Выходим из функции, так как кнопка уже обработана
		
	var crouch_action = Input.is_action_pressed("Ctrl")
	if(crouch_action != is_crouch): crouch_toggle()
	

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

	if is_crouch:
		cam.position = lerp(cam.position, crouch_pos, delta * TO_CROUCH_SPEED)
	else:
		cam.position = lerp(cam.position, head_pos, delta * TO_CROUCH_SPEED)

	move_and_slide()

func crouch_toggle():
	if is_crouch and ceiling_ray.is_colliding(): return
	is_crouch = !is_crouch
	crouch_col.disabled = !is_crouch
	stand_col.disabled = is_crouch

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
