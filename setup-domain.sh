#!/bin/bash

echo "🌐 Wisbee.ai Domain Setup for Vercel"
echo "=================================="

# Cloudflare Dashboard URL for DNS management
echo "📋 Manual Steps Required:"
echo ""
echo "1. 🔐 Get Cloudflare API Token:"
echo "   - Go to: https://dash.cloudflare.com/profile/api-tokens"
echo "   - Click 'Create Token'"
echo "   - Use 'Edit zone DNS' template"
echo "   - Select zone: wisbee.ai"
echo "   - Copy the token"
echo ""

echo "2. 🌍 Get Zone ID:"
echo "   - Go to: https://dash.cloudflare.com"
echo "   - Select wisbee.ai domain"
echo "   - Copy Zone ID from right sidebar"
echo ""

echo "3. 🚀 Run DNS setup:"
cat << 'EOF'
export CLOUDFLARE_API_TOKEN="your-token-here"
export ZONE_ID="your-zone-id-here"

# Create CNAME records for Vercel
curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
     -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{
       "type": "CNAME",
       "name": "@",
       "content": "cname.vercel-dns.com",
       "ttl": 1,
       "proxied": true
     }'

curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
     -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{
       "type": "CNAME",
       "name": "www",
       "content": "cname.vercel-dns.com",
       "ttl": 1,
       "proxied": true
     }'
EOF

echo ""
echo "4. 📊 Add to Vercel:"
echo "   - Go to: https://vercel.com/yukihamadas-projects/wisbee/settings/domains"
echo "   - Add domain: wisbee.ai"
echo "   - Add domain: www.wisbee.ai"
echo ""

echo "✅ Current Vercel URLs:"
echo "   - Development: https://wisbee-p7puf6hpb-yukihamadas-projects.vercel.app"
echo "   - Production:  https://wisbee.vercel.app"
echo ""

echo "🔍 Once setup, test with:"
echo "   dig wisbee.ai"
echo "   curl -I https://wisbee.ai"