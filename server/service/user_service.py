from ..models import User, db
from sqlalchemy.exc import IntegrityError
from werkzeug.exceptions import BadRequest


class UserService:
    def create(self, data):
        user = User()
        user.username = data['username']
        user.uid = data['uid']

        try:
            db.session.add(user)
            db.session.commit()
        except IntegrityError:
            raise BadRequest('A user with that information already exists')
        return user

    def get_all(self):
        return User.query.all()

    def get(self, id):
        return User.query.get_or_404(id)
