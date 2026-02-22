
#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D CC_Texture0;
varying vec2 v_texCoord;

uniform float ColorAmount;


vec4 Desaturate(vec4 color, float Desaturation)
{
	vec3 grayXfer = vec3(0.3, 0.59, 0.11);
	vec3 gray = vec3(dot(grayXfer, color.rgb));
	return vec4(mix(color.rgb, gray, Desaturation), color.a);
}


void main()
{
    vec4 color = texture2D(CC_Texture0, v_texCoord);
    gl_FragColor = Desaturate(color, ColorAmount);


//    // Gray
//    float gray = max(max(color.r, color.g), color.b); //color.r * 0.3 + color.g * 0.59 + color.b * 0.11;
//    gray -= ColorAmount;
//    gl_FragColor = vec4(gray, gray, gray, color.a);


//    // Desaturate (Fade to Black)
//    vec4 des = Desaturate(color, ColorAmount);
//    gl_FragColor = vec4(max(0.0, des.r - Alpha), max(0.0, des.g - Alpha), max(0.0, des.b - Alpha), color.a);


//    // Sepia
//    float red = (color.r * .393) + (color.g *.769) + (color.b * .189);
//    float green = (color.r * .349) + (color.g * .686) + (color.b * .168);
//    float blue = (color.r * .272) + (color.g * .534) + (color.b * .131);
//    gl_FragColor = vec4(red - ColorAmount, green - ColorAmount, blue - ColorAmount, color.a);
}
