from flask.testing import Client
from pytest_flask.plugin import JSONResponse
import json


def test_token(client: Client, headers):
    response = client.get("/api/users/", headers=headers)
    assert response.status_code == 200


def test_create_users(client: Client, headers):
    response = client.post('/api/users/', headers=headers, data=json.dumps({'username': 'kgrunwald@gmail.com'}))
    assert response.status_code == 201

    users_response = client.get("/api/users/", headers=headers)
    assert users_response.status_code == 200
    users = users_response.json
    assert len(users) == 1

    user = users[0]
    assert user['username'] == 'kgrunwald@gmail.com'
    assert user['id'] == 1
    assert user['uid'] == '3hZaX0QPDNs1RdgB2SJxvfx0km6zJSZ7@clients'
    assert user['created'] is not None


def test_me(client: Client, headers):
    response = client.get('/api/me', headers=headers)
    assert response.status_code == 200

    user = response.json
    assert user['username'] == 'kgrunwald@gmail.com'
    assert user['id'] == 1
    assert user['uid'] == '3hZaX0QPDNs1RdgB2SJxvfx0km6zJSZ7@clients'
    assert user['created'] is not None
