const container = document.getElementById('fireworkContainer');
const fireworks = new Fireworks.default(container);

fireworks.updateOptions({
    autoresize: true,
    opacity: 0.5,
    acceleration: 1.05,
    friction: 0.97,
    gravity: 1.5,
    particles: 50,
    traceLength: 1,
    traceSpeed: 10,
    explosion: 5,
    intensity: 30,
    flickering: 50,
    lineStyle: 'round',
    hue: {
        min: 0,
        max: 50
    },
    delay: {
        min: 30,
        max: 60
    },
    rocketsPoint: {
        min: 50,
        max: 50
    },
    lineWidth: {
        explosion: {
            min: 1,
            max: 3
        },
        trace: {
            min: 0,
            max: 0
        }
    },
    brightness: {
        min: 50,
        max: 80
    },
    decay: {
        min: 0.015,
        max: 0.03
    },
    mouse: {
        click: false,
        move: false,
        max: 1
    }
})

document.getElementById('fireworkBtn').addEventListener('click', () => {
    document.getElementById('fireworkContainer').style.zIndex = '10';
    fireworks.launch(2);
    setTimeout(() => {
        window.location.href = '/auth/sign-in';
    }, 500)
});
