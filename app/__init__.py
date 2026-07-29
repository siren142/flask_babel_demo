from flask import Flask, request, session
from flask_babel import Babel, get_locale

babel = Babel()
SUPPORTED_LANGUAGES = {"en": "English", "de": "Deutsch", "fr": "Français", "it": "Italiano"}

def select_locale():
    requested = request.args.get("lang")
    if requested in SUPPORTED_LANGUAGES:
        session["language"] = requested
    return session.get("language") or request.accept_languages.best_match(SUPPORTED_LANGUAGES) or "en"

def create_app(test_config=None):
    app = Flask(__name__)
    app.config.from_mapping(SECRET_KEY="dev-only-change-me", BABEL_DEFAULT_LOCALE="en", BABEL_TRANSLATION_DIRECTORIES="../translations")
    if test_config:
        app.config.update(test_config)
    babel.init_app(app, locale_selector=select_locale)
    from .routes import bp
    app.register_blueprint(bp)
    app.jinja_env.globals.update(
        supported_languages=SUPPORTED_LANGUAGES,
        get_locale=get_locale,
    )
    return app
