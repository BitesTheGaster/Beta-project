shader_type canvas_item;

uniform sampler2D noise : repeat_enable;

uniform float speed = 1.0;

uniform vec3 dark = vec3(0.0, 0.22, 0.314);
uniform vec3 mid = vec3(0.043, 0.4, 0.498);
uniform vec3 light = vec3(0.196, 0.549, 0.655);

uniform float dark_chance = 0.333;
uniform float mid_chance = 0.333;
uniform float light_chance = 0.334;

void fragment() {
	vec3 color = light;
	float noise_rand = texture(noise, vec2(UV.x, UV.y)).r;
	float uv_mod = 0.0;
	uv_mod = sin(TIME*4.0) * UV.x + cos(TIME*3.0) * UV.y;
	float rand = abs(sin((noise_rand+TIME+(uv_mod))*speed));
	if(rand < dark_chance)
		color = dark;
	else if(rand < dark_chance+mid_chance)
		color = mid;
	
	COLOR = vec4(color, 1.0);
}