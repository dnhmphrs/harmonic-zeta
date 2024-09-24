<script>
	import { onMount, onDestroy  } from 'svelte';
	import { screenType, mousePosition, mouseOverHeader } from '$lib/store/store';
	import { page } from '$app/stores';
	import { afterNavigate } from '$app/navigation';

	import * as THREE from 'three';
	import Stats from 'stats.js'

	import vertexShader from './shaders/vertexShader-three.glsl';
	import fragmentShader_harmonic_zeta_simple from './shaders/harmonicZetaFrag-simple.glsl';
	import fragmentShader_harmonic_zeta_inside from './shaders/harmonicZetaFrag-inside.glsl';
	import fragmentShader_harmonic_zeta_inside_alt from './shaders/harmonicZetaFrag-inside-alt.glsl';

	let shaderMaterial_harmonic_zeta_simple, shaderMaterial_harmonic_zeta_inside, shaderMaterial_harmonic_zeta_inside_alt;

	let container;
	let stats;

	let camera, scene, renderer;

	let width = window.innerWidth;
	let height = window.innerHeight;

	let mouse = new THREE.Vector2();
	const clock = new THREE.Clock();

	stats = new Stats()
	stats.showPanel(0) // 0: fps, 1: ms, 2: mb, 3+: custom
	document.body.appendChild(stats.dom)
	
	init();
	animate();

	function setupShaderMaterials() {
		const uniformsBase = {
			time: { value: 0 },
			mouse: { value: mouse }
		};

		const colors = {
			color1: new THREE.Color(0xd0d0d0),
			color2: new THREE.Color(0xbb4500),
			color3: new THREE.Color(0xdaaa55),
			color4: new THREE.Color(0x006994 ),
			color5: new THREE.Color(0x5099b4 ),
			color6: new THREE.Color(0x0000ff),
			color7: new THREE.Color(0x00ff00),
			// deep purple
			color8: new THREE.Color(0xA020F0),
			color9: new THREE.Color(0x8fbd5a),
			color0: new THREE.Color(0x232323),
		}

		shaderMaterial_harmonic_zeta_simple = new THREE.ShaderMaterial({
			vertexShader: vertexShader,
			fragmentShader: fragmentShader_harmonic_zeta_simple,
			uniforms: {
				...uniformsBase,
				color1: { value: colors.color1 },
				color2: { value: colors.color5 },
				color3: { value: colors.color9 },
			}
		});

		shaderMaterial_harmonic_zeta_inside = new THREE.ShaderMaterial({
			vertexShader: vertexShader,
			fragmentShader: fragmentShader_harmonic_zeta_inside,
			uniforms: {
				...uniformsBase,
				color1: { value: colors.color1 },
				color2: { value: colors.color5 },
				color3: { value: colors.color9 },
			}
		});

		shaderMaterial_harmonic_zeta_inside_alt = new THREE.ShaderMaterial({
			vertexShader: vertexShader,
			fragmentShader: fragmentShader_harmonic_zeta_inside_alt,
			uniforms: {
				...uniformsBase,
				color1: { value: colors.color1 },
				color2: { value: colors.color5 },
				color3: { value: colors.color9 },
			}
		});
	}

	function init() {
		camera = new THREE.PerspectiveCamera(20, width / height, 1, 800);
		camera.position.z = 400;

		scene = new THREE.Scene();
		scene.background = new THREE.Color(0x232323);

		setupShaderMaterials();
		setScene();

		renderer = new THREE.WebGLRenderer({ antialias: false });
		renderer.setPixelRatio(window.devicePixelRatio);
		renderer.setSize(width, height);

		onMount(() => {
			container.appendChild(renderer.domElement);


		});

		window.addEventListener('mousemove', onDocumentMouseMove);
		window.addEventListener('resize', onWindowResize);
		// window.addEventListener('navigate', onNavigate);
	}

	function setSimple () {

		let plane4 = new THREE.Mesh(new THREE.PlaneGeometry(1000, 1000), shaderMaterial_harmonic_zeta_simple);
		scene.add(plane4);
	}

	function setInside() {

		let plane4 = new THREE.Mesh(new THREE.PlaneGeometry(1000, 1000), shaderMaterial_harmonic_zeta_inside);
		scene.add(plane4);
	}

	function setInsideAlt() {

		let plane4 = new THREE.Mesh(new THREE.PlaneGeometry(1000, 1000), shaderMaterial_harmonic_zeta_inside_alt);
		scene.add(plane4);
	}

	function setScene () {

		if ($page.url.pathname == '/') {
			setSimple();
		}

		if ($page.url.pathname == '/inside') {
			setInside();
		}

		if ($page.url.pathname == '/inside-alt') {
			setInsideAlt();
		}
	}

	afterNavigate (onNavigate);
	function onNavigate() {

		for( var i = scene.children.length - 1; i >= 0; i--) { 
				let obj = scene.children[i];
				scene.remove(obj); 
		}

		setScene();

	}

	function onWindowResize() {
		let width = window.innerWidth;
		let height = window.innerHeight;

		camera.aspect = width / height;
		camera.updateProjectionMatrix();

		renderer.setSize(width, height);
	}

	function onDocumentMouseMove(event) {

		var clientX = event.clientX;
		var clientY = event.clientY;

		mouse.x = (clientX / window.innerWidth) * 2 - 1;
		mouse.y = -(clientY / window.innerHeight) * 2 + 1;

		if ($mouseOverHeader) {
			mouse.x = 0;
			mouse.y = 0;
		}
		
		// update store
		mousePosition.set(mouse);
	};

	function animate() {
		requestAnimationFrame(animate);
		stats.begin()
		render();
		stats.end()
	}

	function render() {
		// updateShaderUniforms();
		renderer.render(scene, camera);
	}

	onDestroy(() => {
    // Remove event listeners
    window.removeEventListener('mousemove', onDocumentMouseMove);
    window.removeEventListener('resize', onWindowResize);
    // Dispose of the materials, geometries, textures etc.
    scene.traverse(object => {
        if (object instanceof THREE.Mesh) {
            object.geometry.dispose();
            object.material.dispose();
        }
        // Consider adding other types if they hold resources (like textures).
    });
    
    // If you've added any textures, dispose of them too
    // texture.dispose();

    renderer.dispose();  // Dispose of the renderer's resources
});

</script>

<div bind:this={container} class:geometry={true} />

<style>
	.geometry {
		position: absolute;
		overflow: hidden;
		z-index: -1;
	}
</style>
