# config.py

db_config = {
    'host': 'instancia-db-iot.cdqosigc86rq.us-east-1.rds.amazonaws.com',
    'user': 'admin',
    'password': 'Admin12345#!',
    'database': 'db_iot',
    'cursorclass': 'pymysql.cursors.DictCursor'  # DictCursor para obtener resultados como diccionarios
}
