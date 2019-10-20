from flask import Blueprint
from flask_restplus import Resource, Namespace, fields, Api
from flask_injector import inject
from .auth import ProtectedResource, authorizations, requires_auth, requires_scope
from ..service.user_service import UserService
from ..models.user import User
from ..models import modelize

api = Namespace('users', description='User related operations')
user_model = modelize(User, api)


@api.route('/')
@api.response(404, 'Not Found')
class Users(Resource):
    @inject
    def __init__(self, api: Api, svc: UserService):
        super().__init__(api)
        self.svc = svc

    @api.marshal_list_with(user_model)
    def get(self):
        return self.svc.get_all()

    @api.expect(user_model)
    @api.marshal_with(user_model, code=201)
    def post(self):
        return self.svc.create(api.payload), 201


@api.route('/<int:id>')
class User1(Resource):
    @inject
    def __init__(self, api: Api, svc: UserService):
        super().__init__(api)
        self.svc = svc

    @api.marshal_with(user_model)
    def get(self, id):
        return self.svc.get(id)
