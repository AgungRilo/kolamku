-- name: ListRoles :many
SELECT
  id,
  name,
  description
FROM roles
ORDER BY id;