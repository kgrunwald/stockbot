from flask import Flask, Blueprint, jsonify
from controllers.auth import Unauthorized
from controllers import api


app = Flask(__name__)
blueprint = Blueprint('api', __name__, url_prefix='/api')
api.init_app(blueprint)
app.register_blueprint(blueprint)
