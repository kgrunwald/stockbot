from .db import db
from typing import Dict


class FieldDef:
    def __init__(self, description, required=False):
        self.description = description
        self.required = required


class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    uid = db.Column(db.String(80), unique=True, nullable=False)

    def __repr__(self):
        return '<User %r %r>' % self.username, self.uid

    @classmethod
    def field_defs(self) -> Dict[str, FieldDef]:
        return {
            'id': FieldDef("Unique ID for the user in the database", False),
            'username': FieldDef("The user's email address or username", True),
            'uid': FieldDef('The uid for this user from the Auth0 SSO system', True)
        }
