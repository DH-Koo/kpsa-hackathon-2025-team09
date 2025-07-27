from rest_framework import serializers
from .models import Medicine, Music, Mood, MedicineOfDay

class MedicineSerializer(serializers.ModelSerializer):
    class Meta:
        model = Medicine
        fields = [
            'id', 'user', 'name', 'description', 'num_per_take',
            'num_per_day', 'total_days', 'take_time', 'weekday',
            'start_day', 'end_day'
        ]

class MusicSerializer(serializers.ModelSerializer):
    audio_url = serializers.SerializerMethodField()
    download_url = serializers.SerializerMethodField()

    class Meta:
        model = Music
        fields = (
            "id", "title", "report_id",
            "bpm", "scale", "instruments", "music_genre", "mood_description", "description",
            "audio_url", "download_url"
        )

    # 스트리밍용 URL (DRF 기본 STATIC 서버 또는 S3 URL 등)
    def get_audio_url(self, obj):
        request = self.context.get("request")
        return request.build_absolute_uri(obj.audio.url) if obj.audio else None

    # 파일 다운로드 ENDPOINT
    def get_download_url(self, obj):
        request = self.context.get("request")
        return request.build_absolute_uri(
            f"/api/medicine/{obj.medicine_id}/music/{obj.id}/"
        )

class MoodSerializer(serializers.ModelSerializer):
    class Meta:
        model = Mood
        fields = ['id', 'user', 'positivity', 'energy', 'stress', 'self_control', 'timestamp']

class MedicineOfDaySerializer(serializers.ModelSerializer):
    class Meta:
        model = MedicineOfDay
        fields = ['id', 'user', 'medicine', 'date', 'is_taken', 'take_time']
        unique_together = ('user', 'date')  # 같은 사용자와 날짜에 대해 중복되지 않도록 설정