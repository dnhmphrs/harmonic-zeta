precision highp float;
varying vec2 vUv;
uniform vec3 color1;
uniform vec3 color2;
uniform vec3 color3;
uniform vec2 mouse;

float e = 2.718281828459045; // Euler's number

float scale = 400.0;
float lineWidth = 0.05;  // Width of the vertical lines

// Function to compute the harmonic number H_n
float harmonicNumber(float n) {
    return log(n) + 0.5772156649 + 1.0 / (2.0 * n); // Approximation: H_n ≈ ln(n) + γ + 1/(2n)
}

// // Function to compute zeta* as Σ σ⋅n^it
// vec2 zetaStarComplex(float sigma, float t) {
//     vec2 sum = vec2(0.0, 0.0); // (real part, imaginary part)
//     const int N = 1000; // Number of terms in the series for approximation

//     for (int n = 1; n <= N; ++n) {
//         // float hn = harmonicNumber(float(n));  // Compute H_n
//         float angle = t * log(float(n));      // Angle for n^it = cos(t log n) + i sin(t log n)
        
//         // Compute σ * n^it
//         float realPart = sigma * cos(angle);  // Real part of σ * n^it
//         float imaginaryPart = sigma * sin(angle);  // Imaginary part of σ * n^it

//         // Sum the real and imaginary parts divided by H_n
//         // sum.x += realPart / hn;
//         // sum.y += imaginaryPart / hn;
//         sum.x += realPart;
//         sum.y += imaginaryPart;
//     }

//     return sum; // Return the complex result as (real, imaginary)
// }

vec2 zetaStarComplex(float sigma, float t) {
    vec2 sum = vec2(0.0, 0.0); // (real part, imaginary part)
    
    // Hardcoded prime numbers (up to a reasonable limit, for example, the first 168 primes up to 1000)
    int primes[168] = int[168](
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
        947, 953, 967, 971, 977, 983, 991, 997
    );

    // Number of primes in the array
    const int numPrimes = 168;

    for (int i = 0; i < numPrimes; ++i) {
        float prime = float(primes[i]);
        float angle = t * log(prime);      // Angle for prime^it = cos(t log prime) + i sin(t log prime)

        // Compute σ * prime^it
        float realPart = sigma * cos(angle);  // Real part of σ * prime^it
        float imaginaryPart = sigma * sin(angle);  // Imaginary part of σ * prime^it

        // Sum the real and imaginary parts
        sum.x += realPart;
        sum.y += imaginaryPart;
    }

    return sum; // Return the complex result as (real, imaginary)
}


void main() {
    // Map the fragment coordinates to the complex plane
    float sigma = (vUv.y * 1.0 * scale) - (0.5 * scale); // Real part of s
    // float sigma = 0.4; // Real part of s
    float t = (vUv.x * 2.0 * scale) - (1.0 * scale);     // Imaginary part of s

    // Compute zetaStarComplex(sigma, t)
    vec2 zetaStarValue = zetaStarComplex(sigma, t);

    // Get the magnitude of the complex value for visualization
    float magnitude = length(zetaStarValue); // Magnitude of the complex number

    // Normalize the magnitude to map to color range
    float normalizedMagnitude = 0.5 + 0.5 * magnitude;

    // Create gradients for visualization
    vec3 gradient1 = mix(color1, color2, log(normalizedMagnitude));
    vec3 gradient2 = mix(color3, gradient1, 0.25 + 0.25 * sin(normalizedMagnitude));
    
    // Add vertical red lines at every integer on the y-axis (mapped to the x-axis)
    // float xPos = mod(t, 1.0); // Position for integer lines on the x-axis
    // if (abs(xPos) < abs(lineWidth)) {
    //     gradient2 = vec3(1.0, 1.0, 1.0); // Red line
    // }


    // // Define the first 29 non-trivial zeros of the zeta function (imaginary parts)
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
