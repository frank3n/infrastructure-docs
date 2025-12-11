# Wide Shoe Finder - Documentation

Documentation for the wide-shoe-finder project deployed on fedora-vps.

---

## 📚 Documentation Files

### 1. [API Test Results](./API-TEST-RESULTS.md)
Comprehensive results from running 23 API test queries against the search endpoint.

**What's inside**:
- ✅ Test summary (23/23 passing, 100% success rate)
- ✅ Detailed results by category (running shoes, dress shoes, boots, etc.)
- ✅ Mock product catalog (6 products)
- ✅ API endpoint details (request/response format)
- ✅ Performance metrics (~520ms average response time)

**Quick stats**:
- 23 total tests
- 138 products found (6 per query)
- 100% success rate
- Average response time: 520ms

### 2. [Setup Guide](./SETUP-GUIDE.md)
Complete step-by-step guide for deploying wide-shoe-finder on VPS.

**What's inside**:
- ✅ GitHub CLI authentication
- ✅ Repository cloning (private repo)
- ✅ Dependency installation
- ✅ Environment configuration (.env setup)
- ✅ Server startup (port 3001)
- ✅ Test execution
- ✅ Troubleshooting common issues

**Key commands**:
```bash
# Start server
PORT=3001 npm run dev

# Run tests
node test-api.js

# Check logs
tail -f /tmp/wide-shoe-finder.log
```

---

## 🚀 Quick Start

### On VPS

```bash
# Clone repository
gh repo clone frank3n/wide-shoe-finder
cd wide-shoe-finder

# Checkout branch
git checkout claude/plan-shoe-finder-01RKZc72zo8gNYbacwWoGMbW

# Install dependencies
npm install

# Create .env file
cat > .env << 'EOF'
RAPIDAPI_KEY=mock_key_for_testing
RAPIDAPI_HOST=real-time-product-search.p.rapidapi.com
USE_MOCK_DATA=true
EOF

# Start server
PORT=3001 npm run dev

# Run tests (in another terminal)
node test-api.js
```

---

## 📊 Project Status

| Component | Status | Details |
|-----------|--------|---------|
| **Repository** | ✅ Cloned | Private repo from frank3n/wide-shoe-finder |
| **Branch** | ✅ Checked out | claude/plan-shoe-finder-01RKZc72zo8gNYbacwWoGMbW |
| **Dependencies** | ✅ Installed | Next.js 16.0.3, React 19, axios, TypeScript |
| **Environment** | ✅ Configured | Mock data mode enabled (.env created) |
| **Server** | ✅ Running | Port 3001 (avoiding conflict with port 3000) |
| **API Tests** | ✅ Passing | 23/23 tests successful |
| **Documentation** | ✅ Complete | 3 markdown files created |

---

## 🏗️ Architecture

### Application Stack
- **Framework**: Next.js 16.0.3 (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **HTTP Client**: axios
- **API**: Next.js Route Handlers

### Deployment
- **VPS**: fedora-vps (138.199.218.115)
- **OS**: Fedora Linux
- **Runtime**: Node.js
- **Port**: 3001
- **Process Manager**: nohup (background process)

### API Integration
- **Provider**: RapidAPI (real-time-product-search)
- **Mode**: Mock data (USE_MOCK_DATA=true)
- **Endpoint**: POST /api/search
- **Response Format**: JSON

---

## 📁 File Locations

### On VPS

```
~/wide-shoe-finder/              # Application code
├── app/api/search/route.ts      # Search API endpoint
├── lib/api.ts                   # Search logic with mock data
├── test-api.js                  # Test script
└── .env                         # Environment configuration

~/wide-shoe-finder-docs/         # Documentation
├── API-TEST-RESULTS.md          # Test results
├── SETUP-GUIDE.md               # Setup instructions
└── README.md                    # This file

/tmp/wide-shoe-finder.log        # Server logs
```

### Locally

```
C:\2025-claude-code-laptop\projects\wide-shoe-finder-docs\
├── API-TEST-RESULTS.md
├── SETUP-GUIDE.md
└── README.md
```

---

## 🧪 Testing

### API Test Coverage

**23 test queries** covering:
- **Running shoes** (8 queries): EE, 2E, EEE, 3E, EEEE, 4E, wide width, extra wide
- **Dress shoes** (4 queries): EE, 2E, EEE, 3E
- **Boots** (3 queries): EEEE, 4E, wide width
- **Athletic/Casual** (5 queries): athletic EE, sneakers 2E, walking 3E, casual wide, loafers EE
- **Brand-specific** (3 queries): New Balance 990 4E, Brooks 2E, ASICS wide

### Test Results
- ✅ **23/23 passing** (100% success rate)
- ✅ **138 products found** (6 per query)
- ✅ **~520ms average response time**
- ✅ **All queries returned results**

See [API-TEST-RESULTS.md](./API-TEST-RESULTS.md) for detailed breakdown.

---

## 🔧 Configuration

### Mock Data Mode (Current)

**Advantages**:
- ✅ No API key required
- ✅ Consistent test results
- ✅ Fast response times
- ✅ No API rate limits
- ✅ Free to use

**Limitations**:
- ❌ Fixed 6 products
- ❌ Same results for all queries
- ❌ Product content doesn't match query
- ❌ Limited variety

### Production Mode (RapidAPI)

**Advantages**:
- ✅ Real product data
- ✅ Query-specific results
- ✅ Large product catalog
- ✅ Multiple retailers
- ✅ Live pricing

**Requirements**:
- RapidAPI subscription
- Valid API key
- Set `USE_MOCK_DATA=false`

---

## 🔍 API Details

### Endpoint
```
POST http://localhost:3001/api/search
```

### Request
```json
{
  "query": "running shoes EE",
  "filters": {
    "width": ["EE", "EEE", "EEEE"],
    "minPrice": 0,
    "maxPrice": 500
  }
}
```

### Response
```json
{
  "products": [
    {
      "id": "1",
      "name": "New Balance 990v5 Extra Wide",
      "price": 184.99,
      "width": "EEEE",
      "retailer": "Amazon",
      "url": "https://amazon.com",
      "availability": true
    }
  ],
  "total": 6
}
```

---

## 📈 Performance

### Mock Data Performance
- **Average Response Time**: 520ms
- **Simulated Delay**: 500ms
- **Range**: 515-583ms
- **Consistency**: Very high (±68ms)

### Expected Real API Performance
- **Response Time**: 1-3 seconds
- **Variability**: Higher (depends on RapidAPI)
- **Rate Limits**: Depends on subscription tier

---

## 🐛 Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Port 3001 in use | `lsof -ti:3001 \| xargs kill -9` |
| 404 errors | Check server is running: `curl localhost:3001` |
| 500 errors | Check `.env` file exists and `USE_MOCK_DATA=true` |
| Module errors | Reinstall dependencies: `npm install` |

See [SETUP-GUIDE.md](./SETUP-GUIDE.md) for detailed troubleshooting.

---

## 📝 Changelog

### December 11, 2025
- ✅ Cloned repository from GitHub (private repo)
- ✅ Checked out branch: claude/plan-shoe-finder-01RKZc72zo8gNYbacwWoGMbW
- ✅ Installed dependencies (Next.js 16.0.3)
- ✅ Created .env file (mock data mode)
- ✅ Started server on port 3001 (avoiding port 3000 conflict)
- ✅ Updated test-api.js to use port 3001
- ✅ Ran 23 API tests - all passing
- ✅ Created comprehensive documentation (3 files)
- ✅ Deployed documentation to VPS

---

## 🔗 Related Documentation

### VPS Management
- `~/CONNECTION-LIMITS.md` - VPS connection limit optimization
- `~/increase-connection-limits.sh` - Connection limit configuration script

### Project Documentation (in repo)
- `API_STATUS.md` - API integration status
- `API_SETUP.md` - API setup instructions
- `PROJECT_PLAN.md` - Project planning document

---

## 🎯 Next Steps

### Immediate
- [x] Repository cloned and configured
- [x] Tests running successfully
- [x] Documentation created

### Short-term
- [ ] Add RapidAPI key for live testing
- [ ] Compare mock vs real API results
- [ ] Test with various product searches
- [ ] Document real API performance

### Long-term
- [ ] Deploy to production domain
- [ ] Add SSL certificate
- [ ] Set up systemd service
- [ ] Configure nginx reverse proxy
- [ ] Add monitoring and logging

---

## 📞 Quick Reference

### Server Commands
```bash
# Start
PORT=3001 npm run dev

# Start in background
PORT=3001 nohup npm run dev > /tmp/wide-shoe-finder.log 2>&1 &

# Stop
lsof -ti:3001 | xargs kill -9

# Check status
curl http://localhost:3001

# View logs
tail -f /tmp/wide-shoe-finder.log
```

### Test Commands
```bash
# Run tests
node test-api.js

# View latest results
cat test-summary-*.json | tail -1

# Count test files
ls test-*.json | wc -l
```

---

**Documentation Created**: December 11, 2025
**Project**: wide-shoe-finder
**VPS**: fedora-vps (138.199.218.115)
**Status**: ✅ Fully Operational
