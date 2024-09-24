// attribute vec2 uv;
// attribute vec3 position;
// uniform mat4 projectionMatrix;
// uniform mat4 modelViewMatrix;
varying vec2 vUv; // Varying variable to pass the UV coordinates to the fragment shader

void main() {
    vUv = uv;
    // vUv.x = (10.0 * vUv.x - 5.0);
    // vUv.y = (5.0 * vUv.y - 2.0);
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 2.0);
}