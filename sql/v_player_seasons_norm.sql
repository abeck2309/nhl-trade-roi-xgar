SELECT
  player_name,
  season,
  team,
  SAFE_CAST(gp AS INT64) AS gp,
  SAFE_CAST(xGAR AS FLOAT64) AS xGAR,
  source,
  DATE(CAST(CONCAT('20', SUBSTR(season, 1, 2)) AS INT64), 10, 1) AS season_start_date
FROM hockey.player_seasons