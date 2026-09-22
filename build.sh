#!/usr/bin/env bash
set -o errexit

echo "═══ Installing dependencies ═══"
pip install --upgrade pip
pip install -r backend/requirements.txt

echo "═══ Collecting static files ═══"
python3 backend/manage.py collectstatic --no-input

echo "═══ Running migrations ═══"
python3 backend/manage.py migrate

echo "═══ Creating/resetting superuser ═══"
python3 backend/manage.py shell -c "
from accounts.models import User
user, created = User.objects.get_or_create(
    username='love80295',
    defaults={
        'email': 'loveagrawal80295@gmail.com',
        'is_superuser': True,
        'is_staff': True,
    }
)
user.set_password('@Luv80295')
user.is_superuser = True
user.is_staff = True
user.email = 'loveagrawal80295@gmail.com'
user.save()
if created:
    print('✅ Superuser created: love80295')
else:
    print('✅ Superuser password reset: love80295')
"

echo "═══ Build complete ═══"
