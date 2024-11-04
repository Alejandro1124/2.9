document.addEventListener("DOMContentLoaded", function() {
    // URL de la API
    const apiUrl = 'http://54.198.42.156:5000/status';

    // Función para obtener y mostrar el último registro
    async function fetchLastRecord() {
        try {
            const response = await fetch(apiUrl);
            const records = await response.json();
            const lastRecord = records[0];

            // Insertar el último registro en la tabla
            const lastRecordRow = document.getElementById("last-record");
            lastRecordRow.innerHTML = `
                <tr>
                    <td>${lastRecord.id}</td>
                    <td>${lastRecord.name}</td>
                    <td>${lastRecord.ip_client}</td>
                    <td>${lastRecord.status}</td>
                    <td>${new Date(lastRecord.date).toLocaleString()}</td>
                    <td>${lastRecord.id_device}</td>
                </tr>
            `;
        } catch (error) {
            console.error("Error al obtener el último registro:", error);
        }
    }

    // Función para obtener y mostrar todos los registros
    async function fetchAllRecords() {
        try {
            const response = await fetch(apiUrl);
            const records = await response.json();

            // Insertar todos los registros en la tabla
            const allRecordsTable = document.getElementById("all-records");
            allRecordsTable.innerHTML = records.map(record => `
                <tr>
                    <td>${record.id}</td>
                    <td>${record.name}</td>
                    <td>${record.ip_client}</td>
                    <td>${record.status}</td>
                    <td>${new Date(record.date).toLocaleString()}</td>
                    <td>${record.id_device}</td>
                </tr>
            `).join("");
        } catch (error) {
            console.error("Error al obtener todos los registros:", error);
        }
    }

    // Alternar la visibilidad de la tabla al hacer clic en el botón
    const toggleButton = document.getElementById("fetchAllRecords");
    const eyeIcon = document.getElementById("eyeIcon");
    const allRecordsContainer = document.getElementById("allRecordsContainer");

    toggleButton.addEventListener("click", function() {
        const isHidden = allRecordsContainer.style.display === "none";

        if (isHidden) {
            // Si la tabla está oculta, cargar y mostrar los registros
            fetchAllRecords();
            allRecordsContainer.style.display = "block";
            eyeIcon.classList.remove("closed");
            eyeIcon.classList.add("opened");
        } else {
            // Si la tabla está visible, ocultarla
            allRecordsContainer.style.display = "none";
            eyeIcon.classList.remove("opened");
            eyeIcon.classList.add("closed");
        }
    });

    // Asegurarse de que el contenedor de registros esté oculto al inicio y cargar el último registro
    allRecordsContainer.style.display = "none"; // Ocultar por defecto
    eyeIcon.classList.add("closed"); // Configurar el icono en estado cerrado inicialmente
    fetchLastRecord(); // Cargar el último registro al iniciar
});
