#!/usr/bin/env bash
set -o errexit

echo "═══ Installing dependencies ═══"
pip install --upgrade pip
pip install -r backend/requirements.txt

echo "═══ Collecting static files ═══"
python3 backend/manage.py collectstatic --no-input

echo "═══ Running migrations ═══"
python3 backend/manage.py migrate

echo "═══ Build complete ═══"
