shader_type spatial;

// This shader calculates light at the corners (vertices) 
// and blends it across the face for a clean, retro look.

uniform vec4 tint : source_color = vec4(1.0);
uniform sampler2D albedo_tex : source_color, filter_nearest;

varying vec3 v_illumination;

void vertex() {
	// Define a static light direction (like a sun)
	vec3 light_dir = normalize(vec3(0.5, 1.0, 0.4));
	
	// Lambertian lighting: How much the face points at the sun
	// Calculated here in vertex() means it happens PER-VERTEX
	float dot_product = max(dot(NORMAL, light_dir), 0.15); // 0.15 is minimum ambient light
	
	v_illumination = vec3(dot_product);
}

void fragment() {
	vec4 color = texture(albedo_tex, UV) * tint;
	
	// Multiply the texture by the light we calculated at the vertices
	ALBEDO = color.rgb * v_illumination;
}