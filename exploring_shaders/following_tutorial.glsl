void draw(out vec4 fragColor, in vec2 fragCoord, in vec3 newColor);

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec3 pixel = vec3(0.0);
    vec2 r = fragCoord.xy / iResolution.xy;
    vec3 color1 = vec3(0.3, 0.0, 0.0);
    vec3 color2 = vec3(0.0, 0.0, 0.3);
    vec3 color3 = vec3(0.0, 0.3, 0.0);
    float stripWidth = iResolution.x / 2.0;

    r.x += sin(r.y * 10.0 + iTime) * 0.05;
    r.y += sin(r.x * 10.0 + iTime) * 0.025;
    
    if (r.x > 0.54 && r.x < 0.55) pixel = color1;
    if (abs(r.x - 0.6) < 0.003) pixel = color2;
    if (abs(r.y - 0.5) < 0.005) pixel = color3;

    draw(fragColor, fragCoord, pixel);
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
