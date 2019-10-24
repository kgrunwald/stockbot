import pytest
from flask import g
from sqlalchemy.orm import subqueryload
import uuid
from ..models import db, Account, User


@pytest.fixture(scope='function')
def acct(user):
    acct = Account()
    acct.api_key = str(uuid.uuid4())
    acct.secret_key = str(uuid.uuid4())
    acct.add_acl(user)
    user.account = acct

    db.session.add(user)
    db.session.commit()
    return acct


def test_create_acl(acct, user):
    assert len(acct.acl.permissions) == 1
    p = acct.acl.permissions[0]
    assert p.user_id == user.id
    assert p.permission == 'read'


def test_read_with_acl(acct, user):
    g.jwt = {'sub': user.uid}
    accts = Account.query.all()

    assert len(accts) == 1


def test_no_read_without_acl(acct, user):
    acct2 = Account()
    acct2.api_key = 'test2'
    acct2.secret_key = 'test2'

    db.session.add(acct2)
    db.session.commit()

    accts = Account.query.all()
    assert len(accts) == 1
    assert accts[0] == acct


def test_get_all_accounts_with_read_user(acct, admin):
    jwt = g.jwt
    jwt['scope'] = 'read:user'
    g.jwt = jwt

    users = User.query.all()
    assert len(users) > 1
    for user in users:
        assert user.account is None


def test_get_all_accounts_with_read_user(acct, admin):
    jwt = g.jwt
    jwt['scope'] = 'read:user read:account'
    g.jwt = jwt

    users = User.query.all()
    assert len(users) > 1
    found = False
    for user in users:
        if user.account is not None:
            found = True
    assert found
