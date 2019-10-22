from flask_restplus import fields, Model
from .db import db
from .user import User
from .account import Account
from .base import ACL
from .query import *


def modelize(cls, api):
    attrs = tuple(set(dir(cls)) - set(dir(db.Model)))
    attrs = [attr for attr in attrs if not attr.startswith(
        "_") and not attr.startswith('acl') and not attr.startswith('add_acl')]
    attr_dict = {}
    for attr in attrs:
        definition = getattr(cls, attr)
        if hasattr(definition, 'description'):
            field_type = definition.property.columns[0].type.__repr__()
            if field_type.startswith('String'):
                attr_dict[attr] = fields.String(
                    description=definition.description, required=definition.required)
            elif field_type.startswith('Integer'):
                attr_dict[attr] = fields.Integer(
                    description=definition.description, required=definition.required)
            elif field_type.startswith('DateTime'):
                attr_dict[attr] = fields.DateTime(
                    description=definition.description, required=definition.required)
            else:
                raise 'Unkown field type ' + definition
        else:
            print("Skipping relationship when building response model")
    name = cls.__tablename__.capitalize()
    return api.model(name, attr_dict)
