// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
#define iChannel0 bitmap
#define texture flixel_texture2D

// end of ShadertoyToFlixel header

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Coordenadas UV normalizadas
    vec2 uv = fragCoord / iResolution.xy;
    
    // Obtener el color original de la textura
    vec4 col = texture(iChannel0, uv);
    
    // Calcular qu tan puro es el azul frente al rojo y verde.
    float bluePurity = col.b - max(col.r, col.g);
    
    // Umbral estricto para detectar azul puro y evitar morados
    float threshold = 0.3; 
    
    vec3 finalColor;
    
    if (bluePurity > threshold) {
        // MANTENER SHADING EN LOS AZULES:
        // Respeta los azules claros y oscuros originales.
        finalColor = col.rgb;
        
    } else {
        // NO ES AZUL (Gris, Blanco, Negro, etc.)
        float luminance = dot(col.rgb, vec3(0.299, 0.587, 0.114));
        
        // ==========================================
        // AQU USAMOS EL bwThreshold REALMENTE:
        // 'bwThreshold' acta como el punto medio o balance. 
        // Valores por defecto como 0.5 son neutrales. 
        // Si lo bajas (ej. 0.3), la imagen se vuelve ms blanca/clara.
        // Si lo subes (ej. 0.7), la imagen se vuelve ms oscura/negra.
        float bwThreshold = 0.28; 
        
        // Desplazamos la luminancia segn el umbral para cambiar el balance
        float adjustedLuma = luminance - (bwThreshold - 0.5);
        
        // Opcional: Controlar cuntos niveles de grises quieres (ej: 3 o 4 niveles)
        float levels = 3.0; // 3.0 te da negro, un tono de gris, y blanco
        float grayShade = floor(clamp(adjustedLuma, 0.0, 1.0) * levels) / (levels - 1.0);
        
        finalColor = vec3(grayShade);
    }
    
    fragColor = vec4(finalColor, texture(iChannel0, fragCoord / iResolution.xy).a);
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}