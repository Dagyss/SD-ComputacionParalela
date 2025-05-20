void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Coordenadas normalizadas (0..1)
    vec2 uv = fragCoord.xy / iResolution.xy;

    // Invertimos X e Y:
    vec2 uvFlipped = vec2(1.0 - uv.x, 1.0 - uv.y);

    // Muestreamos la textura volteada tanto vertical como horizontalmente
    fragColor = texture(iChannel0, uvFlipped);
}