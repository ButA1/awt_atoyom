extends RayCast3D


var NoCollisionLayer
var ShotLayer
var GrabLayer
var grabIndicator
var isHolding = false
var isPaused = false
var heldObject
var heldObjectRigidBody
var heldObjectTrailRenderer
@onready var holdingPosition = $"../HUDcamera/ObjectHolder"
@onready var animationTree = $"../HUDcamera/hand/AnimationTree"
var stateMachine

func _ready():
	var layers = [""] # for offset
	for i in range(1, 21):
		layers.append(ProjectSettings.get_setting("layer_names/3d_physics/layer_" + str(i)))
	
	NoCollisionLayer = layers.find("NoCollision")
	ShotLayer = layers.find("ShotLayer")
	GrabLayer = layers.find("GrabLayer")
	grabIndicator = get_node("/root/RootNode3D/LevelMinimumPrefabs/Canvas/Crosshair/GrabIndicator")
	
	stateMachine = animationTree.get("parameters/Base Layer/playback")
	# TODO get grab sound

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_colliding() && !isHolding:
		grabIndicator.visible = true
	elif grabIndicator.visible:
		grabIndicator.visible = false
		
	if !isPaused:
		if (Input.is_action_just_pressed("grabshoot") && !isHolding && is_colliding()):
			Grab()
		elif (Input.is_action_just_pressed("grabshoot") && isHolding):
			Release()
			
func Grab():
	SetHoldVariables()
	# probably don't need to turn off physics interpolation since there is none
	heldObject.freeze = true
	heldObject.global_position = holdingPosition.global_position
	heldObject.rotation = holdingPosition.rotation
	print("caught " + heldObject.name)
	heldObject.get_parent().remove_child(heldObject)
	holdingPosition.add_child(heldObject)
	# TODO disable trail
	stateMachine.travel("Hold")
	# TODO play grab sound
	heldObject.collision_layer = NoCollisionLayer

func SetHoldVariables():
	isHolding = true
	heldObject = get_collider() as RigidBody3D
	# don't know if I even need to get the rigidbody seperately
	
func Release():
	# again skip physics interpolation
	# TODO enable trails
	heldObject.freeze = false
	holdingPosition.remove_child(heldObject)
	get_node("/root").add_child(heldObject) # instead of removing parent
	stateMachine.travel("Flick")
	
	Shoot()
	
	ChangeObjectLayers()
	
	ResetHoldVariables()
	
func Shoot():
	pass
	# TODO

func ChangeObjectLayers():
	pass
	
func ResetHoldVariables():
	# reset other heldObject variables
	heldObject = null
	isHolding = false
