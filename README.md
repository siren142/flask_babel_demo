# Flask-Babel multilingual demo

A content-focused Flask demo that showcases localisation in templates and Python backend code.

## Included

- 8 application views plus translated 404 and 500 pages
- English source language
- German, French, and Italian translations
- 209 unique localisation strings
- Short fragments, labels, headings, and complete sentences
- Template strings using Jinja `_(...)`
- Backend strings using `gettext(...)` and `lazy_gettext(...)`
- A translated POST workflow with validation and flash messages
- Compiled `.mo` files, so the app runs without an initial Babel compilation step

## Run locally

```bash
python -m venv .venv
# Windows
.venv\Scripts\activate
# macOS/Linux
source .venv/bin/activate

pip install -r requirements.txt
flask --app run.py run --debug
```

Open `http://127.0.0.1:5000`.

Switch language with the links in the header or by adding `?lang=de`, `?lang=fr`, or `?lang=it`.

## Translation workflow

Extract source messages:

```bash
pybabel extract -F babel.cfg -o messages.pot .
```

Update existing catalogues:

```bash
pybabel update -i messages.pot -d translations
```

Compile catalogues:

```bash
pybabel compile -d translations
```

## Where localisation appears

- `app/templates/*.html`: navigation, headings, buttons, form labels, paragraphs, errors, and dashboard labels
- `app/routes.py`: plans, metrics, project status, activity updates, validation errors, and success messages
- `app/content.py`: feature cards, solution descriptions, and resource content via `lazy_gettext`

The project intentionally keeps CSS minimal so the example remains focused on Flask-Babel.
