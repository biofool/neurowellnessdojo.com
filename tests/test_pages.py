"""
Local integration tests for neurowellnessdojo.com.

Requires: pip install pytest requests
Run with: pytest tests/ from the project root.

Starts a PHP built-in server against the local site root.
Note: .htaccess rules (deny config.php, deny includes/) are not enforced
by php -S — those protections are server-only and not tested here.
"""

import re
import subprocess
import time
import os
import pytest
import requests

SITE_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PORT = 8765
BASE = f"http://localhost:{PORT}"
PHP_ERROR_MARKERS = ("Fatal error", "Parse error", "Warning:", "Notice:", "Deprecated:")


@pytest.fixture(scope="session", autouse=True)
def php_server():
    proc = subprocess.Popen(
        ["php", "-S", f"localhost:{PORT}", "-t", SITE_ROOT],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    time.sleep(0.8)
    if proc.poll() is not None:
        raise RuntimeError("PHP built-in server failed to start")
    yield proc
    proc.terminate()
    proc.wait()


def has_php_errors(text: str) -> bool:
    return any(m in text for m in PHP_ERROR_MARKERS)


def csrf_from(html: str) -> str | None:
    m = re.search(r'name="csrf"\s+value="([^"]+)"', html)
    return m.group(1) if m else None


# ---------------------------------------------------------------------------
# Page rendering
# ---------------------------------------------------------------------------

def test_home_200():
    r = requests.get(f"{BASE}/")
    assert r.status_code == 200
    assert not has_php_errors(r.text)
    assert "Neuro Wellness Dojo" in r.text


def test_home_shows_code_gate_when_locked():
    r = requests.get(f"{BASE}/")
    assert "access_code" in r.text
    assert "Referral code" in r.text


def test_home_unlocks_with_correct_code():
    s = requests.Session()
    r = s.post(f"{BASE}/", data={"access_code": "DrClemans"})
    assert r.status_code == 200
    assert not has_php_errors(r.text)
    assert "Request your free session" in r.text


def test_home_shows_error_on_wrong_code():
    s = requests.Session()
    r = s.post(f"{BASE}/", data={"access_code": "wrong"})
    assert r.status_code == 200
    assert "wasn't recognized" in r.text


def test_contact_200():
    r = requests.get(f"{BASE}/contact.php")
    assert r.status_code == 200
    assert not has_php_errors(r.text)
    assert "Contact" in r.text


def test_contact_has_intake_form():
    r = requests.get(f"{BASE}/contact.php")
    assert 'name="name"' in r.text
    assert 'name="email"' in r.text
    assert 'name="csrf"' in r.text


def test_privacy_200():
    r = requests.get(f"{BASE}/privacy.php")
    assert r.status_code == 200
    assert not has_php_errors(r.text)
    assert "Privacy" in r.text


def test_thankyou_200():
    r = requests.get(f"{BASE}/thank-you.php")
    assert r.status_code == 200
    assert not has_php_errors(r.text)
    assert "Thanks" in r.text


def test_404_page_returns_404():
    r = requests.get(f"{BASE}/404.php")
    assert r.status_code == 404
    assert not has_php_errors(r.text)
    assert "Page not found" in r.text


# ---------------------------------------------------------------------------
# submit.php security
# ---------------------------------------------------------------------------

def test_submit_rejects_get():
    r = requests.get(f"{BASE}/submit.php")
    assert r.status_code == 405


def test_submit_rejects_missing_csrf():
    r = requests.post(f"{BASE}/submit.php", data={
        "name": "Test",
        "email": "test@example.com",
        "variant": "A",
    })
    assert r.status_code == 400


def test_submit_rejects_wrong_csrf():
    r = requests.post(f"{BASE}/submit.php", data={
        "csrf": "deadbeef00000000",
        "name": "Test",
        "email": "test@example.com",
        "variant": "A",
    })
    assert r.status_code == 400


def test_honeypot_gives_silent_redirect():
    s = requests.Session()
    page = s.get(f"{BASE}/contact.php")
    csrf = csrf_from(page.text)
    assert csrf is not None, "No CSRF token found on contact page"
    r = s.post(f"{BASE}/submit.php", data={
        "csrf": csrf,
        "name": "Bot",
        "email": "bot@example.com",
        "variant": "A",
        "website": "http://spam.com",  # honeypot field filled
    }, allow_redirects=False)
    assert r.status_code == 302
    assert "/thank-you.php" in r.headers.get("Location", "")
