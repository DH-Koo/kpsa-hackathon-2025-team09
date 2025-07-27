from django.contrib.auth.hashers import make_password
from rest_framework import serializers
from .models import UserProfile

class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = (
            'id', 'gmail', 'password', 'name', 'birth_date', 
            'i_e', 'n_s', 't_f', 'p_j',
        )
        read_only_fields = ('id',)  # 추천
        extra_kwargs     = {'password': {'write_only': True}}

    def create(self, validated_data):
        # 비밀번호 해싱
        validated_data['password'] = make_password(validated_data['password'])
        return super().create(validated_data)
