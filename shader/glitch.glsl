#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D texture;
uniform vec2  iResolution;
uniform float iTime;      

float rand () {
    return fract(sin(iTime)*1e4);
}

void main() {
    vec2 uv = gl_FragCoord.xy/iResolution;  
    uv.y=1.-uv.y;
    vec2 uvR = uv;
    vec2 uvB = uv;

    uvR.x = uv.x * 1.0 - rand() * 0.02 * 0.8;
    uvB.y = uv.y * 1.0 + rand() * 0.02 * 0.8;

    if(uv.y < rand() && uv.y > rand() -0.1 && sin(iTime) < 0.0)
    {
        uv.x = (uv + 0.02 * rand()).x;
    }

    vec4 c;
    c.r = texture(texture, uvR).r;
    c.g = texture(texture, uv).g;
    c.b = texture(texture, uvB).b;
    c.a=1.;

    float scanline = sin( uv.y * abs(sin(iTime*0.005))*800.0 * rand())/30.0; 
    c *= 1.0 - scanline; 

    float vegDist = length(( 0.5 , 0.5 ) - uv);
    c *= 1.0 - vegDist * 0.3;

    gl_FragColor =c;
}