function getStepFromUrl() {
    const progressContainer = document.querySelector('.progress-container');
    const partClass = Array.from(progressContainer.classList).find(cls => cls.startsWith('part'));
    return parseInt(partClass.replace('part', '')) || 1;
}

function getCheckmarkSVG() {
    return `<svg class="checkmark" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24"> 
                <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 11.917 9.724 16.5 19 7.5"/> 
            </svg>`;
}

function updateProgress(step) {
    let startStep = step === 3 ? 2 : 1;
    for (let i = 1; i < startStep; i++) {
        document.getElementById(`step${i}`).classList.add('active');
        document.getElementById(`step${i}`).innerHTML = getCheckmarkSVG();
        document.getElementById(`line${i}`).classList.add('filled-line');
    }

    let currentStep = startStep;
    function animateStep() {
        if (currentStep <= step) {
            const stepElement = document.getElementById(`step${currentStep}`);
            stepElement.classList.add('active');

            if (currentStep < step) {
                stepElement.innerHTML = getCheckmarkSVG();
            }

            if (currentStep > 1) {
                document.getElementById(`line${currentStep - 1}`).classList.add('filled-line');
            }
            currentStep++;
            setTimeout(animateStep, 500);
        }
    }
    animateStep();
}

const step = getStepFromUrl();
updateProgress(step);