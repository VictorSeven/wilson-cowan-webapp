extends Node2D

#Store a reference to our shader material
onready var shader_material = $ViewportA/ColorRect.material

var interacting = false #Pressing the screen to interact with shader
var lock_input = false #To lock the "change to fullscreen" button in desktop

# Called when the node enters the scene tree for the first time.
func _ready():
	
	get_tree().root.connect("size_changed", self, "_on_windows_resize")
	
	#Set the Viewport to the adequate render mode for simulation, which allows feedback
	$ViewportA.render_target_clear_mode = Viewport.CLEAR_MODE_ONLY_NEXT_FRAME
	
	position_elements()

	#Create the menu adding all the properties
	var property_scn = preload("property.tscn")
	
	var shader_pars = ["wee", "wei", "wie", "wii", "thres_x", "gain_x", "thres_y", "gain_y", "noise_int_x", "noise_int_y"]
	var names = ["E<E", "E<I", "I<E", "I<I", "ThrE", "GainE", "ThrI", "GainI", "NoiE", "NoiI"]
	var maxval = [20.0, 20.0, 20.0, 20.0, 0.2, 10.0, 0.2, 10.0, 2.0, 2.0]
	var step = [0.05, 0.05, 0.05, 0.05, 0.01, 0.05, 0.01, 0.05, 0.01, 0.01]
	var npars = len(names)
	
	for j in range(npars):
		var property = property_scn.instance()
		property.set_parameters(names[j], shader_pars[j], 0.0, maxval[j], step[j], shader_material)
		$Panel/margin/parlist.add_child(property)
	
	#Reduce panel size in web
	if OS.get_name() == "HTML5":
		$Panel.rect_min_size.y = 300
		$Panel.rect_size = $Panel.rect_min_size
	
	#Eliminate the logic of main loop
	set_process(false)
	set_physics_process(false)

#This function positions all the elements independently of the device's size
func position_elements():
	#Get the window size where this is rendered and set all viewports to that size
	var shader_size = OS.get_real_window_size()
	$ViewportA.size = shader_size
	$ViewportB.size = shader_size
	$ViewportA/ColorRect.rect_min_size = shader_size
	
	#Position left corner correctly
	$Panel.rect_position.x = shader_size.x - $Panel.rect_size.x - 10
	$menu.rect_position.x = shader_size.x - $menu.rect_size.x - 20
	
	#Now that viewports are loaded set the output to our renderer and to feedback loop
	$renderer.texture = $ViewportA.get_texture()
	shader_material.set_shader_param("last_frame", $ViewportB.get_texture())
	
	#Move Sprites and Camera in order to make it coincide with ColorRect
	$ViewportB/Sprite.position = shader_size / 2.0
	$ViewportA/camA.position = shader_size / 2.0
	$ViewportB/camB.position  = shader_size / 2.0
	
	#Get the interaction area of the correct size
	$renderer/clickarea/shape.shape.extents = shader_size / 2.0
	$renderer/clickarea.position = shader_size / 2.0

#Check if we want to change
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		OS.window_fullscreen = !OS.window_fullscreen

#Use the spacebar to change to fullscreen
func _input(event):
	if event.is_action_pressed("ui_accept") and not lock_input:
		OS.window_fullscreen = !OS.window_fullscreen
		lock_input = true #Simulate "just pressed"ç
	elif event.is_action_released("ui_accept"):
		lock_input = false
	

#Click interaction
func _on_clickarea_input_event(viewport, event, shape_idx):
	#Button left also captures touchscreen!
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.is_pressed(): 
			#Double click makes inhibitory interaction
			if not event.is_doubleclick():
				shader_material.set_shader_param("exc_input", true)
			else:
				shader_material.set_shader_param("exc_input", false)
			
			#Set shader properties to allow changing it
			shader_material.set_shader_param("is_mouse_pressed", true)
			var mouse_pos = event.position
			shader_material.set_shader_param("mouse_pos", mouse_pos)
			interacting = true
		else: 
			#Eliminate the interaction
			shader_material.set_shader_param("is_mouse_pressed", false)
			interacting = false
	elif interacting and event is InputEventMouseMotion: 
			#If we started touching capture movement
			var mouse_pos = event.position
			shader_material.set_shader_param("mouse_pos", mouse_pos)
	

#Show/hide menu
func _on_close_pressed():
	$Panel.hide()
	$menu.show()
func _on_menu_pressed():
	$menu.hide()
	$Panel.show()

#Allows to re-change everything when windows is resized. Also called when changed
#to fullscreen
func _on_windows_resize(): 
	#Hide vewiports to eliminate any feedback among them while repositioning
	$ViewportA/ColorRect.hide()
	$ViewportB/Sprite.hide()
	#Reposition and restart
	position_elements()
	$ViewportA/ColorRect.show()
	$ViewportB/Sprite.show()
