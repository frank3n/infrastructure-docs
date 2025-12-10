# GitHub Repositories List

**Owner:** frank3n
**Scan Date:** December 9, 2025
**Total Repositories:** 9

---

## Repository Overview

| # | Repository | Description | Visibility | Created | TypeScript? |
|---|------------|-------------|------------|---------|-------------|
| 1 | calculator-website | Calculator website with multi-language support | Private | 2025-12-08 | ✅ YES |
| 2 | vpn-setup-scripts | Creating scripts for vpn setup | Private | 2025-11-30 | ❓ Unknown |
| 3 | wide-shoe-finder | (No description) | Private | 2025-11-20 | ❓ Unknown |
| 4 | claude-code-credits | Testing claude code 1000 USD credits until Nov 18 | Private | 2025-11-17 | ❓ Unknown |
| 5 | electronics | (No description) | Private | 2025-11-12 | ❓ Unknown |
| 6 | adventurer-dating-website | Claude code coding adventurer dating website, that can be whitelabel | Private | 2025-11-09 | ✅ Likely YES |
| 7 | d1-template | (No description) | Private | 2025-07-04 | ❓ Unknown |
| 8 | elevenlabs-sfx | (No description) | Public, Fork | 2024-06-21 | ❓ Unknown |
| 9 | FTDParser | Used to build csv files for any desired ticker from FTD data | Public, Fork | 2021-06-12 | ❌ NO (Python) |

---

## Repositories for TypeScript Quality Rollout

### High Priority (Confirmed TypeScript)

#### 1. ✅ calculator-website
**Status:** Phase 2 Complete
**URL:** https://github.com/frank3n/calculator-website
**Type:** React + TypeScript + Vite
**Quality Status:**
- ✅ Phase 1 & 2 complete on `claude/multilang-calculator-plan-011CUz48qy2HekjPBWXe9Req`
- ✅ 0 TypeScript errors
- ✅ 99.97% type coverage
- ✅ All CI/CD workflows set up

**Action:** None needed - template is ready

---

#### 2. ❓ adventurer-dating-website
**Status:** Not analyzed yet
**URL:** https://github.com/frank3n/adventurer-dating-website
**Description:** "Claude code coding adventurer dating website, that can be whitelabel"
**Created:** November 9, 2025
**Likely TypeScript:** YES (Claude Code projects typically use TypeScript)

**Recommended Action:** 
1. Clone and scan for TypeScript errors
2. Apply Phase 1 & 2 improvements using rollout scripts
3. Estimate: Similar scope to calculator-website

**Priority:** HIGH (Recent project, likely needs quality improvements)

---

### Medium Priority (Need Analysis)

#### 3. ❓ wide-shoe-finder
**Status:** Unknown
**URL:** https://github.com/frank3n/wide-shoe-finder
**Created:** November 20, 2025

**Action:** Check if TypeScript project
```bash
gh repo clone frank3n/wide-shoe-finder
cd wide-shoe-finder
ls -la
```

---

#### 4. ❓ electronics
**Status:** Unknown
**URL:** https://github.com/frank3n/electronics
**Created:** November 12, 2025

**Action:** Check contents and determine if applicable

---

#### 5. ❓ claude-code-credits
**Status:** Unknown (Testing project)
**URL:** https://github.com/frank3n/claude-code-credits
**Description:** "Testing claude code 1000 USD credits until Nov 18"
**Created:** November 17, 2025

**Action:** Check if TypeScript project, may be test/playground

---

#### 6. ❓ d1-template
**Status:** Unknown
**URL:** https://github.com/frank3n/d1-template
**Created:** July 4, 2025

**Action:** Check if Cloudflare D1 + TypeScript project

---

### Low Priority

#### 7. ❓ vpn-setup-scripts
**Status:** Likely shell scripts
**URL:** https://github.com/frank3n/vpn-setup-scripts
**Type:** Probably Bash/Shell scripts
**Priority:** LOW (Not TypeScript)

---

#### 8. ⏭️ elevenlabs-sfx (Fork)
**Status:** Public fork
**URL:** https://github.com/frank3n/elevenlabs-sfx
**Priority:** SKIP (Public fork - don't modify without upstream PR)

---

#### 9. ⏭️ FTDParser (Fork)
**Status:** Public fork - Python project
**URL:** https://github.com/frank3n/FTDParser
**Priority:** SKIP (Not TypeScript)

---

## Summary

### TypeScript Projects
- ✅ **Confirmed:** 1 (calculator-website)
- ❓ **Likely:** 1 (adventurer-dating-website)
- ❓ **Unknown:** 4 (need analysis)
- ❌ **Not TypeScript:** 2 (vpn-setup-scripts, FTDParser)
- ⏭️ **Skip:** 1 (elevenlabs-sfx - public fork)

### Recommended Next Steps

1. **Immediate:** Clone and analyze `adventurer-dating-website`
2. **Quick scan:** Check `wide-shoe-finder`, `electronics`, `claude-code-credits`, `d1-template`
3. **Apply rollout:** Use automation scripts for confirmed TypeScript projects

---

## Automation Commands

### Clone and Scan All Unknown Repos
```bash
# Clone repos for analysis
gh repo clone frank3n/adventurer-dating-website
gh repo clone frank3n/wide-shoe-finder
gh repo clone frank3n/electronics
gh repo clone frank3n/claude-code-credits
gh repo clone frank3n/d1-template

# Check each for package.json
for repo in adventurer-dating-website wide-shoe-finder electronics claude-code-credits d1-template; do
  echo "=== $repo ==="
  if [ -f "$repo/package.json" ]; then
    echo "✅ Has package.json"
    cat "$repo/package.json" | grep -E '"typescript|react|@types'
  else
    echo "❌ No package.json"
  fi
  echo ""
done
```

### Quick Lint Check
```bash
# For each TypeScript repo found
cd <repo-name>
npm ci
npm run lint 2>&1 | grep -c "error"
```

### Apply Rollout (When Ready)
```powershell
# Update repos-to-scan.txt with new repo paths
# Then run:
powershell -ExecutionPolicy Bypass -File scan-all-repos.ps1
powershell -ExecutionPolicy Bypass -File rollout-to-all-repos.ps1 -DryRun
```

---

## Priority Matrix

| Repository | TypeScript? | Priority | Est. Errors | Est. Time |
|------------|-------------|----------|-------------|-----------|
| calculator-website | ✅ YES | ✅ COMPLETE | 0 | Done |
| adventurer-dating-website | ⭐ LIKELY | 🔥 HIGH | 50-100? | 2-3 hours |
| wide-shoe-finder | ❓ UNKNOWN | 🔶 MEDIUM | Unknown | TBD |
| electronics | ❓ UNKNOWN | 🔶 MEDIUM | Unknown | TBD |
| claude-code-credits | ❓ UNKNOWN | 🔶 MEDIUM | Unknown | TBD |
| d1-template | ❓ UNKNOWN | 🔶 MEDIUM | Unknown | TBD |
| vpn-setup-scripts | ❌ NO | ⏸️ LOW | N/A | N/A |
| elevenlabs-sfx (fork) | ❓ | ⏭️ SKIP | N/A | N/A |
| FTDParser (fork) | ❌ NO | ⏭️ SKIP | N/A | N/A |

---

**Next Action:** Clone and analyze `adventurer-dating-website` (highest priority)

