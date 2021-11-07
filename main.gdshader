shader_type canvas_item;

const vec3 veczero = vec3(0.0, 0.0, 0.0);
const vec3 vecuno = vec3(1.0, 1.0, 1.0);

uniform sampler2D last_frame : hint_black;

uniform float wee : hint_range(0.0, 20.0);
uniform float wei : hint_range(0.0, 20.0);
uniform float wie : hint_range(0.0, 20.0);
uniform float wii : hint_range(0.0, 20.0);

uniform float thres_x : hint_range(0.0, 0.2);
uniform float gain_x : hint_range(0.0, 10.0);

uniform float thres_y : hint_range(0.0, 0.2);
uniform float gain_y : hint_range(0.0, 10.0);

uniform float noise_int_x : hint_range(0.0, 2.0);
uniform float noise_int_y : hint_range(0.0, 2.0);

uniform float diff : hint_range(0.0, 5.0);

uniform bool is_mouse_pressed = false;
uniform bool exc_input = true;
uniform vec2 mouse_pos = vec2(0.0, 0.0);

float sigmoid(float inpt, float gain, float thres)
{
	return max(0.0, gain*tanh(inpt-thres));
}

float rand(vec2 co)
{
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

vec3 wilson_cowan(vec2 myuv, sampler2D tex, float dt, float time, vec2 disp)
{
	float up = texture(tex, myuv + vec2(0.0, -disp.y)).r;
	float down = texture(tex, myuv + vec2(0.0, +disp.y)).r;
	float left = texture(tex, myuv + vec2(-disp.x, 0.0)).r;
	float right = texture(tex, myuv + vec2(+disp.x, 0.0)).r;
	
	vec3 center = texture(tex, myuv).rgb;
	
	float x = center.r;
	float y = center.b;
	float rec = center.g;
	
	float input = (up + down + left + right - 4.0*x);
	float noise_x = 2.0*rand(myuv*cos(time)) - 1.0;
	float noise_y = 2.0*rand(myuv*cos(time)+0.5) - 1.0;
	
	center.r += dt*(-x + (1.0-x)*sigmoid(wee*x - wei*y + diff*input + noise_int_x*noise_x, gain_x, thres_x));
	center.b += dt*(-y + (1.0-y)*sigmoid(wie*x - wii*y + noise_int_y*noise_y, gain_y, thres_y));

	
	center = max(min(vecuno, center), veczero);
	
	return center; 
}


void fragment() 
{
	vec2 vecmouse = (UV / SCREEN_PIXEL_SIZE) - mouse_pos;
	float dist_2_mouse = dot(vecmouse, vecmouse);
	bool interaction = is_mouse_pressed && (dist_2_mouse < 100.0);
	
	vec3 wc = wilson_cowan(UV, last_frame, 0.08, TIME, SCREEN_PIXEL_SIZE);
	
	COLOR = vec4(wc.r, 0.0, wc.b, 1.0);
	COLOR.r = min(1.0, COLOR.r + float(exc_input) * float(interaction));
	COLOR.b = min(1.0, COLOR.b + float(!exc_input) * float(interaction));
}