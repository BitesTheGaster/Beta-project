shader_type canvas_item;

uniform sampler2D noise : repeat_enable;

uniform float speed = 1.0;

uniform vec3 dark = vec3(0.8, 0.663, 0.431);
uniform vec3 mid = vec3(0.91, 0.796, 0.51);
uniform vec3 light = vec3(0.984, 0.918, 0.639);

uniform float dark_chance = 0.5469;
uniform float mid_chance = 0.3857;
uniform float light_chance = 0.0674;

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