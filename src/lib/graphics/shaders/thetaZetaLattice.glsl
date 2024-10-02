precision highp float;
varying vec2 vUv;
uniform vec3 color1;
uniform vec3 color2;
uniform vec3 color3;
uniform vec2 mouse;

float pi = 3.14159265359;
float scale = 500.0;
float lineWidth = 0.1;   // Width of the vertical lines

// Function to compute the Theta function on a lattice
vec2 thetaLattice(float sigma, float t) {
    vec2 sum = vec2(0.0, 0.0); // (real part, imaginary part)
    const int N = 15; // Number of terms in the series for approximation
    float pi = 3.14159265359;

    for (int n = -N; n <= N; ++n) {
        float normSquared = float(n * n);   // The inner product ⟨v, v⟩ is n^2 for integers
        float angleOscillatory = 2.0 * pi * float(n) * t; // This corresponds to the oscillation term (2 pi i n t)
        float angleDamping = -pi * normSquared * sigma;   // The damping term (−pi n^2 sigma)

        // Combine the real and imaginary parts for each term: 
        // e^{pi i n^2 tau + 2 pi i n t} = cos(angleOscillatory) * exp(angleDamping)
        float damping = exp(angleDamping); // Apply the damping (real, from sigma)

        // Real and imaginary parts of the lattice theta function
        sum.x += cos(angleOscillatory) * damping; // Real part
        sum.y += sin(angleOscillatory) * damping; // Imaginary part
    }

    return sum; // Return the complex result as (real, imaginary)
}

void main() {
    // Map the fragment coordinates to the complex plane
    float adaptedScale = scale;
    float t = (vUv.x * 1.0 * adaptedScale) - (0.5 * adaptedScale);     // z coordinate (complex input)
    float sigma = (vUv.y * 1.0 * adaptedScale) - (0.5 * adaptedScale);   // tau coordinate (real/imaginary axis)

    // Compute the lattice theta function
    vec2 thetaValue = thetaLattice(sigma * mouse.x * 0.001, t * mouse.y);

    // Get the magnitude and phase of the complex value for visualization
    float magnitude = length(thetaValue); // Magnitude of the complex number
    float phase = atan(thetaValue.y, thetaValue.x); // Compute the phase

    // Normalize the magnitude and phase to map to color range
    float normalizedMagnitude = 0.5 + 0.5 * magnitude;
    float normalizedPhase = 0.5 + 0.5 * phase / 3.14159265359; // Normalize phase to [0, 1] range

    // Create gradients for visualization
    vec3 gradient1 = mix(color1, color2, normalizedMagnitude);
    vec3 gradient2 = mix(color3, gradient1, 0.0 + (0.5 * normalizedMagnitude * 0.5 * normalizedPhase) * abs((2.0 * mouse.y)));

    // Set the fragment color
    gl_FragColor = vec4(gradient2, 1.0);
}
