from django.shortcuts import render
from rest_framework import status
from rest_framework.response import Response 
from rest_framework.views import APIView
from django.utils import timezone 
from django.shortcuts import get_object_or_404
from django.http import FileResponse, Http404
from rest_framework.parsers import JSONParser, MultiPartParser, FormParser
#___________________________________________________________________________________
from user.models import UserProfile as User
from .models import Medicine, Music, Mood, MedicineOfDay
from chat.models import EmotionReport
from .serializers import MedicineOfDaySerializer, MusicSerializer, MedicineSerializer
import mindtune.settings as settings
from django.core.files import File
#___________________________________________________________________________________
from google import genai
from google.genai import types
from google.genai.types import Part, Content
#___________________________________________________________________________________
from qdrant_client import QdrantClient
from qdrant_client.models import PointStruct
#___________________________________________________________________________________
from dotenv import load_dotenv
import os
import re
import mimetypes
import threading
from distutils.util import strtobool
import numpy
from numpy.linalg import norm
import json
import uuid
import wave, asyncio, time
import datetime
load_dotenv() 
client = genai.Client(api_key=os.environ["GEMINI_API_KEY"])
music_client = genai.Client(api_key=os.environ["GEMINI_API_KEY"],
                      http_options={"api_version": "v1alpha"})

# Create your views here.
#___________________________________________________________________________________
medicine_prompts = """다음 처방전을 읽고 다음 형식대로 내용을 출력해 주세요.  
출력은 반드시 아래와 같은 JSON 형식의 리스트여야 하며, Python의 `json.loads()`로 파싱 가능해야 합니다.  
특히 복용시간은 튜플 대신 리스트 형식([[8,0],[12,30],...])으로 출력하세요.

[
  {{
    "name": "(약 이름을 문자열 형식으로 넣어주세요)",
    "1회 투여량": (1회 투여량을 정수로 입력하세요),
    "1일 투여횟수": (1일 투여 횟수를 정수로 입력하세요),
    "총 투여일수": (총 투여일수를 정수로 입력하세요),
    "복용시간": (복용 시간을 용법으로부터 추정해 [[시, 분], ...] 형식으로 작성하세요. 예: 아침, 점심, 저녁, 자기 전 복용 시 [[8,0],[12,30],[18,0],[23,0]])
  }},
  {{dict2}},
  ...
]
출력은 이 형식 외의 설명이나 부가 정보 없이 JSON 리스트 하나만 제공해야 합니다."""

user_context_prompt = """유저의 기분에 따라 추천할 음악을, 검색 기능을 사용하여 유튜브 url을 찾아보고, 해당 곡의 내용에 대해 설명해 주세요. 유저의 기분은 다음과 같습니다. 긍정도:
{positivity}, 에너지: {energy}, 스트레스: {stress}, 자기 자제력: {self_control}.
각 항목에 대해, 모든 값들은 0부터 100 사이의 정수로 입력되며, 100은 해당 값이 가장 높은 상태를, 0은 해당 값이 가장 낮은 상태를 의미합니다.
조건: 사운드클라우드에서 곡을 검색할 때, 반드시 무료로 스트리밍이 가능한 곡을 선택해야 합니다."""

user_medicine_prompt = """유저가 복용하는 약에 대해, 해당 약의 복용 시간에 맞춰 재생할 음악을 추천해 주세요. 입력으로는 다음 두 가지가 들어옵니다. 
1: 유저의 최근 감정 리포트
2: 챗봇과 유저의 최근 대화 내용
해당 정보들을 바탕으로 유저가 복용하는 약의 복용 시간에 맞춰 재생할 음악을 사운드클라우드 URL 형식으로 3개 추천해 주세요. 
출력 형식은 반드시 아래와 같은 JSON 형식이어야 하며, Python의 `json.loads()`로 파싱 가능해야 합니다.
[
  {{
    "title": (음악 제목을 문자열 형식으로 넣어주세요),
    "explanation": (음악에 대한 설명과 해당 음악이 왜 추천되었는지에 대한 설명을 문자열 형식으로 넣어주세요),
    "report_id": (해당 추천 과정에서 참고한 감정 리포트의 ID를 문자열 형식으로 넣어주세요),
    "music_url": (음악의 스트리밍 URL을 문자열 형식으로 넣어주세요)
  }},
  {{dict2}},
  ...
]
"""
def user_context_node(query_text: str, user_id: int, limit: int = 20):
    """
    Role: 사용자의 입력이 대해, 사용자의 개인 정보가 필요한 경우, Qdrant에서 
    벡터 검색을 수행해 가장 관련성 높은 정보를 반환하는 함수
    arguments:
        query_text: 사용자의 입력 메시지
        user_id: 사용자의 ID
    Return: List[ScoredPoint] - Qdrant에서 검색된 결과
    각 ScoredPoint 객체는 다음과 같은 정보를 포함한다.
        - id: 검색된 벡터의 ID
        - score: 검색된 벡터의 점수
        - payload: 검색된 벡터의 페이로드 (메시지 내용, 유저 ID, 세션 ID 등)
    """
    client = QdrantClient(host="localhost", port=6333)
    search_result = client.search(
        collection_name="chat_memory",
        query_vector=get_embedding(query_text, is_query=True),
        limit=limit,
        query_filter={
            "must": [
                {"key": "user_id", "match": {"value": user_id}}
            ]
        }
    )
    return search_result

def get_embedding(text:str, is_query:bool) -> list[float]:
    if is_query:
        task_type = "RETRIEVAL_QUERY"
    else:
        task_type = "RETRIEVAL_DOCUMENT"
    response = client.models.embed_content(
        model = "gemini-embedding-001",
        contents = text,
        config = types.EmbedContentConfig(
            task_type = task_type, output_dimensionality = 768,  
        ))
    [embedding_obj] = response.embeddings
    embedding_values_np = numpy.array(embedding_obj.values)
    normed_embedding = embedding_values_np / norm(embedding_values_np)
    return normed_embedding.tolist() 


async def music_generation(medicine_id: int, music: dict, music_client: genai.Client):
    
    async with music_client.aio.live.music.connect(
            model = "models/lyria-realtime-exp"
        ) as session:
            await session.set_weighted_prompts(
                prompts=[
                types.WeightedPrompt(text=music['mood_description'], weight=1.0), 
                types.WeightedPrompt(text=music['music_genre'], weight=1.0),
                types.WeightedPrompt(text=music['instruments'], weight=1.0)
                ]
            )
            await session.set_music_generation_config(
                config=types.LiveMusicGenerationConfig(bpm=music['bpm'], temperature=1.0)
            )
            file_path = os.path.join(settings.MEDIA_ROOT, f"audio/music_{medicine_id}.wav")

            with wave.open(file_path, "wb") as wf:
                wf.setnchannels(CHANNELS)
                wf.setsampwidth(SAMPLE_WIDTH)
                wf.setframerate(SAMPLE_RATE)

                await session.play()
                start = timezone.now()

                async for msg in session.receive():
                    wf.writeframes(msg.server_content.audio_chunks[0].data)
                    if (timezone.now() - start).total_seconds() >= MAX_SEC:
                        await session.stop()
                        break
                return file_path
    


MAX_SEC      = 60            # 저장 길이
SAMPLE_RATE  = 48_000        # 48 kHz, 16‑bit PCM, 스테레오 2 ch :contentReference[oaicite:1]{index=1}
SAMPLE_WIDTH = 2
CHANNELS     = 2
#___________________________________________________________________________________
class MedicineOfDayView(APIView):
    """
    Role: 오늘의 날짜를 받아 해당 날짜에 복용해야 할 약 목록을 반환하는 API
    """
    def get(self,request,user_id,day,weekday):
        """
        오늘 날짜에 복용해야 할 약 목록을 반환합니다.
        :param request: HTTP 요청 객체
        :param user_id: 사용자 ID
        :param day: 날짜 (YYYY-MM-DD 형식)
        :return: 복용해야 할 약 목록
        """
        user = get_object_or_404(User, id=user_id)
        medicines = user.medicines.filter(start_day__lte=day, end_day__gte=day)
        
        
        medicine_list = []
        day = timezone.datetime.strptime(day, "%Y-%m-%d").date()
        for medicine in medicines:
            # 복용 시간이 리스트로 변환
            take_time = []
            for time in medicine.take_time:
                if isinstance(time, list) and len(time) == 2:
                    take_time.append((time[0], time[1]))
                else:
                    # 잘못된 형식의 복용 시간은 무시
                    continue
                if weekday not in medicine.weekday:
                    continue

                medicine_of_day = MedicineOfDay.objects.filter(user=user, medicine=medicine, date=day, take_time=datetime.time(time[0], time[1])).first()
                if medicine_of_day:
                    serializer = MedicineOfDaySerializer(medicine_of_day)
                    medicine_list.append(serializer.data)
                else:
                    medicine_of_day = MedicineOfDay(
                        user=user,
                        medicine=medicine,
                        date=day,
                        is_taken=False,
                        take_time=datetime.time(time[0], time[1]) if time else None
                    )
                    medicine_of_day.save()
                    serializer = MedicineOfDaySerializer(medicine_of_day)
                    medicine_list.append(serializer.data)
            
        return Response(medicine_list, status=status.HTTP_200_OK)

    def put(self,request,user_id,day,weekday):
        """
        오늘 날짜에 복용한 약을 업데이트합니다.
        :param request: HTTP 요청 객체
        :param user_id: 사용자 ID
        :param day: 날짜 (YYYY-MM-DD 형식)
        :param medicine: 약 ID
        :return: 업데이트된 약 정보
        """
        medicine_of_day_id = request.data.get('medicine_of_day_id')
        user = get_object_or_404(User, id=user_id)
        medicine_of_day = MedicineOfDay.objects.get(id=medicine_of_day_id)
        
        if not medicine_of_day:
            return Response({"message": "오늘 복용할 약이 없습니다."}, status=status.HTTP_404_NOT_FOUND)

        medicine_of_day.is_taken = not medicine_of_day.is_taken 
        medicine_of_day.save()

        serializer = MedicineOfDaySerializer(medicine_of_day)
        
        return Response(serializer.data, status=status.HTTP_200_OK)

#___________________________________________________________________________________
class MusicRecommendView(APIView):
    """
    Role: 사용자의 기분에 맞는 음악을 추천하는 API
    Input: 사용자의 기분 상태 (긍정도, 에너지, 스트레스, 자기 자제력)
    Output: 추천 음악 목록과 해당 음악에 대한 설명
    """
    def post(self, request):
      positivity = request.data.get('positivity', None)
      energy = request.data.get('energy', None)
      stress = request.data.get('stress', None)
      self_control = request.data.get('self_control', None)
      if not all([positivity, energy, stress, self_control]):
          return Response({"error": "모든 기분 상태를 입력해야 합니다."}, status=status.HTTP_400_BAD_REQUEST)
      user = get_object_or_404(User, id=request.data.get('user_id'))
      # 기분 상태에 따라 음악 추천 로직 구현
      system_prompt = user_context_prompt.format(
          positivity=positivity,
          energy=energy,
          stress=stress,
          self_control=self_control
      )
      grounding_tool = types.Tool(
      google_search=types.GoogleSearch()
      )
      config = types.GenerateContentConfig(
      tools=[grounding_tool],
      system_instruction=system_prompt
      )
      contents = [Content(role="user", parts=[Part(text="추천 음악을 4개 찾고, 이에 대한 설명을 작성해 주세요. 설명을 작성할 때는 반드시 유저의 기분 상태를 근거로 왜 이 음악을 추천하는지 설명해 주세요.")])]
      response = client.models.generate_content(
          model="gemini-2.5-flash",
          contents=contents,
          config=config
      )
      citations = []
      titles = []
      chunks = response.candidates[0].grounding_metadata.grounding_chunks
      if chunks:
          for chunk in chunks:
              uri = chunk.web.uri
              title = chunk.web.title
              citations.append(uri)
              titles.append(title)

      text = response.text

      return Response({
          "text": text,
          "citations": citations,
          "titles": titles
      }, status=status.HTTP_200_OK)

#___________________________________________________________________________________
class MedicinePostView(APIView):
    """
    Role: 사용자가 약을 등록하는 API, 약 정보를 입력받아 데이터베이스에 저장한다. 또한 해당 약과 유저의 정보를 바탕으로 어울리는 음악을 저장한다.
    Input: 약 정보 (이름, 설명, 1회 투여량, 1일 투여 횟수, 총 투여일수, 복용 시간, 요일, 시작일, 종료일, 유저 아이디)
    Output: 등록된 약 정보
    """
    parser_classes = [JSONParser, MultiPartParser, FormParser]

    def post(self, request):
        user = get_object_or_404(User, id=request.data.get('user_id', request.user.id))
        data = request.data

        start_day = data.get('start_day')
        end_day = data.get('end_day')
        total_days = data.get('total_days')
        start_day = timezone.datetime.strptime(start_day, "%Y-%m-%d").date() if start_day else timezone.now().date()
        end_day = timezone.datetime.strptime(end_day, "%Y-%m-%d").date() if end_day else start_day + timezone.timedelta(days=total_days)
        
        medicine = Medicine.objects.create(
            user=user,
            name=data.get('name'),
            description=data.get('description', ''),
            num_per_take=data.get('num_per_take'),
            num_per_day=data.get('num_per_day'),
            total_days=total_days,
            take_time=data.get('take_time'),
            weekday=data.get('weekday', []),
            start_day=start_day,
            end_day=end_day
        )
        medicine_id = medicine.id
        medicine_name = medicine.name

        # 최근 감정 리포트 1개 가져오기
        report = EmotionReport.objects.filter(user=user).order_by('-timestamp')[0]
        query_text = "사용자의 감정을 가장 잘 반영하는 메시지를 검색해 주세요"
        recent_user_context = user_context_node(query_text, user.id)
        # 약에 어울리는 음악 추천
        grounding_tool = types.Tool(
        google_search=types.GoogleSearch()
        )
        config = types.GenerateContentConfig(
            tools=[grounding_tool],
            system_instruction=user_medicine_prompt,
        )
        prompt = """사용자의 최근 감정 리포트와 챗봇과의 대화 내용, 약 정보를 바탕으로
        음악 생성을 위한 파라미터를 설정해 주세요. 파라미터는 총 5개 입니다: [bpm, scale, instruments, music genre, mood/description]
        당신은 1. 사용자의 감정 리포트와 챗봇과의 대화 내용, 2. 약 정보를 바탕으로, 
        음악 파라미터를 신경과학적/ 약학적 원리에 기반해 설정해야 합니다.
        당신은 약의 부작용을 고려하여, 사용자의 기분을 안정시키고 긍정적인 감정을 유도할 수 있는 음악을 추천해야 합니다.
        Instruments, Music Genre, Mood/Description는 각각 다음과 같은 값들을 가질 수 있습니다:
        Instruments: 303 Acid Bass, 808 Hip Hop Beat, Accordion, Alto Saxophone, Bagpipes, Balalaika Ensemble, Banjo, Didgeridoo, Dirty Synths, Djembe, Drumline, Dulcimer, Fiddle, Flamenco Guitar, Funk Drums, Glockenspiel, Guitar, Hang Drum, Harmonica, Harp, Harpsichord, Hurdy-gurdy, Kalimba, Koto, Lyre, Mandolin, Maracas, Marimba, Mbira, Mellotron, Metallic Twang, Moog Oscillations, Ocarina, Persian Tar, Pipa, Precision Bass, Ragtime Piano, Rhodes Piano, Shamisen, Shredding Guitar, Sitar, Slide Guitar, Smooth Pianos, Spacey Synths, Steel Drum, Synth Pads, Tabla, TR-909 Drum Machine, Trumpet, Tuba, Vibraphone, Viola Ensemble, Warm Acoustic Guitar, Woodwinds, ...
        Music Genre: Acid Jazz, Afrobeat, Alternative Country, Baroque, Bengal Baul, Bhangra, Bluegrass, Blues Rock,  Chillout, Chiptune, Classic Rock, Contemporary R&B, Cumbia, Deep House, Disco Funk, Drum & Bass, Dubstep, EDM, Electro Swing, Funk Metal, G-funk, Garage Rock, Glitch Hop, Grime, Hyperpop, Indian Classical, Indie Electronic, Indie Folk, Indie Pop, Irish Folk, Jam Band, Jamaican Dub, Jazz Fusion, Latin Jazz, Lo-Fi Hip Hop, Marching Band, Merengue, New Jack Swing, Minimal Techno, Moombahton, Neo-Soul, Orchestral Score, Piano Ballad, Polka, Post-Punk, 60s Psychedelic Rock, Psytrance, R&B, Reggae, Reggaeton, Renaissance Music, Salsa, Shoegaze, Ska, Surf Rock, Synthpop, Techno, Trance, Trap Beat, Trip Hop, Vaporwave, Witch house, ...
        Mood/Description: Acoustic Instruments, Ambient, Bright Tones, Chill, Crunchy Distortion, Danceable, Dreamy, Echo, Emotional, Ethereal Ambience, Experimental, Fat Beats, Funky, Glitchy Effects, Huge Drop, Live Performance, Lo-fi, Ominous Drone, Psychedelic, Rich Orchestration, Saturated Tones, Subdued Melody, Sustained Chords, Swirling Phasers, Tight Groove, Unsettling, Upbeat, Virtuoso, Weird Noises, ...
        출력은 반드시 아래와 같은 JSON 형식의 리스트여야 하며, Python의 `json.loads()`로 파싱 가능해야 합니다. 
        [
            {{
                "bpm": (bpm을 정수로 입력하세요. int()함수를 이용해 변환 가능한 값이여야 합니다. 예시: 120),
                "scale": (scale를 문자열로 입력하세요, 단 하나의 음계만 입력하세요),
                "instruments": (instruments를 문자열로 입력하세요, 단 하나의 악기만 입력하세요),
                "music_genre": (music genre를 문자열로 입력하세요, 단 하나의 장르만 입력하세요),
                "mood_description": (mood/description를 문자열로 입력하세요, 단 하나의 기분/설명만 입력하세요),
                "description": (음악에 대한 설명을 문자열로 입력하세요, 이 설명은 음악이 왜 추천되었는지에 대한 설명이어야 합니다, 추천된 이유에는 반드시
                1. 약의 부작용에 대해 설정된 음악 파라미터가 어떤 긍정적 영향을 줄 수 있는지, 2. 사용자의 개인정보(감정 리포트, 챗봇과의 대화 내용 등)를 반영해 음악 파라미터가 어떻게 사용자에 대한 긍정적인 영향을 줄 수 있을 지에 대한 설명이 포함되어야 합니다),
                "title": (음악 제목을 직접 지어 문자열로 입력하세요),
            }},
            {{dict2}},
            ...
        ]
        해당 리스트만 출력해야 하며, 앞 뒤에 어떤 문자열도 포함하지 않아야 합니다. 즉 첫 문자열은 [로 시작하고, 마지막 문자열은 ]로 끝나야 합니다. 
        주의사항: 
        리스트에는 반드시 하나의 객체만의 포함되어야 합니다.
            
        사용자의 최근 감정 리포트는 다음과 같습니다: """
        prompt += f"\n- {report.content} (ID: {report.id})"
        prompt += "\n유저가 한 챗봇과의 최근 대화 내용은 다음과 같습니다: "
        for context in recent_user_context:
            prompt += f"\n- {context.payload['message']}"
        contents = [Content(role="user", parts=[Part(text=prompt)])]
        response = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=contents,
            config=config
        )
        # JSON 파싱
        try:
            music_data = response.text.strip()
            # 앞에 "```json\n" 또는 "```json" 제거
            if music_data.startswith("```json\n"):
                music_data = music_data[len("```json\n"):]

            if music_data.endswith("```"):
                music_data = music_data[:-len("```")]
            print(music_data)
            music_list = json.loads(music_data)  # JSON 문자열을 파싱하여 리스트로 변환
            # music_list 예시:
            # [
            #     {
            #         "bpm": 120,
            #         "scale": "C Major",
            #         "instruments": "Piano",
            #         "music_genre": "Chillout",
            #         "mood_description": "Chill",
            #         "description": "이 음악은 사용자의 긍정적인 기분을 반영하여 추천되었습니다."
            #     },
            #     ...
            # ]
            music = music_list[0]  # 첫 번째 음악 정보만 사용
        except Exception as e:
            return Response({"error": "json 파싱 과정 중 오류 발생: " + str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        # 음악 생성
        music['bpm'] = int(music['bpm'])
        # 음악 생성 함수 호출
        try:
            file_path = asyncio.run(music_generation(medicine_id, music, music_client))
        except Exception as e:
            return Response({"error": "음악 생성 중 오류 발생: " + str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        # 음악 정보 저장
        with open(file_path, 'rb') as audio_file:
            django_file = File(audio_file, name=f"music_{medicine_id}.wav")
            music_instance = Music.objects.create(
            medicine=medicine,
            title=music['title'],
            report=report,
            audio=django_file
        )
        return Response({
            "message": "약 정보가 성공적으로 등록되었습니다.",
            "medicine_id": medicine.id,
            "music_recommendations": music_list
        }, status=status.HTTP_201_CREATED)

#___________________________________________________________________________________
class MedicineListView(APIView):
    """
    Role: 사용자가 등록한 약 목록을 가져오는 API
    Input: 사용자 ID
    Output: 등록된 약 목록
    """
    def get(self, request, user_id):
        user = get_object_or_404(User, id=user_id)
        medicines = user.medicines.all()
        if not medicines:
            return Response({"message": "등록된 약이 없습니다."}, status=status.HTTP_404_NOT_FOUND)

        serializer = MedicineSerializer(
            medicines,
            many=True,
            context={"request": request}
        )
        return Response(serializer.data, status=status.HTTP_200_OK)

class MedicineMusicListView(APIView):
    """
    GET  /api/medicine/<medicine_id>/music/          ▶ 해당 약의 음악 목록(JSON)
    GET  /api/medicine/<medicine_id>/music/<music_id>/ ▶ 음악 파일(WAV 스트림)
    """

    def get(self, request, medicine_id, music_id=None):
        # ① 약 객체 가져오기 (권한 체크 포함)
        medicine = get_object_or_404(
            Medicine.objects.prefetch_related("musics"),
            id=medicine_id,
        )

        # ② 특정 음악 파일 다운로드
        if music_id is not None:
            music = get_object_or_404(Music, id=music_id, medicine=medicine)
            if not music.audio:
                raise Http404("음악 파일이 없습니다.")
            # as_attachment=True 로 브라우저 자동 다운로드
            return FileResponse(
                music.audio.open("rb"),
                as_attachment=True,
                filename=os.path.basename(music.audio.name),
                content_type="audio/wav"
            )

        # ③ 음악 목록 JSON 반환
        musics = medicine.musics.all()
        if not musics:
            return Response(
                {"message": "해당 약에 대한 음악이 없습니다."},
                status=status.HTTP_404_NOT_FOUND
            )

        # serializer 내에서 절대 URL 생성
        serializer = MusicSerializer(
            musics,
            many=True,
            context={"request": request}
        )
        return Response(serializer.data, status=status.HTTP_200_OK)
#___________________________________________________________________________________
class MedicinePostByAIView(APIView):
  """Role: AI를 사용하여 약 정보를 등록하는 API
  Input: 처방전 사진
  Output: AI가 추출한 약 정보
  """
  parser_classes = [MultiPartParser, FormParser]

  def post(self, request):
      file = request.FILES.get('file')
      if not file:
          return Response({"error": "처방전 사진이 필요합니다."}, status=status.HTTP_400_BAD_REQUEST)

      # 파일 타입 확인
      mime_type, _ = mimetypes.guess_type(file.name)
      if mime_type not in ['image/jpeg', 'image/png', 'image/gif']:
          return Response({"error": "지원하지 않는 파일 형식입니다."}, status=status.HTTP_400_BAD_REQUEST)

      parts = [Part.from_bytes(data=image.read(), mime_type=mime_type)]

      # AI 모델에 요청
      contents = [Content(role="user", parts=parts)]
      config = types.GenerateContentConfig(
          tools=[],
          system_instruction=medicine_prompts
      )
      response = client.models.generate_content(
          model="gemini-2.5-flash",
          contents=contents,
          config=config
      )

      # JSON 파싱
      try:
          medicine_data = response.text.strip()
          medicines = eval(medicine_data)  # JSON 문자열을 파싱하여 리스트로 변환
      except Exception as e:
          return Response({"error": "AI 응답 처리 중 오류 발생: " + str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

      # 약 정보 저장
      user = get_object_or_404(User, id=request.user.id)
      for med in medicines:
          Medicine.objects.create(
              user=user,
              name=med['name'],
              num_per_take=med['1회 투여량'],
              num_per_day=med['1일 투여횟수'],
              total_days=med['총 투여일수'],
              take_time=med['복용시간'],
              weekday=['월','화', '수', '목', '금', '토', '일'],  # 기본적으로 모든 요일로 설정
              start_day=timezone.now().date(),  # 시작일은 현재 날짜로 설정
              end_day=timezone.now().date() + timezone.timedelta(days=med['총 투여일수'] - 1)  # 종료일 계산
          )

      return Response({"message": "약 정보가 성공적으로 등록되었습니다."}, status=status.HTTP_201_CREATED)





    
        