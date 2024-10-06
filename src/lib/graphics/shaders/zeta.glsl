precision highp float;
varying vec2 vUv;
uniform vec3 color1;
uniform vec3 color2;
uniform vec3 color3;
uniform vec2 mouse;

float pi = 3.14159265359;
float scale = 1000.0;
float lineWidth = 0.1;   // Width of the vertical lines

// // Function to compute the Theta function on a lattice
// vec2 thetaLattice(float sigma, float t) {
//     vec2 sum = vec2(0.0, 0.0); // (real part, imaginary part)
//     const int N = 25; // Number of terms in the series for approximation
//     float pi = 3.14159265359;

//     for (int n = -N; n <= N; ++n) {
//         float normSquared = float(n * n);   // The inner product ⟨v, v⟩ is n^2 for integers
//         float angleOscillatory = 2.0 * pi * float(n) * t; // This corresponds to the oscillation term (2 pi i n t)
//         float angleDamping = -pi * normSquared * sigma;   // The damping term (−pi n^2 sigma)

//         // Combine the real and imaginary parts for each term: 
//         // e^{pi i n^2 tau + 2 pi i n t} = cos(angleOscillatory) * exp(angleDamping)
//         float damping = exp(angleDamping); // Apply the damping (real, from sigma)

//         // Real and imaginary parts of the lattice theta function
//         sum.x += cos(angleOscillatory) * damping; // Real part
//         sum.y += sin(angleOscillatory) * damping; // Imaginary part
//     }

//     return sum; // Return the complex result as (real, imaginary)
// }

// Function to compute the approximation of the zeta function on the critical line
// vec2 zetaCriticalLine(float sigma, float t) {
//     vec2 sum = vec2(0.0, 0.0);  // (real part, imaginary part)
//     const int N = 1000;          // Number of terms for approximation (increase for higher accuracy)

//     for (int n = 1; n <= N; ++n) {
//         float log_n = log(float(n));
//         float theta = t * log_n;

//         // Compute the real and imaginary parts of the zeta function sum
//         sum.x += cos(theta) / sqrt(float(n));  // Real part
//         sum.y += sin(theta) / sqrt(float(n));  // Imaginary part
//     }

//     return sum;  // Return the complex value (real, imaginary)
// }

// Function to compute the approximation of the zeta function on the critical line
vec2 zeta(float sigma, float t) {
    vec2 sum = vec2(0.0, 0.0);  // (real part, imaginary part)
    const int N = 100;          // Number of terms for approximation (increase for higher accuracy)

    for (int n = 1; n <= N; ++n) {
        float log_n = log(float(n));
        float theta = t * log_n;  // Oscillatory term from the imaginary part

        // Compute the real and imaginary parts of the zeta function sum for general sigma
        float factor = pow(float(n), -sigma);  // This introduces sigma (the real part of s)
        sum.x += factor * cos(theta) / sqrt(float(n));  // Real part
        sum.y += factor * sin(theta) / sqrt(float(n));  // Imaginary part
    }

    return sum;  // Return the complex value (real, imaginary)
}

void main() {
    // Map the fragment coordinates to the complex plane
    float adaptedScale = scale;
    float t = (vUv.x * 1.0 * adaptedScale) - (0.5 * adaptedScale);     // z coordinate (complex input)
    float sigma = (vUv.y * 1.0 * adaptedScale) - (0.5 * adaptedScale);   // tau coordinate (real/imaginary axis)

    float tAdapted = t * mouse.x; // Scale the t value for the theta function
    float sigmaAdapted = sigma * mouse.y * 0.1; // Scale the sigma value for the theta function

    // Compute the lattice theta function
    vec2 thetaValue = zeta(sigmaAdapted, tAdapted);
    // vec2 thetaValue = thetaLattice(0.0, t * mouse.x * 100.0);

    // Get the magnitude and phase of the complex value for visualization
    float magnitude = length(thetaValue); // Magnitude of the complex number
    float phase = atan(thetaValue.y, thetaValue.x); // Compute the phase

    // Normalize the magnitude and phase to map to color range
    float normalizedMagnitude = 0.5 + 0.5 * magnitude;
    float normalizedPhase = 0.5 + 0.5 * phase / 3.14159265359; // Normalize phase to [0, 1] range

    // Create gradients for visualization
    vec3 gradient1 = mix(color1, color2, normalizedMagnitude);
    // vec3 gradient2 = mix(color3, gradient1, 0.0 + (0.5 * normalizedMagnitude * 0.5 * normalizedPhase) * abs((2.0 * mouse.y)));
    vec3 gradient2 = mix(color3, gradient1, 0.0 + sin(0.5 * normalizedMagnitude)); // * abs(mouse.x));

    // Define the first 29 non-trivial zeros of the zeta function (imaginary parts)
    float zeros[29] = float[](14.135, 21.022, 25.011, 30.425, 32.935, 
                              37.586, 40.918, 43.327, 48.005, 49.773, 
                              52.970, 56.446, 59.347, 60.831, 65.112, 
                              67.079, 69.546, 72.067, 75.704, 77.145, 
                              79.337, 82.910, 84.735, 87.099, 88.809, 
                              92.491, 94.651, 95.870, 98.831);

    // Check if the current y position (t) is close to one of the zero values and draw horizontal lines
    for (int i = 0; i < 29; i++) {
        if (abs(tAdapted - zeros[i]) < lineWidth || abs(tAdapted + zeros[i]) < lineWidth) {
            gradient2 = vec3(0.0, 0.5, 0.5); // Red line at the non-trivial zero position (both positive and negative)
        }
    }

    // Set the fragment color
    gl_FragColor = vec4(gradient2, 1.0);
}
