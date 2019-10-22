from sqlalchemy.ext.declarative import declared_attr
from .db import db, Column


class BaseModel(db.Model):
    __abstract__ = True

    created = Column(db.DateTime, server_default=db.func.now(), description="Updated timestamp")
    updated = Column(db.DateTime, onupdate=db.func.now(), description="Updated timestamp")


class Permission(BaseModel):
    id = Column(db.Integer, primary_key=True)
    acl_id = Column(db.Integer, db.ForeignKey('acl.id'), nullable=False)
    user_id = Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    user = db.relationship('User', uselist=False)
    permission = Column(db.String, nullable=False, default='read')

    def __repr__(self):
        return '<Permission {} {} {}>'.format(self.user.username, self.permission, self.acl_id)


class ACL(BaseModel):
    __tablename__ = 'acl'

    id = Column(db.Integer, primary_key=True)
    permissions = db.relationship('Permission', backref='acl', lazy=True)


class ProtectedModel(BaseModel):
    __abstract__ = True

    @declared_attr
    def acl(self):
        return db.relationship('ACL', uselist=False)

    @declared_attr
    def acl_id(self):
        return Column(db.Integer, db.ForeignKey('acl.id'))

    def add_acl(self, user, permission='read') -> ACL:
        if self.acl is None:
            self.acl = ACL()
            db.session.add(self.acl)

        for perm in self.acl.permissions:
            if perm.user_id == user.id and perm.permission == permission:
                return self.acl

        p = Permission()
        p.user = user
        p.permission = permission
        self.acl.permissions.append(p)
        return self.acl
