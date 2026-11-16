#define TWOPI 6.28318530718

void keepOriginalTerminal(out vec4 fragColor, in vec2 fragCoord, in vec3 newColor);
void sway(inout vec2 r);
vec2 calculateCoords(in vec2 fragCoord);
void drawGrid(in vec2 r, inout vec3 pixel);
void drawCircle(vec2 r, inout vec3 pixel, float radius, vec2 loc, vec3 color);
float smootherstep(float edge0, float edge1, float x);

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 r = calculateCoords(fragCoord);
    vec2 p = fragCoord.xy / iResolution.xy;
    sway(p);

    vec3 black = vec3(0.0);
    vec3 red = vec3(0.3, 0.0, 0.0);
    vec3 green = vec3(0.0, 0.4, 0.0);
    vec3 blue = vec3(0.0, 0.1, 0.5);
    vec3 yellow = vec3(0.3, 0.4, 0.0);
    vec3 cyan = vec3(0.4, 0.1, 0.8);

    vec3 pixel = black;

    vec3 ret = black;

    if (p.x < 0.25) {
        float x0 = 0.2;
        float x1 = 0.7;
        float m = 0.1; // percentage of mixture (10% x1, 90% x0)
        float mix = x0 * (1.0 - m) + x1 * m;
        ret = vec3(mix);
    } else if (p.x < 0.5) {
        float x0 = 0.2;
        float x1 = 0.7;
        float m = p.y;
        ret = vec3(mix(x0, x1, m));
    } else if (p.x < 0.75) {
        float m = p.y;
        ret = mix(red, blue, m);
    } else {
        float m = smootherstep(0.45, 0.55, p.y);
        ret = mix(cyan, yellow, m);
    }

    pixel = vec3(ret);

    keepOriginalTerminal(fragColor, fragCoord, pixel);
}

void drawGrid(in vec2 r, inout vec3 pixel) {
    vec3 gridColor = vec3(0.2);
    vec3 axesColor = vec3(0.0, 0.0, 0.9);
    float gridWidth = 0.002;
    float tickWidth = 0.1;
    
    if(mod(r.x, tickWidth) < gridWidth) pixel = gridColor;
    if(mod(r.y, tickWidth) < gridWidth) pixel = gridColor;

    if(abs(r.x) < 0.005) pixel = axesColor;
    if(abs(r.y) < 0.005) pixel = axesColor;
}

vec2 calculateCoords(in vec2 fragCoord) {
    vec2 halfCoord = fragCoord.xy - 0.5 * iResolution.xy;
    return 2.0 * halfCoord.xy / iResolution.y;
    return halfCoord;
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

    if (length(translation) < radius) pixel = color;
}

float smootherstep(float edge0, float edge1, float x) {
    float t = clamp((x - edge0)/(edge1 - edge0), 0., 1.);
    return pow(t, 3)*(t*(t*6. - 15.) + 10.);
}
