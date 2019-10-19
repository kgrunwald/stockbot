from flask import Blueprint
from flask_restplus import Resource, Namespace, fields
from .auth import authorizations

api = Namespace('users', description='User related operations',
                authorizations=authorizations)

user = api.model('User', {
    'name': fields.String,
    'id': fields.String
})


@api.route('/')
@api.doc(security='apikey')
@api.response(404, 'Not Found')
class Index(Resource):
    @api.marshal_with(user)
    def get(self):
        return {
            'name': 'Kyle',
            'id': '12345'
        }
