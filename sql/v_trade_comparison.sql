WITH ranked AS (
  SELECT
    trade_id,
    team,
    realized_xgar_in,
    ev_xgar_in,
    net_xgar,
    RANK() OVER (PARTITION BY trade_id ORDER BY net_xgar DESC) AS rnk
  FROM hockey.v_trade_roi_team
)

SELECT
  trade_id,
  team,
  realized_xgar_in,
  ev_xgar_in,
  net_xgar,
  CASE
    WHEN rnk = 1 THEN 'Winner'
    ELSE 'Loser'
  END AS trade_result
FROM ranked