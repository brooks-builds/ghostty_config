#define TWOPI 6.28318530718
#define PI 3.14159265359

void keepOriginalTerminal(out vec4 fragColor, in vec2 fragCoord, in vec3 newColor);
void sway(inout vec2 r);
vec2 calculateCoords(in vec2 fragCoord);
float inGrid(vec2 r);
void drawCircle(vec2 r, inout vec3 pixel, float radius, vec2 loc, vec3 color);
float smootherstep(float edge0, float edge1, float x);
float linearstep(float edge0, float edge1, float x);
void plot(vec2 r, float y, float lineThickness, vec3 color, inout vec3 pixel);
float insideCircle(vec2 r, vec2 location, float radius);
float toRadians(float angle);
float insideRect(vec2 r, vec2 topLeft, vec2 bottomRight);

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 r = calculateCoords(fragCoord); // r.xy == [-1.0, 1.0]
    vec2 p = fragCoord.xy / iResolution.xy; // percentage of the screen we're on
    float xMax = iResolution.x / iResolution.y; // ratio of the screen
       
    // sway(r);

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

    // float rotateBy = 0.2;
    float rotateBy = iTime / 50.0;
    float angle = toRadians(rotateBy);
    vec2 rotatedR = vec2(
        cos(angle) * r.x + sin(angle) * r.y,
        -sin(angle) * r.x + cos(angle) * r.y
    );

    sway(rotatedR);

    pixel = mix(pixel, blue, inGrid(r) * 0.4);
    pixel = mix(pixel, blue, insideCircle(r, vec2(1.0, 0.0), 0.2));
    pixel = mix(pixel, blue, insideRect(r, vec2(-0.8, 0.2), vec2(-0.5, 0.4)));

    pixel = mix(pixel, red, inGrid(rotatedR));
    pixel = mix(pixel, red, insideCircle(rotatedR, vec2(1.0, 0.0), 0.2));
    pixel = mix(pixel, red, insideRect(rotatedR, vec2(-0.8, 0.2), vec2(-0.5, 0.4)));
    // float insideCircle(vec2 r, vec2 location, float radius);


    keepOriginalTerminal(fragColor, fragCoord, pixel);
}

// inGrid, returns number 0-1, which is the percentage inside the grid, 0 is completely outside.
float inGrid(vec2 r) {
    const float tickWidth = 0.1;

    vec3 axesColor = vec3(0.0, 0.0, 1.0);
    vec3 gridColor = vec3(0.5);
    float ret = 0.0;
    float gridWidth = 0.004;
    
    for(float i = -2.0; i < 2.0; i += tickWidth) {
        ret += 1.0 - smoothstep(0.0, 0.008, abs(r.x - i));
        ret += 1.0 - smoothstep(0.0, 0.008, abs(r.y - i));
    }

    ret += 1.0 - smoothstep(0.001, 0.015, abs(r.x));
    ret += 1.0 - smoothstep(0.001, 0.015, abs(r.y));

    return ret;
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

float insideRect(vec2 r, vec2 topLeft, vec2 bottomRight) {
    float lineThickness = 0.005;
    float inside = smoothstep(topLeft.x - lineThickness, topLeft.x + lineThickness, r.x);
    inside *= smoothstep(topLeft.y - lineThickness, topLeft.y + lineThickness, r.y);
    inside *= 1.0 - smoothstep(bottomRight.x - lineThickness, bottomRight.x + lineThickness, r.x);
    inside *= 1.0 - smoothstep(bottomRight.y - lineThickness, bottomRight.y + lineThickness, r.y);
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

float toRadians(float angle) {
    float pi = 3.14159265359;

    return angle * pi;
}
