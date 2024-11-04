


document.addEventListener('DOMContentLoaded', () => {
    const tableBody = document.getElementById('last-record');
    let isFetching = false; // Bandera para controlar las solicitudes concurrentes

    // Función para obtener y mostrar el último registro con control de solicitudes
    async function fetchLastRecord() {
        if (isFetching) return;  // Evita solicitudes si una ya está en proceso
        isFetching = true;
        
        try {
            const response = await fetch(`http://54.198.42.156:5000/last_status`);
            if (!response.ok) throw new Error('Error en la respuesta de la API');

            const data = await response.json();
            const lastRecord = data[0];

            // Limpiar el contenido existente y crear una nueva fila con los datos obtenidos
            tableBody.innerHTML = `
                <tr>
                    <td>${lastRecord.id}</td>
                    <td>${lastRecord.name}</td>
                    <td>${lastRecord.ip_client}</td>
                    <td>${lastRecord.status}</td>
                    <td>${lastRecord.date}</td>
                    <td>${lastRecord.id_device}</td>
                </tr>
            `;
        } catch (error) {
            console.error('Error al obtener el último registro:', error);
            tableBody.innerHTML = `
                <tr>
                    <td colspan="6" class="text-center text-danger">Error al cargar los datos</td>
                </tr>
            `;
        } finally {
            isFetching = false;  // Restablece la bandera después de completar la solicitud
        }
    }

    // Llamar a la función al cargar la página y luego cada 5 segundos
    fetchLastRecord();  // Llamada inicial
    setInterval(fetchLastRecord, 5000);  // Llamada cada 5 segundos
});
