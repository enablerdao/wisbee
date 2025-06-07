# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is an Ollama LLM benchmarking toolkit for evaluating language model performance and quality through speed tests and Q&A evaluations.

## Key Commands

### Performance Benchmarking
```bash
# Test default models (llama3.2, gemma2:2b, qwen2.5:0.5b, llama3.2:1b, smollm2:135m)
./obench.sh

# Test specific models
./obench.sh gemma2:2b llama3:latest

# Test with custom token limit
./obench.sh --max-tok 2048
```

### Q&A Evaluation
```bash
# Run Q&A evaluation with GPT-4 scoring
export OPENAI_API_KEY="your-key-here"
./obench2.sh

# Run without scoring
./obench2.sh --no-score

# Test specific models with custom token limit
./obench2.sh gemma3:1b qwen3:latest --max-tok 128
```

## Architecture

- **obench.sh**: Simple performance benchmarker measuring tokens/second
- **obench2.sh**: Comprehensive Q&A evaluator with optional GPT-4 scoring
- **questions.txt**: 15 Japanese evaluation questions testing various capabilities
- Results logged to `~/oeval_logs/` in JSONL format

## Development Requirements

- Ollama server running on localhost:11434
- Dependencies: `brew install jq bc`
- Optional: OPENAI_API_KEY for Q&A scoring