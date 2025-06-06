#!/usr/bin/env python3
"""
Standalone LLM Chat Server using llama-cpp-python
Fast, lightweight alternative to Ollama
"""

import os
import json
import asyncio
from pathlib import Path
from typing import Optional, List, Dict
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException
from fastapi.responses import StreamingResponse, FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from llama_cpp import Llama
import uvicorn

# Model configurations
MODEL_CONFIGS = {
    "tinyllama-1.1b": {
        "url": "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf",
        "context_size": 2048,
        "gpu_layers": 35,  # Adjust based on your GPU
    },
    "phi-2": {
        "url": "https://huggingface.co/TheBloke/phi-2-GGUF/resolve/main/phi-2.Q4_K_M.gguf",
        "context_size": 2048,
        "gpu_layers": 40,
    },
    "orca-mini-3b": {
        "url": "https://huggingface.co/TheBloke/orca_mini_3B-GGUF/resolve/main/orca-mini-3b.q4_k_m.gguf",
        "context_size": 2048,
        "gpu_layers": 43,
    }
}

class ChatRequest(BaseModel):
    model: str
    prompt: str
    stream: bool = True
    options: Optional[Dict] = None

class ModelManager:
    def __init__(self, models_dir: Path):
        self.models_dir = models_dir
        self.models_dir.mkdir(exist_ok=True)
        self.loaded_models: Dict[str, Llama] = {}
        self.current_model: Optional[str] = None
        
    async def download_model(self, model_name: str) -> Path:
        """Download model if not exists"""
        if model_name not in MODEL_CONFIGS:
            raise ValueError(f"Unknown model: {model_name}")
            
        model_path = self.models_dir / f"{model_name}.gguf"
        
        if not model_path.exists():
            print(f"Downloading {model_name}...")
            from huggingface_hub import hf_hub_download
            
            config = MODEL_CONFIGS[model_name]
            hf_hub_download(
                repo_id=config["url"].split("/")[3] + "/" + config["url"].split("/")[4],
                filename=config["url"].split("/")[-1],
                local_dir=str(self.models_dir),
                local_dir_use_symlinks=False
            )
            # Rename to our standard name
            downloaded_file = self.models_dir / config["url"].split("/")[-1]
            downloaded_file.rename(model_path)
            
        return model_path
    
    async def load_model(self, model_name: str) -> Llama:
        """Load or switch to a model"""
        if model_name in self.loaded_models:
            self.current_model = model_name
            return self.loaded_models[model_name]
            
        model_path = await self.download_model(model_name)
        config = MODEL_CONFIGS[model_name]
        
        print(f"Loading {model_name}...")
        
        # Unload other models to save memory (keep only 1 model loaded)
        if len(self.loaded_models) >= 1:
            oldest_model = list(self.loaded_models.keys())[0]
            del self.loaded_models[oldest_model]
            
        llm = Llama(
            model_path=str(model_path),
            n_ctx=config["context_size"],
            n_gpu_layers=config["gpu_layers"],
            n_threads=8,  # Adjust based on your CPU
            verbose=False
        )
        
        self.loaded_models[model_name] = llm
        self.current_model = model_name
        return llm

# Global model manager
model_manager: Optional[ModelManager] = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    global model_manager
    models_dir = Path.home() / ".llama_models"
    model_manager = ModelManager(models_dir)
    
    # Pre-load a default model
    await model_manager.load_model("tinyllama-1.1b")
    
    yield
    
    # Cleanup
    model_manager.loaded_models.clear()

app = FastAPI(lifespan=lifespan)

@app.post("/api/generate")
async def generate(request: ChatRequest):
    """Generate text from the model"""
    try:
        if not model_manager:
            raise HTTPException(status_code=500, detail="Model manager not initialized")
            
        # Load/switch model if needed
        llm = await model_manager.load_model(request.model)
        
        # Extract parameters
        options = request.options or {}
        temperature = options.get("temperature", 0.7)
        max_tokens = options.get("num_predict", 512)
        
        # Format prompt (simple chat format)
        formatted_prompt = f"User: {request.prompt}\nAssistant:"
        
        if request.stream:
            async def generate_stream():
                stream = llm(
                    formatted_prompt,
                    max_tokens=max_tokens,
                    temperature=temperature,
                    stream=True,
                    stop=["User:", "\n\n"]
                )
                
                for output in stream:
                    token = output["choices"][0]["text"]
                    response = json.dumps({"response": token}) + "\n"
                    yield response.encode()
                    
            return StreamingResponse(generate_stream(), media_type="application/x-ndjson")
        else:
            output = llm(
                formatted_prompt,
                max_tokens=max_tokens,
                temperature=temperature,
                stop=["User:", "\n\n"]
            )
            
            response_text = output["choices"][0]["text"].strip()
            return {"response": response_text}
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/models")
async def list_models():
    """List available models"""
    return {
        "models": [
            {"name": name, "loaded": name in model_manager.loaded_models}
            for name in MODEL_CONFIGS.keys()
        ]
    }

@app.get("/config.json")
async def get_config():
    """Return configuration for the UI"""
    return {
        "ollama": {
            "defaultModel": "tinyllama-1.1b",
            "models": list(MODEL_CONFIGS.keys())
        },
        "ui": {
            "defaultMaxTokens": 512,
            "defaultTemperature": 0.7,
            "title": "Fast Local LLM Chat",
            "subtitle": "Powered by llama.cpp"
        }
    }

# Serve static files
@app.get("/")
async def read_index():
    return FileResponse("static/index.html")

if __name__ == "__main__":
    # Create static directory and copy HTML file
    static_dir = Path("static")
    static_dir.mkdir(exist_ok=True)
    
    # Check if we need to copy the HTML file
    html_source = Path("../index.html")
    html_dest = static_dir / "index.html"
    
    if html_source.exists() and not html_dest.exists():
        import shutil
        shutil.copy(html_source, html_dest)
        print(f"Copied {html_source} to {html_dest}")
    
    # Mount static files
    app.mount("/static", StaticFiles(directory="static"), name="static")
    
    print("🚀 Starting Fast Local LLM Chat Server")
    print("📍 Open http://localhost:8899 in your browser")
    print("⚡ Using llama.cpp for maximum performance")
    
    uvicorn.run(app, host="0.0.0.0", port=8899)