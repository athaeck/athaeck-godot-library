extends Node3D
class_name RTSCameraController

#region NodeReferences
@onready var _rotationX = $CameraRotationX
@onready var _zoomPivot = $CameraRotationX/CameraZoomPivot
@onready var _camera = $CameraRotationX/CameraZoomPivot/Camera3D
#endregion

#region EditorMutatables
@export var _movementSpeed := 0.6
@export var _rotationSpeed := 1.5
@export var _zoomSpeed := 3.0
@export var _minZoom := -20.0
@export var _maxZoom := 20.0
@export var _scrollSpeed := 0.6
@export var _edgeSize := 5.0
@export var _mouseSensitivity := 0.2
#endregion

#region Parameter
var _movementTarget: Vector3
var _rotationTarget: float
var _zoomTarget: float
#endregion

#region Hooks
func _init():
	pass

func _ready():
	_movementTarget = position
	_rotationTarget = rotation_degrees.y
	_zoomTarget = _camera.position.z
	
	_camera.look_at(position)

func _process(delta):
	var mousePosition := get_viewport().get_mouse_position()
	var viewportSize := get_viewport().get_visible_rect().size
	
	if Input.is_action_just_pressed("Rotate"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	if Input.is_action_just_released("Rotate"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	var scrollDirection = Vector3.ZERO
	if mousePosition.x < _edgeSize:
		scrollDirection.x = -1
	elif mousePosition.x > viewportSize.x - _edgeSize:
		scrollDirection.x = 1
	
	if mousePosition.y < _edgeSize:
		scrollDirection.z = -1
	elif mousePosition.y > viewportSize.y - _edgeSize:
		scrollDirection.z = 1
	
	_movementTarget += transform.basis * scrollDirection * _scrollSpeed
	
	var direction := Input.get_vector("Left","Right","Up","Down")
	var movementDirection := (transform.basis * Vector3(direction.x,0,direction.y)).normalized()
	var zoomDirection := (int(Input.is_action_just_released("ZoomOut")) - int(Input.is_action_just_released("ZoomIn")))
	
	var rotateAxis := Input.get_axis("RotateLeft","RotateRight")
	
	_movementTarget += _movementSpeed * movementDirection
	_rotationTarget += rotateAxis * _rotationSpeed
	_zoomTarget += zoomDirection * _zoomSpeed
	
	position = lerp(position,_movementTarget,0.05)
	rotation_degrees.y = lerp(rotation_degrees.y, _rotationTarget,0.05)
	_camera.position.z = lerp(_camera.position.z, _zoomTarget, 0.1)
#endregion


func _unhandled_input(event)-> void:
	if event is InputEventMouseMotion and Input.is_action_pressed("Rotate"):
		var e: InputEventMouseMotion = event
		_rotationTarget -= e.relative.x * _mouseSensitivity
		_rotationX.rotation_degrees.x -= e.relative.y * _mouseSensitivity
		_rotationX.rotation_degrees.x = clamp(_rotationX.rotation_degrees.x, -10 , 30)
