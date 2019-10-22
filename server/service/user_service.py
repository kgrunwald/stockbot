from ..models import User, db
from sqlalchemy.exc import IntegrityError
from werkzeug.exceptions import BadRequest


class UserService:
    def create(self, user_id, data):
        user = User()
        user.username = data['username']
        user.uid = user_id

        try:
            db.session.add(user)
            db.session.commit()
            user.add_acl(user)
        except IntegrityError:
            raise BadRequest('A user with that information already exists')
        return user

    def get_all(self):
        return User.query.all()

    def get(self, id):
        user = User.query.get_or_404(id)
        user.add_acl(user)
        return user

    def get_by_uid(self, uid):
        return User.query.filter_by(uid=uid).first_or_404()
