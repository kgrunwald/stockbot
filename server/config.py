import os

SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or 'sqlite:////tmp/test.db'
SQLALCHEMY_TRACK_MODIFICATIONS = False
