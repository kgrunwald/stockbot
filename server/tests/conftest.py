from .. import create_app
from ..models import db, User
from flask import g
import uuid
import os
import json
import pytest
import http.client

TEST_DB = 'pytest-test.db'
ADMIN_SCOPE = 'read:users read:accounts'


@pytest.fixture(scope='session')
def token():
    conn = http.client.HTTPSConnection("kgrunwald.auth0.com")
    payload = {
        'client_id': '3hZaX0QPDNs1RdgB2SJxvfx0km6zJSZ7',
        'client_secret': 'bRGWIgLueoMcB2L84ZCURBCqPxX7soE9r3iR7E5_ym3mknlaBcfQFYy86sRXG16U',
        'audience': 'https://api.stockbot.com',
        'grant_type': 'client_credentials',
        'scope': 'read:users read:accounts'
    }
    headers = {'content-type': "application/json"}
    conn.request("POST", "/oauth/token", json.dumps(payload), headers)
    res = conn.getresponse()
    data = res.read()
    token = json.loads(data.decode("utf-8"))
    return token


@pytest.fixture(scope='session')
def headers(token):
    return {
        'Authorization': '{} {}'.format(token['token_type'], token['access_token']),
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    }


@pytest.fixture(scope='module')
def app():
    app = create_app()
    app.config['TESTING'] = True
    app.config['WTF_CSRF_ENABLED'] = False
    app.config['DEBUG'] = False
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:////tmp/' + TEST_DB

    app.app_context().push()
    db.drop_all()
    db.create_all()
    return app


@pytest.fixture(scope='function')
def user(app):
    user = User()
    user.username = str(uuid.uuid4())
    user.uid = str(uuid.uuid4())
    g.jwt = {'sub': user.uid}
    db.session.add(user)
    db.session.commit()
    return user


@pytest.fixture(scope='function')
def admin(app):
    admin = User()
    admin.username = str(uuid.uuid4())
    admin.uid = str(uuid.uuid4())
    g.jwt = {'sub': admin.uid, 'scope': 'read:users'}
    db.session.add(admin)
    db.session.commit()
    return admin
