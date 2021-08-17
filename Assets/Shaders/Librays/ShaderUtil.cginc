#ifndef SHADER_UTIL_INCLUDE
#define SHADER_UTIL_INCLUDE

half random (half2 st) {
    return frac(sin(dot(st.xy, half2(12.9898,78.233))) * 43758.5453123);
}


half3 ACESToneMapping(half3 color, half adapted_lum)
{
	const half A = 2.51;
	const half B = 0.03;
	const half C = 2.43;
	const half D = 0.59;
	const half E = 0.14;

	color *= adapted_lum;
	return (color * (A * color + B)) / (color * (C * color + D) + E);
}

uniform float _Global_BloomThreshold;
half EncodeLuminanceImpl(half3 color, half luminance, half threshold)
{
	half l = dot(color, fixed3(0.299f, 0.587f, 0.114f));
	l = max(l - threshold, 0.0) * luminance;
	l = sqrt(l);
	l = l / (1 + l);
	return l; // Inverse luminance
}
half EncodeLuminance(half3 color, half luminance)
{
	return EncodeLuminanceImpl(color, luminance, _Global_BloomThreshold);
}
half EncodeLuminance(half3 color, half luminance, half threshold)
{
	return EncodeLuminanceImpl(color, luminance, _Global_BloomThreshold * threshold);
}

#endif