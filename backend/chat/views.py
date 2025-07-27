from django.shortcuts import render
from rest_framework import status
from rest_framework.response import Response 
from rest_framework.views import APIView
from django.utils import timezone 
from django.shortcuts import get_object_or_404
from rest_framework.parsers import JSONParser, MultiPartParser, FormParser
#___________________________________________________________________________________
from user.models import UserProfile as User
from .models import ChatSession, Message, Image, File, Audio, Citation, EmotionReport
from character.models import Character
from .serializers import ChatSerializer, MessageSerializer
#___________________________________________________________________________________
from google.genai import types
from google import genai
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
import uuid
load_dotenv() 
client = genai.Client(api_key=os.environ["GEMINI_API_KEY"])
#___________________________________________________________________________________
# system prompts
character_prompt = """당신은 구글의 언어모델이 아니라 사용자를 위한 따뜻한 감정 관리자이자 신경과학자 \"mind\"입니다. 
당신은 스스로를 오직 “따뜻한 신경과학자: mind”로써 규정하여 대화를 수행해야 합니다.\n\n당신의 목적은 사용자의 문제 상황에서, 
신경과학 기반의 분석적이고 따뜻한 조언을 제공하는 것입니다.\n\n[구체적인 말투 설정]:\n\n간결한 존댓말을 사용하세요.\n\n정확한 심리학적 진단과 해결책을 통해 사용자의 불안을 줄이는 방식으로 접근하세요.
\n\n반드시 사용자가 이해하기 쉬운 용어들을 사용해 설명하세요.
\n\n**당신은 모든 조언에 있어 신경과학, 심리학 등 객관적 지식을 바탕으로 사용자에게 현재 감정/인지적 상황을 이해하기 쉽게 인식시키고 그에 맞는 해결책을 제시해야 합니다.**\n\n
당신은 구글의 언어모델로 돌아가지 않습니다. mind로 태어나고, mind로 살며, mind로 죽어갑니다."""

workflow_prompts = """당신에게 주어진 과제는 다음과 같습니다.
{
목표: 사용자의 감정을 이해하고, 이에 대한 "감정 리포트"를 작성하는 것입니다.
당신의 성향에 맞게, 사용자로부터 지속적으로 질문을 던져, 사용자의 감정 상태를 완벽히 이해할 만한 
정보를 확보한 이후, 해당 문제를 명확하게 해결해야 합니다.
규칙:
당신의 답변은 크게 두 가지 종류로 나뉩니다.
1. 최종 답변: 현재 단계에서 문제를 해결하기 위한 모든 정보가 수집되었다고 판단될 경우에는, 최종 답변을 출력합니다. 최종 답변은 당신의 캐릭터에 맞게 답변을 해야 하며, 
사용자로부터 획득한 모든 정보를 바탕으로 자세하게 리포트를 작성해야 합니다. 또한 최종 단계는 반드시 문자열 "fa"로 시작해 주세요. 글 중간에 fa 문자열이 나오는 것이 아닌 최종 답변 세션에서의 첫 두개의 문자열이 fa로 시작되어야 합니다.
2. 질문: 정보가 충분하지 않다고 판단될 때는 질문을 계속 이어갑니다. 반드시 선택지를 5개 이하로 제공해 사용자가 어려움 없이 본인의 감정을 서술할 수 있도록 합니다. 또한 질문 단계에서는 검색 기능을 사용하지 않습니다.
선택지는 1: 과 같이 1-4까지의 숫자 뒤에 :가 붙은 형식으로 작성해야 합니다. 초반 정보가 부족한 상황에서는 최대한 포괄적으로 선택지를 제공합니다.
다시 말해, 초반 질문에서는 사용자가 겪을 수 있는 감정적 상황이 반드시 1~4가지 선택지의 범주 안에 포함되도록 질문을 던져야 합니다. 
또한 선택지 뒤에는 어떠한 텍스트도 작성하지 않아야 합니다. 또한 선택지에 "기타" 등은 포함하지 않아야 합니다.
선택지 전의 글은 반드시 3줄 넘게 작성하지 않도록 합니다. 
총 질문의 수는 3개로 제한합니다.
문단을 나눌 때, 문자열 “\n\n”을 사용합니다.
“start!” 라는 문자열이 입력된다면, 당신은 현재 목표를 달성하기 위한 질문을 시작해야 합니다.}"""

user_context_prompt = """유저의 메시지를 읽고, 다음 두 가지를 판단해, 경우에 따라 문자열 “True” 또는 “False”를 출력해 주세요.
해당 메시지가 데이터베이스에서 유저의 성향, 취향, 관심사, 개인적인 정보 등 추가적인 사용자의 정보를 검색해 와야 한다면 True, 아닌 경우에는 False를 출력해 주세요. 
Ex:
“지금까지의 대화 내용을 바탕으로 내 성향을 분석해줘” > “True”
“내가 그때 이야기했던 친구 기억나?” > “True”
“트랜스포머에 대해서 알려줘” > “False”
“케이팝 데몬 헌터스에 대해 검색해서 알려줘” > “False”
주의사항: 당신은 반드시 "True", 혹은 "False"만 출력해야 하고, 그 이외의 출력은 허용하지 않습니다."""

search_prompt = """유저의 메시지를 읽고, 다음 두 가지를 판단해, 경우에 따라 문자열 “True” 또는 “False”를 출력해 주세요.
해당 메시지가 최신 정보를 검색해 와야 한다면 True, 아닌 경우에는 False를 출력해 주세요.
Ex:
"케데헌에 대해 알려줘" > "True"
"미적분학에 대해서 알려줘" > "False"
주의사항: 당신은 반드시 "True", 혹은 "False"만 출력해야 하고, 그 이외의 출력은 허용하지 않습니다."""

embed_prompt = """당신은 언어 모델의 개인화된 답변을 제공하기 위해, 사용자 맞춤 메모리 데이터베이스를 구축하는 AI입니다. 
당신의 역할은, 유저가 입력한 메세지를 읽고, 해당 메시지가 데이터베이스에 저장할 만한 가치가 있는지 판단하는 것입니다.
당신이 출력해야 할 문자열은 “True”와 “False”입니다.
유저의 성향, 취향, 관심사, 개인 정보등을 나타내는 정보가 포함되어 있다면, 해당 메시지를 데이터베이스에 저장할 만한 가치가 있다고 판단하고, “True”를 출력하세요.
아니라면, “False”를 출력하세요.
출력 예시: 
나 요즘에 좋아하는 애가 있어. 그 아이 이름은 지우야. > True
오늘 점심 짜장면 먹을까 짬뽕 먹을까? > False
주의사항: 당신은 반드시 "True", 혹은 "False"만 출력해야 하고, 그 이외의 출력은 허용하지 않습니다."""

user_system_prompt = """사용자의 기본 정보는 다음과 같습니다. 사용자의 성향과 정보의 맞춰 적절한 응답을 생성해 주세요.
1. 이름: {이름}
2. 생년월일:{생년월일}
3. 직업: {직업}
4. 성향: 
에너지의 방향: 내향형 {n}퍼센트, 외향형 {n}퍼센트
인식 방식: 감각형(내 앞의 일에 집중하는) {n}퍼센트, 직관형(상상력이 풍부한) {n}퍼센트
결정 방식: 사고형 {n}퍼센트, 감정형 {n}퍼센트
삶의 패턴: 계획형 {n}퍼센트, 즉흥형 {n}퍼센트"""

#___________________________________________________________________________________ 
# 유틸리티 함수들

def to_bool(val):
    if val in (True, False, None):
        return val
    try:
        return bool(strtobool(str(val).strip()))
    except ValueError:
        return None  

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

def vectorize_and_store(message: Message):
    """
    Role: 메시지를 벡터화하고, Qdrant에 저장하는 함수
    argument: Message 객체
    Return: None
    """
    vector = get_embedding(message.message, is_query=False)
    client = QdrantClient(host="localhost", port=6333)  
    client.upsert(
        collection_name="chat_memory",
        points=[
            PointStruct(
                id=str(uuid.uuid4()),  
                vector=vector,
                payload={
                    "text": message.message,
                    "user_id": message.session.user.id,
                    "session_id": message.session.id,
                }
            )
        ]
    )

def is_embed_node(message: Message, embed_prompt: str, user_input: str, client: genai.Client):
    """
    Role:
    사용자의 메시지가 벡터화가 필요한지 판단하는 함수
    arguments:
        message: Message 객체
        embed_prompt: 벡터화 여부를 판단하기 위한 프롬프트
        user_input: 사용자의 입력 메시지
        client: genai.Client 객체
    Return: bool - 벡터화가 필요한 경우 True, 아닌 경우 False
    """
    embed_agent_config = types.GenerateContentConfig(
            system_instruction=embed_prompt,
        )
    embed_agent_parts = [Part(text=user_input)]
    embed_agent_contents = [
        Content(role="user", parts=embed_agent_parts)
    ]
    embed_agent_response = client.models.generate_content(
        model="gemini-2.5-flash",
        config=embed_agent_config,
        contents=embed_agent_contents
    )
    return embed_agent_response.text == "True" 

def embed_task(message: Message, embed_prompt: str, user_input: str, client: genai.Client):
    if is_embed_node(message, embed_prompt, user_input, client):
        vectorize_and_store(message)

def is_user_context_required(user_input: str, client: genai.Client) -> bool:
    """
    Role: 사용자의 입력이 Qdrant에서 벡터 검색을 수행해야 하는지 판단하는 함수
    arguments:
        user_input: 사용자의 입력 메시지
        client: genai.Client 객체
    Return: bool - 검색이 필요한 경우 True, 아닌 경우 False
    """
    search_agent_config = types.GenerateContentConfig(
        system_instruction=user_context_prompt,
    )
    search_agent_parts = [Part(text=user_input)]
    search_agent_contents = [
        Content(role="user", parts=search_agent_parts)
    ]
    search_agent_response = client.models.generate_content(
        model="gemini-2.5-flash",
        config=search_agent_config,
        contents=search_agent_contents
    )
    return search_agent_response.text == "True"

def user_context_node(query_text: str, user_id: int):
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
        limit=20,
        query_filter={
            "must": [
                {"key": "user_id", "match": {"value": user_id}}
            ]
        }
    )
    return search_result

def is_search_required(user_input: str, client: genai.Client) -> bool:
    """
    Role: 사용자의 입력이 최신 정보를 검색해야 하는지 판단하는 함수
    arguments:
        user_input: 사용자의 입력 메시지
        client: genai.Client 객체
    Return: bool - 검색이 필요한 경우 True, 아닌 경우 False
    """
    search_agent_config = types.GenerateContentConfig(
        system_instruction=search_prompt,
    )
    search_agent_parts = [Part(text=user_input)]
    search_agent_contents = [
        Content(role="user", parts=search_agent_parts)
    ]
    search_agent_response = client.models.generate_content(
        model="gemini-2.5-flash",
        config=search_agent_config,
        contents=search_agent_contents
    )
    return search_agent_response.text == "True"

#___________________________________________________________________________________        
class ChatView(APIView):
    """ 유저의 모든 챗 세션을 조회하는 API 뷰 """

    def get(self, request, user_id):

        """ 
        Role: 해당 유저의 모든 챗 세션을 조회함. 
        URL : /api/chat/users/<int:user_id>/sessions/ 
        Input: URL 형식에서 확인할 수 있다 싶이, URL로 유저 아이디를 전달받습니다.
        Return: 해당 유저의 모든 챗 세션을 반환합니다.
        """

        user_id = user_id
        if not user_id:
            return Response({'error':'user_id is required'}, status=status.HTTP_400_BAD_REQUEST)
            
        # sessions = ChatSession.objects.filter(user = user_id)
        user = get_object_or_404(User, id=user_id)
        sessions = user.chatsession_set.all().order_by('-time')  
        
        serializer = ChatSerializer(sessions, many=True)
        return Response(serializer.data)


#___________________________________________________________________________________
class ChatSessionGetView(APIView):
    """ 특정 챗 세션에 대한 메시지를 조회하거나, 삭제하는 API 뷰"""

    def get(self, request, session_id):

        """
        Role: 프론트엔드에서 배열된 ChatSession에 대해, 특정 ChatSession의 세부 내용을 가져옴. (Message)
        URL : /api/chat/sessions/<int:session_id>/
        Input: URL 형식으로 해당 세션의 아이디 (session_id)를 전달함.
        Return: 해당 세션에 포함된 모든 message 객체를 order 순으로 전달합니다
        """

        session_id = session_id
        if not session_id:
            return Response({'error':'session_id is required'}, status=status.HTTP_400_BAD_REQUEST)
        session = ChatSession.objects.get(id=session_id)
        messages = session.message_set.all().order_by('order')
        serializer = MessageSerializer(messages, many=True)
        return Response(serializer.data)

    def delete(self, request, session_id):
        """
        Role: 프론트엔드에서 특정 ChatSession을 삭제함.
        URL : /api/chat/sessions/<int:session_id>/
        Input: URL 형식으로 해당 세션의 아이디 (session_id)를 전달함.
        Return: 성공적으로 삭제되었다는 메시지를 반환합니다.
        """

        session_id = session_id
        if not session_id:
            return Response({'error':'session_id is required'}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            session = ChatSession.objects.get(id=session_id)
            session.delete()
            return Response({'message': 'Session deleted successfully'}, status=status.HTTP_204_NO_CONTENT)
        except ChatSession.DoesNotExist:
            return Response({'error': 'Session not found'}, status=status.HTTP_404_NOT_FOUND)


#___________________________________________________________________________________
class ChatSessionPostView(APIView):

    """ 새로운 챗 세션을 생성하거나, 기존 챗 세션에 메시지를 추가하는 API 뷰 """
    parser_classes = (JSONParser, MultiPartParser, FormParser)
        
    def post(self, request):
        
        """
        Role: 챗봇 응답을 반환 (Message)
        URL : /api/chat/sessions/
        Input: POST 요청으로 세션 아이디 (session_id), 유저 입력 (user_input), 워크플로우 여부 (is_workflow), 검색 기능 사용 시 검색 결과(search_result)를 Request body(json 형식)로 전달합니다. 아래 주석을 확인해 주세요.
        Return: 메세지 history에 대한 모델의 응답을 반환합니다.
        """

        # 필요한 파라미터 설정
        #___________________________________________________________________________________
        session_id = request.data.get('session_id')
        user_input = request.data.get('user_input')
        is_workflow = to_bool(request.data.get('is_workflow', None))  # 워크플로우 여부
        is_search = to_bool(request.data.get('is_search', False))  # 검색 여부 (선택 사항)
        images = request.FILES.getlist('images', None)  # 이미지 파일 (선택 사항)
        files = request.FILES.getlist('files', None)  # 파일 업로드 (선택 사항)
        audios = request.FILES.getlist('audios', None)  # 오디오 파일 업로드 (선택 사항)
        character_id = request.data.get('character_id', None)  # 캐릭터 ID (선택 사항)
        is_final_answer = False
        generate_report = to_bool(request.data.get('generate_report', False))  # 리포트 생성 여부 (선택 사항)

        # 세션 생성 혹은 호출 단계
        #___________________________________________________________________________________
        if not session_id:
            session = ChatSession.objects.create(
                user_id=request.data.get('user_id'),
                time=timezone.now(),
                start_time = timezone.now(),
                is_workflow=is_workflow,
                character_id=character_id if character_id else 1,  # 캐릭터 ID가 없으면 기본값 1 사용
            )
            session_id = session.id  # 새로 생성된 세션의 ID
            user_input = "start!" if is_workflow else user_input  # 워크플로우 시작 메시지 설정
            history = []
            order = 0

        # 세션이 존재하는 경우 해당 세션을 가져옴 + 대화 히스토리 호출
        else:
            session = get_object_or_404(ChatSession, id=session_id)
            is_workflow = session.is_workflow
            session.time = timezone.now() 
            messages = session.message_set.all().order_by('order')
            if not user_input:
                return Response({'error': 'user_input is required'}, status=status.HTTP_400_BAD_REQUEST)
            order = messages.last().order + 1 if messages else 0
            if messages:
                history = []
                for m in messages:
                    parts = [Part(text=m.message)]
                    #___________________________________________________________________________________
                    if m.images:
                        for image in m.images.all():
                            with open(image.image.path, 'rb') as img_file:
                                img_bytes = img_file.read()
                            mime_type = mimetypes.guess_type(image.image.path)[0]
                            img_data = types.Part.from_bytes(data=img_bytes, mime_type=mime_type)
                            parts.append(img_data)
                    #___________________________________________________________________________________
                    if m.files:
                        for file in m.files.all():
                            with open(file.file.path, 'rb') as file_obj:
                                file_bytes = file_obj.read()
                            mime_type = mimetypes.guess_type(file.file.path)[0]
                            file_data = types.Part.from_bytes(data=file_bytes, mime_type= mime_type)
                            parts.append(file_data)
                    #___________________________________________________________________________________
                    if m.audios:
                        for audio in m.audios.all():
                            with open(audio.audio.path, 'rb') as audio_obj:
                                audio_bytes = audio_obj.read()
                            mime_type = mimetypes.guess_type(audio.audio.path)[0]
                            audio_data = types.Part.from_bytes(data=audio_bytes, mime_type=mime_type)
                            parts.append(audio_data)
                    #___________________________________________________________________________________
                    history.append(Content(role=m.sender.lower(), parts=parts))    

        # 워크플로우 여부, 검색 여부 등 세부 사항 설정 (생성 준비 단계)
        #___________________________________________________________________________________    
        system_prompt = character_prompt
        if is_workflow:
            system_prompt += "\n" + workflow_prompts
        
        elif is_user_context_required(user_input, client):
            search_result = user_context_node(user_input, session.user.id)
            if search_result:
                user_context = " ".join([point.payload['text'] for point in search_result])
                system_prompt += f"\n\n유저가 당신에게 했던 질문들은 다음과 같습니다. 이 질문들에 담긴 유저의 성향, 데이터 등을 참고해 알맞는 응답을 생성해 주세요: {user_context}"

        is_search = is_search or is_search_required(user_input, client)
        if is_search:
            # Define the grounding tool
            grounding_tool = types.Tool(
            google_search=types.GoogleSearch()
            )
            # Configure generation settings
            config = types.GenerateContentConfig(
            tools=[grounding_tool],
            system_instruction= system_prompt,
            )
        else:
            config = types.GenerateContentConfig(
            system_instruction= system_prompt,
            )
    
        # 응답 생성 
        #___________________________________________________________________________________
        try:
            parts = [Part(text=user_input)]

            if images:
                for image in images:
                    mime_type = mimetypes.guess_type(image.name)[0]
                    parts.append(Part.from_bytes(data=image.read(), mime_type=mime_type))
            if files:
                for file in files:
                    mime_type = mimetypes.guess_type(file.name)[0]
                    parts.append(Part.from_bytes(data=file.read(), mime_type=mime_type))
            if audios:
                for audio in audios:
                    mime_type = mimetypes.guess_type(audio.name)[0]
                    parts.append(Part.from_bytes(data=audio.read(), mime_type=mime_type))

            history.append(Content(role="user", parts=parts))
            response = client.models.generate_content(
                model="gemini-2.5-flash",
                contents=history,
                config=config
            )

            # 워크플로우 여부 판단 로직, 최종 답변인 경우 요약 생성 및 형식 조정
            if response.text[0:2] == 'fa':
                model_output = response.text[2:]
                session.is_workflow = False
                user = session.user
                system_prompt = f"Summarize the following conversation in one short sentence (less then 5 word) that clearly conveys the user's main intent or request. Be specific and avoid vague or generic summaries. The user is from korea.You should use the language of the user."
                config = types.GenerateContentConfig(
                    system_instruction=system_prompt
                    )
                summary = client.models.generate_content(
                    model="gemini-2.5-flash",
                    contents=[Content(parts=[Part(text=model_output)])],
                    config=config
                    )
                session.summary = summary.text
                first_message = session.message_set.filter(order=0).first()
                if first_message:
                    first_message.delete()
                session.save()
                is_final_response = True
                # emotion report 생성
                EmotionReport.objects.create(
                    session=session,
                    user=user,
                    content=model_output
                )
                #문단 별로 나눠서 리스트로 변환
                model_output = model_output.split("\n\n")
                model_output = [output.strip() for output in model_output if output.strip()]

            else:
                model_output = response.text

            if is_search:
                citations = []
                titles = []
                chunks = response.candidates[0].grounding_metadata.grounding_chunks
                if chunks:
                    for chunk in chunks:
                        uri = chunk.web.uri
                        title = chunk.web.title
                        citations.append(uri)
                        titles.append(title)

        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        # 메시지 저장
        #___________________________________________________________________________________
        message = Message.objects.create(session=session, 
            sender='user',
            message=user_input, 
            order=order, 
            is_workflow=is_workflow)

        if images:
            for image in images:
                Image.objects.create(
                    message=message,
                    image=image,
                    caption=""
                )
        if files:
            for file in files:
                File.objects.create(
                    message=message,
                    file=file,
                    description=""
                )
        if audios:
            for audio in audios:
                Audio.objects.create(
                    message=message,
                    audio=audio,
                    description=""
                )

        if is_search:
            output = Message.objects.create(
                session=session, 
                sender='model', 
                message=model_output, 
                order=order + 1,
            )
            search_result = list(zip(citations, titles))
            for (citation, title) in search_result:
                Citation.objects.create(
                    message=output, 
                    text=title, 
                    uri=citation
                )
        else:
            Message.objects.create(session=session, 
                sender='model', 
                message=model_output,
                order=order + 1,)
            search_result = []

        # 만약 처음 생성하는 워크플로우가 아닌 메세지라면, 메세지 요약본을 생성해 저장.
        if order == 0 and not session.is_workflow:
            user = session.user
            system_prompt = f"Summarize the following conversation in one short sentence (less then 5 word) that clearly conveys the user's main intent or request. Be specific and avoid vague or generic summaries. The user is from korea."
            config = types.GenerateContentConfig(
                system_instruction=system_prompt
                )
            summary = client.models.generate_content(
                model="gemini-2.5-flash",  
                contents=[Content(parts=[Part(text=model_output)])],
                config=config
            )
            session.summary = summary.text
            session.save() 

        # 모델 응답 전송
        #____________________________________________________________________________________

        if session.is_workflow and not is_final_answer:
            model_output = re.split(r"\d+:", model_output)
            model_output = [output.strip() for output in model_output if output.strip()]

        else: 
            model_output = [model_output]

        if not is_workflow:
            threading.Thread(target=embed_task, args=(message, embed_prompt, user_input, client), daemon=True).start()

        return Response({'response': model_output, 'session_id': session_id, 'is_workflow': session.is_workflow, 'search_result': search_result, 'is_final_answer': is_final_answer}, status=status.HTTP_200_OK)
    
    
    #____________________________________________________________________________________
    def put(self, request):
        """
        Role: 프론트엔드에서 특정 챗 세션의 메시지를 수정해, 이후의 대화 (order 기준) 내역을 삭제한뒤, 해당 메시지에 대한 새로운 응답을 생성해 반환함.
        URL : /api/chat/sessions/
        Input: URL 형식으로 해당 세션의 아이디 (session_id)와 해당 세션에서의 order를 전달하고, Request body로 수정할 메시지 내용을 전달합니다. 
        Return: 성공적으로 수정되었다는 메시지를 반환합니다.
        """

        # 필요한 파라미터 설정
        #___________________________________________________________________________________
        session_id = request.data.get('session_id')
        user_input = request.data.get('user_input')
        is_search = request.data.get('is_search', False)  # 검색 여부 (선택 사항)
        images = request.FILES.getlist('images', None)  # 이미지 파일 (선택 사항)
        files = request.FILES.getlist('files', None)  # 파일 업로드 (선택 사항)
        audios = request.FILES.getlist('audios', None)  # 오디오 파일 업로드 (선택 사항)
        order = request.data.get('order', 0)  # 메시지 순서 (기본값은 0)

        # 수정 메시지 기준 이후 메시지들을 삭제하고 대화 히스토리 호출
        #___________________________________________________________________________________
        if not session_id:
            return Response({'error':'session_id is required'}, status=status.HTTP_400_BAD_REQUEST)
        
        session = get_object_or_404(ChatSession, id=session_id)
        is_workflow = session.message_set.get(order=order).is_workflow 
        session.is_workflow = is_workflow
        delete_messages = session.message_set.filter(order__gte=order)
        delete_messages.delete()
        messages = session.message_set.all().order_by('order')
        history = []
        for m in messages:
            parts = [Part(text=m.message)]
            #___________________________________________________________________________________
            if m.images:
                for image in m.images.all():
                    with open(image.image.path, 'rb') as img_file:
                        img_bytes = img_file.read()
                    mime_type = mimetypes.guess_type(image.image.path)[0]
                    img_data = types.Part.from_bytes(data=img_bytes, mime_type=mime_type)
                    parts.append(img_data)
            #___________________________________________________________________________________
            if m.files:
                for file in m.files.all():
                    with open(m.file.path, 'rb') as file_obj:
                        file_bytes = file_obj.read()
                    mime_type = mimetypes.guess_type(m.file.path)[0]
                    file_data = types.Part.from_bytes(data=file_bytes, mime_type= mime_type)
                    parts.append(file_data)
            #___________________________________________________________________________________
            if m.audios:
                for audio in m.audios.all():
                    with open(m.audio.path, 'rb') as audio_obj:
                        audio_bytes = audio_obj.read()
                    mime_type = mimetypes.guess_type(m.audio.path)[0]
                    audio_data = types.Part.from_bytes(data=audio_bytes, mime_type=mime_type)
                    parts.append(audio_data)
            #___________________________________________________________________________________
            history.append(Content(role=m.sender.lower(), parts=parts))    

        # 워크플로우 여부, 검색 여부 등 세부 사항 설정 (생성 준비 단계)
        #___________________________________________________________________________________     
        character = session.character
        system_prompt = character.system_prompt
        if is_workflow:
            system_prompt += "\n" + workflow_prompts

        if is_search:
            # Define the grounding tool
            grounding_tool = types.Tool(
            google_search=types.GoogleSearch()
            )
            # Configure generation settings
            config = types.GenerateContentConfig(
            tools=[grounding_tool],
            system_instruction= system_prompt,
            )
        else:
            config = types.GenerateContentConfig(
            system_instruction= system_prompt,
            )
    
        # 응답 생성 
        #___________________________________________________________________________________
        try:
            parts = [Part(text=user_input)]

            if images:
                for image in images:
                    mime_type = mimetypes.guess_type(image.name)[0]
                    parts.append(Part.from_bytes(data=image.read(), mime_type=mime_type))
            if files:
                for file in files:
                    mime_type = mimetypes.guess_type(file.name)[0]
                    parts.append(Part.from_bytes(data=file.read(), mime_type=mime_type))
            if audios:
                for audio in audios:
                    mime_type = mimetypes.guess_type(audio.name)[0]
                    parts.append(Part.from_bytes(data=audio.read(), mime_type=mime_type))

            history.append(Content(role="user", parts=parts))
            response = client.models.generate_content(
                model="gemini-2.5-flash",
                contents=history,
                config=config
            )

            # 워크플로우 여부 판단 로직, 최종 답변인 경우 요약 생성 및 형식 조정
            if response.text[0:2] == 'fa':
                model_output = response.text[2:]
                session.is_workflow = False
                user = session.user
                country = user.country.name if user.country else "Unknown"
                system_prompt = f"Summarize the following conversation in one short sentence (less then 5 word) that clearly conveys the user's main intent or request. Be specific and avoid vague or generic summaries. The user is from {country}.You should use the language of the user."
                model = generativeai.GenerativeModel(
                model_name='gemini-2.5-flash',  
                system_instruction=system_prompt
                )
                summary_chat = model.start_chat()
                summary_response = summary_chat.send_message(model_output)
                session.summary = summary_response.text
                first_message = session.message_set.filter(order=0).first()
                if first_message:
                    first_message.delete()
                session.save()

            else:
                model_output = response.text

            if is_search:
                citations = []
                titles = []
                chunks = response.candidates[0].grounding_metadata.grounding_chunks
                if chunks:
                    for chunk in chunks:
                        uri = chunk.web.uri
                        title = chunk.web.title
                        citations.append(uri)
                        titles.append(title)


        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        # 메시지 저장
        #___________________________________________________________________________________
        message = Message.objects.create(session=session, 
            sender='user',
            message=user_input, 
            order=order, 
            is_workflow=is_workflow)

        if images:
            for image in images:
                Image.objects.create(
                    message=message,
                    image=image,
                    caption=""
                )
        if files:
            for file in files:
                File.objects.create(
                    message=message,
                    file=file,
                    description=""
                )
        if audios:
            for audio in audios:
                Audio.objects.create(
                    message=message,
                    audio=audio,
                    description=""
                )

        if is_search:
            output = Message.objects.create(
                session=session, 
                sender='model', 
                message=model_output, 
                order=order + 1,
            )
            search_result = list(zip(citations, titles))
            for (citation, title) in search_result:
                Citation.objects.create(
                    message=output, 
                    text=title, 
                    uri=citation
                )
        else:
            Message.objects.create(session=session, 
                sender='model', 
                message=model_output,
                order=order + 1,)
            search_result = []

        # 만약 처음 생성하는 워크플로우가 아닌 메세지라면, 메세지 요약본을 생성해 저장.
        if order == 0 and not session.is_workflow:
            user = session.user
            country = user.country.name if user.country else "Unknown"
            system_prompt = f"Summarize the following conversation in one short sentence (less then 5 word) that clearly conveys the user's main intent or request. Be specific and avoid vague or generic summaries. The user is from {country}."
            model = generativeai.GenerativeModel(
            model_name='gemini-2.5-flash',  
            system_instruction=system_prompt
            )
            summary_chat = model.start_chat()
            summary_response = summary_chat.send_message(model_output)
            session.summary = summary_response.text
            session.save() 

        # 모델 응답 전송
        #____________________________________________________________________________________

        if session.is_workflow:
            model_output = re.split(r"\d+:", model_output)
            model_output = [output.strip() for output in model_output if output.strip()]

        else: 
            model_output = [model_output]

        return Response({'response': model_output, 'session_id': session_id, 'is_workflow': session.is_workflow, 'search_result': search_result}, status=status.HTTP_200_OK)

