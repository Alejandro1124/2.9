# Importamos Blueprint para crear un módulo de rutas, jsonify para devolver respuestas JSON
from flask import Blueprint, jsonify

# Importamos la función get_db_connection para obtener la conexión a la base de datos
from db import get_db_connection

# Importamos pymysql para manejar posibles errores de MySQL
import pymysql

# Creamos un blueprint llamado 'delete_status', que maneja las rutas para eliminar registros
delete_status_route = Blueprint('delete_status', __name__)

# Definimos una ruta que escucha solicitudes DELETE en la URL '/status/<status_id>'
@delete_status_route.route('/status/<int:status_id>', methods=['DELETE'])
def delete_status(status_id):
    # Intentamos ejecutar el bloque de código principal dentro de try-except-finally para capturar errores
    try:
        # Obtenemos la conexión a la base de datos
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Ejecutamos la consulta SQL para eliminar el registro cuyo 'id' coincida con 'status_id'
        cursor.execute('DELETE FROM IoTCarStatus WHERE id = %s', (status_id,))
        
        # Aplicamos los cambios en la base de datos
        conn.commit()
        
        # Si no se ha eliminado ninguna fila (rowcount == 0), devolvemos un error 404 (no encontrado)
        if cursor.rowcount == 0:
            return jsonify({'error': 'Registro no encontrado'}), 404
    except pymysql.MySQLError as err:
        # Si ocurre un error de MySQL, devolvemos un mensaje de error con el código de error 500 (error interno del servidor)
        return jsonify({'error': str(err)}), 500
    finally:
        # Cerramos el cursor y la conexión a la base de datos en cualquier caso (éxito o error)
        cursor.close()
        conn.close()

    # Si la eliminación es exitosa, devolvemos un mensaje confirmando que el registro fue eliminado correctamente
    return jsonify({'message': 'Registro eliminado correctamente'})
