precision highp float;
varying vec2 vUv;
uniform vec3 color1;
uniform vec3 color2;
uniform vec3 color3;
uniform vec2 mouse;

float pi = 3.14159265359;
float scale = 50.0;
float lineWidth = 0.1;   // Width of the vertical lines

// Function to compute the Jacobi Theta function as a sum approximation
vec2 jacobiTheta(float z, float tau) {
    vec2 sum = vec2(0.0, 0.0); // (real part, imaginary part)
    const int N = 25; // Number of terms in the series for approximation

    for (int n = -N; n <= N; ++n) {
        float nSquaredTau = float(n * n) * tau;
        float nZ = float(n) * z;

        // Compute the angle for e^{2 * pi * i * (n^2 * tau + n * z)}
        float angle = 2.0 * pi * (nSquaredTau + nZ);

        // Real and imaginary parts of e^{i * angle}
        sum.x += cos(angle);
        sum.y += sin(angle);
    }

    return sum; // Return the complex result as (real, imaginary)
}

void main() {
    // Map the fragment coordinates to the complex plane
    float adaptedScale = scale;
    float z = (vUv.x * 2.0 * adaptedScale) - (1.0 * adaptedScale);     // z coordinate (related to complex input s)
    float tau = (vUv.y * 1.0 * adaptedScale) - (0.5 * adaptedScale);   // tau coordinate (analogous to sigma)

    // Compute the Jacobi Theta function
    vec2 thetaValue = jacobiTheta(z * abs(mouse.x) * 2.0, tau * abs(mouse.y) * 0.1);

    // Get the magnitude / phase of the complex value for visualization
    float magnitude = length(thetaValue); // Magnitude of the complex number
    float phase = atan(thetaValue.y, thetaValue.x); // Compute the phase

    // Normalize the magnitude / phase to map to color range
    float normalizedMagnitude = 0.5 + 0.5 * magnitude;
    float normalizedPhase = 0.5 + 0.5 * phase / 3.14159265359; // Normalize phase to [0, 1] range

    // Create gradients for visualization
    vec3 gradient1 = mix(color1, color2, normalizedMagnitude);
    vec3 gradient2 = mix(color3, gradient1, 0.0 + 0.25 * normalizedMagnitude * 0.5 * normalizedPhase);

    // Set the fragment color
    gl_FragColor = vec4(gradient2, 1.0);
}
