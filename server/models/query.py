from sqlalchemy.orm.query import Query
from sqlalchemy import event
from flask import g
from .user import User
from .base import ProtectedModel


def admin_query():
    q = User.query
    setattr(q, '__is_admin', True)
    return q


@event.listens_for(Query, 'before_compile', retval=True)
def acl_check(query: Query):
    if hasattr(query, '__is_admin'):
        return query

    protected_entites = get_protected_entities(query)

    if len(protected_entites) > 0:
        jwt = g.jwt
        for entity in protected_entites:
            scope = 'read:{}'.format(entity.__tablename__.lower())
            if validate_scope(jwt, scope):
                continue

            if entity == User:
                query = query.filter(entity.uid == jwt['sub'])
            else:
                acls = get_acls(jwt, 'read')
                query = query.filter(entity.acl_id.in_(acls))
    return query


def validate_scope(jwt: dict, scope: str) -> bool:
    if 'scope' in jwt.keys():
        if scope in jwt['scope']:
            return True
    return False


def get_acls(jwt: dict, permission: str) -> [str]:
    user = admin_query().filter_by(uid=jwt['sub']).first()
    return [p.acl_id for p in user.permissions if p.permission == permission]


def get_protected_entities(query: Query):
    entities = []
    for desc in query.column_descriptions:
        entity = desc['entity']
        if issubclass(entity, ProtectedModel):
            entities.append(entity)
        elif entity == User:
            entities.append(entity)
    return entities
