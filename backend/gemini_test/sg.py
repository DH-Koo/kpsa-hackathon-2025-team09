"""
pip install -U google-genai python-dotenv
.env 파일에 GEMINI_API_KEY=발급받은키 저장
"""
import os, wave, asyncio, time
from dotenv import load_dotenv
from google import genai
from google.genai import types

load_dotenv()
client = genai.Client(api_key=os.environ["GEMINI_API_KEY"],
                      http_options={"api_version": "v1alpha"})

OUT_WAV      = "warm_edm.wav"
MAX_SEC      = 30            # 저장 길이
SAMPLE_RATE  = 48_000        # 48 kHz, 16‑bit PCM, 스테레오 2 ch :contentReference[oaicite:1]{index=1}
SAMPLE_WIDTH = 2
CHANNELS     = 2

async def main():
    async with client.aio.live.music.connect(
        model="models/lyria-realtime-exp"
    ) as session:
        await session.set_weighted_prompts(
            prompts=[types.WeightedPrompt(text="Piano", weight=1.0),
            types.WeightedPrompt(text="Lo-fi", weight=1.0)],
        )
        await session.set_music_generation_config(
            config=types.LiveMusicGenerationConfig(bpm=90, temperature=1.0)
        )

        with wave.open(OUT_WAV, "wb") as wf:
            wf.setnchannels(CHANNELS)
            wf.setsampwidth(SAMPLE_WIDTH)
            wf.setframerate(SAMPLE_RATE)

            await session.play()
            start = time.monotonic()

            async for msg in session.receive():
                wf.writeframes(msg.server_content.audio_chunks[0].data)
                if time.monotonic() - start >= MAX_SEC:
                    await session.stop()
                    break

    print("✅ Saved →", OUT_WAV)

if __name__ == "__main__":
    asyncio.run(main())

user_prompts 