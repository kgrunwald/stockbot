from .api import api
from .user import api as user_api
from .account import api as acct_api

api.add_namespace(user_api, path='/users')
api.add_namespace(acct_api, path='/accounts')
