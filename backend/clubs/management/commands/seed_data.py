from django.core.management.base import BaseCommand
from accounts.models import User
from clubs.models import Club
from events.models import Event
from datetime import date, time


class Command(BaseCommand):
    help = 'Seed database with sample clubs and events'

    def handle(self, *args, **kwargs):
        self.stdout.write(self.style.WARNING('Seeding data...'))

        admin = User.objects.get(username='love')

        # Create Clubs
        clubs_data = [
            ('Google Developer Group', 'Learn, connect, and grow as a developer.', 'Technical'),
            ('Music Club', 'For music lovers and performers.', 'Cultural'),
            ('Robotics Club', 'Build robots and compete.', 'Technical'),
            ('Photography Club', 'Capture the moment.', 'Arts'),
            ('Sports Club', 'Stay active and healthy.', 'Sports'),
        ]

        for name, desc, cat in clubs_data:
            club, created = Club.objects.get_or_create(
                name=name,
                defaults={
                    'description': desc,
                    'category': cat,
                    'coordinator': admin,
                }
            )
            club.members.add(admin)
            if created:
                self.stdout.write(self.style.SUCCESS(f'  Created club: {name}'))

        # Create Events
        gdg = Club.objects.get(name='Google Developer Group')
        music = Club.objects.get(name='Music Club')
        robotics = Club.objects.get(name='Robotics Club')

        events_data = [
            ('Flutter Workshop 2026', 'Learn Flutter from basics.', date(2026, 10, 25), time(10, 0), 'CS Building', 'Workshop', gdg, 50),
            ('Tech Hackathon 2026', '48-hour hackathon.', date(2026, 11, 5), time(9, 0), 'Auditorium', 'Hackathon', gdg, 100),
            ('AI & ML Seminar', 'Latest trends in AI.', date(2026, 10, 20), time(14, 0), 'Science Hall', 'Event', gdg, 80),
            ('Annual Music Night', 'Music performances.', date(2026, 11, 15), time(19, 0), 'Amphitheater', 'Club Activity', music, 200),
            ('Robotics Competition', 'Showcase your robot.', date(2026, 10, 30), time(10, 0), 'Engineering Hall', 'Hackathon', robotics, 60),
        ]

        for title, desc, d, t, venue, cat, club, max_p in events_data:
            event, created = Event.objects.get_or_create(
                title=title,
                defaults={
                    'description': desc,
                    'date': d,
                    'time': t,
                    'venue': venue,
                    'category': cat,
                    'club': club,
                    'organizer_name': club.name,
                    'max_participants': max_p,
                }
            )
            if created:
                self.stdout.write(self.style.SUCCESS(f'  Created event: {title}'))

        # Summary
        self.stdout.write('')
        self.stdout.write(self.style.SUCCESS('=' * 50))
        self.stdout.write(self.style.SUCCESS('DATABASE SUMMARY'))
        self.stdout.write(self.style.SUCCESS('=' * 50))
        self.stdout.write(f'Users: {User.objects.count()}')
        self.stdout.write(f'Clubs: {Club.objects.count()}')
        self.stdout.write(f'Events: {Event.objects.count()}')
        self.stdout.write(self.style.SUCCESS('=' * 50))
        self.stdout.write(self.style.SUCCESS('Sample data created successfully!'))
