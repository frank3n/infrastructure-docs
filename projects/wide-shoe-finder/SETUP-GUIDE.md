# Wide Shoe Finder - VPS Setup Guide

**Project**: wide-shoe-finder
**Repository**: https://github.com/frank3n/wide-shoe-finder (private)
**Branch**: claude/plan-shoe-finder-01RKZc72zo8gNYbacwWoGMbW
**VPS**: fedora-vps (138.199.218.115)
**Setup Date**: December 11, 2025

---

## Quick Summary

✅ Repository cloned from GitHub
✅ Dependencies installed
✅ Environment configured (mock data mode)
✅ Dev server running on port 3001
✅ All 23 API tests passing

---

## Prerequisites

### 1. GitHub CLI Authentication
The repository is private and requires GitHub authentication:

```bash
# Check if gh CLI is installed
gh --version

# Login to GitHub (if not already authenticated)
gh auth login

# Verify authentication
gh auth status
```

### 2. Node.js and npm
```bash
node --version  # Should be v18+ for Next.js 16
npm --version
```

---

## Installation Steps

### 1. Clone Repository

```bash
# Using GitHub CLI (required for private repos)
cd ~
gh repo clone frank3n/wide-shoe-finder

cd wide-shoe-finder
```

### 2. Checkout Latest Branch

```bash
# List all branches
gh repo list-branches

# Checkout the newest branch
git checkout claude/plan-shoe-finder-01RKZc72zo8gNYbacwWoGMbW

# Verify branch
git branch
```

### 3. Install Dependencies

```bash
npm install
```

Expected packages:
- Next.js 16.0.3
- React 19
- axios 1.7.9
- TypeScript
- Tailwind CSS

### 4. Configure Environment

Create `.env` file:

```bash
cat > .env << 'EOF'
# RapidAPI Configuration
RAPIDAPI_KEY=mock_key_for_testing
RAPIDAPI_HOST=real-time-product-search.p.rapidapi.com

# Set to 'true' to use mock data for testing without API key
USE_MOCK_DATA=true
EOF
```

**Important**: With `USE_MOCK_DATA=true`, the API will return 6 mock products for all queries. This allows testing without a RapidAPI subscription.

---

## Running the Application

### Start Development Server

```bash
# Port 3000 is used by spot-gold-trading, so use 3001
PORT=3001 npm run dev
```

Server will start at: `http://localhost:3001`

### Start Server in Background

```bash
cd ~/wide-shoe-finder
PORT=3001 nohup npm run dev > /tmp/wide-shoe-finder.log 2>&1 &
echo $!  # Save PID for later
```

### Check Server Status

```bash
# Check if server is running
curl http://localhost:3001

# Check server logs
tail -f /tmp/wide-shoe-finder.log

# Find server process
ps aux | grep next-server | grep 3001

# Stop server
lsof -ti:3001 | xargs kill -9
```

---

## Running API Tests

### Run Test Script

```bash
cd ~/wide-shoe-finder
node test-api.js
```

### Expected Output

```
Starting API tests...

[1/23] Testing: "running shoes EE"
  ✓ Found 6 products in 583ms
[2/23] Testing: "running shoes 2E"
  ✓ Found 6 products in 528ms
...
[23/23] Testing: "ASICS wide width"
  ✓ Found 6 products in 518ms

=== TEST SUMMARY ===
Total tests: 23
Successful: 23
Failed: 0
Total products found: 138
Average products per query: 6.00
```

### Test Output Files

Test results are saved with timestamps:
- `test-results-{timestamp}.json` - Detailed results for each query
- `test-summary-{timestamp}.json` - Aggregated statistics

---

## Port Configuration

### Port Conflicts

The VPS runs multiple Next.js applications:

| Application | Port | Status |
|------------|------|--------|
| spot-gold-trading | 3000 | Running |
| wide-shoe-finder | 3001 | Running |

### Update Test Script Port

The `test-api.js` file has been updated to use port 3001:

```javascript
const API_URL = 'http://localhost:3001/api/search';
```

---

## File Structure

```
~/wide-shoe-finder/
├── app/
│   ├── api/
│   │   └── search/
│   │       └── route.ts        # API endpoint
│   ├── layout.tsx
│   ├── page.tsx
│   └── globals.css
├── lib/
│   ├── api.ts                  # Search logic with mock data
│   └── types.ts
├── components/
├── public/
├── .env                        # Environment configuration
├── .env.example
├── package.json
├── test-api.js                 # API test script
├── test-results-*.json         # Test output files
└── test-summary-*.json

~/wide-shoe-finder-docs/
├── API-TEST-RESULTS.md         # Detailed test results
├── SETUP-GUIDE.md              # This file
└── README.md                   # Project overview
```

---

## Mock Data Details

### Mock Products (6 total)

When `USE_MOCK_DATA=true`, the API returns these products:

1. New Balance 990v5 Extra Wide ($184.99, EEEE)
2. Skechers Work Relaxed Fit ($89.99, EEE)
3. Dunham 8000 Wide Boot ($149.99, EEEE)
4. Allen Edmonds Dress Shoe ($395.00, EE)
5. ASICS Gel-Kayano Extra Wide ($159.99, EEEE)
6. Propét Stability Walker ($79.99, EEE)

### Mock Data Behavior

```typescript
// In lib/api.ts:71
if (USE_MOCK_DATA) {
  console.log('Using mock data for search:', query)
  await new Promise((resolve) => setTimeout(resolve, 500))  // Simulate delay

  return MOCK_PRODUCTS.filter((product) => {
    const widthMatch = filters.width.includes(product.width)
    const priceMatch = product.price >= filters.minPrice && product.price <= filters.maxPrice
    return widthMatch && priceMatch
  })
}
```

---

## Production Configuration

### Switch to Real RapidAPI

1. **Get API Key**:
   - Sign up at: https://rapidapi.com
   - Subscribe to: real-time-product-search API
   - Copy your API key

2. **Update .env**:
   ```env
   RAPIDAPI_KEY=your_actual_rapidapi_key_here
   USE_MOCK_DATA=false
   ```

3. **Restart Server**:
   ```bash
   lsof -ti:3001 | xargs kill -9
   PORT=3001 npm run dev
   ```

4. **Re-run Tests**:
   ```bash
   node test-api.js
   ```

Expected changes:
- Different products per query
- Real product data from Google Shopping
- Response times may vary
- Product counts will differ per query

---

## Troubleshooting

### Server Won't Start - Port in Use

```bash
# Find process using port 3001
lsof -i:3001

# Kill the process
lsof -ti:3001 | xargs kill -9

# Restart server
PORT=3001 npm run dev
```

### Tests Getting 404 Errors

```bash
# Check if server is running
curl http://localhost:3001

# Check server logs for errors
tail -100 /tmp/wide-shoe-finder.log

# Verify .env file exists
cat ~/wide-shoe-finder/.env
```

### Tests Getting 500 Errors

```bash
# Check if USE_MOCK_DATA is set
grep USE_MOCK_DATA ~/wide-shoe-finder/.env

# Should show: USE_MOCK_DATA=true

# If using real API, check RAPIDAPI_KEY is set
grep RAPIDAPI_KEY ~/wide-shoe-finder/.env
```

### Server Logs Show Module Errors

```bash
# Reinstall dependencies
cd ~/wide-shoe-finder
rm -rf node_modules package-lock.json
npm install
```

### Out of Memory Errors

```bash
# Increase Node.js memory limit
NODE_OPTIONS="--max-old-space-size=4096" PORT=3001 npm run dev
```

---

## Monitoring

### Check Active Connections

```bash
# View connections to port 3001
ss -tunapl | grep :3001

# Count active connections
ss -tunapl | grep :3001 | wc -l
```

### Monitor Resource Usage

```bash
# Find Next.js process
ps aux | grep next-server

# Monitor CPU and memory
top -p $(pgrep -f next-server | head -1)
```

### Check Logs in Real-Time

```bash
# Follow server logs
tail -f /tmp/wide-shoe-finder.log

# Follow with grep filter
tail -f /tmp/wide-shoe-finder.log | grep -E 'Error|Warning|Using mock'
```

---

## VPS Connection Limits

The VPS has been optimized for high connection loads:

- **File Descriptors**: 65,536 per process
- **TCP Accept Queue**: 8,192 connections
- **TCP SYN Backlog**: 8,192
- **SSH Max Sessions**: 50

See `~/CONNECTION-LIMITS.md` for full details.

---

## Next Steps

### Immediate
- [x] Repository cloned
- [x] Dependencies installed
- [x] Environment configured
- [x] Tests running successfully

### Short-term
- [ ] Add RapidAPI key for live testing
- [ ] Compare mock vs real API results
- [ ] Test with various product searches
- [ ] Optimize response times

### Long-term
- [ ] Deploy to production domain
- [ ] Add SSL certificate
- [ ] Set up systemd service for auto-restart
- [ ] Configure nginx reverse proxy
- [ ] Add monitoring and alerting

---

## Useful Commands Reference

```bash
# Start server
PORT=3001 npm run dev

# Start server in background
PORT=3001 nohup npm run dev > /tmp/wide-shoe-finder.log 2>&1 &

# Run tests
node test-api.js

# Check server
curl http://localhost:3001

# View logs
tail -f /tmp/wide-shoe-finder.log

# Stop server
lsof -ti:3001 | xargs kill -9

# Check connections
ss -tunapl | grep :3001

# Find process
ps aux | grep next-server | grep 3001
```

---

**Setup Completed**: December 11, 2025
**Documentation By**: Claude Code
**Status**: ✅ Ready for testing
