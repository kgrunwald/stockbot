from flask import Blueprint
from flask_restplus import Resource, Namespace, fields
from .auth import ProtectedResource, authorizations, requires_auth, requires_scope

api = Namespace('users', description='User related operations')

user = api.model('User', {
    'name': fields.String,
    'id': fields.String
})


@api.route('/')
@api.response(404, 'Not Found')
class Index(ProtectedResource):
    @api.marshal_with(user)
    def get(self):
        return {
            'name': 'Kyle',
            'id': '12345'
        }


@api.route("/private")
class Index2(ProtectedResource):
    def get(self):
        response = "Hello from a private endpoint! You need to be authenticated to see this."
        return {"message": response}
