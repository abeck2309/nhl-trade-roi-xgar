# NHL Trade ROI Tracker (xGAR-Based)

This project evaluates the return on investment (ROI) of major NHL trades using a combination of realized on-ice value and expected future value.
https://www.linkedin.com/pulse/rethinking-nhl-trades-data-driven-return-investment-roi-andrew-beck-7jt8c

## Overview
Player value is measured using xGAR (expected Goals Above Replacement) for skaters. Trades are evaluated from each team’s perspective by comparing:
- Realized xGAR produced by acquired players
- Remaining expected value (EV) from draft picks and prospects
- Opportunity cost of players traded away

The result is a net trade value metric that can be analyzed over different time horizons.

## Methodology (TL;DR)

This analysis evaluates NHL trades using a consistent value framework built on skater xGAR (expected Goals Above Replacement).

- **Realized Value:** xGAR produced by acquired skaters after the trade date.
- **Value Given Up:** xGAR produced post-trade by skaters traded away (opportunity cost).
- **Draft Picks:** Converted to expected xGAR using a pick-value curve (1st round by slot, rounds 2–7 by round).
- **Time Discounting:** Future picks are discounted to reflect delayed realization of value.
- **Prospects:** Drafted but unproven players are valued using expected xGAR and discounted for attrition based on years since draft.
- **Net Trade Value:**  
  *(Realized IN + Expected Value IN) − Realized Value OUT*

Trades are also evaluated across multiple time windows (1-year, 3-year, to-date) and contextualized using cap efficiency (xGAR relative to cap hit). Goalie-only trades are excluded due to the use of skater-based metrics.

## Tool Aspects

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
