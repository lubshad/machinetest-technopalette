from django.db import models
from django.contrib.auth import get_user_model
from phonenumber_field.modelfields import PhoneNumberField

User = get_user_model()


class UserProfile(models.Model):
    """
    User profile model with OneToOne relationship to User.
    Contains additional profile information for matrimony app.
    """
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name='profile',
        primary_key=True
    )
    
    # Photo
    photo = models.ImageField(
        upload_to='profile_photos/',
        null=True,
        blank=True,
        help_text="User profile photo"
    )
    
    # Gender
    gender = models.CharField(
        max_length=10,
        choices=[
            ('Male', 'Male'),
            ('Female', 'Female'),
        ],
        help_text="User gender"
    )
    
    # Phone Number
    phone_number = PhoneNumberField(
        help_text="User phone number"
    )
    
    # Physical attributes
    height = models.DecimalField(
        max_digits=5,
        decimal_places=2,
        null=True,
        blank=True,
        help_text="Height in centimeters"
    )

    
    weight = models.DecimalField(
        max_digits=5,
        decimal_places=2,
        null=True,
        blank=True,
        help_text="Weight in kilograms"
    )
    
    # Address and Residence Information
    address_line1 = models.CharField(max_length=255, blank=True, default='')
    address_line2 = models.CharField(max_length=255, blank=True, default='')
    city = models.CharField(max_length=100, blank=True, default='')
    state = models.CharField(max_length=100, blank=True, default='')
    country = models.CharField(max_length=100, blank=True, default='')
    postal_code = models.CharField(max_length=20, blank=True, default='')
    
    # Family Information
    father_name = models.CharField(max_length=255, blank=True, default='')
    mother_name = models.CharField(max_length=255, blank=True, default='')
    siblings = models.IntegerField(null=True, blank=True, help_text="Number of siblings")
    family_type = models.CharField(
        max_length=50,
        choices=[
            ('nuclear', 'Nuclear'),
            ('joint', 'Joint'),
        ],
        blank=True,
        default=''
    )
    family_status = models.CharField(
        max_length=50,
        choices=[
            ('middle_class', 'Middle Class'),
            ('upper_middle_class', 'Upper Middle Class'),
            ('rich', 'Rich'),
        ],
        blank=True,
        default=''
    )
    
    # Bio
    bio = models.TextField(blank=True, default='', help_text="Personal bio/description")
    
    # Interests - ManyToMany relation to self
    interests = models.ManyToManyField(
        'self',
        symmetrical=False,
        related_name='interested_by',
        blank=True,
        help_text="Profiles this user is interested in"
    )
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'User Profile'
        verbose_name_plural = 'User Profiles'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"Profile of {self.user.username}"
