from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator
from django_countries.fields import CountryField
from django.utils import timezone

class UserProfile(models.Model):
    #GENDER_CHOICES =[
    #    ("Male", "남성"),
    #    ("Female", "여성"),
    #    ("Other", "기타"),
    #]
    name = models.CharField(max_length=50)
    #gender = models.CharField(choices=GENDER_CHOICES, max_length=10)
    birth_date = models.DateField()
    job = models.CharField(max_length=50, blank=True, null=True)
    # MBTI 점수 (0~100)
    i_e = models.PositiveSmallIntegerField(validators=[MinValueValidator(0), MaxValueValidator(100)], blank=True, null=True)
    n_s = models.PositiveSmallIntegerField(validators=[MinValueValidator(0), MaxValueValidator(100)], blank=True, null=True)
    t_f = models.PositiveSmallIntegerField(validators=[MinValueValidator(0), MaxValueValidator(100)], blank=True, null=True)
    p_j = models.PositiveSmallIntegerField(validators=[MinValueValidator(0), MaxValueValidator(100)], blank=True, null=True)
    gmail = models.EmailField(max_length=254)
    password = models.CharField(max_length=128)
    created_at = models.DateTimeField(default=timezone.now)


