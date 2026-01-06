WITH base_assets AS (
  SELECT
    ta.trade_id,
    ta.from_team,
    ta.to_team
  FROM hockey.trade_assets ta
  JOIN hockey.trades t USING (trade_id)
  WHERE
    -- exclude draft helper rows
    ta.from_team NOT IN ('DRAFT')
    AND ta.to_team   NOT IN ('DRAFT')
    AND (
      ta.asset_type IN ('PLAYER','PROSPECT')
      OR (ta.asset_type = 'PICK' AND ta.acq_date = t.trade_date)
    )
),
teams_in_trade AS (
  SELECT DISTINCT trade_id, from_team AS team
  FROM base_assets
  UNION DISTINCT
  SELECT DISTINCT trade_id, to_team AS team
  FROM base_assets
),
real_in AS (
  SELECT trade_id, team, SUM(realized_xgar_in) AS realized_in
  FROM hockey.v_realized_in
  GROUP BY 1,2
),
real_out AS (
  SELECT trade_id, team, SUM(realized_xgar_out) AS realized_out
  FROM hockey.v_realized_out
  GROUP BY 1,2
),
ev_in AS (
  SELECT trade_id, team, SUM(CAST(ev_value AS FLOAT64)) AS ev_in
  FROM hockey.asset_valuation
  GROUP BY 1,2
)
SELECT
  t.trade_id,
  x.team,
  t.trade_date,
  t.trade_name,

  COALESCE(ri.realized_in, 0)  AS realized_xgar_in,
  COALESCE(ro.realized_out, 0) AS realized_xgar_out,
  COALESCE(ei.ev_in, 0)        AS ev_xgar_in,

  (COALESCE(ri.realized_in,0) + COALESCE(ei.ev_in,0)) AS total_xgar_in,
  COALESCE(ro.realized_out,0) AS total_xgar_out,

  (COALESCE(ri.realized_in,0) + COALESCE(ei.ev_in,0) - COALESCE(ro.realized_out,0)) AS net_xgar,

  SAFE_DIVIDE(
    (COALESCE(ri.realized_in,0) + COALESCE(ei.ev_in,0)),
    NULLIF(COALESCE(ro.realized_out,0), 0)
  ) AS roi_ratio
FROM teams_in_trade x
JOIN hockey.trades t USING (trade_id)
LEFT JOIN real_in  ri USING (trade_id, team)
LEFT JOIN real_out ro USING (trade_id, team)
LEFT JOIN ev_in    ei USING (trade_id, team)