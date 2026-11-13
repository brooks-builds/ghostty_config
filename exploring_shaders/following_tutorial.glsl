void draw(out vec4 fragColor, in vec2 fragCoord, in vec3 newColor);
void sway(inout vec2 r);
void calculateCoords(in vec2 fragCoord, out vec2 r);

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec3 pixel = vec3(0.0);
    vec2 r;
    calculateCoords(fragCoord, r);
    vec3 gridColor = vec3(0.5, 0.5, 0.5);
    vec3 axesColor = vec3(0.0, 0.0, 0.9);
    float gridWidth = 0.002;
    float tickWidth = 0.1;

    sway(r);
   
    if(mod(r.x, tickWidth) < gridWidth) pixel = gridColor;
    if(mod(r.y, tickWidth) < gridWidth) pixel = gridColor;

    if(abs(r.x) < 0.005) pixel = axesColor;
    if(abs(r.y) < 0.005) pixel = axesColor;

    draw(fragColor, fragCoord, pixel);
}

void calculateCoords(in vec2 fragCoord, out vec2 r) {
    vec2 halfCoord = fragCoord.xy - 0.5 * iResolution.xy;
    r = 2.0 * halfCoord.xy / iResolution.xy;
}

void sway(inout vec2 r) {
    r.x += sin(r.y * 10.0 + iTime) * 0.005;
    r.y += sin(r.x * 10.0 + iTime) * 0.005;
}

void draw(out vec4 fragColor, in vec2 fragCoord, in vec3 newColor)
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
