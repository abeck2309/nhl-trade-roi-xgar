SELECT
  valuation_date,
  trade_id,
  team,
  asset_type,
  asset_name,
  status,
  CAST(ev_value AS FLOAT64) AS ev_value,
  ev_source,
  notes
FROM hockey.asset_valuation