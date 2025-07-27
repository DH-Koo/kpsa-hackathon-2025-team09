from django.db import models
from user.models import UserProfile as User
from chat.models import EmotionReport

def default_weekdays():
    return ["월", "화", "수", "목", "금", "토", "일"]

class Medicine(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='medicines')
    name = models.CharField(max_length=100)  # 약 이름
    description = models.TextField(blank=True, null=True)  # 약 설명
    num_per_take = models.IntegerField()  # 1회 투여량
    num_per_day = models.IntegerField()  # 1일 투여 횟수
    total_days = models.IntegerField()  # 총 투여일수
    take_time = models.JSONField()  # 복용 시간 (예: [[8,0],[12,30],[18,0],[23,0]])
    weekday = models.JSONField(default=default_weekdays)  # 디폴트: 모든 요일
    start_day = models.DateField()  # 시작일
    end_day = models.DateField()  # 종료일

class Music(models.Model):
    # 약 복용 시간에 맞춰 재생할 음악
    medicine = models.ForeignKey(Medicine, on_delete=models.CASCADE, related_name='musics')
    title = models.CharField(max_length=100)  # 음악 제목
    description = models.TextField(blank=True, null=True)  # 음악 설명
    audio = models.FileField(upload_to='audio/', null=True, blank=True)  # 음악 파일


class Mood(models.Model):
    # 사용자의 기분 상태
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='moods')
    positivity = models.FloatField()  # 긍정성
    energy = models.FloatField()  # 에너지
    stress = models.FloatField()  # 스트레스
    self_control = models.FloatField()  # 자기 통제력
    timestamp = models.DateField(auto_now_add=True)  # 기분 기록 시간

class MedicineOfDay(models.Model):
    # 오늘 복용해야 할 약 정보
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='medicines_of_day')
    medicine = models.ForeignKey(Medicine, on_delete=models.CASCADE, related_name='medicines_of_day')
    date = models.DateField()  # 오늘 날짜
    is_taken = models.BooleanField(default=False)  # 복용 여부
    take_time = models.TimeField(null=True, blank=True)  # 복용 시간 (복용한 경우에만 기록)





    


