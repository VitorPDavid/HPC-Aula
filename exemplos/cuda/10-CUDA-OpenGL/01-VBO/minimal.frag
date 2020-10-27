// minimal fragment shader
// www.lighthouse3d.com


vec4 ColorFromFloat(float vmin, float vmax, float v)
 {
	if (v > vmax) v = vmax;
	if (v < vmin) v = vmin;
	// Calculate local position within the [vmin,vmax] interval
	v -= vmin;
	v /= vmax - vmin;
	// Apply color mapping based on local position
	vec4 RGB;

	if  (v > 7.0/8.0) {
		RGB.r = 1.0 - 0.5*(8.0*v - 7.0);
		RGB.g = 0.0;
		RGB.b = 0.0;
	}
	else if (v > 6.0/8.0) {
		RGB.r = 1.0;
		RGB.g = 0.5 - 0.5*(8.0*v - 6.0);
		RGB.b = 0.0;
	}
	else if (v > 5.0/8.0) {
		RGB.r = 1.0;
		RGB.g = 1.0 - 0.5*(8.0*v - 5.0);
		RGB.b = 0.0;
	}
	else if (v > 4.0/8.0) {
		RGB.r = 0.45 + 0.5*(8.0*v - 4.0);
		RGB.g = 1.0;
		RGB.b = 1.0 - 1.0*(8.0*v - 4.0);
	}
	else if (v > 3.0/8.0) {
		RGB.r = 0.5*(8.0*v - 3.0);
		RGB.g = 1.0;
		RGB.b = 1.0 - 0.5*(8.0*v - 3.0);
	}
	else if (v > 2.0/8.0) {
		RGB.r = 0.0;
		RGB.g = 0.45 + 0.5*(8.0*v - 2.0);
		RGB.b = 1.0;
	}
	else if (v > 1.0/8.0) {
		RGB.r = 0.0;
		RGB.g = 0.5*(8.0*v - 1.0);
		RGB.b = 1.0;
	}
	else {
		RGB.r = 0.0;
		RGB.g = 0.0;
		RGB.b = 0.45 + 128.0*8.0*v;
	}
	RGB.a = 1.0;
	return RGB; 
}


varying float ampli;

void main()
{

   if ((ampli > -0.5) && (ampli < 0.5))
      discard;
   vec4 c = ColorFromFloat(-1.0, 1.0, ampli);

   gl_FragColor = c.bgra;
 
}
