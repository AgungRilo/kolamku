-- ============================================================
-- Kolamku - Seed data awal
-- Jalankan SETELAH schema.sql:  psql -d kolamku -f seed.sql
-- Aman dijalankan sekali pada DB kosong.
-- (super_admin TIDAK di-seed sebagai role — pakai flag is_superadmin
--  di tabel users. User pertama dibuat lewat fitur register nanti.)
-- ============================================================

-- ---------------- ROLES ----------------
INSERT INTO roles (name, description) VALUES
  ('admin',          'Administrator aplikasi'),
  ('pemberi_makan',  'Bertugas memberi pakan'),
  ('maintener_air',  'Bertugas menjaga kualitas air'),
  ('tukang_belanja', 'Bertugas belanja pakan & bibit'),
  ('user',           'Akses dasar (lihat saja)');

-- ---------------- PERMISSIONS ----------------
INSERT INTO permissions (code, description) VALUES
  ('kolam.view',     'Lihat data kolam'),
  ('kolam.manage',   'Kelola data kolam'),
  ('pakan.view',     'Lihat catatan pakan'),
  ('pakan.create',   'Input catatan pakan'),
  ('air.view',       'Lihat kualitas air'),
  ('air.create',     'Input kualitas air'),
  ('belanja.view',   'Lihat belanja'),
  ('belanja.create', 'Input belanja pakan/bibit'),
  ('panen.view',     'Lihat data panen'),
  ('panen.create',   'Input data panen'),
  ('keuangan.view',  'Lihat keuangan'),
  ('user.manage',    'Kelola user'),
  ('role.manage',    'Kelola role & hak akses');

-- ---------------- ROLE -> PERMISSIONS ----------------
-- admin: hampir semua
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.name = 'admin'
  AND p.code IN ('kolam.view','kolam.manage','pakan.view','pakan.create',
                 'air.view','air.create','belanja.view','belanja.create',
                 'panen.view','panen.create','keuangan.view',
                 'user.manage','role.manage');

-- pemberi_makan
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.name = 'pemberi_makan'
  AND p.code IN ('kolam.view','pakan.view','pakan.create');

-- maintener_air
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.name = 'maintener_air'
  AND p.code IN ('kolam.view','air.view','air.create');

-- tukang_belanja
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.name = 'tukang_belanja'
  AND p.code IN ('belanja.view','belanja.create');

-- user (dasar)
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.name = 'user'
  AND p.code IN ('kolam.view','panen.view');

-- ---------------- MENUS (induk / top-level dulu) ----------------
-- permission_id NULL = tampil untuk semua user yang login.
INSERT INTO menus (label, icon, path, sort_order, permission_id)
SELECT 'Beranda', 'home', '/', 1, NULL;

INSERT INTO menus (label, icon, path, sort_order, permission_id)
SELECT 'Kolam', 'waves', '/kolam', 2, p.id
FROM permissions p WHERE p.code = 'kolam.view';

INSERT INTO menus (label, icon, path, sort_order, permission_id)
SELECT 'Operasional', 'clipboard-list', NULL, 3, NULL;   -- grouper (tanpa path)

INSERT INTO menus (label, icon, path, sort_order, permission_id)
SELECT 'Belanja', 'shopping-cart', '/belanja', 4, p.id
FROM permissions p WHERE p.code = 'belanja.view';

INSERT INTO menus (label, icon, path, sort_order, permission_id)
SELECT 'Pengaturan', 'settings', NULL, 5, NULL;          -- grouper (tanpa path)

-- ---------------- SUB-MENU (anak "Operasional") ----------------
INSERT INTO menus (parent_id, label, icon, path, sort_order, permission_id)
SELECT m.id, 'Pakan', 'utensils', '/pakan', 1, p.id
FROM menus m, permissions p
WHERE m.label = 'Operasional' AND p.code = 'pakan.view';

INSERT INTO menus (parent_id, label, icon, path, sort_order, permission_id)
SELECT m.id, 'Kualitas Air', 'droplet', '/air', 2, p.id
FROM menus m, permissions p
WHERE m.label = 'Operasional' AND p.code = 'air.view';

INSERT INTO menus (parent_id, label, icon, path, sort_order, permission_id)
SELECT m.id, 'Panen', 'package', '/panen', 3, p.id
FROM menus m, permissions p
WHERE m.label = 'Operasional' AND p.code = 'panen.view';

-- ---------------- SUB-MENU (anak "Pengaturan") ----------------
INSERT INTO menus (parent_id, label, icon, path, sort_order, permission_id)
SELECT m.id, 'Kelola User', 'users', '/users', 1, p.id
FROM menus m, permissions p
WHERE m.label = 'Pengaturan' AND p.code = 'user.manage';

INSERT INTO menus (parent_id, label, icon, path, sort_order, permission_id)
SELECT m.id, 'Kelola Role', 'shield', '/roles', 2, p.id
FROM menus m, permissions p
WHERE m.label = 'Pengaturan' AND p.code = 'role.manage';
