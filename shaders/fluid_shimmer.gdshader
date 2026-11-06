shader_type canvas_item;
// Optional lightweight overlay material for future replacement artwork.
uniform vec4 tint : source_color = vec4(0.95, 0.61, 0.17, 0.12);
uniform float speed = 0.3;
void fragment() {
	float wave = sin(UV.y * 35.0 - TIME * speed * 6.0 + sin(UV.x * 16.0));
	COLOR = vec4(tint.rgb, tint.a * smoothstep(0.4, 1.0, wave));
}
