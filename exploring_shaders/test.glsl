#define PI     3.14159265359
#define TWO_PI 6.28318530718

void keepOriginalTerminal(vec2 fragCoord, inout vec3 pixel)
{
    vec3 originalColor = texture(iChannel0, fragCoord.xy / iResolution.xy).rgb;
    float threshold = 0.2;
    float smoothness = 0.2;
    pixel = mix(pixel, originalColor, smoothstep(threshold - smoothness, threshold + smoothness, length(originalColor)));
}

float plot(vec2 st, float percentage) {    
    float lineWidth = 0.02;
    return smoothstep(percentage - lineWidth, percentage, st.y) - smoothstep(percentage, percentage + lineWidth, st.y);
}

vec2 calcR(vec2 fragCoord) {
    vec2 r = fragCoord.xy / iResolution.y;
    r.y = abs(1.0 - r.y);
    r.y -= 0.5;
    r.x -= (iResolution.x / iResolution.y) * 0.5;
    r *= 2.0;

    return r;
}

vec2 calcP(vec2 fragCoord) {
    vec2 r = fragCoord.xy / iResolution.xy;
    r.y = abs(1.0 - r.y);

    return r;
}

vec3 rgb2hsb(vec3 c){
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz),
                 vec4(c.gb, K.xy),
                 step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r),
                 vec4(c.r, p.yzx),
                 step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)),
                d / (q.x + e),
                q.x);
}

vec3 hsb2rgb(vec3 c){
    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),
                             6.0)-3.0)-1.0,
                     0.0,
                     1.0 );
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * mix(vec3(1.0), rgb, c.y);
}

float inRect(vec2 center, vec2 size, vec2 r) {
    vec2 halfSize = size / 2.0;
    float smoothness = 0.001;
    vec2 tl = smoothstep(center - halfSize - smoothness, center - halfSize + smoothness, r);
    vec2 br = smoothstep(r - smoothness, r+ smoothness, center + halfSize);

    return tl.x * tl.y * br.x * br.y;
}

void mainImage(out vec4 fragColor, vec2 fragCoord) {
    vec2 r = calcR(fragCoord);
    vec2 p = calcP(fragCoord);
    
    vec3 blue = vec3(0.287, 0.473, 0.966);
    vec3 red = vec3(0.646, 0.188, 0.180);
    vec3 black = vec3(0.0);
    vec3 white = vec3(1.0);
    vec3 yellow = vec3(0.996, 0.830, 0.130);
    vec3 background = black;
    vec3 pixel = background;

    vec3 color = vec3(inRect(vec2(0.0), vec2(0.1, 0.2), r));

    pixel = mix(pixel, red, color);

    keepOriginalTerminal(fragCoord, pixel);
    fragColor = vec4(pixel, 1.0);
}
