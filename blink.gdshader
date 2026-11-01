shader_type canvas_item;

// Eyelids for the intro blink. Black everywhere
// except an eye-shaped ellipse in the middle.
// 0 = eyes shut, 1 = fully open (screen clear).
uniform float open : hint_range(0.0, 1.0) = 0.0;
// Blur of the eyelid edge
uniform float softness : hint_range(0.0, 0.5) = 0.15;

void fragment() {
	vec2 p = UV - vec2(0.5);
	// Wide slit first, then it opens up and out.
	// 0.95 radius at open=1 clears the corners.
	float rx = mix(0.3, 0.95, open);
	float ry = max(0.95 * open, 0.0001);
	float e = length(p / vec2(rx, ry));
	float lid = smoothstep(1.0 - softness, 1.0 + softness, e);
	COLOR = vec4(0.0, 0.0, 0.0, lid);
}
