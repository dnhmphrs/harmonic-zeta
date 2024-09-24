precision highp float;
varying vec2 vUv;
uniform vec3 color1;
uniform vec3 color2;
uniform vec3 color3;
uniform vec2 mouse;

float scale = 100.0;
float lineWidth = 0.1;  // Width of the vertical lines

// Function to compute the harmonic number H_n
float harmonicNumber(float n) {
    return log(n) + 0.5772156649 + 1.0 / (2.0 * n); // Approximation: H_n ≈ ln(n) + γ + 1/(2n)
}

// Function to compute zeta* as Σ σ⋅n^it / H_n
vec2 zetaStarComplex(float sigma, float t) {
    vec2 sum = vec2(0.0, 0.0); // (real part, imaginary part)
    const int N = 100; // Number of terms in the series for approximation

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
    float sigma = (vUv.y * 2.0 * scale) - (1.0 * scale); // Real part of s
    float t = (vUv.x * 2.0 * scale) - (1.0 * scale);     // Imaginary part of s

    // Compute zetaStarComplex(sigma, t)
    vec2 zetaStarValue = zetaStarComplex(sigma, t);

    // Get the magnitude of the complex value for visualization
    float magnitude = length(zetaStarValue); // Magnitude of the complex number

    // Normalize the magnitude to map to color range
    float normalizedMagnitude = 0.5 + 0.5 * magnitude;

    // Create gradients for visualization
    vec3 gradient1 = mix(color1, color2, normalizedMagnitude);
    vec3 gradient2 = mix(color3, gradient1, 0.25 + 0.25 * atan(normalizedMagnitude));
    

    // Set the fragment color
    gl_FragColor = vec4(gradient2, 1.0);
}
