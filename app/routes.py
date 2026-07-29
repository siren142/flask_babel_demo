from flask import Blueprint, flash, redirect, render_template, request, url_for
from flask_babel import gettext as _
from .content import CATALOGUE, FEATURES, LOCALISATION_DEMO_COPY, RESOURCES, SOLUTIONS

bp = Blueprint("main", __name__)

@bp.get("/")
def home():
    return render_template("home.html", features=FEATURES[:6])

@bp.get("/platform")
def platform():
    return render_template("platform.html", features=FEATURES)

@bp.get("/solutions")
def solutions():
    return render_template("solutions.html", solutions=SOLUTIONS)

@bp.get("/pricing")
def pricing():
    plans = [
        {"name": _("Starter"), "price": 19, "description": _("For small teams testing a connected workflow."), "features": [_('Up to 5 users'), _('Core workflows'), _('Email support')]},
        {"name": _("Growth"), "price": 59, "description": _("For growing teams coordinating multiple campaigns."), "features": [_('Up to 25 users'), _('Advanced automation'), _('Custom dashboards'), _('Priority support')]},
        {"name": _("Enterprise"), "price": None, "description": _("For organisations with advanced governance needs."), "features": [_('Unlimited users'), _('Single sign-on'), _('Audit export'), _('Dedicated success manager')]},
    ]
    return render_template("pricing.html", plans=plans)

@bp.get("/resources")
def resources():
    return render_template("resources.html", resources=RESOURCES)

@bp.get("/about")
def about():
    return render_template("about.html", localisation_copy=LOCALISATION_DEMO_COPY)

@bp.route("/contact", methods=["GET", "POST"])
def contact():
    if request.method == "POST":
        required = [request.form.get("first_name", "").strip(), request.form.get("last_name", "").strip(), request.form.get("email", "").strip(), request.form.get("message", "").strip()]
        if not all(required):
            flash(_("Please complete all required fields."), "error")
        elif "@" not in required[2]:
            flash(_("Please enter a valid email address."), "error")
        else:
            flash(_("Thank you, %(name)s. Your message has been received.", name=required[0]), "success")
            return redirect(url_for("main.contact"))
    return render_template("contact.html")

@bp.get("/catalogue")
def catalogue():
    return render_template("catalogue.html", catalogue=CATALOGUE)

@bp.get("/dashboard")
def dashboard():
    metrics = [
        (_("Active campaigns"), 12), (_("Open reviews"), 7),
        (_("Local markets online"), 4), (_("Tasks due this week"), 18),
    ]
    projects = [
        (_("Spring product launch"), _("On track")),
        (_("Customer welcome series"), _("Needs review")),
        (_("Regional brand update"), _("At risk")),
    ]
    updates = [
        (_("Today"), _("Three approvals are waiting for your decision.")),
        (_("Yesterday"), _("The Italian landing page is ready for final review.")),
        (_("This week"), _("A campaign owner changed the launch date.")),
    ]
    return render_template("dashboard.html", metrics=metrics, projects=projects, updates=updates)

@bp.app_errorhandler(404)
def not_found(error):
    return render_template("404.html"), 404

@bp.app_errorhandler(500)
def server_error(error):
    return render_template("500.html"), 500
