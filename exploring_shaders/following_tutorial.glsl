void keepOriginalTerminal(out vec4 fragColor, in vec2 fragCoord, in vec3 newColor);
void sway(inout vec2 r);
vec2 calculateCoords(in vec2 fragCoord);
void drawGrid(in vec2 r, inout vec3 pixel);
void drawCircle(vec2 r, inout vec3 pixel, float radius, vec2 loc, vec3 color);

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec3 pixel = vec3(0.0);
    vec2 r = calculateCoords(fragCoord);
    float xMax = iResolution.x/iResolution.y; // getting the ratio for the screen, however I don't understand why and how this works yet.
    // sway(r);

    vec3 red = vec3(0.3, 0.0, 0.0);
    vec3 green = vec3(0.0, 0.4, 0.0);
    vec3 blue = vec3(0.0, 0.1, 0.5);
    vec3 yellow = vec3(0.3, 0.4, 0.0);
    vec3 cyan = vec3(0.4, 0.1, 0.8);

    float edge, variable, ret;

    if (r.x < -0.6 * xMax) {
        variable = r.y;
        edge = 0.2;
        if (variable > edge) {
            ret = 1.0;
        } else {
            ret = 0.0;
        }
    } else if (r.x < -0.2 * xMax) {
        variable = r.y;
        edge = -0.2;
        ret = step(edge, variable); // equivalent to the if statement above
    } else if (r.x < 0.2 * xMax) {
        ret = 1.0 - step(0.5, r.y);
    } else if (r.x < 0.6 * xMax) {
        ret = 0.3 + 0.5 * step(-0.4, r.y);
    } else {
        ret = step(-0.3, r.y) * (1.0 - step(0.2, r.y));
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
