shader_type canvas_item;

uniform float line_strength : hint_range(0.0, 1.0) = 0.10;
uniform float vignette_amt : hint_range(0.0, 2.0) = 0.7;

void fragment() {
	float s = sin(UV.y * 720.0 * 3.14159265);
	float scan = line_strength * step(0.0, s);
	vec2 d = UV - vec2(0.5);
	float vig = vignette_amt * dot(d, d);
	float a = clamp(scan + vig, 0.0, 1.0);
	COLOR = vec4(0.0, 0.02, 0.04, a);
}
