# Carpe Data — Product Deep Dive

> Reference file for product questions, RFP responses, and customer conversations.

## Minerva Platform (Commercial Underwriting)

### Carpe Instant (Sub-Second API)
- Pre-built profiles on 50M+ businesses
- Returns 30+ attributes per query
- 50% high-confidence match rate
- Used for: NB triage, automated flow, real-time pricing

### Carpe Thinking (1-3 Minutes, AI-Enhanced)
- Adds +30% match rate (80% total with Instant)
- Multi-paragraph business descriptions
- Custom appetite prompting per carrier
- Hidden AI insights not available in Instant
- New in 2026 — blends LLMs with structured data
- Used for: batch analytics, manual UW, complex risks

### Predictive Scores

| Score | What It Measures | Signal Strength |
|-------|-----------------|-----------------|
| Customer Rating | Aggregated online reviews (numeric) | Hotels in lowest 30th %ile → 70% of losses |
| Reputation | Customer perception from review text | Contractors low score → 150% more losses |
| Loss Propensity | Independent loss prediction model | Low score → 210% more losses |
| Anomaly Score | Business complexity vs. industry norm | Poor score → 2x higher WC losses |
| Proximity | Address-level environmental risks | High entertainment density → 30% higher liability |
| Carpe Risk Score | Composite 1-5 score | 70% of large losses in bottom 35% |

### Carpe Risk Score Scale
| Score | Meaning | UW Action | % of Book |
|-------|---------|-----------|-----------|
| 5 | Far Above Average | Review for credits / STP | 5% |
| 4 | Above Average | Straight-through processing | 25% |
| 3 | Average | Standard processing | 50% |
| 2 | Below Average | Review for debits | 18% |
| 1 | Far Below Average | Decline / Non-renew | 2% |

### Additional Data Products
- **200+ Business Characteristics:** Boolean indicators (outdoor seating, BYOB, live music, etc.)
- **30,000+ Classification Profiles:** Keywords sorted into behavioral profiles
- **NAICS/SIC 2.0:** Up to 5 most likely codes with confidence %
- **5 Index Scores:** Customer Rating, Health & Sanitation, Maintenance & Condition, Reputation, Visibility (1-5, with percentile by zip/state)
- **Location Scores:** Proximity (address) and Density (zip)
- **Lessors Only Risk:** Tenant attributes, NAICS, hours, aggregated scores
- **Business Trends:** 12-month operational change monitoring

### Packaged Solutions
- **AppetiteIQ:** NB appetite selection + triage with reason codes
- **Pricing Insight:** Numeric loss prediction + boolean appetite output
- **Carpe Retain:** Renewal reverification + UW review flagging

### ROI by Use Case (per $1B premium book)
| Use Case | Annual Value |
|----------|-------------|
| Misclassification detection | $3.3M |
| Renewal underwriting efficiency | $2.5M |
| Quote prefill & flow automation | $2.0M |
| UW process time savings | $2.1M |
| Pricing & segmentation lift | $1.0M |
| UW rules automation | $0.5M |
| Target marketing / cross-sell | $0.7M |
| **Total** | **$12.2M** (5-10x ROI) |

---

## ClaimsX Platform (Claims Intelligence)

### Online Injury Alerts
- Automated monitoring from FNOL through closure
- Evidence-based alerts with curated media capture
- Standardized, bias-free (same logic for every claim)
- Continuous — not point-in-time searches
- 5-10% alert rate with actionable evidence

### Alert Reason Codes
- Physical Activity
- Travel
- Lifestyle Activity
- Potentially Unlawful Activity
- Possible Fatality
- Financial Concern
- Association with Business
- Information Related to the Claim
- Pain/Illness/Medical
- LTC-specific: Caregiver Info, Facility/Service Info

### Investigative Reports (RiskIQ Dynamic Tiering)
| Tier | When | Features | % of Orders |
|------|------|----------|-------------|
| Snapshot | Simple validation | AI scan, rapid delivery | 50-70% |
| Standard | Moderate SIU cases | Human-reviewed, more research | 20-40% |
| Pro+ | Complex fraud | Analyst deep-dive, facial recognition, monitoring | 5-15% |

- **No Hit = No Charge**
- **30% savings** vs. traditional flat-rate reports

### Pricing
| Volume (Unique Claimants) | Price/Claimant |
|--------------------------|----------------|
| 0-2,500 | $35 |
| 2,501-5,000 | $33 |
| 5,001-10,000 | $31 |
| 10,001-20,000 | $28 |
| 20,000+ | $25 |

- 15% discount for 2-year commitment
- 20% discount for 3-year commitment

### Claims Reasoning Engine (Flagship 2026)
Pipeline: Sources → Qualifying (AI/entity resolution/QA) → Reasoning (prioritization) → Recommending (next best action, escalation, suggested talk track)
- "Continuous assessment" messaging
- Tiered pricing: $20-$100+ depending on depth

### ROI Model (95K claims/year)
| Category | Impact |
|----------|--------|
| Severity Reduction | $23.6M |
| Litigation Reduction | $5.4M |
| Settlement Speed | $1.6M |
| **Total** | **$30.6M** (5-10x ROI) |

### Cost Comparison
| Model | Coverage | Annual Cost |
|-------|----------|-------------|
| Traditional (deep dives only) | 10% of claims | $1.5M |
| Carpe (automated monitoring) | 100% of claims | $2.0M |
| Internal team (20 FTEs) | 20% of claims | $2.4M |

### Lines of Business
Personal Auto Liability, Commercial Auto Liability, Workers Comp, General Liability, Disability, Malpractice

### Free Pilot Process
1. **Week 1:** Carrier provides CSV of 2,000 claims (zero IT effort)
2. **Weeks 2-3:** Automated screening through Claims Reasoning Engine
3. **Weeks 4-6:** Executive readout with statistics, calibrations, value assessment

---

## Roadmap (2026)

### 0-6 Months
- AppetiteIQ launch
- Enhanced Micro-Match
- Anomaly Score 2.0
- Carpe Risk Score 2.0
- Business Trends
- Social Media Sourcing Optimization
- Investigative Reports V2
- API Enhancements

### 6-12 Months
- Lessors Only Risk GUI
- WC Loss Model
- API Stats Dashboard

### 12+ Months
- Rating Variables
- Company Lookup
- Automated Portfolio Score
- Self-Service Batch

---

## Fraud Statistics (for presentations/proposals)
- 25% of 18-24 year-olds would help bill for treatment not received
- 30% would submit WC claim for off-work injury
- 34-40% of injury medical costs submitted to P&C appear excessive
- $42B yearly impact to auto carriers
- $80B across all insurance lines
