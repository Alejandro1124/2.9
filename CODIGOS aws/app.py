from flask import Flask, render_template
from flask_cors import CORS
from routes.get_status import get_status_route
from routes.post_status import create_status_route
from routes.put_status import update_status_route
from routes.delete_status import delete_status_route
from routes.get_last_status import get_last_status_route

app = Flask(__name__)
# habilitamos los cors
CORS(app)

# Registrar las rutas de los diferentes métodos HTTP
app.register_blueprint(get_status_route)
app.register_blueprint(create_status_route)
app.register_blueprint(update_status_route)
app.register_blueprint(delete_status_route)
app.register_blueprint(get_last_status_route)

# Rutas para servir las páginas HTML del frontend
@app.route('/')
def index():
    return render_template('index.html')

@app.route('/Registros')
def otra_pagina():
    return render_template('Get_registros.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
