from flask_restplus import fields, Model
from .db import db
from .user import User


def modelize(cls, api):
    attrs = tuple(set(dir(cls)) - set(dir(db.Model)))
    attrs = [attr for attr in attrs if not attr.startswith("_") and attr != 'field_defs']
    attr_dict = {}
    for attr in attrs:
        definition = getattr(cls, attr).property.columns[0].type.__repr__()
        field_def = cls.field_defs()[attr] if attr in cls.field_defs().keys() else {}
        if definition.startswith('String'):
            attr_dict[attr] = fields.String(description=field_def.description, required=field_def.required)
        elif definition.startswith('Integer'):
            attr_dict[attr] = fields.Integer(description=field_def.description, required=field_def.required)
        else:
            raise 'Unkown field type ' + definition
    name = cls.__tablename__.capitalize()
    return api.model(name, attr_dict)
