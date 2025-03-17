import os
from dotenv import load_dotenv

load_dotenv()
class Settings:
    # Project Config
    PROJECT_NAME = os.getenv('PROJECT_NAME', 'MyProject')
    PROJECT_VERSION = os.getenv('PROJECT_VERSION', '1.0.0')
    PROJECT_DESCRIPTION = os.getenv('PROJECT_DESCRIPTION', 'A sample project')
    PROJECT_URL = os.getenv('PROJECT_URL', 'http://localhost:8000')
    PROJECT_API_PREFIX = os.getenv('PROJECT_API_PREFIX', '/api')
    PROJECT_API_VERSION = os.getenv('PROJECT_API_VERSION', 'v1')
    PROJECT_DOCS_URL = os.getenv('PROJECT_DOCS_URL', '/docs')
    PROJECT_REDOC_URL = os.getenv('PROJECT_REDOC_URL', '/redoc')

    # General Config
    SECRET_KEY = os.getenv('SECRET_KEY', 'your_secret_key')
    DEBUG = os.getenv('DEBUG', 'False') == 'True'
    TESTING = os.getenv('TESTING', 'False') == 'True'
    ENV = os.getenv('ENV', 'production')
    

settings = Settings()
    
