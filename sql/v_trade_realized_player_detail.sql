SELECT
  trade_id,
  team,
  player_name,
  realized_xgar_in,
  realized_gp_in
FROM hockey.v_realized_in
UNION ALL
SELECT
  trade_id,
  team,
  player_name,
  -realized_xgar_out AS realized_xgar_in,   -- negative = value you gave up
  realized_gp_out AS realized_gp_in
FROM hockey.v_realized_out