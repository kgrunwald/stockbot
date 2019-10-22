from typing import Dict
from .base import ProtectedModel
from .db import db, Column


class Account(ProtectedModel):
    id = Column(db.Integer, primary_key=True,
                description="Unique ID for the account in the database", required=True)
    api_key = Column(db.String(80), unique=True, nullable=False,
                     description="The Alpaca API Key", required=True)
    secret_key = Column(db.String(80), nullable=False,
                        description="The Alpaca API Secret Key", required=True)

    def __repr__(self):
        return '<Account %r>' % self.id
