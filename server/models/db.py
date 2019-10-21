from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()


class Column(db.Column):
    def __init__(self, *args, **kwargs):
        self.description = kwargs.pop('description', '')
        self.required = kwargs.pop('required', False)
        super().__init__(*args, **kwargs)
