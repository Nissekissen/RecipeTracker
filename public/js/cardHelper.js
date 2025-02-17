

document.querySelectorAll('.recipe-brief-container').forEach(container => {
    container.addEventListener('mousemove', (e) => {
        const { left, top, width, height } = container.getBoundingClientRect();
        const x = e.clientX - left;
        const y = e.clientY - top;

        const maxAngle = 10; // Adjust this value to increase or decrease the tilt effect

        // Calculate rotation values
        const rotateX = ((y / height) - 0.5) * -(maxAngle * 2); // Negative for upward tilt
        const rotateY = ((x / width) - 0.5) * (maxAngle * 2);  // Positive for rightward tilt

        const card = container.querySelector('.recipe-brief');

        card.style.transform = `rotateX(${rotateX}deg) rotateY(${rotateY}deg)`;
    })

    container.addEventListener('mouseleave', () => {
        const card = container.querySelector('.recipe-brief');
        card.style.transform = `rotateX(0deg) rotateY(0deg)`;
    });
});

container.addEventListener('mouseleave', () => {
    card.style.transform = `rotateX(0deg) rotateY(0deg)`;
});
