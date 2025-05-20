void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // 1) Coordenadas normalizadas (0..1)
    vec2 uv = fragCoord.xy / iResolution.xy;

    // 2) Muestreos de textura
    vec4 src0 = texture(iChannel1, uv);  // video de fondo
    vec4 src1 = texture(iChannel0, uv);  // video con fondo verde

    // 3) Definición del color de chroma (verde puro)
    vec4 chromaColor = vec4(0.0, 1.0, 0.0, 1.0);

    // 4) Umbral de chroma
    float threshold = 0.5;

    float dr = src1.r - chromaColor.r;
    float dg = src1.g - chromaColor.g;
    float db = src1.b - chromaColor.b;
    float dist = sqrt(drdr + dgdg + db*db);

    // 5) Mezcla: si la distancia es menor que el umbral, usamos src0, si no, src1
    float m = smoothstep(threshold - 0.05, threshold + 0.05, dist);

    fragColor = mix(src0, src1, m);
}