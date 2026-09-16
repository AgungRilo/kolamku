-- ============================================================
-- Kolamku - Skema RBAC + Menu (initial schema)
-- PostgreSQL 15+
-- Jalankan: psql -d kolamku -f schema.sql
-- ------------------------------------------------------------
-- Rantai akses:
--   user -> user_roles -> roles -> role_permissions -> permissions <- menus
-- ============================================================

-- Untuk reset (HATI-HATI: menghapus SEMUA tabel & data di bawah).
-- Buang komentar hanya kalau mau mulai ulang dari nol:
-- DROP TABLE IF EXISTS role_permissions, user_roles, menus, permissions, roles, users CASCADE;


-- ------------------------------------------------------------
-- 1. users  (akun login)
-- ------------------------------------------------------------
CREATE TABLE users (
    id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    email          TEXT        NOT NULL,
    username       TEXT        NOT NULL,
    password_hash  TEXT        NOT NULL,                 -- HASH bcrypt, BUKAN password asli
    name           TEXT        NOT NULL,
    is_superadmin  BOOLEAN     NOT NULL DEFAULT FALSE,   -- bypass semua permission
    is_active      BOOLEAN     NOT NULL DEFAULT TRUE,    -- nonaktifkan tanpa hapus data
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- email & username unik + case-insensitive (Foo@x.com == foo@x.com).
-- Login boleh pakai salah satu: backend cek lower(email)=input OR lower(username)=input.
CREATE UNIQUE INDEX users_email_lower_idx    ON users (lower(email));
CREATE UNIQUE INDEX users_username_lower_idx ON users (lower(username));


-- ------------------------------------------------------------
-- 2. roles  (jabatan/fungsi: admin, pemberi_makan, dll)
-- ------------------------------------------------------------
CREATE TABLE roles (
    id          INT         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        TEXT        NOT NULL UNIQUE,             -- mis. 'pemberi_makan'
    description TEXT,
    is_active   BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- ------------------------------------------------------------
-- 3. permissions  (hak akses granular: 'kolam.view', 'pakan.create')
-- ------------------------------------------------------------
CREATE TABLE permissions (
    id          INT         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code        TEXT        NOT NULL UNIQUE,             -- string yang dicek backend
    description TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- ------------------------------------------------------------
-- 4. menus  (item menu / modul; self-referential untuk sub-menu)
-- ------------------------------------------------------------
CREATE TABLE menus (
    id            INT         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    parent_id     INT         REFERENCES menus(id) ON DELETE CASCADE,       -- NULL = menu induk/top-level
    label         TEXT        NOT NULL,                  -- teks tampil: "Data Kolam"
    icon          TEXT,                                  -- nama ikon utk frontend (bottom nav)
    path          TEXT,                                  -- rute: "/kolam" (NULL utk grouper murni)
    sort_order    INT         NOT NULL DEFAULT 0,        -- urutan tampil
    permission_id INT         REFERENCES permissions(id) ON DELETE RESTRICT, -- NULL = semua user login boleh lihat
    is_active     BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX menus_parent_id_idx     ON menus (parent_id);
CREATE INDEX menus_permission_id_idx ON menus (permission_id);


-- ------------------------------------------------------------
-- 5. user_roles  (M:N — satu user bisa punya banyak role)
-- ------------------------------------------------------------
CREATE TABLE user_roles (
    user_id     UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id     INT         NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, role_id)                       -- cegah duplikat pasangan
);

-- untuk query balik: "role ini dipakai user siapa saja"
CREATE INDEX user_roles_role_id_idx ON user_roles (role_id);


-- ------------------------------------------------------------
-- 6. role_permissions  (M:N — satu role punya banyak permission)
-- ------------------------------------------------------------
CREATE TABLE role_permissions (
    role_id       INT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id INT NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

-- untuk query balik: "permission ini dimiliki role apa saja"
CREATE INDEX role_permissions_permission_id_idx ON role_permissions (permission_id);
