#!/usr/bin/env python3
"""
Enhanced Voice Chat Server with Multiple TTS Options
Supports Edge TTS, VOICEVOX, and other voice synthesis options
"""

import asyncio
import json
import logging
import os
import time
from aiohttp import web
from aiohttp_cors import setup, ResourceOptions
import aiohttp
import numpy as np
from typing import Optional, Dict, Any
import base64
import io

# Audio processing imports
try:
    import soundfile as sf
    import librosa
    AUDIO_ENABLED = True
except ImportError:
    AUDIO_ENABLED = False
    print("Warning: Audio libraries not installed. Install with: pip install soundfile librosa")

# TTS imports
try:
    from gtts import gTTS
    from pydub import AudioSegment
    from pydub.effects import speedup
    GTTS_ENABLED = True
except ImportError:
    GTTS_ENABLED = False
    print("Warning: gTTS not installed. Install with: pip install gtts pydub")

# For more natural TTS (optional)
try:
    import edge_tts
    EDGE_TTS_ENABLED = True
except ImportError:
    EDGE_TTS_ENABLED = False
    print("Info: edge-tts not installed. Install with: pip install edge-tts for better voice quality")

# For anime-style voices (optional)
try:
    from voicevox import Client as VoicevoxClient
    VOICEVOX_ENABLED = True
except ImportError:
    VOICEVOX_ENABLED = False
    print("Info: voicevox-client not installed. Install with: pip install voicevox-client for anime-style voices")

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class VoiceProcessor:
    """Handles audio processing and voice synthesis"""
    
    def __init__(self):
        self.sample_rate = 16000
        self.voices = {
            # Edge TTS voices (realistic)
            'ja-JP-NanamiNeural': {'type': 'edge', 'lang': 'ja-JP', 'style': 'realistic'},
            'ja-JP-KeitaNeural': {'type': 'edge', 'lang': 'ja-JP', 'style': 'realistic'}, 
            'en-US-JennyNeural': {'type': 'edge', 'lang': 'en-US', 'style': 'realistic'},
            'en-US-GuyNeural': {'type': 'edge', 'lang': 'en-US', 'style': 'realistic'},
            # VOICEVOX voices (anime-style)
            'voicevox-zundamon': {'type': 'voicevox', 'speaker_id': 3, 'style': 'anime'},
            'voicevox-tsumugi': {'type': 'voicevox', 'speaker_id': 8, 'style': 'anime'},
            'voicevox-himari': {'type': 'voicevox', 'speaker_id': 14, 'style': 'anime'},
            'voicevox-metan': {'type': 'voicevox', 'speaker_id': 2, 'style': 'anime'},
            'voicevox-ritsu': {'type': 'voicevox', 'speaker_id': 6, 'style': 'anime'}
        }
        self.voicevox_client = None
        if VOICEVOX_ENABLED:
            try:
                self.voicevox_client = VoicevoxClient()
            except:
                print("Warning: Could not connect to VOICEVOX engine. Make sure it's running on http://localhost:50021")
    
    async def text_to_speech_edge(self, text: str, voice: str = 'ja-JP-NanamiNeural') -> Optional[bytes]:
        """Convert text to speech using Edge TTS for natural voice"""
        if not EDGE_TTS_ENABLED:
            return None
            
        try:
            communicate = edge_tts.Communicate(text, voice)
            audio_data = b""
            
            async for chunk in communicate.stream():
                if chunk["type"] == "audio":
                    audio_data += chunk["data"]
            
            return audio_data
        except Exception as e:
            logger.error(f"Edge TTS error: {e}")
            return None
    
    async def text_to_speech_voicevox(self, text: str, speaker_id: int = 3) -> Optional[bytes]:
        """Convert text to speech using VOICEVOX for anime-style voices"""
        if not VOICEVOX_ENABLED or not self.voicevox_client:
            return None
            
        try:
            # Generate audio query
            loop = asyncio.get_event_loop()
            audio_query = await loop.run_in_executor(
                None, 
                lambda: self.voicevox_client.audio_query(text, speaker=speaker_id)
            )
            
            # Synthesize audio
            audio_data = await loop.run_in_executor(
                None,
                lambda: self.voicevox_client.synthesis(audio_query, speaker=speaker_id)
            )
            
            return audio_data
        except Exception as e:
            logger.error(f"VOICEVOX error: {e}")
            return None
    
    def text_to_speech_gtts(self, text: str, lang: str = 'ja') -> Optional[bytes]:
        """Fallback TTS using gTTS"""
        if not GTTS_ENABLED:
            return None
            
        try:
            tts = gTTS(text=text, lang=lang, slow=False)
            fp = io.BytesIO()
            tts.write_to_fp(fp)
            fp.seek(0)
            
            # Speed up slightly for more natural speech
            audio = AudioSegment.from_file(fp, format="mp3")
            audio = speedup(audio, 1.1)
            
            # Convert to WAV
            wav_fp = io.BytesIO()
            audio.export(wav_fp, format="wav")
            wav_fp.seek(0)
            
            return wav_fp.read()
        except Exception as e:
            logger.error(f"gTTS error: {e}")
            return None
    
    def process_audio_chunk(self, audio_data: bytes) -> Dict[str, Any]:
        """Process incoming audio chunk for real-time analysis"""
        if not AUDIO_ENABLED:
            return {"status": "audio_disabled"}
            
        try:
            # Decode audio
            audio_array, sr = sf.read(io.BytesIO(audio_data))
            
            # Resample if needed
            if sr != self.sample_rate:
                audio_array = librosa.resample(audio_array, orig_sr=sr, target_sr=self.sample_rate)
            
            # Calculate features for VAD (Voice Activity Detection)
            rms = np.sqrt(np.mean(audio_array**2))
            is_speech = rms > 0.01  # Simple threshold
            
            return {
                "status": "processed",
                "is_speech": is_speech,
                "rms": float(rms),
                "duration": len(audio_array) / self.sample_rate
            }
        except Exception as e:
            logger.error(f"Audio processing error: {e}")
            return {"status": "error", "message": str(e)}

class RealtimeVoiceServer:
    def __init__(self, ollama_host: str = "localhost", ollama_port: int = 11434):
        self.ollama_base_url = f"http://{ollama_host}:{ollama_port}"
        self.voice_processor = VoiceProcessor()
        self.active_connections: Dict[str, web.WebSocketResponse] = {}
        
    async def websocket_handler(self, request):
        """WebSocket handler for real-time voice communication"""
        ws = web.WebSocketResponse()
        await ws.prepare(request)
        
        connection_id = str(time.time())
        self.active_connections[connection_id] = ws
        
        try:
            async for msg in ws:
                if msg.type == aiohttp.WSMsgType.TEXT:
                    data = json.loads(msg.data)
                    await self.handle_websocket_message(ws, data)
                elif msg.type == aiohttp.WSMsgType.BINARY:
                    # Handle binary audio data
                    result = self.voice_processor.process_audio_chunk(msg.data)
                    await ws.send_json({"type": "audio_processed", "data": result})
                elif msg.type == aiohttp.WSMsgType.ERROR:
                    logger.error(f'WebSocket error: {ws.exception()}')
        except Exception as e:
            logger.error(f"WebSocket handler error: {e}")
        finally:
            self.active_connections.pop(connection_id, None)
            
        return ws
    
    async def handle_websocket_message(self, ws: web.WebSocketResponse, data: Dict[str, Any]):
        """Handle different types of WebSocket messages"""
        msg_type = data.get("type")
        
        if msg_type == "transcription":
            # Process transcribed text
            text = data.get("text", "")
            model = data.get("model", "gemma3:4b")
            voice = data.get("voice", "ja-JP-NanamiNeural")
            
            # Stream response from Ollama
            await self.stream_ollama_response(ws, text, model, voice)
            
        elif msg_type == "audio_chunk":
            # Process audio chunk
            audio_b64 = data.get("audio", "")
            audio_bytes = base64.b64decode(audio_b64)
            result = self.voice_processor.process_audio_chunk(audio_bytes)
            await ws.send_json({"type": "audio_analysis", "data": result})
        
        elif msg_type == "list_voices":
            # Send available voices
            voices_list = []
            for voice_id, voice_info in self.voice_processor.voices.items():
                voices_list.append({
                    "id": voice_id,
                    "name": self.get_voice_display_name(voice_id),
                    "type": voice_info['type'],
                    "style": voice_info.get('style', 'unknown')
                })
            await ws.send_json({"type": "voices_list", "voices": voices_list})
    
    def get_voice_display_name(self, voice_id: str) -> str:
        """Get display name for voice"""
        voice_names = {
            'ja-JP-NanamiNeural': '日本語 - ななみ (リアル女性)',
            'ja-JP-KeitaNeural': '日本語 - けいた (リアル男性)',
            'en-US-JennyNeural': 'English - Jenny (Realistic Female)',
            'en-US-GuyNeural': 'English - Guy (Realistic Male)',
            'voicevox-zundamon': 'ずんだもん (アニメ)',
            'voicevox-tsumugi': '春日部つむぎ (アニメ)',
            'voicevox-himari': '九州そら (アニメ)',
            'voicevox-metan': '四国めたん (アニメ)',
            'voicevox-ritsu': '波音リツ (アニメ)'
        }
        return voice_names.get(voice_id, voice_id)
    
    async def stream_ollama_response(self, ws: web.WebSocketResponse, prompt: str, model: str, voice: str):
        """Stream response from Ollama and convert to speech in chunks"""
        try:
            # Start streaming from Ollama
            async with aiohttp.ClientSession() as session:
                async with session.post(
                    f"{self.ollama_base_url}/api/generate",
                    json={"model": model, "prompt": prompt, "stream": True}
                ) as response:
                    
                    full_text = ""
                    buffer = ""
                    sentence_endings = ["。", "！", "？", ".", "!", "?", "\n"]
                    
                    async for line in response.content:
                        if line:
                            try:
                                chunk = json.loads(line)
                                if "response" in chunk:
                                    text_chunk = chunk["response"]
                                    full_text += text_chunk
                                    buffer += text_chunk
                                    
                                    # Send text chunk immediately
                                    await ws.send_json({
                                        "type": "text_chunk",
                                        "text": text_chunk
                                    })
                                    
                                    # Check for sentence completion
                                    for ending in sentence_endings:
                                        if ending in buffer:
                                            # Generate speech for complete sentence
                                            sentence = buffer.split(ending)[0] + ending
                                            buffer = buffer[len(sentence):]
                                            
                                            # Generate TTS
                                            audio_data = await self.generate_tts(sentence, voice)
                                            if audio_data:
                                                await ws.send_json({
                                                    "type": "audio_chunk",
                                                    "audio": base64.b64encode(audio_data).decode(),
                                                    "text": sentence
                                                })
                                            break
                                    
                                if chunk.get("done", False):
                                    # Process remaining buffer
                                    if buffer.strip():
                                        audio_data = await self.generate_tts(buffer, voice)
                                        if audio_data:
                                            await ws.send_json({
                                                "type": "audio_chunk",
                                                "audio": base64.b64encode(audio_data).decode(),
                                                "text": buffer
                                            })
                                    
                                    # Send completion
                                    await ws.send_json({
                                        "type": "complete",
                                        "text": full_text
                                    })
                                    break
                                    
                            except json.JSONDecodeError:
                                continue
                                
        except Exception as e:
            logger.error(f"Ollama streaming error: {e}")
            await ws.send_json({
                "type": "error",
                "message": str(e)
            })
    
    async def generate_tts(self, text: str, voice: str) -> Optional[bytes]:
        """Generate TTS audio with multiple engine options"""
        # Skip if text is too short
        if len(text.strip()) < 2:
            return None
            
        voice_info = self.voice_processor.voices.get(voice, {'type': 'edge', 'lang': 'ja-JP'})
        
        # Use VOICEVOX for anime-style voices
        if voice_info['type'] == 'voicevox' and VOICEVOX_ENABLED:
            audio = await self.voice_processor.text_to_speech_voicevox(text, voice_info['speaker_id'])
            if audio:
                return audio
        
        # Try Edge TTS for natural voices
        if voice_info['type'] == 'edge' and EDGE_TTS_ENABLED:
            audio = await self.voice_processor.text_to_speech_edge(text, voice)
            if audio:
                return audio
        
        # Fallback to gTTS
        if GTTS_ENABLED:
            lang = 'ja' if 'ja' in voice else 'en'
            audio = self.voice_processor.text_to_speech_gtts(text, lang)
            if audio:
                return audio
        
        return None
    
    async def chat_handler(self, request):
        """Regular HTTP endpoint for non-streaming chat"""
        try:
            data = await request.json()
            prompt = data.get("prompt", "")
            model = data.get("model", "gemma3:4b")
            voice = data.get("voice", "ja-JP-NanamiNeural")
            
            # Get response from Ollama
            async with aiohttp.ClientSession() as session:
                async with session.post(
                    f"{self.ollama_base_url}/api/generate",
                    json={"model": model, "prompt": prompt, "stream": False}
                ) as response:
                    result = await response.json()
                    text = result.get("response", "")
            
            # Generate TTS
            audio_data = await self.generate_tts(text, voice)
            
            response_data = {"text": text}
            if audio_data:
                response_data["audio"] = base64.b64encode(audio_data).decode()
            
            return web.json_response(response_data)
            
        except Exception as e:
            logger.error(f"Chat handler error: {e}")
            return web.json_response({"error": str(e)}, status=500)
    
    async def health_handler(self, request):
        """Health check endpoint"""
        return web.json_response({
            "status": "healthy",
            "audio_enabled": AUDIO_ENABLED,
            "gtts_enabled": GTTS_ENABLED,
            "edge_tts_enabled": EDGE_TTS_ENABLED,
            "voicevox_enabled": VOICEVOX_ENABLED,
            "available_voices": list(self.voice_processor.voices.keys()),
            "timestamp": time.time()
        })

def create_app():
    """Create and configure the web application"""
    server = RealtimeVoiceServer()
    app = web.Application()
    
    # Add routes
    app.router.add_get("/ws", server.websocket_handler)
    app.router.add_post("/chat", server.chat_handler)
    app.router.add_get("/health", server.health_handler)
    
    # Serve static files from current directory
    app.router.add_static('/', path='.', name='static')
    
    # Configure CORS
    cors = setup(app, defaults={
        "*": ResourceOptions(
            allow_credentials=True,
            expose_headers="*",
            allow_headers="*",
            allow_methods="*"
        )
    })
    
    for route in list(app.router.routes()):
        cors.add(route)
    
    return app

if __name__ == "__main__":
    app = create_app()
    print("Enhanced Voice Server starting on http://localhost:8890")
    print(f"Edge TTS: {'Enabled' if EDGE_TTS_ENABLED else 'Disabled'}")
    print(f"VOICEVOX: {'Enabled' if VOICEVOX_ENABLED else 'Disabled'}")
    print(f"gTTS: {'Enabled' if GTTS_ENABLED else 'Disabled'}")
    web.run_app(app, host="0.0.0.0", port=8890)