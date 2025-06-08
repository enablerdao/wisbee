#!/bin/bash

# Cloudflare DNS Setup for wisbee.ai → Vercel
echo "🌐 Setting up Cloudflare DNS for wisbee.ai"

# Check if required environment variables are set
if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo "❌ Error: CLOUDFLARE_API_TOKEN not set"
    echo "Please set your Cloudflare API token:"
    echo "export CLOUDFLARE_API_TOKEN='your-token-here'"
    exit 1
fi

if [ -z "$ZONE_ID" ]; then
    echo "❌ Error: ZONE_ID not set"
    echo "Please set your wisbee.ai zone ID:"
    echo "export ZONE_ID='your-zone-id-here'"
    exit 1
fi

# Function to create/update DNS record
create_dns_record() {
    local name=$1
    local content=$2
    local type=${3:-CNAME}
    
    echo "📝 Creating DNS record: $name → $content"
    
    response=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
         -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
         -H "Content-Type: application/json" \
         --data "{
           \"type\": \"$type\",
           \"name\": \"$name\",
           \"content\": \"$content\",
           \"ttl\": 1,
           \"proxied\": true
         }")
    
    success=$(echo $response | jq -r '.success')
    if [ "$success" = "true" ]; then
        echo "✅ Successfully created $name record"
    else
        echo "❌ Failed to create $name record"
        echo "Response: $response"
    fi
}

# Create DNS records
echo ""
echo "🚀 Creating DNS records for Vercel..."

# Root domain
create_dns_record "@" "cname.vercel-dns.com"

# WWW subdomain  
create_dns_record "www" "cname.vercel-dns.com"

echo ""
echo "✅ DNS setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Go to Vercel Dashboard: https://vercel.com/dashboard"
echo "2. Select 'wisbee' project"
echo "3. Go to Settings → Domains"
echo "4. Add domain: wisbee.ai"
echo "5. Add domain: www.wisbee.ai (redirect to wisbee.ai)"
echo ""
echo "🕒 DNS propagation may take up to 48 hours"
echo "🔍 Check status: dig wisbee.ai"