from sqlalchemy.ext.declarative import declared_attr
from .db import db, Column


class Permission(db.Model):
    id = Column(db.Integer, primary_key=True)
    acl_id = Column(db.Integer, db.ForeignKey('acl.id'), nullable=False)
    user_id = Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    user = db.relationship('User', uselist=False)
    permission = Column(db.String, nullable=False, default='read')


class ACL(db.Model):
    __tablename__ = 'acl'

    id = Column(db.Integer, primary_key=True)
    permissions = db.relationship('Permission', backref='acl', lazy=True)


class ProtectedModel(object):
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
        db.session.commit()
        self.acl_id = self.acl.id
        return self.acl
