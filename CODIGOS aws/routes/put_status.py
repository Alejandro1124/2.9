# Importamos Blueprint para definir un módulo de rutas, request para manejar datos recibidos, y jsonify para enviar respuestas en formato JSON
from flask import Blueprint, request, jsonify

# Importamos la función get_db_connection para obtener la conexión a la base de datos
from db import get_db_connection

# Importamos pymysql para manejar posibles errores relacionados con MySQL
import pymysql

# Creamos un blueprint llamado 'update_status', que manejará la ruta para actualizar registros existentes
update_status_route = Blueprint('update_status', __name__)

# Definimos una ruta que escucha solicitudes PUT en la URL '/status/<status_id>'
@update_status_route.route('/status/<int:status_id>', methods=['PUT'])
def update_status(status_id):
    # Recibimos los datos del cuerpo de la solicitud en formato JSON
    updated_status = request.json
    
    # Extraemos los campos necesarios del JSON recibido
    name = updated_status.get('name')
    ip_client = updated_status.get('ip_client')
    status = updated_status.get('status')
    date = updated_status.get('date')
    id_device = updated_status.get('id_device')

    # Verificamos que todos los campos requeridos estén presentes, si falta alguno devolvemos un error 400 (Bad Request)
    if not all([name, ip_client, status, date, id_device]):
        return jsonify({'error': 'Faltan datos'}), 400

    # Intentamos ejecutar la lógica principal de actualización dentro del bloque try-except-finally para capturar errores
    try:
        # Obtenemos la conexión a la base de datos
        conn = get_db_connection()
        cursor = conn.cursor()

        # Ejecutamos la consulta SQL para actualizar un registro en la tabla 'IoTCarStatus' con los nuevos datos, filtrando por el 'id' especificado
        cursor.execute(
            'UPDATE IoTCarStatus SET name = %s, ip_client = %s, status = %s, date = %s, id_device = %s WHERE id = %s',
            (name, ip_client, status, date, id_device, status_id)
        )
        
        # Aplicamos los cambios en la base de datos
        conn.commit()

        # Si no se ha actualizado ninguna fila (rowcount == 0), devolvemos un error 404 (registro no encontrado)
        if cursor.rowcount == 0:
            return jsonify({'error': 'Registro no encontrado'}), 404
    except pymysql.MySQLError as err:
        # Si ocurre un error de MySQL, devolvemos un mensaje de error con el código de error 500 (error interno del servidor)
        return jsonify({'error': str(err)}), 500
    finally:
        # Cerramos el cursor y la conexión a la base de datos en cualquier caso (éxito o error)
        cursor.close()
        conn.close()

    # Si la actualización es exitosa, devolvemos un mensaje confirmando que el registro fue actualizado correctamente
    return jsonify({'message': 'Registro actualizado correctamente'})
