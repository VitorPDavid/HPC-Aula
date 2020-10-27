// minimal vertex shader
// www.lighthouse3d.com

//varying float zvalue;

varying float ampli;

void main()
{	

// the following three lines provide the same result

//	gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * gl_Vertex;
//	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
   ampli = gl_Vertex.y;
	gl_Position = ftransform();
   //gl_Point = 5.0f;
}
