precision highp float;
varying vec2 vUv;
uniform vec3 color1;
uniform vec3 color2;
uniform vec3 color3;
uniform vec2 mouse;

float scale = 1000.0;
float lineWidth = 0.1;  // Width of the vertical lines

// Function to compute the harmonic number H_n
float harmonicNumber(float n) {
    return log(n) + 0.5772156649 + 1.0 / (2.0 * n); // Approximation: H_n ≈ ln(n) + γ + 1/(2n)
}

// // Function to compute zeta* in full complex form: Σ (cos(t log n) + i sin(t log n)) / ((sigma) / H_n)
// vec2 zetaStarComplex(float sigma, float t) {
//     vec2 sum = vec2(0.0, 0.0); // (real part, imaginary part)
//     const int N = 200; // Number of terms in the series for approximation

//     for (int n = 1; n <= N; ++n) {
//         // float hn = harmonicNumber(float(n));     // Compute H_n
//         float angle = t * log(float(n));         // Angle for n^it = cos(t log n) + i sin(t log n)

//         // Real part of H_n * n^{-it}
//         float realPart = cos(-angle);  // Use n^{-it} for real part
//         // Imaginary part of H_n * n^{-it}
//         float imaginaryPart = sin(-angle);  // Use n^{-it} for imaginary part

//         // Sum the real and imaginary parts divided by (σ * n)
//         sum.x += realPart / (sigma);
//         sum.y += imaginaryPart / (sigma);
//     }

//     return sum; // Return the complex result as (real, imaginary)
// }

vec2 zetaStarComplex(float sigma, float t) {
    vec2 sum = vec2(0.0, 0.0); // (real part, imaginary part)
    
    // Hardcoded prime numbers (up to a reasonable limit, for example, the first 168 primes up to 1000)
    int primes[256] = int[256](
        2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 
        53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 
        109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 
        173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 
        233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 
        293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359, 
        367, 373, 379, 383, 389, 397, 401, 409, 419, 421, 431, 
        433, 439, 443, 449, 457, 461, 463, 467, 479, 487, 491, 
        499, 503, 509, 521, 523, 541, 547, 557, 563, 569, 571, 
        577, 587, 593, 599, 601, 607, 613, 617, 619, 631, 641, 
        643, 647, 653, 659, 661, 673, 677, 683, 691, 701, 709, 
        719, 727, 733, 739, 743, 751, 757, 761, 769, 773, 787, 
        797, 809, 811, 821, 823, 827, 829, 839, 853, 857, 859, 
        863, 877, 881, 883, 887, 907, 911, 919, 929, 937, 941, 
        947, 953, 967, 971, 977, 983, 991, 997, 1009, 1013, 1019, 1021, 1031, 1033, 1039, 1049, 1051, 1061, 
        1063, 1069, 1087, 1091, 1093, 1097, 1103, 1109, 1117, 1123, 
        1129, 1151, 1153, 1163, 1171, 1181, 1187, 1193, 1201, 1213, 
        1217, 1223, 1229, 1231, 1237, 1249, 1259, 1277, 1279, 1283, 
        1289, 1291, 1297, 1301, 1303, 1307, 1319, 1321, 1327, 1361, 
        1367, 1373, 1381, 1399, 1409, 1423, 1427, 1429, 1433, 1439, 
        1447, 1451, 1453, 1459, 1471, 1481, 1483, 1487, 1489, 1493, 
        1499, 1511, 1523, 1531, 1543, 1549, 1553, 1559, 1567, 1571, 
        1579, 1583, 1597, 1601, 1607, 1609, 1613, 1619
    );

    // Number of primes in the array
    const int numPrimes = 168;
    for (int n = 1; n <= numPrimes; ++n) {
        // float hn = harmonicNumber(float(n));     // Compute H_n
        float angle = t * log(float(n));         // Angle for n^it = cos(t log n) + i sin(t log n)

        // Real part of H_n * n^{-it}
        float realPart = cos(-angle);  // Use n^{-it} for real part
        // Imaginary part of H_n * n^{-it}
        float imaginaryPart = sin(-angle);  // Use n^{-it} for imaginary part

        // Sum the real and imaginary parts divided by (σ * n)
        sum.x += realPart / (sigma);
        sum.y += imaginaryPart / (sigma);
    }

    return sum; // Return the complex result as (real, imaginary)
}

void main() {
    // Map the fragment coordinates to the complex plane
    float adaptedScale = scale * mouse.x;
    float sigma = (vUv.y * scale) - (0.5 * scale); // Real part of s
    float t = (vUv.x * adaptedScale) - (0.5 * adaptedScale);     // Imaginary part of s

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
            gradient2 = vec3(1.0, 0.0, 0.0); // Red line at the non-trivial zero position (both positive and negative)
        }
    }

    // Set the fragment color
    gl_FragColor = vec4(gradient2, 1.0);
}

