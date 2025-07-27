from django.db import models
from character.models import Character
from user.models import UserProfile
from django.utils import timezone

# Create your models here.
class ChatSession(models.Model):
    character = models.ForeignKey(Character, on_delete=models.CASCADE, db_index=True, default = 0)  # default=1은 기본 캐릭터 ID로 설정
    user = models.ForeignKey(UserProfile, on_delete=models.CASCADE, db_index = True)
    class Meta:
        indexes = [ models.Index(fields = ['user','character']),]
    summary = models.CharField(max_length = 50)
    start_time = models.DateTimeField(default=timezone.now)
    time = models.DateTimeField()
    is_workflow = models.BooleanField(default=False)

class Message(models.Model):
    SENDER_CHOICES = [
        ("user", "사용자"),
        ("model", "인공지능")
    ]
    session = models.ForeignKey(ChatSession, on_delete=models.CASCADE)
    sender = models.CharField(max_length=10, choices=SENDER_CHOICES)
    message = models.TextField()
    order = models.IntegerField()
    is_workflow = models.BooleanField(default=False)

class Image(models.Model):
    message = models.ForeignKey(Message, on_delete=models.CASCADE, related_name='images')
    image = models.ImageField(upload_to='chat_images/')
    caption = models.CharField(max_length=255, blank=True, null=True)
    def delete(self, *args, **kwargs):
        # ① 파일 삭제
        if self.image:
            self.image.delete(save=False)
        # ② DB 레코드 삭제
        super().delete(*args, **kwargs)

class File(models.Model):
    message = models.ForeignKey(Message, on_delete=models.CASCADE, related_name='files')
    file = models.FileField(upload_to='chat_files/')
    description = models.CharField(max_length=255, blank=True, null=True)
    def delete(self, *args, **kwargs):
    # ① 파일 삭제
        if self.file:
            self.file.delete(save=False)
        # ② DB 레코드 삭제
        super().delete(*args, **kwargs)

class Audio(models.Model):
    message = models.ForeignKey(Message, on_delete=models.CASCADE, related_name='audios')
    audio = models.FileField(upload_to='chat_audio/')
    transcript = models.TextField(blank=True, null=True)
    def delete(self, *args, **kwargs):
        # ① 파일 삭제
        if self.audio:
            self.audio.delete(save=False)
        # ② DB 레코드 삭제
        super().delete(*args, **kwargs)

class Citation(models.Model):
    message = models.ForeignKey(Message, on_delete=models.CASCADE, related_name='citations')
    text = models.TextField()
    uri = models.URLField()

class EmotionReport(models.Model):
    session = models.ForeignKey(ChatSession, on_delete=models.CASCADE, related_name='emotion_reports')
    user = models.ForeignKey(UserProfile, on_delete=models.CASCADE, related_name='emotion_reports')
    timestamp = models.DateTimeField(auto_now_add=True)
    content = models.TextField()

    class Meta:
        unique_together = ('session', 'timestamp')  # 같은 세션과 타임스탬프에 대해 중복되지 않도록 설정
