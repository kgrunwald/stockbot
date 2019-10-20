from flask import request, jsonify, _request_ctx_stack
from functools import wraps
from jose import jwt
from werkzeug.exceptions import Unauthorized, Forbidden
import json
import requests

authorizations = {
    'apikey': {
        'type': 'apiKey',
        'in': 'header',
        'name': 'X-API-Key'
    }
}

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

        _request_ctx_stack.top.current_user = payload
        return
    raise JWTUnauthorized("invalid_header", "Unable to find appropriate key")


def requires_auth(f):
    """Determines if the Access Token is valid"""
    @wraps(f)
    def decorated(*args, **kwargs):
        _jwt_validator()
        return f(*args, **kwargs)
    return decorated


def requires_scope(required_scope):
    """Determines if the required scope is present in the Access Token
    Args:
        required_scope (str): The scope required to access the resource
    """
    def scope_validator(f):
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
