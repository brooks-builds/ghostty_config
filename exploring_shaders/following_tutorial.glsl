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
vec2 rotateVec2(float angle, vec2 toRotate);

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 r = calculateCoords(fragCoord); // r.xy == [-1.0, 1.0]
    vec2 p = fragCoord.xy / iResolution.xy; // percentage of the screen we're on
    float xMax = iResolution.x / iResolution.y; // ratio of the screen
       
    // sway(p);
    // sway(r);

    vec3 black = vec3(0.0);
    vec3 red = vec3(0.3, 0.0, 0.0);
    vec3 green = vec3(0.0, 0.4, 0.0);
    vec3 blue = vec3(0.2, 0.25, 0.8);
    vec3 yellow = vec3(0.8, 0.8, 0.5);
    vec3 cyan = vec3(0.4, 0.1, 0.8);
    vec3 darkGray = vec3(0.2);
    vec3 gray = vec3(0.3);
    vec3 lightGray = vec3(0.4);
    vec3 white = vec3(1.0);

    vec3 background = black;
    vec3 pixel = background;

    if (p.x < 1./5.) {
        vec2 q = r + vec2(xMax * 4./5., 0.0);
        pixel = darkGray;
        float x = 0.0;
        float y = mod(iTime, 2.0) - 1.0;
        float radius = 0.1;
        pixel = mix(pixel, blue, insideCircle(q, vec2(x, y), radius));
    } else if (p.x < 2./5.) {
        pixel = gray;
        vec2 q = r + vec2(xMax * 2./5., 0.0);
        float x = 0.0;
        float y = sin(iTime * TWOPI * 0.5) * 0.75;
        float radius = 0.05 * sin(iTime * 8.0) + 0.15;
        pixel = mix(pixel, blue, insideCircle(q, vec2(x, y), radius));
    } else if (p.x < 3./5.) {
        pixel = lightGray;
        vec2 q = r + vec2(xMax * 0./5., 0.0);
        float width = 0.1;
        float x = cos(iTime * 5.0) * 0.2;
        float y = sin(iTime * 5.0 * -1.)  * 0.3;
        vec3 color = mix(blue, red, sin(iTime) * 0.5 + 0.5);
        pixel = mix(pixel, color, insideRect(q, vec2(x - 0.5 * width, y - 0.5 * width), vec2(x + 0.5 * width, y + 0.5 * width)));
    } else if (p.x < 4./5.) {
        pixel = gray;
        vec2 q = r + vec2(xMax * -2./5., 0.0);
        float width = 0.1;

        for (float i = -1.0; i <= 1.0; i+= 0.2) {
            float x = cos(iTime * 5. + i * PI) * 0.2;
            float y = i;
            vec2 s = q - vec2(x, y);
            float angle = -1.0 * (iTime * 3.0 + i);

            s = rotateVec2(angle, s);
            pixel = mix(pixel, blue, insideRect(s, vec2(-0.5 * width), vec2(0.5 * width)));
        }
    } else {
        pixel = darkGray;
        vec2 q = r + vec2(xMax * -4./5., 0.0);
        float speed = 2.0;
        float time = iTime * speed;
        float stopEveryAngle = PI * 0.5; // PI * 0.5 == 90 degrees
        float t = (floor(time) + smoothstep(0.0, 0.5, fract(time))) * stopEveryAngle;
        float width = sin(time * 10.0) * 0.03 + 0.1;
        float height = sin(time * 10.0 + PI) * 0.03 + 0.1;
        float x = cos(t) * -0.2;
        float y = sin(t) * 0.3;

        pixel = mix(pixel, blue, insideRect(q, vec2(x - 0.5 * width, y - 0.5 * height), vec2(x + 0.5 * width, y + 0.5 * height)));
    }


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

vec2 rotateVec2(float angle, vec2 toRotate) {
    mat2 rotation = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    return toRotate * rotation;
}
