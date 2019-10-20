from .db import db


class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    uid = db.Column(db.String(80), unique=True, nullable=False)

    def __repr__(self):
        return '<User %r %r>' % self.username, self.uid
