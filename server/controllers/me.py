from flask_restplus import Namespace, Api
from flask_injector import inject
from .auth import ProtectedResource, AuthUtils, requires_scope
from ..service.user_service import UserService
from ..models import User, modelize

api = Namespace('me', description='Operations that use the JWT to load the user in context')
user_model = modelize(User, api)


@api.route('/', strict_slashes=False)
class UserResource(ProtectedResource):
    @inject
    def __init__(self, api: Api, utils: AuthUtils, svc: UserService):
        super().__init__(api)
        self.svc = svc
        self.utils = utils

    @api.doc(description="Get user from JWT")
    @api.marshal_with(user_model)
    def get(self):
        userinfo = self.utils.current_jwt()
        return self.svc.get_by_uid(userinfo['sub'])
