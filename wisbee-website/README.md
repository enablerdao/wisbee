# Wisbee Website

This is the official website for Wisbee, hosted at [wisbee.ai](https://wisbee.ai).

## Deployment

This website is deployed using GitHub Pages. To deploy:

1. Push this directory to a GitHub repository
2. Enable GitHub Pages in repository settings
3. Set up custom domain (wisbee.ai) in GitHub Pages settings
4. Update DNS records:
   - Add A records pointing to GitHub Pages IPs:
     - 185.199.108.153
     - 185.199.109.153
     - 185.199.110.153
     - 185.199.111.153
   - Or add CNAME record pointing to `[your-username].github.io`

## Local Development

To test locally:
```bash
python3 -m http.server 8000
# Then open http://localhost:8000
```

## Updates

To update download links or version numbers, edit `index.html` and push to GitHub.