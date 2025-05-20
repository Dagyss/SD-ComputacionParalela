void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // 1) Coordenadas normalizadas (0..1)
    vec2 uv = fragCoord.xy / iResolution.xy;

    // 2) Muestreos de textura
    vec4 src0 = texture(iChannel1, uv);  // video de fondo (sin chroma)
    vec4 src1 = texture(iChannel0, uv);  // video con fondo verde

    // 3) Definición del color de chroma (verde puro)
    vec3 chromaColor = vec3(0.0, 1.0, 0.0);

    // 4) Umbral de chroma
    float threshold = 0.5;

    // 5) Distancia pitagórica en RGB
    float dr = src1.r - chromaColor.r;
    float dg = src1.g - chromaColor.g;
    float db = src1.b - chromaColor.b;
    float dist = sqrt(dr*dr + dg*dg + db*db);

    // 6) Mezcla con smoothstep
    float m = smoothstep(threshold - 0.05, threshold + 0.05, dist);
    vec4 mixed = mix(src0, src1, m);

    // 7) Convertir a escala de grises
    float gray = dot(mixed.rgb, vec3(0.2126, 0.7152, 0.0722));
    fragColor = vec4(vec3(gray), mixed.a);
}