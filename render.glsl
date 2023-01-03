
// Example Pixel Shader

uniform vec4 _bgColor;
uniform vec4 _fgColor;
uniform vec4 _dim;
uniform vec4 _height;

out vec4 fragColor;

void main() {

    float tw = _dim.z;
    float th = _dim.w;

    vec2 uv = vUV.st;


    vec4 col = texture(sTD2DInputs[0], uv);
    vec3 delta = col.z * vec3(_dim.z, _dim.w, 0);

    float height = smoothstep(0.1, 0.3, col.y);
    col = mix(_bgColor, _fgColor, height);
                // scale normal by local scale from sim
    //             // delta *= col.z;
    vec4 dx = texture(sTD2DInputs[0], uv + delta.xz) - texture(sTD2DInputs[0], uv - delta.xz);
    vec4 dy = texture(sTD2DInputs[0], uv + delta.yz) - texture(sTD2DInputs[0], uv - delta.yz);

    vec3 normal = normalize(vec3(dx.y, dy.y, _height));

    vec3 lightDir = normalize(vec3(0.3, 0.2, 0.6));
    float phong = dot(normal, lightDir);
    col.rgb *= abs(phong);

    // col.rgb = normal*0.5 + 0.5;

    //             //specular
    lightDir = normalize(vec3(0.5, 0.1, 0.6));
    col.rgb += height * pow(phong, 10);

    fragColor = TDOutputSwizzle(col);
}
