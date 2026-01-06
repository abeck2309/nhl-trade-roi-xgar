# NHL Trade ROI Tracker (xGAR-Based)

This project evaluates the return on investment (ROI) of major NHL trades using a combination of realized on-ice value and expected future value.

## Overview
Player value is measured using xGAR (expected Goals Above Replacement) for skaters. Trades are evaluated from each team’s perspective by comparing:
- Realized xGAR produced by acquired players
- Remaining expected value (EV) from draft picks and prospects
- Opportunity cost of players traded away

The result is a net trade value metric that can be analyzed over different time horizons.

## Methodology

### Player Value
- Skater value measured using xGAR (Evolving Hockey)
- Only xGAR produced after the trade date is counted

### Draft Picks
- First-round picks use a position-specific expected xGAR curve
- Rounds 2–7 use round-level expected values
- Picks are time-discounted at 10% annually starting in 2027

### Prospects
- Drafted prospects with no NHL games are valued using expected xGAR
- Prospect EV is discounted based on years since draft to account for attrition

### Scope
- Goalie-only trades are excluded
- Trades with incomplete skater data are excluded

## Tools
- Google BigQuery (SQL)
- Tableau Public
- Microsoft Excel
