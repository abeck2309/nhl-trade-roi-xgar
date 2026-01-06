# Valuation Methodology (xGAR-Based Trade ROI)

This project evaluates the ROI of major NHL trades by converting “what was exchanged” into a consistent value unit, then comparing value received vs. value given up over time. The core idea is simple:

**A trade is good if the assets you acquire deliver more on-ice value (or expected future value) than the assets you give away.**

Because trades can include many asset types (players, prospects, draft picks, retained salary, conditions), the methodology is designed to:
1) put everything on one comparable scale (xGAR),
2) avoid double counting value,
3) reflect uncertainty and time value in future assets,
4) remain transparent and defensible.

---

## 1. Primary Value Metric: xGAR (Expected Goals Above Replacement)

### What xGAR represents
**xGAR** (expected Goals Above Replacement) estimates how many goals a skater contributes above a replacement-level player, based on underlying events and context-adjusted expected goal models. In practice, xGAR is useful because it:
- captures two-way impact better than points,
- is less noisy than raw goal differential,
- is additive (you can sum across seasons/players),
- can be compared across positions (skaters).

### Why use xGAR rather than points, WAR, or +/-?
- **Points** measure scoring output, but miss defense, shot suppression, transition value, and usage context.
- **+/-** is extremely sensitive to teammates, systems, and luck.
- **Team results** (wins, playoff rounds) are too coarse and confounded.
- **xGAR / GAR-style metrics** are closer to “player impact” and align with how modern hockey analytics evaluates talent.

### Why “above replacement” matters
Replacement-level baselines make trade comparisons sane:
- If Team A trades away a middle-six winger for a prospect + pick, the right question isn’t “how many points does the winger score?” but “how much impact above an easily replaceable alternative did they give up?”
- Replacement baselines prevent overvaluing average players and highlight true surplus value.

### Scope limitation: skaters only
This project uses skater xGAR tables. That means:
- **Goalies are not valued in realized xGAR** in v1.
- Goalie-heavy trades are excluded to avoid misleading “0 value” outputs.
This is a deliberate scope choice: better to be consistent than to force an incorrect valuation.

---

## 2. Realized Value: What the Acquired Players Actually Produced (Post-Trade)

### Definition
**Realized value** is the xGAR produced by acquired skaters **after the trade date** while they are controlled/owned by the acquiring team.

### Why only post-trade value counts
If you include pre-trade value, you double count:
- A player’s pre-trade xGAR was produced for the original team.
- The trade should be evaluated on what each team got *because of the trade*, not what already happened.

### Why “realized” is separated from “expected”
This matters for interpretation:
- Some trades are immediate wins (contending teams acquiring proven skaters).
- Others are long-horizon bets (rebuilding teams acquiring picks/prospects).
Separating realized and expected makes the story transparent instead of blending everything into one opaque number.

---

## 3. Opportunity Cost: Value Given Up (Realized-Out)

### Definition
**Value given up** is the xGAR produced *after the trade date* by skaters that the team traded away (i.e., what the team no longer had access to).

### Why include “given up” as realized value
Trades are relative. A team can acquire a good player and still lose the trade if they gave up more value. Using post-trade xGAR for outgoing skaters approximates the opportunity cost:
- “If we kept the player, we would have had that value.”
- Instead, the other team got that value.

### Why the model does not use “expected value” for assets you traded away
Once a team trades away a pick or prospect, it no longer has claim to that future upside. In this model, expected value is only counted for assets currently held on the IN side (or until they become realized via NHL games). This avoids double counting and keeps the accounting intuitive:
- **IN side** includes remaining upside you still own.
- **OUT side** measures what you actually lost in realized NHL performance.

---

## 4. Expected Value (EV) of Draft Picks

Draft picks are uncertain future assets. To value them consistently with players, we convert picks into an **expected xGAR outcome**.

### 4.1 Pick EV model structure
The model assigns:
- **First round:** EV by exact pick position (1–32).
- **Rounds 2–7:** EV by round-level averages.

#### Why first-round by pick position?
Top-end outcomes vary dramatically within the first round:
- Pick 1 has vastly different expected impact than pick 28.
Pick-position EV preserves that gradient and prevents treating all first-rounders as equal.

#### Why rounds 2–7 by round-level EV?
After the first round, pick-position variance is high but the signal difference by exact slot is smaller (and data quality can be noisier). Using round averages:
- simplifies the model,
- avoids false precision,
- is easier to explain.

### 4.2 Future pick value vs. “used pick” value
A key rule prevents double counting:

- **If a pick has already been used and the selected player has NHL games**, the pick is no longer an asset—its value is realized through the player’s xGAR.
- The dataset represents this by adding a secondary row under the pick for the drafted player.
- EV is therefore assigned only when the pick still represents uncertainty (future pick) or when the drafted player has not yet produced NHL value.

This mirrors real asset accounting:
- A pick is a claim on a future player.
- Once converted into a player, the pick itself is gone.

---

## 5. Time Discounting of Picks (Time Value of Assets)

Even if two picks have identical expected talent outcomes, a pick that arrives sooner is more valuable for ROI measurement.

### 5.1 Why future value is discounted
A 2027 first-round pick has three practical disadvantages compared to a 2026 first:
1) **Delayed contribution**: You can’t get on-ice value until the player is drafted and developed.
2) **Higher uncertainty**: More things can change (team strength, injuries, league environment).
3) **Opportunity cost of waiting**: A team could deploy value sooner to compete or reallocate.

For ROI tracking, a trade should get more credit for value it can realize sooner.

### 5.2 Discount rule used in this project
- No time discount for **2026 picks** (treated as “near-term” in this dataset).
- Time discount begins with **2027 picks**, increasing for 2028, 2029, etc.
- Discounting is applied as a multiplier to the pick’s EV.

This reflects a pragmatic portfolio lens:
- Short-term picks are close enough that discounting adds little.
- Longer horizons should not be treated as equal to near-term assets.

---

## 6. Prospect Valuation and Prospect Attrition Discount

Prospects are not equal to picks:
- A drafted prospect has already “consumed” a pick.
- Their distribution of outcomes changes as time passes and development unfolds.

### 6.1 Why prospects need an attrition discount
Two prospects drafted at the same slot but in different years are not equally valuable:
- A 2025 draftee is earlier in development; many upside paths remain open.
- A 2023 draftee who still hasn’t established NHL value has already “used up” time and development runway.

Prospects “decay” in probability of becoming impact NHLers if they don’t progress as expected. This is not a perfect rule—late bloomers exist—but it’s directionally consistent and improves realism.

### 6.2 How attrition is applied
For prospects without meaningful NHL contribution (based on NHL games threshold):
- Start with an expected value baseline tied to their draft slot (or pick EV proxy).
- Apply a discount factor based on years since draft.

This produces a common-sense behavior:
- A prospect’s EV is highest immediately after being drafted.
- EV declines if the prospect remains unproven as years pass.

### 6.3 NHL games threshold for “prospect” vs “player”
The dataset classifies drafted assets as:
- **Prospect** if < 20 NHL games
- **Player** if ≥ 20 NHL games

Reasoning:
- <20 games is often “taste of NHL” territory (call-ups, injuries, limited sample noise).
- ≥20 games indicates a more stable transition into NHL usage (still imperfect, but practical).

Once a prospect becomes a player, valuation focuses primarily on realized xGAR rather than hypothetical EV.

---

## 7. Net Trade Value and ROI Outputs

### 7.1 Total Value Received (IN)
For a given team in a trade:
- **Realized IN** = post-trade xGAR from acquired skaters
- **EV IN** = remaining expected xGAR from picks + unproven prospects

So:
**Total IN = Realized IN + EV IN**

### 7.2 Value Given Up (OUT)
- **Realized OUT** = post-trade xGAR produced by skaters traded away

### 7.3 Net Trade Value (NTV)
**NTV = (Realized IN + EV IN) − Realized OUT**

Interpretation:
- NTV > 0: the team gained more value than it gave up (so far, plus remaining upside).
- NTV < 0: the team gave up more value than it received.

### 7.4 Time-window analysis
Trade outcomes can look different at different horizons. To separate “immediate payoff” from “long-term payoff,” the project also reports realized xGAR by windows:
- **1YR**
- **3YR**
- **TO_DATE**

This is crucial because many trades are intentionally structured as:
- win-now rentals (front-loaded realized value),
- rebuild packages (back-loaded EV, later realized).

---

## 8. Cap Efficiency (Value Relative to Cost)

A trade can “win” on raw value but still be inefficient financially. Cap efficiency provides a second lens:
- High xGAR with a low cap hit = strong surplus value.
- High cap hit with low xGAR = poor surplus value.

This is not a full contract model (term, aging curves, buyouts), but it is a strong first-order indicator of whether value was acquired efficiently.

---

## 9. Known Limitations and Future Improvements

This methodology is intentionally transparent and scoped. Key limitations:
- **Goalies not modeled** (skater xGAR only).
- No explicit modeling of:
  - retained salary value,
  - contract term / aging curves,
  - playoff-specific value,
  - team context effects (usage changes).
- EV models are simplified to avoid false precision.

Potential v2 improvements:
- Add goalie value (goalie xGAR or GSAx).
- Add contract surplus value modeling (market $/xGAR, term, aging).
- Model conditional picks probabilistically when conditions are unresolved.

---

## Summary
This trade ROI framework is built to be:
- **consistent** (everything mapped to xGAR),
- **honest about uncertainty** (EV for future assets),
- **time-aware** (discounting future value),
- **transparent** (separate realized vs expected),
- and **practical** for portfolio-grade analysis and visualization.
