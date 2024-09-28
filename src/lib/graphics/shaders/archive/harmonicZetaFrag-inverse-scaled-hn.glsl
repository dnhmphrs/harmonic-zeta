precision highp float;
varying vec2 vUv;
uniform vec3 color1;
uniform vec3 color2;
uniform vec3 color3;
uniform vec2 mouse;

float scale = 1000.0;
float lineWidth = 0.1;  // Width of the horizontal lines

// Function to compute the harmonic number H_n
float harmonicNumber(float n) {
    return log(n) + 0.5772156649 + 1.0 / (2.0 * n); // Approximation: H_n ≈ ln(n) + γ + 1/(2n)
}

// Function to compute zeta* as Σ σ⋅n^it / H_n
vec2 zetaStarComplex(float sigma, float t) {
    vec2 sum = vec2(0.0, 0.0); // (real part, imaginary part)
    const int N = 200; // Number of terms in the series for approximation

    for (int n = 1; n <= N; ++n) {
        float hn = harmonicNumber(float(n));  // Compute H_n
        float angle = t * log(float(n));      // Angle for n^it = cos(t log n) + i sin(t log n)
        
        // Compute σ * n^it
        float realPart = sigma * cos(angle);  // Real part of σ * n^it
        float imaginaryPart = sigma * sin(angle);  // Imaginary part of σ * n^it

        // Sum the real and imaginary parts divided by H_n
        sum.x += realPart / hn;
        sum.y += imaginaryPart / hn;
    }

    return sum; // Return the complex result as (real, imaginary)
}

void main() {
    // Map the fragment coordinates to the complex plane
    float adaptedScale = scale * mouse.x;
    float sigma = (vUv.y * 2.0 * scale) - (1.0 * scale); // Real part of s
    float t = (vUv.x * 2.0 * adaptedScale) - (1.0 * adaptedScale);     // Imaginary part of s

    // Compute zetaStarComplex(sigma, t)
    vec2 zetaStarValue = zetaStarComplex(sigma, t);

    // Get the magnitude / phase of the complex value for visualization
    float magnitude = length(zetaStarValue); // Magnitude of the complex number
    // float phase = atan(zetaStarValue.y, zetaStarValue.x); // Compute the phase


    // Normalize the magnitude / phase to map to color range
    float normalizedMagnitude = 0.5 + 0.5 * magnitude;
    // float normalizedPhase = 0.5 + 0.5 * phase / 3.14159265359; // Normalize phase to [0, 1] range

    // Create gradients for visualization
    vec3 gradient1 = mix(color1, color2, normalizedMagnitude);
    vec3 gradient2 = mix(color3, gradient1, 0.25 + 0.25 * sin(normalizedMagnitude * abs((2.0 * mouse.y))));

    // Define the first 29 non-trivial zeros of the zeta function (imaginary parts)
    float zeros[29] = float[](14.135, 21.022, 25.011, 30.425, 32.935, 
                              37.586, 40.918, 43.327, 48.005, 49.773, 
                              52.970, 56.446, 59.347, 60.831, 65.112, 
                              67.079, 69.546, 72.067, 75.704, 77.145, 
                              79.337, 82.910, 84.735, 87.099, 88.809, 
                              92.491, 94.651, 95.870, 98.831);

    // Check if the current y position (t) is close to one of the zero values and draw horizontal lines
    for (int i = 0; i < 29; i++) {
        if (abs(t - zeros[i]) < lineWidth || abs(t + zeros[i]) < lineWidth) {
            gradient2 = vec3(0.0, 0.5, 0.5); // Red line at the non-trivial zero position (both positive and negative)
        }
    }

    // Set the fragment color
    gl_FragColor = vec4(gradient2, 1.0);
}
