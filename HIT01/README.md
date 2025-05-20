# Informe de Shaders 2D y WebGL

## 1. Tipos de Shaders 2D (Pixel/Fragment Shaders)

Los shaders en 2D, también llamados *fragment shaders* o *pixel shaders*, se ejecutan en la GPU y procesan cada píxel individualmente para determinar su color final, iluminación, transparencia y otros efectos visuales como bump mapping o sombras. Aunque operan de forma aislada por fragmento, se pueden encadenar múltiples pasadas para realizar efectos de postprocesado más avanzados, incluyendo manipulación del eje Z del fragmento para simulaciones de profundidad.

## 2. Pipeline de Renderizado y Distinción entre 3D y 2D

WebGL/WebGPU emplea un *pipeline* gráfico dividido en seis etapas principales, las cuales pueden separarse según el espacio en el que operan:

### Etapas en Espacio 3D:

1. **Vertex Array**  
   Define los vértices en coordenadas 3D.

2. **Vertex Shader**  
   Transforma dichos vértices aplicando matrices de modelado, vista y proyección.

3. **Triangle Assembly**  
   Construcción de triángulos a partir de los vértices procesados.

### Transición al Espacio 2D:

4. **Rasterización**  
   Convierte los triángulos en fragmentos o píxeles que ocupan la pantalla.

### Etapas en Espacio 2D:

5. **Fragment Shader**  
   Calcula el color y otros atributos visuales de cada fragmento individualmente.

6. **Testing & Blending**  
   Se aplican pruebas como *z-buffer*, *stencil*, y luego se mezclan los colores para renderizar el resultado final en el framebuffer.

Este pipeline muestra cómo se pasa de una escena 3D a una representación 2D final, haciendo que los *fragment shaders* sean claves en la etapa de visualización final.

## 3. Conceptos Básicos de Postprocesado

El *postprocesado* ocurre **después** de que la GPU genera el framebuffer y **antes** de presentar la imagen en pantalla. Se utilizan fragment shaders para aplicar filtros o combinar la imagen completa y lograr efectos visuales como:

- **Antialiasing**
- **Blur (desenfoque)**
- **Bloom**
- **Corrección de color**

Usualmente se realiza en una o más pasadas adicionales, renderizando la imagen sobre una textura intermedia que se vuelve a procesar.

## 4. Entradas Disponibles en Shadertoy

| Nombre                | Tipo               | Descripción                                                                 |
|----------------------|--------------------|-----------------------------------------------------------------------------|
| `iResolution`         | `vec3 (int)`       | Resolución del viewport: ancho, alto, profundidad.                         |
| `iTime`               | `float`            | Tiempo transcurrido en segundos desde el inicio.                           |
| `iTimeDelta`          | `float`            | Intervalo en segundos entre el frame actual y el anterior.                 |
| `iFrameRate`          | `float`            | Tasa de fotogramas (FPS).                                                  |
| `iFrame`              | `int`              | Número de frames renderizados desde el inicio.                             |
| `iChannelTime[4]`     | `float[4]`         | Tiempo de reproducción por canal (hasta 4 canales).                        |
| `iChannelResolution`  | `vec3[4]`          | Resolución en píxeles de cada canal de entrada.                            |
| `iChannel0..3`        | `sampler2D/Cube`   | Texturas o buffers externos usados como input.                             |
| `iMouse`              | `vec4`             | Posición y estado del mouse: xy posición, zw clic.                         |
| `iDate`               | `vec4`             | Fecha y hora actual: año, mes, día, segundos desde medianoche.            |

## 5. Salidas de los Pixel Shaders en Shadertoy

| Tipo      | Salida       | Descripción                                                                 |
|-----------|--------------|-----------------------------------------------------------------------------|
| `vec4`    | Imagen        | Color final en formato RGBA para cada píxel.                                |
| `vec2`    | Sonido        | Canales de audio estéreo (izquierdo, derecho).                              |
| `vec4`    | Realidad Virtual | Color + datos de rayo para render en VR.                                 |

## 6. Desglose del Shader

```glsl
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  // 1. Coordenadas normalizadas (0.0–1.0)
  vec2 uv = fragCoord / iResolution.xy;

  // 2. Color variable en el tiempo
  vec3 col = 0.5 + 0.5 * cos(iTime + uv.xyx + vec3(0.0, 2.0, 4.0));

  // 3. Salida final al framebuffer
  fragColor = vec4(col, 1.0);
}
```

## 7. Explicación del código

**uv:** coordenadas normalizadas de píxel en el rango [0,1]. Permiten efectos gráficos que funcionan sin importar la resolución de pantalla.

**¿Por qué uv y no xy directamente?**  
Usar `uv` hace que el shader escale bien con distintas resoluciones. Trabajar con `xy` (coordenadas absolutas) daría resultados distintos en cada tamaño de pantalla.

**Animación con iTime:**  
La variable `iTime` aumenta con cada frame, lo que genera animación en el color aunque las coordenadas sean fijas.

**¿Cómo `col` es un vec3 si hay floats en la operación?**  
En GLSL, sumar un `float` a un `vec3` aplica el valor a cada componente del vector. Lo mismo ocurre con `cos`, que se aplica componente por componente.

**Constructores comunes de vectores:**
- `vec2(x, y)` → 2D (coordenadas, color RG)
- `vec3(x, y, z)` → 3D (color RGB, posición)
- `vec4(x, y, z, w)` → 4D (RGBA, coordenadas homogéneas)

**Swizzling (accesores):**
- `vec2`: `.x`, `.y`, `.r`, `.g`, `.s`, `.t`
- `vec3`: +`.z`, `.b`, `.p`, `.q`, `.xy`, `.rgb`, etc.
- `vec4`: +`.w`, `.a`, `.u`, `.v`, `.rgba`, `.xyzw`, etc.

**¿Qué es `uv.xyx`?**  
Es un `vec3` formado con los componentes `(uv.x, uv.y, uv.x)`. Se usa para variar el color en cada componente de forma diferente.
