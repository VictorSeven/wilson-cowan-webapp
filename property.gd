extends HBoxContainer

var par_name : String = "" #Name of the parameter we control
var shader_param : String = ""  #The name of shader parameter this bar controls
var shader_mat : Material = null  #A reference to our material 

var in_web = false #To know if the proyect is running on web or not

# Called when the node enters the scene tree for the first time.
func _ready():
	if in_web:
		$scroll.connect("value_changed", self, "_on_value_changed_web") 
	else:
		$scroll.connect("value_changed", self, "_on_value_changed") 

#To be called before enterting the tree. Sets all the properties of the object
func set_parameters(name:String, property:String, minval:float, maxval: float, step: float, mymaterial: Material):
	in_web = OS.get_name() == "HTML5"
	
	#Control of the shader
	shader_param = property
	shader_mat = mymaterial
	
	#Set scroll bar atributes
	$scroll.min_value = minval
	$scroll.max_value = maxval
	$scroll.step = step
	
	#Automatically get value for the bar
	$scroll.value = shader_mat.get_shader_param(shader_param)
	
	#Set label name
	par_name = name
	if in_web:
		$scroll.rect_min_size.y = 20
		$name.text = par_name
		$Pa
	else:
		$name.text = par_name + "\n%.2f" % $scroll.value

#This function changes the shader parameters when the scroll bar changes
func _on_value_changed(value):
	shader_mat.set_shader_param(shader_param, value)
	$name.text = par_name + "\n%.2f"%value
	return

#Same as above but does not write the numeric value, to save space
func _on_value_changed_web(value):
	shader_mat.set_shader_param(shader_param, value)
	return
