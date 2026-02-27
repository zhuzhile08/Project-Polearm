class_name UtilityMath


# Rotates the input vector on the plane defined by the normal vector
static func rotateVectorOntoPlane(input : Vector3, normal : Vector3) -> Vector3:
	return (input - input.dot(normal) * normal).normalized() * input.length()
