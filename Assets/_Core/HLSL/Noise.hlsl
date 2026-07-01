#ifndef RENDERLIB_NOISE_INCLUDED
#define RENDERLIB_NOISE_INCLUDED

// ---------------------------------------------------------------------------
// RenderLib Noise Utilities
// Procedural 2D noise: Value, Simplex, Voronoi.
// Pure math — no URP or texture dependencies.
// Used by Dissolve, Hologram, Cloud, Snow, etc.
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Internal hash helpers (pseudo-random from integer/float2 coordinates)
// Same input -> same output; small input change -> unrelated output
// ---------------------------------------------------------------------------

float RenderLib_Hash21(float2 p)
{
    // frac: keep fractional part only (wrap to [0,1))
    p = frac(p * float2(443.8975, 397.2973));
    // Mix x/y with a constant offset — breaks axis-aligned patterns
    p += dot(p, p.yx + 19.19);
    return frac(p.x * p.y);
}

float2 RenderLib_Hash22(float2 p)
{
    float n = RenderLib_Hash21(p);
    return float2(n, RenderLib_Hash21(p + n + 17.0));
}

// Hermite smoothstep: 0 at 0, 1 at 1, zero derivative at both ends
// Smoother than linear lerp — removes visible "grid seams" in Value Noise
float RenderLib_SmoothStep01(float t)
{
    return t * t * (3.0 - 2.0 * t);
}

// ---------------------------------------------------------------------------
// mod289 / permute — used by Simplex Noise (classic WebGL-noise style)
// 289 is a prime chosen to reduce hash collisions in the permutation table
// ---------------------------------------------------------------------------

float RenderLib_Mod289(float x)
{
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float2 RenderLib_Mod289(float2 x)
{
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float3 RenderLib_Mod289(float3 x)
{
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float3 RenderLib_Permute(float3 x)
{
    return RenderLib_Mod289((34.0 * x + 1.0) * x);
}

// ---------------------------------------------------------------------------
// ValueNoise2D: lattice noise with bilinear + smoothstep interpolation
// Output range: approximately [0, 1]
// uv: sample coordinates (scale up for finer detail, e.g. uv * 8.0)
// ---------------------------------------------------------------------------

float RenderLib_ValueNoise2D(float2 uv)
{
    // i = integer cell corner; f = fractional position within cell [0,1)
    float2 i = floor(uv);
    float2 f = frac(uv);

    // Smooth the interpolation weights (not the values themselves)
    float2 u = float2(
        RenderLib_SmoothStep01(f.x),
        RenderLib_SmoothStep01(f.y)
    );

    // Random value at each of the 4 corners of the 2x2 cell
    float a = RenderLib_Hash21(i + float2(0.0, 0.0));
    float b = RenderLib_Hash21(i + float2(1.0, 0.0));
    float c = RenderLib_Hash21(i + float2(0.0, 1.0));
    float d = RenderLib_Hash21(i + float2(1.0, 1.0));

    // Bilinear interpolation: lerp along X, then lerp along Y
    return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
}

half RenderLib_ValueNoise2D(half2 uv)
{
    return half(RenderLib_ValueNoise2D(float2(uv)));
}

// ---------------------------------------------------------------------------
// SimplexNoise2D: gradient noise on a simplex grid (triangles, not squares)
// Less directional bias than Value Noise; industry standard for organic FX
// Output range: approximately [-1, 1] (multiply by 0.5+0.5 to remap to [0,1])
// Based on Stefan Gustavson / Ashima Arts (MIT license, WebGL-noise)
// ---------------------------------------------------------------------------

float RenderLib_SimplexNoise2D(float2 v)
{
    // Skew constants for 2D simplex grid
    const float4 C = float4(
        0.211324865405187,  // (3 - sqrt(3)) / 6
        0.366025403784439,  // 0.5 * (sqrt(3) - 1)
       -0.577350269189626,  // -1 + 2 * C.x
        0.024390243902439); // 1 / 41

    // Skew input space to find which simplex cell we're in
    float2 i = floor(v + dot(v, C.yy));
    float2 x0 = v - i + dot(i, C.xx);

    // Determine which half of the unit square we're in (two triangles)
    float2 i1 = (x0.x > x0.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
    float4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;

    // Permutation hashing for the 3 corners of the simplex triangle
    i = RenderLib_Mod289(i);
    float3 p = RenderLib_Permute(
        RenderLib_Permute(i.y + float3(0.0, i1.y, 1.0)) + i.x + float3(0.0, i1.x, 1.0)
    );

    // Radial decay: contribution falls off with distance from corner
    float3 m = max(0.5 - float3(
        dot(x0, x0),
        dot(x12.xy, x12.xy),
        dot(x12.zw, x12.zw)
    ), 0.0);
    m = m * m;
    m = m * m;

    // Random gradient direction at each corner
    float3 x = 2.0 * frac(p * C.www) - 1.0;
    float3 h = abs(x) - 0.5;
    float3 ox = floor(x + 0.5);
    float3 a0 = x - ox;

    // Normalize gradient contribution (Taylor inverse sqrt approximation)
    m *= 1.79284291400159 - 0.853735358856562 * (a0 * a0 + h * h);

    // Dot gradient with offset vector from corner to sample point
    float3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;

    // Scale factor tuned so output sits roughly in [-1, 1]
    return 130.0 * dot(m, g);
}

half RenderLib_SimplexNoise2D(half2 v)
{
    return half(RenderLib_SimplexNoise2D(float2(v)));
}

// Remap Simplex from [-1,1] to [0,1] — convenient for dissolve thresholds
float RenderLib_SimplexNoise2D01(float2 v)
{
    return RenderLib_SimplexNoise2D(v) * 0.5 + 0.5;
}

half RenderLib_SimplexNoise2D01(half2 v)
{
    return half(RenderLib_SimplexNoise2D01(float2(v)));
}

// ---------------------------------------------------------------------------
// VoronoiNoise2D: cellular / Worley noise
// For each cell, place a random "feature point"; output distance to nearest one
//
// Returns:
//   .x = F1 (distance to nearest feature point)
//   .y = F2 - F1 (distance gap to second-nearest — thin edges / cell borders)
//   .z = cell hash (random per cell, useful for per-cell color variation)
//
// uv: sample coordinates (scale for cell density, e.g. uv * 5.0)
// ---------------------------------------------------------------------------

float3 RenderLib_VoronoiNoise2D(float2 uv)
{
    float2 i = floor(uv);
    float2 f = frac(uv);

    float minDist1 = 8.0;
    float minDist2 = 8.0;
    float2 nearestCell = float2(0.0, 0.0);

    // Search 3x3 neighborhood — feature point in adjacent cell may be closest
    for (int y = -1; y <= 1; y++)
    {
        for (int x = -1; x <= 1; x++)
        {
            float2 neighbor = float2(x, y);
            float2 cellId   = i + neighbor;

            // Random feature point inside this cell (offset from cell origin)
            float2 point = neighbor + RenderLib_Hash22(cellId);

            // Vector from current pixel to that feature point
            float2 diff = point - f;
            float dist  = dot(diff, diff); // squared distance (cheaper, monotonic)

            if (dist < minDist1)
            {
                minDist2     = minDist1;
                minDist1     = dist;
                nearestCell  = cellId;
            }
            else if (dist < minDist2)
            {
                minDist2 = dist;
            }
        }
    }

    return float3(
        sqrt(minDist1),
        sqrt(minDist2) - sqrt(minDist1),
        RenderLib_Hash21(nearestCell)
    );
}

// Convenience: only F1 distance (most common for dissolve edge masks)
float RenderLib_VoronoiNoise2D_F1(float2 uv)
{
    return RenderLib_VoronoiNoise2D(uv).x;
}

// ---------------------------------------------------------------------------
// FBM (Fractal Brownian Motion): layered noise for richer detail
// Not required by PLAN but essential for Dissolve / Cloud quality
// octaves: number of layers; lacunarity: frequency multiplier per octave
// gain: amplitude falloff per octave
// ---------------------------------------------------------------------------

float RenderLib_FbmSimplex2D(float2 uv, int octaves, float lacunarity, float gain)
{
    float value     = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;

    for (int o = 0; o < octaves; o++)
    {
        value     += amplitude * RenderLib_SimplexNoise2D01(uv * frequency);
        frequency *= lacunarity;
        amplitude *= gain;
    }

    return value;
}

half RenderLib_FbmSimplex2D(half2 uv, int octaves, half lacunarity, half gain)
{
    return half(RenderLib_FbmSimplex2D(float2(uv), octaves, float(lacunarity), float(gain)));
}

#endif // RENDERLIB_NOISE_INCLUDED