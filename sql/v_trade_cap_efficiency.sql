WITH assets AS (
  SELECT
    ta.trade_id,
    t.trade_name,
    t.trade_date,
    ta.to_team AS team,
    ta.asset_name AS player_name,
    ta.acq_date,
    COALESCE(ta.end_date, DATE '9999-12-31') AS end_date
  FROM hockey.trade_assets ta
  JOIN hockey.trades t USING (trade_id)
  WHERE ta.asset_type IN ('PLAYER','PROSPECT')
    AND ta.from_team NOT IN ('DRAFT')
    AND ta.to_team   NOT IN ('DRAFT')
),

value AS (
  SELECT
    a.trade_id,
    a.trade_name,
    a.trade_date,
    a.team,
    a.player_name,
    ps.season,
    ps.season_start_date,
    ps.xGAR
  FROM assets a
  JOIN hockey.v_player_seasons_norm ps
    ON ps.player_name = a.player_name
   AND ps.season_start_date BETWEEN a.acq_date AND a.end_date
),

cost AS (
  SELECT
    player_name,
    season,
    CAST(cap_hit AS FLOAT64) AS cap_hit
  FROM hockey.contracts
)

SELECT
  v.trade_id,
  v.trade_name,
  v.trade_date,
  v.team,
  v.player_name,
  v.season,
  v.xGAR,
  c.cap_hit,
  SAFE_DIVIDE(v.xGAR, NULLIF(c.cap_hit, 0)) AS xgar_per_dollar,
  SAFE_MULTIPLY(SAFE_DIVIDE(v.xGAR, NULLIF(c.cap_hit, 0)), 1000000) AS xgar_per_million
FROM value v
LEFT JOIN cost c
  ON v.player_name = c.player_name
 AND v.season = c.season