from typing import Dict
from .base import BaseModel
from .db import db, Column


class User(BaseModel):
    id = Column(db.Integer, primary_key=True,
                description="Unique ID for the user in the DB")
    username = Column(db.String(80), unique=True, nullable=False,
                      description="Username or email address for the user", required=True)
    uid = Column(db.String(80), unique=True, nullable=False,
                 description="UID attribute of the JWT provided by Auth0", required=True)
    account_id = Column(db.Integer, db.ForeignKey('account.id'), nullable=True,
                        description="Account ID this user has access to")
    account = db.relationship('Account', backref=db.backref('users', lazy=True))

    permissions = db.relationship('Permission')

    def __repr__(self):
        return '<User %r>' % self.username
