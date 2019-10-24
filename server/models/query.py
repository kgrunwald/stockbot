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

    protected_entites = []
    for desc in query.column_descriptions:
        entity = desc['entity']
        if issubclass(entity, ProtectedModel):
            protected_entites.append(entity)
        elif entity == User:
            protected_entites.append(entity)

    if len(protected_entites) > 0:
        jwt = g.jwt
        for entity in protected_entites:
            if 'scope' in jwt.keys():
                scope = 'read:{}'.format(entity.__tablename__.lower())
                if scope in jwt['scope']:
                    return query

            if entity == User:
                query = query.filter(entity.uid == jwt['sub'])
            else:
                user = admin_query().filter_by(uid=jwt['sub']).first()
                acl_ids = [p.acl_id for p in user.permissions if p.permission == 'read']
                query = query.filter(entity.acl_id.in_(acl_ids))
    return query
