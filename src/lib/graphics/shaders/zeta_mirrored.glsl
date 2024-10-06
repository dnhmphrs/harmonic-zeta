precision highp float;
varying vec2 vUv;
uniform vec3 color1;
uniform vec3 color2;
uniform vec3 color3;
uniform vec2 mouse;

float pi = 3.14159265359;
float scale = 1000.0;
float lineWidth = 0.1;   // Width of the vertical lines

// Function to compute the sum for n^(s-1)
vec2 sum_n_s_minus_1(float sigma, float t) {
    vec2 sum = vec2(0.0, 0.0);
    const int N = 100; // Number of terms for approximation

    for (int n = 1; n <= N; ++n) {
        float log_n = log(float(n));
        float theta = t * log_n;  // Oscillatory term from the imaginary part

        // Real and imaginary parts for n^(s-1)
        float factor = pow(float(n), sigma);  // Apply (s-1) exponent
        sum.x += factor * cos(theta);  // Real part
        sum.y += factor * sin(theta);  // Imaginary part
    }

    return sum;  // Return complex value (real, imaginary)
}

// Function to compute the sum for n^(-s+1)
vec2 sum_n_neg_s_plus_1(float sigma, float t) {
    vec2 sum = vec2(0.0, 0.0);
    const int N = 100; // Number of terms for approximation

    for (int n = 1; n <= N; ++n) {
        float log_n = log(float(n));
        float theta = t * log_n;  // Oscillatory term from the imaginary part

        // Real and imaginary parts for n^(-s+1)
        float factor = pow(float(n), -sigma );  // Apply (-s+1) exponent
        sum.x += factor * cos(theta);  // Real part
        sum.y += factor * sin(theta);  // Imaginary part
    }

    return sum;  // Return complex value (real, imaginary)
}


void main() {
    // Map the fragment coordinates to the complex plane
    float adaptedScale = scale;
    float t = (vUv.x * 1.0 * adaptedScale) - (0.5 * adaptedScale);     // z coordinate (complex input)
    float sigma = (vUv.y * 1.0 * adaptedScale) - (0.5 * adaptedScale);   // tau coordinate (real/imaginary axis)

    float tAdapted = t * mouse.x; // Scale the t value for the theta function
    float sigmaAdapted = sigma * mouse.y * 0.1; // Scale the sigma value for the theta function

    vec2 complexValue;
    
    // Split the screen: LHS renders n^(s-1), RHS renders n^(-s+1)
    if (vUv.y < 0.5) {
        // Left-hand side (LHS) for n^(s-1)
        complexValue = sum_n_s_minus_1(sigmaAdapted, tAdapted);
    } else {
        // Right-hand side (RHS) for n^(-s+1)
        complexValue = sum_n_neg_s_plus_1(sigmaAdapted, tAdapted);
    }
    
    // Get the magnitude and phase of the complex value for visualization
    float magnitude = length(complexValue); // Magnitude of the complex number
    float phase = atan(complexValue.y, complexValue.x); // Compute the phase

    // Normalize the magnitude and phase to map to color range
    float normalizedMagnitude = 0.5 + 0.5 * magnitude;
    float normalizedPhase = 0.5 + 0.5 * phase / pi; // Normalize phase to [0, 1] range

    // Create gradients for visualization
    vec3 gradient1 = mix(color1, color2, normalizedMagnitude);
    vec3 gradient2 = mix(color3, gradient1, 0.0 + (0.5 * normalizedMagnitude));

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
            gradient2 = vec3(0.0, 0.5, 0.5); // Line at the non-trivial zero position
        }
    }

    // // Define the first 100 non-trivial zeros of the zeta function (imaginary parts)
    // float zeros[100] = float[](14.134725, 21.02204, 25.010857, 30.424876, 32.935061, 
    //                         37.586178, 40.918719, 43.327073, 48.00515, 49.773832, 
    //                         52.970321, 56.446247, 59.347044, 60.83178, 65.112544, 
    //                         67.079811, 69.546402, 72.067158, 75.704691, 77.144841, 
    //                         79.337376, 82.91038, 84.735492, 87.425274, 88.809112, 
    //                         92.491899, 94.651344, 95.870596, 98.831195, 101.317851, 
    //                         103.725539, 105.446623, 107.168611, 111.029536, 111.874659, 
    //                         114.320221, 116.226689, 118.790782, 121.370125, 122.946829, 
    //                         124.256818, 127.516683, 129.578704, 131.087688, 133.497737, 
    //                         134.756509, 138.116042, 139.736208, 141.123707, 143.111846, 
    //                         146.000982, 147.422765, 150.05352, 150.925257, 153.024693, 
    //                         156.112909, 157.597591, 158.849988, 161.188964, 163.030709, 
    //                         165.537069, 167.184439, 169.094515, 169.911976, 173.411536, 
    //                         174.754191, 176.441435, 178.377407, 179.916484, 182.207817, 
    //                         183.864842, 185.598783, 187.228922, 189.416189, 191.611269, 
    //                         192.830063, 195.42438, 196.876481, 198.015309, 200.115204, 
    //                         201.264751, 204.170427, 205.394697, 207.906258, 208.999269, 
    //                         211.690862, 213.347484, 214.547044, 216.169538, 219.067668, 
    //                         220.714918, 221.430403, 224.007, 224.983324, 227.421444, 
    //                         229.337992, 231.250189, 232.497514, 234.50548, 236.524229);

    // // Check if the current y position (t) is close to one of the zero values and draw horizontal lines
    // for (int i = 0; i < 100; i++) {
    //     if (abs(tAdapted - zeros[i]) < lineWidth || abs(tAdapted + zeros[i]) < lineWidth) {
    //         gradient2 = vec3(0.0, 0.5, 0.5); // Line at the non-trivial zero position
    //     }
    // }


    // float lines[4] = float[](576.0, 22500.0, 45000.0, 443556.0);
    // for (int i = 0; i < 4; i++) {
    //     if (abs(tAdapted - lines[i]) < lineWidth || abs(tAdapted + lines[i]) < lineWidth) {
    //         gradient2 = vec3(0.0, 0.5, 0.5); // Line at the non-trivial zero position
    //     }
    // }


    // Set the fragment color
    gl_FragColor = vec4(gradient2, 1.0);
}
