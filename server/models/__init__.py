from flask_restplus import fields, Model
from .db import db
from .user import User


def modelize(cls, api):
    attrs = tuple(set(dir(cls)) - set(dir(db.Model)))
    attrs = [attr for attr in attrs if not attr.startswith("_")]
    attr_dict = {}
    for attr in attrs:
        definition = getattr(cls, attr).property.columns[0].type.__repr__()
        if definition.startswith('String'):
            attr_dict[attr] = fields.String()
        elif definition.startswith('Integer'):
            attr_dict[attr] = fields.Integer()
        else:
            raise 'Unkown field type ' + definition
    name = cls.__tablename__.capitalize()
    return api.model(name, attr_dict)
