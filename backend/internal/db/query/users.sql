-- name: CreateUser :one
INSERT INTO users (email, username, password_hash, name)
VALUES ($1, $2, $3, $4)
RETURNING id, email, username, name, is_superadmin, is_active;
