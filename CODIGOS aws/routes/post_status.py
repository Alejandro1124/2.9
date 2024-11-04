# Importamos Blueprint para definir el módulo de rutas, request para recibir datos en solicitudes, y jsonify para enviar respuestas JSON
from flask import Blueprint, request, jsonify

# Importamos la función get_db_connection para obtener la conexión a la base de datos
from db import get_db_connection

# Importamos pymysql para manejar posibles errores relacionados con MySQL
import pymysql

# Creamos un blueprint llamado 'create_status', que manejará la ruta para crear nuevos registros
create_status_route = Blueprint('create_status', __name__)

# Definimos una ruta que escucha solicitudes POST en la URL '/status'
@create_status_route.route('/status', methods=['POST'])
def create_status():
    # Recibimos los datos del cuerpo de la solicitud en formato JSON
    new_status = request.json
    
    # Extraemos los campos necesarios del JSON recibido
    name = new_status.get('name')
    status = new_status.get('status')
    date = new_status.get('date')
    id_device = new_status.get('id_device')

    # Obtenemos la dirección IP del cliente desde el contexto de la solicitud
    ip_client = request.remote_addr

    # Verificamos que todos los campos requeridos estén presentes, si falta alguno devolvemos un error 400 (Bad Request)
    if not all([name, status, date, id_device]):
        return jsonify({'error': 'Faltan datos'}), 400

    # Intentamos ejecutar la lógica principal de inserción dentro del bloque try-except-finally para capturar errores
    try:
        # Obtenemos la conexión a la base de datos
        conn = get_db_connection()
        cursor = conn.cursor()

        # Ejecutamos la consulta SQL para insertar un nuevo registro en la tabla 'IoTCarStatus'
        cursor.execute(
            'INSERT INTO IoTCarStatus (name, ip_client, status, date, id_device) VALUES (%s, %s, %s, %s, %s)',
            (name, ip_client, status, date, id_device)
        )
        
        # Aplicamos los cambios en la base de datos
        conn.commit()

        # Obtenemos el ID del nuevo registro insertado
        new_id = cursor.lastrowid
    except pymysql.MySQLError as err:
        # Si ocurre un error de MySQL, devolvemos un mensaje de error con el código de error 500 (error interno del servidor)
        return jsonify({'error': str(err)}), 500
    finally:
        # Cerramos el cursor y la conexión a la base de datos en cualquier caso (éxito o error)
        cursor.close()
        conn.close()

    # Si la inserción es exitosa, devolvemos un JSON con el ID del nuevo registro y los datos insertados, junto con un código 201 (Created)
    return jsonify({
        'id': new_id,
        'name': name,
        'ip_client': ip_client,
        'status': status,
        'date': date,
        'id_device': id_device
    }), 201
