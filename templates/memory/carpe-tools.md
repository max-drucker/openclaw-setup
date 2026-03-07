# Carpe Data — Internal Tools & Applications

> Tools built by Carpe Data for internal use and customer-facing demos.

## Carpe Intel — OSINT Investigation Platform
**Domain:** carpeintel.com
**What:** AI-powered Open Source Intelligence (OSINT) investigation tool built for claims professionals.

### What It Does
- Runs automated investigations on insurance claimants using public online data
- Searches Google, DuckDuckGo, social media, news, images, and public records
- Enriches social profiles via Bright Data (Instagram, LinkedIn, Facebook, Twitter, TikTok)
- AI analyzes findings for fraud indicators and generates intelligence reports
- Exports detailed HTML/PDF investigation reports

### Investigation Tiers
| Tier | Speed | What It Does |
|------|-------|-------------|
| **Score** | <5 seconds | Quick Google search → social check → numeric risk score (0-100) |
| **Instant** | <30 seconds | Google + DuckDuckGo + basic social scan → short summary |
| **Thinking** | <3 minutes | Full pipeline: search, social enrichment, claims analysis, detailed AI report |
| **Pro** | <5 minutes | Everything in Thinking + news, reverse email/phone, deep claims, comprehensive report |

### How It Works (16-Step Pipeline)
1. Google Search (multi-query: name, emails, phones)
2. DuckDuckGo Search
3. Basic Social Scan (Facebook, Instagram, LinkedIn, Twitter, TikTok)
4. Deep Social Enumeration
5. Email-based Search
6. Phone-based Search
7. Image Search
8. Social Profile Enrichment via Bright Data (parallel, all profiles at once)
9. Claims Flag Analysis (AI detects fraud indicators in social content)
10. Deduplication
11. AI Intelligence Brief
12. News & Media Search
13. Reverse Email Lookup
14. Reverse Phone Lookup
15. Deep Claims Analysis (cross-reference activity patterns)
16. Comprehensive AI Report (6-section intelligence report)

### Architecture
- **Frontend:** Next.js on Vercel (carpeintel.com)
- **Worker:** Node.js on Railway (handles long-running investigations, no timeout)
- **Database:** Supabase (investigation queue, results, progress tracking)
- **AI:** Claude Opus 4.6 via OpenRouter (primary), GPT Codex fallback
- **Data Sources:** Serper (Google Search API), Bright Data (social scraping), DuckDuckGo

### Use Case
Claims adjusters and SIU teams use Carpe Intel to:
- Investigate claimants for fraud indicators before paying claims
- Verify identity and cross-reference social media activity with claim details
- Generate evidence-backed investigation reports
- Replace manual social media research with automated, bias-free, compliant investigations

### Relationship to ClaimsX
Carpe Intel is the **investigation tool** — on-demand deep dives. ClaimsX is the **monitoring platform** — continuous automated surveillance. They complement each other: ClaimsX flags claims that need attention, Carpe Intel does the deep investigation.

---

## Minerva Explorer — API Testing & Demo Tool
**Domain:** minervaexplorer2026.com
**What:** Interactive explorer for the Minerva commercial underwriting API.

### What It Does
- Look up any US business and see what Minerva returns
- View all data products: risk scores, indexes, business characteristics, NAICS classification
- Compare Carpe Instant (sub-second) vs. Carpe Thinking (AI-enhanced) results
- Visualize the Carpe Risk Score (1-5) with explanations
- Export results for presentations and demos

### Who Uses It
- **Sales team:** Demo Minerva to prospects during calls — "give me any business name and address"
- **Product team:** Test data quality, match rates, score distributions
- **Engineering:** Debug API responses, validate data pipelines
- **Prospects:** Self-service exploration during evaluation

### Architecture
- **Frontend:** Next.js on Vercel
- **Backend:** Calls Minerva API directly
- **Auth:** Secured — Carpe team access only

### Key Features
- Address autocomplete (Google Places)
- Side-by-side Instant vs. Thinking comparison
- Score breakdown visualization
- Business characteristics display
- Classification confidence display
- Export to PDF/clipboard

---

## Carpe Closer — Sales Intelligence Platform
**Domain:** carpecloser.com
**What:** Internal platform for managing RFIs, RFPs, and sales proposals.

### What It Does
- Upload RFI/RFP documents (PDF, Word)
- AI parses questions and generates draft responses using Carpe product knowledge
- 5-model AI consensus engine (Claude, GPT, Gemini, etc.) for high-quality answers
- Collaborative editing — sales team reviews and refines AI-generated responses
- Export polished proposals

### Who Uses It
- Sales team: Geoff, Matt, Ian, Kate, Maddie
- Used for responding to carrier RFIs and RFPs
- Dramatically reduces response time (days → hours)

### Architecture
- **Frontend:** Next.js on Vercel
- **Database:** Supabase
- **AI:** OpenRouter (5-model consensus)
- **Branding:** Full Carpe Data branding (red #D42027 + navy #1B2D6B)

---

## How These Tools Fit Together

```
PROSPECT JOURNEY:
                                              
  Minerva Explorer ──→ Sales Demo ──→ Carpe Closer ──→ RFP Response ──→ Deal Won!
  (show the data)      (prove value)  (answer questions)  (close it)
                                              
CLAIMS WORKFLOW:
                                              
  ClaimsX ──→ Flag suspicious claims ──→ Carpe Intel ──→ Deep investigation ──→ Report
  (monitor)   (automated alerts)         (on-demand)     (evidence-backed)
```
