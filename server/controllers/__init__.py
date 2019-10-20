from .api import api
from .user import api as user_api

api.add_namespace(user_api, path='/user')
