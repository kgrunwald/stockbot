from flask import Flask, Blueprint, jsonify, redirect, url_for
from flask_injector import FlaskInjector
from flask_migrate import Migrate
from .controllers.auth import Unauthorized, AuthModule
from .controllers import api
from .models.db import db
from .service.module import ServiceModule


def create_app():
    app = Flask(__name__)
    app.config.from_object('server.config')

    blueprint = Blueprint('api', __name__, url_prefix='/api')
    api.init_app(blueprint)
    app.register_blueprint(blueprint)

    db.init_app(app)

    Migrate(app, db, 'server/migrations')
    FlaskInjector(
        app=app,
        modules=[ServiceModule, AuthModule],
    )

    @app.route('/oauth2-redirect.html')
    def oauth_redirect():
        return redirect('/swaggerui/oauth2-redirect.html')

    return app
