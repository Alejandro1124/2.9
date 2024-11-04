// Obtener el carrito y el área de movimiento
const car = document.getElementById('car');
const buttons = document.querySelectorAll('button');

// Posición y rotación iniciales
let posX = 0;
let posY = 0;
let rotation = 0;

// Tamaño del área de movimiento
const moveAmount = 5; // Distancia en píxeles para cada movimiento
const boundaryX = window.innerWidth - 100; // Ajuste para el tamaño del carrito
const boundaryY = window.innerHeight - 100;

// Variable para el intervalo de movimiento
let moveInterval;

// Función para mover el carrito
function moveCar(direction) {
    switch (direction) {
        case 'up':
            posY = Math.max(posY - moveAmount, 0);
            rotation = 0;
            break;
        case 'down':
            posY = Math.min(posY + moveAmount, boundaryY);
            rotation = 180;
            break;
        case 'left':
            posX = Math.max(posX - moveAmount, 0);
            rotation = -90;
            break;
        case 'right':
            posX = Math.min(posX + moveAmount, boundaryX);
            rotation = 90;
            break;
        case 'up-left':
            posX = Math.max(posX - moveAmount, 0);
            posY = Math.max(posY - moveAmount, 0);
            rotation = -45;
            break;
        case 'up-right':
            posX = Math.min(posX + moveAmount, boundaryX);
            posY = Math.max(posY - moveAmount, 0);
            rotation = 45;
            break;
        case 'down-left':
            posX = Math.max(posX - moveAmount, 0);
            posY = Math.min(posY + moveAmount, boundaryY);
            rotation = -135;
            break;
        case 'down-right':
            posX = Math.min(posX + moveAmount, boundaryX);
            posY = Math.min(posY + moveAmount, boundaryY);
            rotation = 135;
            break;
        case 'stop':
            clearInterval(moveInterval);
            return; // No mover el carrito si se detiene
    }

    // Aplicar la transformación de posición y rotación
    car.style.transform = `translate(${posX}px, ${posY}px) rotate(${rotation}deg)`;
}

// Función para iniciar el movimiento automático
function startMoving(direction) {
    clearInterval(moveInterval); // Detener movimiento anterior
    moveInterval = setInterval(() => moveCar(direction), 50); // Mover cada 50 ms
}

// Event listener para los botones
buttons.forEach(button => {
    button.addEventListener('click', () => {
        buttons.forEach(btn => btn.classList.remove('active'));
        button.classList.add('active');
        const direction = button.getAttribute('data-direction');

        // Iniciar el movimiento automático
        if (direction === 'stop') {
            moveCar(direction); // Detener movimiento
        } else {
            startMoving(direction); // Iniciar nuevo movimiento
        }
    });
});

// Detener el movimiento al soltar el botón
document.addEventListener('mouseup', () => {
    clearInterval(moveInterval); // Detener el movimiento
});
