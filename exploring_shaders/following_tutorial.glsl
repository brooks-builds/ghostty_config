#define TWOPI 6.28318530718
#define PI 3.14159265359

void keepOriginalTerminal(out vec4 fragColor, in vec2 fragCoord, in vec3 newColor);
void sway(inout vec2 r);
vec2 calculateCoords(in vec2 fragCoord);
void drawGrid(in vec2 r, inout vec3 pixel);
void drawCircle(vec2 r, inout vec3 pixel, float radius, vec2 loc, vec3 color);
float smootherstep(float edge0, float edge1, float x);
float linearstep(float edge0, float edge1, float x);
void plot(vec2 r, float y, float lineThickness, vec3 color, inout vec3 pixel);
float insideCircle(vec2 r, vec2 location, float radius);

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 r = calculateCoords(fragCoord);
    vec2 p = fragCoord.xy / iResolution.xy;
    float xMax = iResolution.x / iResolution.y;
       
    sway(r);

    vec3 black = vec3(0.0);
    vec3 red = vec3(0.3, 0.0, 0.0);
    vec3 green = vec3(0.0, 0.4, 0.0);
    vec3 blue = vec3(0.2, 0.25, 0.8);
    vec3 yellow = vec3(0.8, 0.8, 0.5);
    vec3 cyan = vec3(0.4, 0.1, 0.8);
    vec3 gray = vec3(0.4);
    vec3 white = vec3(1.0);

    vec3 background = black;
    vec3 pixel = background;

    vec3 ret = gray;
    float radius = 0.4;

    if (p.x < 1./3.) {
        vec2 location1 = vec2(-1.1, 0.3);
        float distance1 = insideCircle(r, location1, radius);
        ret = mix(ret, red, distance1);

        vec2 location2 = vec2(-1.3, 0.0);
        float distance2 = insideCircle(r, location2, radius);
        ret = mix(ret, green, distance2);

        vec2 location3 = vec2(-1.05, -0.3);
        float distance3 = insideCircle(r, location3, radius);
        ret = mix(ret, blue, distance3);
    } else if (p.x < 2./3.) {
        ret = black;
        vec2 location1 = vec2(0.1, 0.3);
        float distance1 = insideCircle(r, location1, radius);
        ret += distance1 * red;

        vec2 location2 = vec2(-0.3, 0.0);
        float distance2 = insideCircle(r, location2, radius);
        ret += distance2 * green;

        vec2 location3 = vec2(0.05, -0.3);
        float distance3 = insideCircle(r, location3, radius);
        ret += distance3 * blue;
    } else if (p.x < 3./3.) {
        ret = white;
        vec2 location1 = vec2(1.1, 0.3);
        float distance1 = insideCircle(r, location1, radius);
        ret -= distance1 * red;

        vec2 location2 = vec2(0.95, 0.0);
        float distance2 = insideCircle(r, location2, radius);
        ret -= distance2 * green;

        vec2 location3 = vec2(1.05, -0.3);
        float distance3 = insideCircle(r, location3, radius);
        ret -= distance3 * blue;
    }

    pixel = ret;


    keepOriginalTerminal(fragColor, fragCoord, pixel);
}


void drawGrid(in vec2 r, inout vec3 pixel) {
    vec3 gridColor = vec3(0.3);
    vec3 axesColor = vec3(0.0, 0.0, 1.0);
    float gridWidth = 0.004;
    float tickWidth = 0.1;
    
    if(mod(r.x, tickWidth) < gridWidth) pixel = gridColor;
    if(mod(r.y, tickWidth) < gridWidth) pixel = gridColor;

    if(abs(r.x) < 0.006) pixel = axesColor;
    if(abs(r.y) < 0.007) pixel = axesColor;
}

vec2 calculateCoords(in vec2 fragCoord) {
    vec2 halfCoord = fragCoord.xy - 0.5 * iResolution.xy;
    halfCoord.y *= -1.0;
    return 2.0 * halfCoord.xy / iResolution.y;
}

void sway(inout vec2 r) {
    r.x += sin(r.y * 10.0 + iTime) * 0.055;
    r.y += sin(r.x * 10.0 + iTime) * 0.055;
}

void keepOriginalTerminal(out vec4 fragColor, in vec2 fragCoord, in vec3 newColor)
{
    vec3 originalColor = texture(iChannel0, fragCoord.xy / iResolution.xy).rgb;
    float threshold = 0.197;
    float alpha = 1.0;
    
    if (length(originalColor) < threshold) {
        // we aren't over our interface or text, draw to our hearts content
        fragColor = vec4(newColor, alpha);
    } else {
        // we want to display what is already there
        fragColor = vec4(originalColor, alpha);
    }
}

void drawCircle(vec2 r, inout vec3 pixel, float radius, vec2 loc, vec3 color) {
    vec2 translation = r - loc;

    if (length(translation) < radius) {
        pixel = color;
    }
}

// insideCircle returns a percentage inside the circle
// 1.0 if we're fully inside
// 0.0 if we're fully outside
// smoothstep edge, so we could be on the edge, 0.5 is halfway inside and outside edge
float insideCircle(vec2 r, vec2 location, float radius) {
    vec2 translation = r - location;
    float distance = length(translation);
    float edge = 0.005;
    float outside = smoothstep(radius - edge, radius + edge, distance);
    float inside = 1.0 - outside;
    return inside;
}

float smootherstep(float edge0, float edge1, float x) {
    float t = clamp((x - edge0)/(edge1 - edge0), 0., 1.);
    return pow(t, 3)*(t*(t*6. - 15.) + 10.);
}

float linearstep(float edge0, float edge1, float x) {
	float t = (x - edge0)/(edge1 - edge0);
	return clamp(t, 0.0, 1.0);
}

void plot(vec2 r, float y, float lineThickness, vec3 color, inout vec3 pixel) {
    if (abs(y - r.y) < lineThickness) pixel = color;
}
