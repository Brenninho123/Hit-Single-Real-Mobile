
#pragma header

uniform float albedo;
//stupid workaround for texture atlas transparency showing symbol overlap
void main()
{
  vec4 tex = flixel_texture2D(bitmap,openfl_TextureCoordv);
  if (tex.a > 0) tex.a = albedo;
  gl_FragColor =tex;
}

