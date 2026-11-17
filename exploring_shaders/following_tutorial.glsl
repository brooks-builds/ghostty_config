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

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 r = calculateCoords(fragCoord);
    // sway(r);

    vec3 black = vec3(0.0);
    vec3 red = vec3(0.3, 0.0, 0.0);
    vec3 green = vec3(0.0, 0.4, 0.0);
    vec3 blue = vec3(0.2, 0.25, 0.8);
    vec3 yellow = vec3(0.8, 0.8, 0.5);
    vec3 cyan = vec3(0.4, 0.1, 0.8);

    vec3 background = black;
    vec3 pixel = background;

    drawGrid(r, pixel);

    float thickness = 0.025;
    // y = 2x + 0.5
    plot(r, 2.0 * r.x + 0.5, 0.02, green, pixel);
    // y = x^2 - .2
    if (abs(pow(r.x, 2) - 0.2 -r.y) < 0.02) pixel = red; 
    // y = sin(PI x)
    if (abs(sin(PI * r.x) - r.y) < 0.02) pixel = red;

    if (abs(0.25 * step(0.0, r.x) + 0.6 - r.y) < 0.01) pixel = blue;
    if (abs(0.25 * linearstep(-0.5, 0.5, r.x) + 0.1 - r.y) < 0.01) pixel = blue;
    if (abs(0.25 * smoothstep(-0.5, 0.5, r.x) - 0.4 - r.y) < 0.01) pixel = blue;
    if (abs(0.25 * smootherstep(-0.5, 0.5, r.x) - 0.9 - r.y) < 0.01) pixel = blue;

    plot(r, 0.5 * (clamp(sin(TWOPI * r.x), 0.0, 1.0) - 0.7), 0.015, yellow, pixel);
    plot(r, 0.6 * exp(-10.0 * (r.x + 0.8) * (r.x + 0.8)) + 0.3, 0.015, yellow, pixel);
    

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
