WITH assets AS (
  SELECT
    ta.trade_id,
    ta.asset_name AS player_name,
    ta.from_team,
    ta.to_team,
    ta.acq_date,
    COALESCE(ta.end_date, DATE '9999-12-31') AS end_date
  FROM hockey.trade_assets ta
  WHERE ta.asset_type IN ('PLAYER','PROSPECT')
    AND ta.from_team NOT IN ('DRAFT')
    AND ta.to_team   NOT IN ('DRAFT')
),

earned_signed AS (
  -- Value for receiving team (positive)
  SELECT
    a.trade_id,
    a.to_team AS team,
    t.trade_name,
    t.trade_date,
    ps.season_start_date,
    ps.xGAR AS xgar_signed
  FROM assets a
  JOIN hockey.trades t USING (trade_id)
  JOIN hockey.v_player_seasons_norm ps
    ON ps.player_name = a.player_name
   AND ps.season_start_date BETWEEN a.acq_date AND a.end_date

  UNION ALL

  -- Value for sending team (negative)
  SELECT
    a.trade_id,
    a.from_team AS team,
    t.trade_name,
    t.trade_date,
    ps.season_start_date,
    -ps.xGAR AS xgar_signed
  FROM assets a
  JOIN hockey.trades t USING (trade_id)
  JOIN hockey.v_player_seasons_norm ps
    ON ps.player_name = a.player_name
   AND ps.season_start_date BETWEEN a.acq_date AND a.end_date
),

windowed AS (
  SELECT
    trade_id,
    trade_name,
    team,
    '1YR' AS window_label,
    SUM(xgar_signed) AS net_realized_xgar
  FROM earned_signed
  WHERE season_start_date < DATE_ADD(trade_date, INTERVAL 1 YEAR)
  GROUP BY 1,2,3,4

  UNION ALL

  SELECT
    trade_id,
    trade_name,
    team,
    '3YR' AS window_label,
    SUM(xgar_signed)
  FROM earned_signed
  WHERE season_start_date < DATE_ADD(trade_date, INTERVAL 3 YEAR)
  GROUP BY 1,2,3,4

  UNION ALL

  SELECT
    trade_id,
    trade_name,
    team,
    'TO_DATE' AS window_label,
    SUM(xgar_signed)
  FROM earned_signed
  GROUP BY 1,2,3,4
)

SELECT
  trade_id,
  trade_name,
  team,
  window_label,
  net_realized_xgar
FROM windowed