# Importamos Blueprint para crear un módulo de rutas, y jsonify para devolver respuestas JSON
from flask import Blueprint, jsonify

# Importamos la función get_db_connection para obtener la conexión a la base de datos
from db import get_db_connection

# Importamos pymysql para manejar posibles errores de MySQL
import pymysql

# Creamos un blueprint llamado 'get_status', que maneja las rutas para obtener el estado de los registros
get_status_route = Blueprint('get_status', __name__)

# Definimos una ruta que escucha solicitudes GET en la URL '/status'
@get_status_route.route('/status', methods=['GET'])
def get_status():
    # Intentamos ejecutar el bloque de código principal dentro de try-except-finally para capturar errores
    try:
        # Obtenemos la conexión a la base de datos
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Ejecutamos la consulta SQL para seleccionar todos los registros de la tabla 'IoTCarStatus'
        cursor.execute('SELECT * FROM IoTCarStatus')
        
        # Obtenemos todos los registros como una lista de tuplas (cada tupla es una fila de la tabla)
        statuses = cursor.fetchall()
    except pymysql.MySQLError as err:
        # Si ocurre un error de MySQL, devolvemos un mensaje de error con el código de error 500 (error interno del servidor)
        return jsonify({'error': str(err)}), 500
    finally:
        # Cerramos el cursor y la conexión a la base de datos en cualquier caso (éxito o error)
        cursor.close()
        conn.close()

    # Devolvemos los registros obtenidos en formato JSON
    return jsonify(statuses)
