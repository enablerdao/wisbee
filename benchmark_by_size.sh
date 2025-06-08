#!/usr/bin/env bash
# Benchmark script for models by size category

echo "Starting benchmarks with size-specific token limits..."
echo "=========================================="

# 7b models with 2000 token limit
echo -e "\n📊 Testing 7b models (2000 token limit):"
./obench2.sh llava:7b --max-tok 2000

# 1.7b and smaller models with 3000 token limit  
echo -e "\n📊 Testing 1.7b and smaller models (3000 token limit):"
./obench2.sh qwen3:1.7b --max-tok 3000
./obench2.sh llama3.2:1b --max-tok 3000
./obench2.sh gemma3:1b --max-tok 3000
./obench2.sh jaahas/qwen3-abliterated:0.6b --max-tok 3000

# Medium models with default limit
echo -e "\n📊 Testing medium models (default 256 token limit):"
./obench2.sh qwen3:latest gemma3:4b phi3:mini

echo -e "\n✅ Benchmark complete!"
echo "Results saved to ~/oeval_logs/"