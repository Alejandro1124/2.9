// Importa la función para obtener la IP
//import { getClientIP } from './Get_IP_Client.js';  
// Variables globales
//let ip_client = '';
const ip = 'http://54.198.42.156:5000/';
export default ip; // Exportar la variable

let name = '';
let isSending = false;  // Bandera para controlar el debounce

// Obtener la IP al cargar la página
//getClientIP().then(ip => {
   // if (ip) {
    //    ip_client = ip;
  //  } else {
   //     console.error('No se pudo obtener la IP');
  //  }
//});

// Función para generar un token en base al nombre usando jsSHA
function generateTokenFromName(name) {
    const shaObj = new jsSHA("SHA-256", "TEXT");
    shaObj.update(name);
    const hash = shaObj.getHash("HEX");
    return hash;
}

// Función para enviar datos a la API con throttle
async function sendData(status) {
    // Evitar múltiples envíos rápidos
    if (isSending) return;
    isSending = true;
    
    // Obtener el nombre desde el input
    name = document.getElementById('name').value;

    if (name.trim() === '') {
        alert('Por favor, ingresa tu nombre antes de continuar.');
        isSending = false;
        return;
    }

    // Generar un token basado en el nombre del usuario
    const id_device = generateTokenFromName(name);

    // Datos a enviar
    const data = {
        id: '',  // Genera un ID aleatorio
        name: name,  // Nombre proporcionado por el usuario
       // ip_client: ip_client,  // IP pública obtenida
        status: status,  // El estado que corresponde al botón
        date: new Date().toISOString(),  // Fecha actual en formato ISO
        id_device: id_device  // Token generado a partir del nombre
    };

    try {
        const response = await fetch(`${ip}/status`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        });
        const result = await response.json();
        console.log('Datos enviados:', result);
    } catch (error) {
        console.error('Error al enviar los datos:', error);
    } finally {
        // Restablecer bandera después de un breve tiempo para permitir otra solicitud
        setTimeout(() => {
            isSending = false;
        }, 200);  // Espera 200 ms antes de permitir el siguiente envío
    }
}

// Manejador de eventos para los botones con debounce
document.getElementById('up').addEventListener('click', () => sendData(1));         // Adelante
document.getElementById('down').addEventListener('click', () => sendData(2));       // Atrás
document.getElementById('left').addEventListener('click', () => sendData(4));       // Izquierda
document.getElementById('right').addEventListener('click', () => sendData(3));      // Derecha
document.getElementById('stop').addEventListener('click', () => sendData(5));       // Parar
document.getElementById('up-left').addEventListener('click', () => sendData(6));    // Esquina arriba-izquierda
document.getElementById('up-right').addEventListener('click', () => sendData(7));   // Esquina arriba-derecha
