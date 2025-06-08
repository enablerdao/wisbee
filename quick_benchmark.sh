#!/usr/bin/env bash
# Quick performance benchmark

echo "Running performance benchmarks..."
echo "================================="

# Run obench.sh for all models
./obench.sh llava:7b qwen3:latest gemma3:4b qwen3:1.7b phi3:mini llama3.2:1b gemma3:1b jaahas/qwen3-abliterated:0.6b