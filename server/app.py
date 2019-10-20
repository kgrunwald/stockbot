from flask import Flask, Blueprint, jsonify
from controllers.auth import Unauthorized
from controllers import api
from models.db import db
from flask_migrate import Migrate

app = Flask(__name__)
app.config.from_object('config')

blueprint = Blueprint('api', __name__, url_prefix='/api')
api.init_app(blueprint)
app.register_blueprint(blueprint)

db.init_app(app)

Migrate(app, db)
