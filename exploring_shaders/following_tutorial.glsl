void draw(out vec4 fragColor, in vec2 fragCoord, in vec3 newColor);
void sway(inout vec2 r);

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec3 pixel = vec3(0.0);
    vec2 r = fragCoord.xy / iResolution.xy;
    vec3 gridColor = vec3(0.5, 0.5, 0.5);
    vec3 axesColor = vec3(0.0, 0.0, 0.9);
    float gridWidth = 0.002;
    float tickWidth = 0.1;

    sway(r);
   
    for (float i = 0.0; i < 1.0; i+=tickWidth) {
        if(abs(r.x - i) < gridWidth) pixel = gridColor;
        if(abs(r.y - i) < gridWidth) pixel = gridColor;
    }

    if(abs(r.x) < 0.005) pixel = axesColor;
    if(abs(r.y) > 0.995) pixel = axesColor;

    draw(fragColor, fragCoord, pixel);
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
