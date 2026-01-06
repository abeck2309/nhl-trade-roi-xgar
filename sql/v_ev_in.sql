SELECT
  trade_id,
  team,
  SUM(CAST(ev_value AS FLOAT64)) AS ev_xgar_in
FROM hockey.asset_valuation
GROUP BY 1,2