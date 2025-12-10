# Branch Testing Tracker - Calculator Website

Use this file to keep notes on which branches you're testing and findings.

## Active Testing Sessions

### Session Date: _________

**Branches Being Tested:**
- [ ] main (baseline)
- [ ] develop
- [ ] feature-_________ (Port: 5173)
- [ ] feature-_________ (Port: 5174)
- [ ] bugfix-__________ (Port: 5175)
- [ ] hotfix-__________ (Port: 5176)

**Testing Focus:**
- Purpose: _______________________________________________
- What to compare: _______________________________________
- Expected outcome: ______________________________________

**Environment:**
- [ ] DeepL API token configured
- [ ] All dependencies installed
- [ ] All servers started successfully
- [ ] Browser tabs organized

---

## Branch Status Tracking

### Main Branch
- **Port:** 5173
- **Status:** ☐ Setup ☐ Running ☐ Tested
- **Notes:** 
  - 
  - 

### Branch: _________________
- **Port:** 5174
- **Status:** ☐ Setup ☐ Running ☐ Tested
- **Purpose:** 
- **Key Changes:** 
- **Notes:** 
  - 
  - 
- **Issues Found:**
  - [ ] 
  - [ ] 

### Branch: _________________
- **Port:** 5175
- **Status:** ☐ Setup ☐ Running ☐ Tested
- **Purpose:** 
- **Key Changes:** 
- **Notes:** 
  - 
  - 
- **Issues Found:**
  - [ ] 
  - [ ] 

### Branch: _________________
- **Port:** 5176
- **Status:** ☐ Setup ☐ Running ☐ Tested
- **Purpose:** 
- **Key Changes:** 
- **Notes:** 
  - 
  - 
- **Issues Found:**
  - [ ] 
  - [ ] 

---

## Testing Checklist

### Pre-Testing
- [ ] All branches pulled latest changes
- [ ] npm dependencies up to date
- [ ] Environment variables configured
- [ ] Servers started and accessible
- [ ] Browser DevTools open

### During Testing
- [ ] Test on main branch first (baseline)
- [ ] Document differences found
- [ ] Screenshot issues/changes
- [ ] Test all major features
- [ ] Check console for errors
- [ ] Verify responsive design
- [ ] Test translation functionality

### Post-Testing
- [ ] Document findings in this file
- [ ] Create GitHub issues if needed
- [ ] Commit any test notes to repo
- [ ] Stop all dev servers
- [ ] Cleanup unused worktrees

---

## Comparison Matrix

| Feature/Test | Main | Branch 1 | Branch 2 | Branch 3 | Winner |
|--------------|------|----------|----------|----------|--------|
| UI/UX | | | | | |
| Performance | | | | | |
| Translations | | | | | |
| Mobile | | | | | |
| Embed Widget | | | | | |
| Accessibility | | | | | |

**Rating Scale:** ⭐⭐⭐⭐⭐ (5 stars), 🐛 (has bugs), ✅ (works), ❌ (broken)

---

## Performance Metrics

| Branch | Load Time | Bundle Size | Lighthouse Score | Memory Usage |
|--------|-----------|-------------|------------------|--------------|
| main | | | | |
| | | | | |
| | | | | |

---

## Issues & Bugs Found

### Issue #1
- **Branch:** _____________
- **Severity:** ☐ Critical ☐ High ☐ Medium ☐ Low
- **Description:** 
- **Steps to Reproduce:**
  1. 
  2. 
  3. 
- **Expected:** 
- **Actual:** 
- **Screenshot/URL:** 
- **GitHub Issue:** #_____

### Issue #2
- **Branch:** _____________
- **Severity:** ☐ Critical ☐ High ☐ Medium ☐ Low
- **Description:** 
- **Steps to Reproduce:**
  1. 
  2. 
  3. 
- **Expected:** 
- **Actual:** 
- **Screenshot/URL:** 
- **GitHub Issue:** #_____

---

## Decision Log

### Decision Date: _________
**Question:** Which branch/approach should we use for X feature?

**Options Tested:**
1. **Branch:** _________ 
   - Pros: 
   - Cons: 
   
2. **Branch:** _________ 
   - Pros: 
   - Cons: 

**Decision:** We chose ___________ because:
- 
- 

**Action Items:**
- [ ] Merge chosen branch
- [ ] Close/archive other branches
- [ ] Update documentation
- [ ] Notify team

---

## Translation Testing

### Languages Tested
- [ ] English (en)
- [ ] Spanish (es)
- [ ] French (fr)
- [ ] German (de)
- [ ] _________

### Translation Quality
| Branch | Accuracy | Completeness | Issues |
|--------|----------|--------------|--------|
| main | | | |
| | | | |

**DeepL API Status:**
- Token configured: ☐ Yes ☐ No
- API calls working: ☐ Yes ☐ No
- Rate limit status: _________

---

## Embed Widget Testing

### Embed Modes Tested
- [ ] Calculator embed
- [ ] Results embed
- [ ] Custom theme embed

### Integration Tests
| Branch | Loads | Functional | Styling | Cross-origin |
|--------|-------|------------|---------|--------------|
| main | | | | |
| | | | | |

---

## Browser Compatibility

### Browsers Tested
| Browser | Version | Main | Branch 1 | Branch 2 | Notes |
|---------|---------|------|----------|----------|-------|
| Chrome | | | | | |
| Firefox | | | | | |
| Edge | | | | | |
| Safari | | | | | |

---

## Mobile Testing

### Devices Tested
| Device | OS | Main | Branch 1 | Branch 2 | Notes |
|--------|-----|------|----------|----------|-------|
| iPhone | iOS | | | | |
| Android | | | | | |
| iPad | iPadOS | | | | |

---

## Next Steps

### Immediate
- [ ] 
- [ ] 
- [ ] 

### This Week
- [ ] 
- [ ] 
- [ ] 

### Future
- [ ] 
- [ ] 
- [ ] 

---

## Cleanup Checklist

When testing is complete:
- [ ] Stop all dev servers
- [ ] Document all findings above
- [ ] Create GitHub issues for bugs
- [ ] Remove worktrees: `.\cleanup-worktrees.ps1 -Branches @(...)`
- [ ] Archive this testing session (save to dated file)
- [ ] Clear browser cache/data

---

## Commands Used This Session

```powershell
# Record the exact commands used for reproducibility

# Setup
.\setup-worktrees.ps1 -Branches @("main", "...")

# Start
.\start-all-servers.ps1 -OnlyBranches @("...")

# Cleanup
.\cleanup-worktrees.ps1 -Branches @("...")
```

---

## Notes & Observations

### General Notes:


### Surprising Findings:


### Questions for Team:
1. 
2. 
3. 

---

**Testing Session Completed:** ☐ Yes ☐ No  
**Tested By:** __________________  
**Date:** __________________  
**Total Testing Time:** __________ hours
