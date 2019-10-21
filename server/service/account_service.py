from flask_injector import inject
from sqlalchemy.exc import IntegrityError
from werkzeug.exceptions import BadRequest
from .user_service import UserService
from ..models import Account, User, db


class AccountService:
    @inject
    def __init__(self, user_service: UserService):
        self.user_service = user_service

    def create(self, user: User, data: dict):
        acct = Account()
        acct.api_key = data['api_key']
        acct.secret_key = data['secret_key']

        user.account = acct

        try:
            db.session.add(user)
            db.session.commit()
        except IntegrityError:
            raise BadRequest('Account with those credentials already exists')
        return acct

    def get_all(self):
        return Account.query.all()

    def get(self, id):
        return Account.query.get_or_404(id)
