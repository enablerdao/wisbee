#!/bin/bash

# Wisbee Vercel Deployment Script
# This script deploys the Wisbee website to Vercel

echo "🐝 Wisbee Vercel Deployment"
echo "=========================="

# Check if we're in the right directory
if [ ! -f "index.html" ]; then
    echo "❌ Error: index.html not found. Make sure you're in the wisbee directory."
    exit 1
fi

# Check if vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    echo "📦 Installing Vercel CLI..."
    npm install -g vercel
fi

# Login to Vercel (if not already logged in)
echo "🔑 Checking Vercel authentication..."
if ! vercel whoami &> /dev/null; then
    echo "Please login to Vercel:"
    vercel login
fi

# Deploy to Vercel
echo "🚀 Deploying to Vercel..."
vercel --prod

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 Check your deployment:"
echo "   - Vercel Dashboard: https://vercel.com/dashboard"
echo "   - Your site will be available at: https://your-project.vercel.app"
echo ""
echo "🔧 To customize your domain:"
echo "   1. Go to your Vercel dashboard"
echo "   2. Select your project"
echo "   3. Go to Settings > Domains"
echo "   4. Add your custom domain"
echo ""
echo "📝 For more help:"
echo "   - Vercel docs: https://vercel.com/docs"
echo "   - Wisbee GitHub: https://github.com/enablerdao/wisbee"