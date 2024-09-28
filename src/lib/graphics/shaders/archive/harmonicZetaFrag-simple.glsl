precision highp float;
varying vec2 vUv;
uniform vec3 color1;
uniform vec3 color2;
uniform vec3 color3;
uniform vec2 mouse;

float e = 2.718281828459045; // Euler's number

float scale = 400.0;
float lineWidth = 0.1;   // Width of the vertical lines

// Function to compute the harmonic number H_n
float harmonicNumber(float n) {
    return log(n) + 0.5772156649 + 1.0 / (2.0 * n); // Approximation: H_n ≈ ln(n) + γ + 1/(2n)
}

// Function to compute zeta* as Σ n^it / σ⋅
vec2 zetaStarComplex(float sigma, float t) {
    vec2 sum = vec2(0.0, 0.0); // (real part, imaginary part)
    const int N = 200; // Number of terms in the series for approximation

    for (int n = 1; n <= N; ++n) {
        // float hn = harmonicNumber(float(n));     // Compute H_n
        float angle = t * log(float(n));         // Angle for n^it = cos(t log n) + i sin(t log n)

        // Real part of H_n * n^{-it}
        // float realPart = hn * cos(-angle);  // Use n^{-it} for real part
        float realPart = cos(-angle);
        // Imaginary part of H_n * n^{-it}
        // float imaginaryPart = hn * sin(-angle);  // Use n^{-it} for imaginary part
        float imaginaryPart = sin(-angle);

        // Sum the real and imaginary parts divided by (σ * n)
        sum.x += realPart / (sigma);
        sum.y += imaginaryPart / (sigma);
    }

    return sum; // Return the complex result as (real, imaginary)
}

void main() {
    // Map the fragment coordinates to the complex plane
    float adaptedScale = scale; //* mouse.x;
    float sigma = (vUv.y * 1.0 * scale) - (0.5 * scale); // Real part of s
    float t = (vUv.x * 2.0 * scale) - (1.0 * scale);     // Imaginary part of s

    // Compute zetaStarComplex(sigma, t)
    vec2 zetaStarValue = zetaStarComplex(sigma, t);

    // Get the magnitude of the complex value for visualization
    float magnitude = length(zetaStarValue); // Magnitude of the complex number

    // Normalize the magnitude to map to color range
    float normalizedMagnitude = 0.5 + 0.5 * magnitude;

    // Create gradients for visualization
    vec3 gradient1 = mix(color1, color2, normalizedMagnitude);
    vec3 gradient2 = mix(color3, gradient1, 0.25 + 0.25 * sin(normalizedMagnitude));

    // // Add vertical red lines at every integer on the y-axis (mapped to the x-axis)
    // float xPos = mod(vUv.x * 2.0 * scale - scale, 1.0); // Position for integer lines on the x-axis
    // if (abs(xPos) < abs(lineWidth)) {
    //     gradient2 = vec3(0.0, 0.3, 0.4); // Red line
    // }
    

        // Define the first 29 non-trivial zeros of the zeta function (imaginary parts)
    // float zeros[29] = float[](14.135, 21.022, 25.011, 30.425, 32.935, 
    //                           37.586, 40.918, 43.327, 48.005, 49.773, 
    //                           52.970, 56.446, 59.347, 60.831, 65.112, 
    //                           67.079, 69.546, 72.067, 75.704, 77.145, 
    //                           79.337, 82.910, 84.735, 87.099, 88.809, 
    //                           92.491, 94.651, 95.870, 98.831);


    // // Check if the current y position (t) is close to one of the zero values and draw horizontal lines
    // for (int i = 0; i < 29; i++) {
    //     if (abs(t - zeros[i]) < lineWidth || abs(t + zeros[i]) < lineWidth) {
    //         gradient2 = vec3(1.0, 1.0, 1.0); // Red line at the non-trivial zero position (both positive and negative)
    //     }
    // }

    // Set the fragment color
    gl_FragColor = vec4(gradient2, 1.0);
}
