from flask_restplus import Namespace, Api
from flask_injector import inject
from .auth import ProtectedResource, AuthUtils
from ..service.account_service import AccountService
from ..models import Account, modelize

api = Namespace('accounts', description='Account related operations')
acct_model = modelize(Account, api)


@api.route('/')
class AccountsResource(ProtectedResource):
    @inject
    def __init__(self, api: Api, svc: AccountService, utils: AuthUtils):
        super().__init__(api)
        self.svc = svc
        self.utils = utils

    @api.marshal_list_with(acct_model)
    def get(self):
        return self.svc.get_all()

    @api.expect(acct_model)
    @api.marshal_with(acct_model, code=201, description='Account created')
    @api.response(400, 'Account with the provided credentials already exists')
    def post(self):
        user = self.utils.current_user()
        return self.svc.create(user, api.payload), 201


@api.route('/<int:id>')
@api.response(404, 'Account with provided ID not found')
class AccountResource(ProtectedResource):
    @inject
    def __init__(self, api: Api, svc: AccountService):
        super().__init__(api)
        self.svc = svc

    @api.doc(description="Get account by ID")
    @api.marshal_with(acct_model)
    def get(self, id):
        return self.svc.get(id)
