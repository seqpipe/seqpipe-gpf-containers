import os
import sys

# Add the app's directory to the PYTHONPATH
sys.path.append('/code/gpf/gpf/wdae')
sys.path.append('/code/gpf/gpf/dae')

os.environ['DJANGO_SETTINGS_MODULE'] = 'wdae.settings'
os.environ['DAE_DB_DIR'] = '/data'


# import django.core.handlers.wsgi
# application = django.core.handlers.wsgi.WSGIHandler()

from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()
