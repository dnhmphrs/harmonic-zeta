precision highp float;
varying vec2 vUv;
uniform vec3 color1;
uniform vec3 color2;
uniform vec3 color3;
uniform vec2 mouse;

float pi = 3.14159265359;
float scale = 100.0;
float lineWidth = 0.1;   // Width of the vertical lines

// Function to compute the Jacobi Theta function as a sum approximation
// vec2 jacobiTheta(float z, float tau) {
//     vec2 sum = vec2(0.0, 0.0); // (real part, imaginary part)
//     const int N = 25; // Number of terms in the series for approximation


//     for (int n = -N; n <= N; ++n) {
//         float nSquaredTau = float(n * n) * tau;
//         float nZ = float(n) * z;

//         // Compute the angle for e^{2 * pi * i * (n^2 * tau + n * z)}
//         float angle = 2.0 * pi * (nSquaredTau + nZ);

//         // Real and imaginary parts of e^{i * angle}
//         sum.x += cos(angle);
//         sum.y += sin(angle);
//     }

//     return sum; // Return the complex result as (real, imaginary)
// }

// Inverted Prime-Modified Theta Function
vec2 jacobiTheta(float z, float tau) {
    vec2 sum = vec2(0.0, 0.0); // Initialize (real, imaginary) sum

    const int N = 50;

    for (int i = -N; i < N; ++i) {
        float n = float(i);
        float angle = tau * n * n + z * n;

        // Real part of the prime-modified theta function
        float realPart = cos(angle);
        
        // Imaginary part of the prime-modified theta function
        float imaginaryPart = sin(angle);

        // Accumulate the sum (real and imaginary components)
        sum.x += realPart / z;
        sum.y += imaginaryPart / z ;
    }


    return sum;
}

void main() {
    // Map the fragment coordinates to the complex plane
    float adaptedScale = scale;
    float z = (vUv.y * 1.0 * adaptedScale) - (0.5 * adaptedScale);     // z coordinate (related to complex input s)
    float tau = (vUv.x * 1.0 * adaptedScale) - (0.5 * adaptedScale);   // tau coordinate (analogous to sigma)

    float adaptedZ = z * 1.0 * abs(mouse.y);
    float adaptedTau =  tau * abs(mouse.x);

    // Compute the Jacobi Theta function
    vec2 thetaValue = jacobiTheta(adaptedZ, adaptedTau);

    // Get the magnitude / phase of the complex value for visualization
    float magnitude = length(thetaValue); // Magnitude of the complex number
    float phase = atan(thetaValue.y, thetaValue.x); // Compute the phase

    // Normalize the magnitude / phase to map to color range
    float normalizedMagnitude = 0.5 + 0.5 * magnitude;
    float normalizedPhase = 0.5 + 0.5 * phase / 3.14159265359; // Normalize phase to [0, 1] range

    // Create gradients for visualization
    vec3 gradient1 = mix(color1, color2, normalizedMagnitude);
    vec3 gradient2 = mix(color3, gradient1, 0.25 + 0.25 * cos(normalizedMagnitude * abs((1.0 * mouse.y))));

    // // Define the first 29 non-trivial zeros of the zeta function (imaginary parts)
    // float zeros[29] = float[](14.135, 21.022, 25.011, 30.425, 32.935, 
    //                           37.586, 40.918, 43.327, 48.005, 49.773, 
    //                           52.970, 56.446, 59.347, 60.831, 65.112, 
    //                           67.079, 69.546, 72.067, 75.704, 77.145, 
    //                           79.337, 82.910, 84.735, 87.099, 88.809, 
    //                           92.491, 94.651, 95.870, 98.831);

    // // Check if the current y position (t) is close to one of the zero values and draw horizontal lines
    // for (int i = 0; i < 29; i++) {
    //     if (abs(adaptedTau * adaptedScale - zeros[i]) < lineWidth || abs(adaptedTau * adaptedScale + zeros[i]) < lineWidth) {
    //         gradient2 = vec3(0.0, 0.5, 0.5); // Red line at the non-trivial zero position (both positive and negative)
    //     }
    // }
        
    // Set the fragment color
    gl_FragColor = vec4(gradient2, 1.0);
}
