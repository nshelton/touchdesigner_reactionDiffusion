
// Example Pixel Shader

uniform vec4 _diffuse;
uniform vec4 _feedKill;
uniform vec4 _dim;

uniform vec4 _flow;
uniform vec4 _scale;

out vec4 fragColor;


vec2 xy_to_kf(float x, float y)
{
    x = pow(x, 0.7)*0.7;
    y = pow(y, 1.1) * 0.7;
    float f = mix(pow(x/2, 0.45)/11 + 0.005 , .07f, clamp(y, 0, 1))/1.01;
    float k = mix(.00f, .07f,  clamp(x, 0, 1));

    return vec2(k, f);
}



void main() {

    float tw = _dim.z;
    float th = _dim.w;
    vec2 aspect = vec2(_dim.x / _dim.y, 1.0);

    vec2 uv = vUV.st;
    vec2 uvWorld = (uv - 0.5) * aspect / 2.0;
    float rad = length(uvWorld);
    vec2 dir = normalize(uvWorld);

    
    vec4 noise_smooth = texture(sTD2DInputs[2], uv);
    vec4 noise = texture(sTD2DInputs[1], uv);

    // base Scale
    float scale = _scale.x;

    // radial Scale
    scale *= (1 + 5 * clamp(0.5 - rad * 2, 0, 1) * _scale.y);
    // ring scale
    scale *= (1 + (0.5 + sin(rad * 5 * 3.141592)) * _scale.z);
    // noise Scale
    scale *= (1 + noise_smooth.z * _scale.w * 3);

    scale *= (1.0 + 10.0 * noise.x * _dim.z);

    vec4 duv = scale * vec4(tw, th, -tw, 0);



    //ring
    uv += th * 0.1 * _flow.x * (0.5 + sin(rad * 5.0 * 3.141592)) * dir;
    //radial 
    uv += th * 0.1 * _flow.y * (0.5 + sin(rad * 2.0 * 3.141592)) * dir;
    //noise
    uv += th * 0.3 * _flow.z * noise_smooth.yz;
    //spin
    uv += th * 0.3 * uvWorld.yx * vec2(-1, 1) * _flow.w;

    vec2 q = texture(sTD2DInputs[0], uv).xy;

    vec2 dq = -q;
    dq += texture(sTD2DInputs[0], uv - duv.xy).xy * 0.05;
    dq += texture(sTD2DInputs[0], uv - duv.wy).xy * 0.20;
    dq += texture(sTD2DInputs[0], uv - duv.zy).xy * 0.05;
    dq += texture(sTD2DInputs[0], uv + duv.zw).xy * 0.20;
    dq += texture(sTD2DInputs[0], uv + duv.xw).xy * 0.20;
    dq += texture(sTD2DInputs[0], uv + duv.zy).xy * 0.05;
    dq += texture(sTD2DInputs[0], uv + duv.wy).xy * 0.20;
    dq += texture(sTD2DInputs[0], uv + duv.xy).xy * 0.05;

    float ABB = q.x * q.y * q.y;

    vec2 kf = xy_to_kf( _feedKill.x , _feedKill.y );
    float feed = kf.x;
    float kill = kf.y;



    q += vec2(dq.x * _diffuse.x - ABB + feed * (1.0 - q.x), dq.y * _diffuse.y + ABB - (kill + feed) * q.y);

    vec4 color = vec4(1);
    // color.rg = clamp(q, vec2(0), vec2(1));
    color.rg = q;
    color.b = scale;

    fragColor = TDOutputSwizzle(color);
}
