from flask_restplus import Namespace, Api
from flask_injector import inject
from .auth import ProtectedResource
from ..service.user_service import UserService
from ..models import User, modelize

api = Namespace('users', description='User related operations')
user_model = modelize(User, api)


@api.route('/')
class UsersResource(ProtectedResource):
    @inject
    def __init__(self, api: Api, svc: UserService):
        super().__init__(api)
        self.svc = svc

    @api.marshal_list_with(user_model)
    def get(self):
        return self.svc.get_all()

    @api.expect(user_model)
    @api.marshal_with(user_model, code=201, description='User created')
    @api.response(400, 'User with the provided credentials already exists')
    def post(self):
        return self.svc.create(api.payload), 201


@api.route('/<int:id>')
@api.response(404, 'User with provided ID not found')
class UserResource(ProtectedResource):
    @inject
    def __init__(self, api: Api, svc: UserService):
        super().__init__(api)
        self.svc = svc

    @api.doc(description="Get user by ID")
    @api.marshal_with(user_model)
    def get(self, id):
        return self.svc.get(id)
