from sqlalchemy.orm.query import Query
from sqlalchemy import event
from flask import g
from .user import User
from .base import ProtectedModel


@event.listens_for(Query, 'before_compile', retval=True)
def acl_check(query: Query):
    protected_entites = []
    for desc in query.column_descriptions:
        entity = desc['entity']
        if issubclass(entity, ProtectedModel):
            protected_entites.append(entity)

    if len(protected_entites) > 0:
        user = User.query.filter_by(uid=g.jwt['sub']).first()
        acl_ids = [p.acl_id for p in user.permissions if p.permission == 'read']
        for entity in protected_entites:
            query = query.filter(entity.acl_id.in_(acl_ids))
    return query
