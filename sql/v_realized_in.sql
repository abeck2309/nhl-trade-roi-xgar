WITH assets_in AS (
  SELECT
    trade_id,
    to_team AS team,
    asset_name AS player_name,
    acq_date,
    COALESCE(end_date, DATE '9999-12-31') AS end_date
  FROM hockey.trade_assets
  WHERE asset_type IN ('PLAYER','PROSPECT')
)
SELECT
  a.trade_id,
  a.team,
  a.player_name,
  SUM(ps.xGAR) AS realized_xgar_in,
  SUM(ps.gp) AS realized_gp_in
FROM assets_in a
JOIN hockey.v_player_seasons_norm ps
  ON ps.player_name = a.player_name
 AND ps.season_start_date BETWEEN a.acq_date AND a.end_date
GROUP BY 1,2,3