import os
from .default_settings import *

INSTALLED_APPS = [
    "rest_framework",
    "rest_framework.authtoken",
    "guardian",
    "django.contrib.admin",
    "django.contrib.messages",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.staticfiles",
    "django.contrib.sessions",
    "utils",
    "gpf_instance",
    "gene_weights",
    "gene_sets",
    "datasets_api",
    "genotype_browser",
    "enrichment_api",
    "measures_api",
    "family_counters_api",
    "pheno_browser_api",
    "common_reports_api",
    "pheno_tool_api",
    "users_api",
    "groups_api",
    # 'gpfjs',
    "chromosome",
    "query_state_save",
    "user_queries",
]

SECRET_KEY = os.environ.get("WDAE_SECRET_KEY")

DEBUG = os.environ.get("WDAE_DEBUG", "False") == "True"

''' Set these for production'''
#
PHENO_BROWSER_BASE_URL = "/gpf19/static/"

EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
if os.environ.get("WDAE_EMAIL_HOST", None):
    EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
    EMAIL_HOST = os.environ.get("WDAE_EMAIL_HOST", None)

    DEFAULT_FROM_EMAIL = os.environ.get("WDAE_DEFAULT_FROM_EMAIL", None)
    EMAIL_HOST_USER = os.environ.get("WDAE_EMAIL_HOST_USER", None)
    EMAIL_HOST_PASSWORD = os.environ.get("WDAE_EMAIL_HOST_PASSWORD", None)

    EMAIL_PORT = os.environ.get("WDAE_EMAIL_PORT", None)
    EMAIL_SUBJECT_PREFIX = '[GPF] '
    EMAIL_USE_TLS = True


EMAIL_VERIFICATION_HOST = "https://{{ sparkgpf_public_name}}/{{ prefix }}"
EMAIL_VERIFICATION_PATH = '/(popup:validate/{})'
# EMAIL_OVERRIDE = ['lubomir.chorbadjiev@gmail.com']

DEFAULT_RENDERER_CLASSES = [
    "rest_framework.renderers.JSONRenderer",
]

if DEBUG:
    DEFAULT_RENDERER_CLASSES = DEFAULT_RENDERER_CLASSES + \
        ["rest_framework.renderers.BrowsableAPIRenderer", ]

REST_FRAMEWORK = {
    'PAGINATE_BY': 10,
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'users_api.authentication.SessionAuthenticationWithoutCSRF',
    ),
    'DEFAULT_RENDERER_CLASSES': DEFAULT_RENDERER_CLASSES
}

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': os.environ.get("WDAE_DB_NAME"),
        'USER': os.environ.get("WDAE_DB_USER"),
        'PASSWORD': os.environ.get("WDAE_DB_PASSWORD"),
        'HOST': os.environ.get("WDAE_DB_HOST"),
        'PORT': os.environ.get("WDAE_DB_PORT"),
    }
}

PRELOAD_ACTIVE = True

ALLOWED_HOSTS = [
    os.environ.get("WDAE_ALLOWED_HOST")
]

TIME_ZONE = "US/Eastern"

STATIC_ROOT = '/code/gpf/static'


PRECOMPUTE_CONFIG = {
    'synonymousBackgroundModel':
    'enrichment_api.background_precompute.SynonymousBackgroundPrecompute',
    'codingLenBackgroundModel':
    'enrichment_api.background_precompute.CodingLenBackgroundPrecompute',
    'samochaBackgroundModel':
    'enrichment_api.background_precompute.SamochaBackgroundPrecompute',
    'variant_reports':
    'common_reports_api.variants.VariantReports',
    'studies_summaries':
    'common_reports_api.studies.StudiesSummaries',
    'datasets': 'datasets_api.datasets_preload.DatasetsPreload',
}

PRELOAD_CONFIG = {
    'gene_sets_collections':
    'gene_sets.preloaded_gene_sets.GeneSetsCollectionsPreload',
    'gene_weights': 'gene_weights.weights.Weights',
    'genomic_scores': 'genomic_scores_api.scores.Scores',
    'datasets': 'datasets_api.datasets_preload.DatasetsPreload',

}


LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'filters': {
        'require_debug_false': {
            '()': 'django.utils.log.RequireDebugFalse'
        }
    },
    'formatters': {
        'verbose': {
            'format': '%(levelname)s %(asctime)s %(module)s %(process)d %(thread)d %(message)s'
        },
        'simple': {
            'format': '%(levelname)s %(message)s'
        },
    },
    'handlers': {
        'console': {
            'level': 'INFO',
            'class': 'logging.StreamHandler',
            'formatter': 'verbose'
        },
        'mail_admins': {
            'level': 'ERROR',
            'filters': ['require_debug_false'],
            'class': 'django.utils.log.AdminEmailHandler'
        },
        # Log to a text file that can be rotated by logrotate
        'logfile': {
            'class': 'logging.handlers.WatchedFileHandler',
            'filename': '/code/gpf/logs/wdae-api.log',
            'formatter': 'verbose',
        },
        'logdebug': {
            'class': 'logging.handlers.WatchedFileHandler',
            'filename': '/code/gpf/logs/wdae-debug.log',
            'formatter': 'verbose',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['console', 'logfile'],
            'propagate': True,
            'level': 'WARN',
        },
        'django.request': {
            'handlers': ['console', 'logfile'],
            'level': 'WARN',
            'propagate': True,
        },
        'wdae.api': {
            'handlers': ['console', 'logfile'],
            'level': 'INFO',
            'propagate': True,
        },
        '': {
            'handlers': ['console', 'logdebug'],  # 'logfile'],
            'level': 'DEBUG',
            'propagate': True,
        },

    }
}


CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.filebased.FileBasedCache',
        'LOCATION': '/code/gpf/cache/wdae_django_default.cache',
        'TIMEOUT': 3600,
        'OPTIONS': {
            'MAX_ENTRIES': 10000
        }
    },

    'long': {
        'BACKEND': 'django.core.cache.backends.filebased.FileBasedCache',
        'LOCATION': '/code/gpf/cache/wdae_django_default.cache',
        'TIMEOUT': 86400,
        'OPTIONS': {
            'MAX_ENTRIES': 1000,
        }
    },


    'pre': {
        'BACKEND': 'django.core.cache.backends.filebased.FileBasedCache',
        'LOCATION': '/code/gpf/cache/wdae_django_pre.cache',
        'TIMEOUT': None,
    },

    'enrichment': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        'LOCATION': 'unique-snowflake',
        'TIMEOUT': 60,
    },
}


PRECOMPUTE_CONFIG = {
    'synonymousBackgroundModel':
    'enrichment_api.background_precompute.SynonymousBackgroundPrecompute',
    'codingLenBackgroundModel':
    'enrichment_api.background_precompute.CodingLenBackgroundPrecompute',
    'samochaBackgroundModel':
    'enrichment_api.background_precompute.SamochaBackgroundPrecompute',
    # 'denovo_gene_sets':
    # 'api.gene_sets.denovo.PrecomputeDenovoGeneSets',
    'variant_reports':
    'common_reports_api.variants.VariantReports',
    'studies_summaries':
    'common_reports_api.studies.StudiesSummaries',
    'datasets': 'datasets_api.datasets_preload.DatasetsPreload',
}

STATIC_URL = '/dae/static/'
