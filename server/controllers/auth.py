from flask import request, jsonify, g
from flask_restplus import Resource
from flask_injector import inject, request as request_scope
from injector import Module, Binder
from functools import wraps
from jose import jwt
from werkzeug.exceptions import Unauthorized, Forbidden
from .api import api
from ..service.user_service import UserService
from ..models.user import User
import json
import requests

authorizations = {
    'oauth2': {
        'type': 'oauth2',
        'flow': 'implicit',
        'authorizationUrl': 'https://kgrunwald.auth0.com/authorize?audience=https://api.stockbot.com',
        'scopes': {
            'read:users': 'Read all users'
        }
    }
}

api.authorizations = authorizations

AUTH0_DOMAIN = 'kgrunwald.auth0.com'
API_AUDIENCE = 'https://api.stockbot.com'
ALGORITHMS = ["RS256"]


def JWTUnauthorized(code: str, message: str) -> Unauthorized:
    e = Unauthorized()
    e.data = {'message': message, 'code': code}
    return e


def JWTForbidden(code: str, message: str) -> Forbidden:
    e = Forbidden()
    e.data = {'message': message, 'code': code}
    return e


def get_token_auth_header():
    """Obtains the Access Token from the Authorization Header"""
    auth = request.headers.get("Authorization", None)
    if not auth:
        raise JWTUnauthorized("authorization_header_missing", "Authorization header is expected")

    parts = auth.split()

    if parts[0].lower() != "bearer":
        raise JWTUnauthorized("invalid_header", "Authorization header must start with Bearer")
    elif len(parts) == 1:
        raise JWTUnauthorized("invalid_header", "Token not found")
    elif len(parts) > 2:
        raise JWTUnauthorized("invalid_header", "Authorization header must be Bearer token")

    token = parts[1]
    return token


def _jwt_validator():
    token = get_token_auth_header()
    key_response = requests.get("https://" + AUTH0_DOMAIN + "/.well-known/jwks.json")
    jwks = json.loads(key_response.text)
    unverified_header = jwt.get_unverified_header(token)
    rsa_key = {}
    for key in jwks["keys"]:
        if key["kid"] == unverified_header["kid"]:
            rsa_key = {
                "kty": key["kty"],
                "kid": key["kid"],
                "use": key["use"],
                "n": key["n"],
                "e": key["e"]
            }
    if rsa_key:
        try:
            payload = jwt.decode(
                token,
                rsa_key,
                algorithms=ALGORITHMS,
                audience=API_AUDIENCE,
                issuer="https://"+AUTH0_DOMAIN+"/"
            )
        except jwt.ExpiredSignatureError:
            raise JWTUnauthorized("token_expired", "token is expired")
        except jwt.JWTClaimsError:
            raise JWTUnauthorized("invalid_claims", "incorrect claim, check audience/issuer")
        except Exception:
            raise JWTUnauthorized("invalid_header", "Unable to parse authentication token.")

        g.jwt = payload
        return
    raise JWTUnauthorized("invalid_header", "Unable to find appropriate key")


def requires_auth(f):
    """Determines if the Access Token is valid"""
    @wraps(f)
    def decorated(*args, **kwargs):
        _jwt_validator()
        return f(*args, **kwargs)
    return decorated


def requires_scope(api, required_scope):
    """Determines if the required scope is present in the Access Token
    Args:
        required_scope (str): The scope required to access the resource
    """
    desc = 'Requires scope: `{}`'.format(required_scope)

    def scope_validator(f):
        @api.doc(description=desc, security={'oauth2': [required_scope]})
        @wraps(f)
        def decorated(*args, **kwargs):
            _jwt_validator()
            token = get_token_auth_header()
            unverified_claims = jwt.get_unverified_claims(token)
            if unverified_claims.get("scope"):
                token_scopes = unverified_claims["scope"].split()
                for token_scope in token_scopes:
                    if token_scope == required_scope:
                        return f(*args, **kwargs)
            raise JWTForbidden("invalid_header", "Unable to find appropriate scope")
        return decorated
    return scope_validator


class AuthUtils:
    @inject
    def __init__(self, user_svc: UserService):
        self.user_svc = user_svc

    def current_jwt(self):
        return g.jwt

    def current_user(self):
        if not hasattr(g, 'user') or g.user is None:
            jwt = self.current_jwt()
            g.user = self.user_svc.get_by_uid(jwt['sub'])
        return g.user


class AuthModule(Module):
    def configure(self, binder: Binder):
        binder.create_binding(AuthUtils, to=AuthUtils)


@api.doc(security='oauth2')
@api.response(401, 'Missing or invalid JWT')
@api.response(403, 'Missing or invalid API scopes')
class ProtectedResource(Resource):
    method_decorators = [requires_auth]
