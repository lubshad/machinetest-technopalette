from django.db import migrations
from django.contrib.auth.hashers import make_password
import random

def create_sample_profiles(apps, schema_editor):
    User = apps.get_model('auth', 'User')
    UserProfile = apps.get_model('user_profile', 'UserProfile')

    first_names_female = ["Emma", "Olivia", "Ava", "Isabella", "Sophia"]
    first_names_male = ["Liam", "Noah", "Oliver", "Elijah", "William"]
    
    last_names = [
        "Smith", "Johnson", "Williams", "Brown", "Jones", 
        "Garcia", "Miller", "Davis", "Rodriguez", "Martinez",
        "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", 
        "Thomas", "Taylor", "Moore", "Jackson", "Martin"
    ]
    
    cities = [
        'New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix', 
        'Philadelphia', 'San Antonio', 'San Diego', 'Dallas', 'San Jose',
        'Austin', 'Jacksonville', 'Fort Worth', 'Columbus', 'Charlotte'
    ]
    
    street_types = ['Street', 'Avenue', 'Road', 'Lane', 'Drive', 'Court', 'Boulevard']
    states = ['California', 'New York', 'Texas', 'Florida', 'Washington', 'Illinois', 'Georgia']
    
    family_types = ['nuclear', 'joint']
    family_statuses = ['middle_class', 'upper_middle_class', 'rich']
    
    def generate_phone():
        return f"+1{random.randint(200, 999)}{random.randint(200, 999)}{random.randint(1000, 9999)}"

    # Profile Images from constants.dart
    profile_images = [
        "https://images.unsplash.com/photo-1712847331947-9460dd2f264b?w=800&auto=format&fit=crop&q=60",
        "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&auto=format&fit=crop&q=60",
        "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800&auto=format&fit=crop&q=60",
        "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=800&auto=format&fit=crop&q=60",
        "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=800&auto=format&fit=crop&q=60",
        "https://images.unsplash.com/photo-1580489944761-15a19d654956?w=800&auto=format&fit=crop&q=60",
        "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=800&auto=format&fit=crop&q=60",
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&auto=format&fit=crop&q=60",
        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800&auto=format&fit=crop&q=60",
        "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800&auto=format&fit=crop&q=60",
    ]

    # bios
    female_bios = [
        "Software engineer by day, amateur painter by night. Looking for someone who appreciates both logic and creativity.",
        "Passionate traveler and foodie. I've been to 15 countries and counting! Hope to find a partner for my next adventure.",
        "Nature lover who enjoys hiking and weekend camping trips. Family-oriented and looking for something meaningful.",
        "Lifelong learner and bookworm. Always curious about the world. Seeking someone kind and intellectually stimulating.",
        "Yoga enthusiast with a love for spicy food and classic cinema. Excited to meet someone who values health and happiness."
    ]
    
    male_bios = [
        "Entrepreneur with a passion for tech and fitness. Believe in hard work and having a good sense of humor.",
        "Architect who loves old buildings and modern art. Enjoy weekend cycles and cooking for friends.",
        "Data scientist who spends too much time thinking about AI. Looking for someone to share coffee and meaningful conversations.",
        "High school teacher and basketball coach. Love working with kids and being active outdoors.",
        "Musician and dog lover. Spend my free time playing guitar and exploring local parks. Seeking a kind soul."
    ]

    # Generate 5 Female profiles
    for i in range(5):
        first_name = first_names_female[i]
        last_name = random.choice(last_names)
        username = f"{first_name.lower()}_{i+1}"
        email = f"{username}@example.com"
        
        user, created = User.objects.get_or_create(
            username=username,
            defaults={
                'first_name': first_name,
                'last_name': last_name,
                'email': email,
                'password': make_password('password123')
            }
        )

        UserProfile.objects.get_or_create(
            user=user,
            defaults={
                'gender': 'Female',
                'photo': profile_images[i],
                'phone_number': generate_phone(),
                'address_line1': f"{random.randint(100, 9999)} {random.choice(last_names)} {random.choice(street_types)}",
                'address_line2': random.choice(['Apt 4B', 'Suite 102', 'Unit 7', '', 'Floor 2']),
                'city': random.choice(cities),
                'state': random.choice(states),
                'country': 'USA',
                'postal_code': f"{random.randint(10000, 99999)}",
                'bio': female_bios[i],
                'height': round(random.uniform(155.0, 175.0), 2),
                'weight': round(random.uniform(50.0, 70.0), 2),
                'father_name': f"{random.choice(first_names_male)} {last_name}",
                'mother_name': f"{random.choice(first_names_female)} {last_name}",
                'siblings': random.randint(0, 3),
                'family_type': random.choice(family_types),
                'family_status': random.choice(family_statuses),
            }
        )

    # Generate 5 Male profiles
    for i in range(5):
        first_name = first_names_male[i]
        last_name = random.choice(last_names)
        username = f"{first_name.lower()}_{i+6}"
        email = f"{username}@example.com"
        
        user, created = User.objects.get_or_create(
            username=username,
            defaults={
                'first_name': first_name,
                'last_name': last_name,
                'email': email,
                'password': make_password('password123')
            }
        )

        UserProfile.objects.get_or_create(
            user=user,
            defaults={
                'gender': 'Male',
                'photo': profile_images[i+5],
                'phone_number': generate_phone(),
                'address_line1': f"{random.randint(100, 9999)} {random.choice(last_names)} {random.choice(street_types)}",
                'address_line2': random.choice(['Apt 12', 'Suite 500', '', 'Unit B', 'P.O. Box 456']),
                'city': random.choice(cities),
                'state': random.choice(states),
                'country': 'USA',
                'postal_code': f"{random.randint(10000, 99999)}",
                'bio': male_bios[i],
                'height': round(random.uniform(170.0, 190.0), 2),
                'weight': round(random.uniform(70.0, 90.0), 2),
                'father_name': f"{random.choice(first_names_male)} {last_name}",
                'mother_name': f"{random.choice(first_names_female)} {last_name}",
                'siblings': random.randint(0, 4),
                'family_type': random.choice(family_types),
                'family_status': random.choice(family_statuses),
            }
        )

def remove_sample_profiles(apps, schema_editor):
    User = apps.get_model('auth', 'User')
    User.objects.filter(email__endswith='@example.com').delete()

class Migration(migrations.Migration):

    dependencies = [
        ('user_profile', '0001_initial'),
    ]

    operations = [
        migrations.RunPython(create_sample_profiles, remove_sample_profiles),
    ]
