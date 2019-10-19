from flask_restplus import Api
from .user import api as user_api

api = Api(
    title="StockBot API",
    version="0.1"
)

api.add_namespace(user_api, path='/user')
