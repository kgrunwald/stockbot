from injector import Module, Binder
from flask_injector import request
from .user_service import UserService
from .account_service import AccountService


class ServiceModule(Module):
    def configure(self, binder: Binder):
        self.configure_user(binder)

    def configure_user(self, binder: Binder):
        binder.bind(UserService, to=UserService, scope=request)

    def configure_acct(self, binder: Binder):
        binder.bind(AccountService, to=AccountService, scope=request)
