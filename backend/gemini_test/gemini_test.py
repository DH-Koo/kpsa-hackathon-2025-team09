import os
from google import genai
from dotenv import load_dotenv
from google.genai import types
from google.genai.types import Part, Content
import base64

load_dotenv()

client = genai.Client(api_key=os.environ["GEMINI_API_KEY"])

user_context_prompt = """유저의 기분에 따라 추천할 음악을, 검색 기능을 사용하여 사운드클라우드 url을 찾아보고, 해당 곡의 내용에 대해 설명해 주세요. 유저의 기분은 다음과 같습니다. 긍정도:
{positivity}, 에너지: {energy}, 스트레스: {stress}, 자기 자제력: {self_control}.
각 항목에 대해, 모든 값들은 0부터 10 사이의 정수로 입력되며, 10은 해당 값이 가장 높은 상태를, 0은 해당 값이 가장 낮은 상태를 의미합니다.
조건: 사운드클라우드에서 곡을 검색할 때, 반드시 무료로 스트리밍이 가능한 곡을 선택해야 합니다.
"""

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

#____________________________________________________________________________________
def add_citations(response):
    text = response.text
    supports = response.candidates[0].grounding_metadata.grounding_supports
    chunks = response.candidates[0].grounding_metadata.grounding_chunks

    sorted_supports = sorted(supports, key=lambda s: s.segment.end_index, reverse=True)

    for support in sorted_supports:
        end_index = support.segment.end_index
        if support.grounding_chunk_indices:
            citation_links = []
            for i in support.grounding_chunk_indices:
                if i < len(chunks):
                    uri = chunks[i].web.uri
                    citation_links.append(f"[{i + 1}]({uri})")
            citation_string = ", ".join(citation_links)
            text = text[:end_index] + citation_string + text[end_index:]

    return text

#____________________________________________________________________________________
# 입력 처리
is_image_file = None
history = []

user_input = "추천 음악을 4개 찾고, 이에 대한 설명을 작성해 주세요. 설명을 작성할 때는 반드시 유저의 기분 상태를 근거로 왜 이 음악을 추천하는지 설명해 주세요."
is_search = bool(input("검색 도구를 사용할까요? (T/F): ").strip().lower() == 't')

if is_search:
    system_prompt = user_context_prompt.format(
        positivity=input("긍정도를 입력하세요: "),
        energy=input("에너지를 입력하세요: "),
        stress=input("스트레스를 입력하세요: "),
        self_control=input("자기 자제력을 입력하세요: ")
    )
else:
    system_prompt = medicine_prompts

#___________________________________________________________________________________

parts = [Part(text=user_input)]

if is_image_file:
    with open(is_image_file, "rb") as image_file:
        image_bytes = image_file.read()
        image_data = types.Part.from_bytes(data=image_bytes, mime_type="image/jpeg")
        parts.append(image_data)

contents = [Content(role="user", parts=parts)]

#___________________________________________________________________________________

if is_search:
    grounding_tool = types.Tool(google_search=types.GoogleSearch())
    config = types.GenerateContentConfig(
        tools=[grounding_tool],
        system_instruction=system_prompt,
    )
    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=contents,
        config=config,
    )
    text_with_citations = add_citations(response)
    print(text_with_citations)
else:
    config = types.GenerateContentConfig(system_instruction=system_prompt)
    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=contents,
        config=config
    )
    print(response.text)
