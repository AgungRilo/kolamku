package database

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

// Connect membuat connection pool ke Postgres dan memverifikasinya dengan ping.
// databaseURL diambil dari config (.env).
func Connect(databaseURL string) (*pgxpool.Pool, error) {
	// Batasi waktu tunggu koneksi awal biar tidak menggantung selamanya.
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	pool, err := pgxpool.New(ctx, databaseURL)
	if err != nil {
		return nil, fmt.Errorf("gagal membuat pool DB: %w", err)
	}

	// Ping: pastikan DB benar-benar bisa dihubungi, bukan cuma string valid.
	if err := pool.Ping(ctx); err != nil {
		pool.Close()
		return nil, fmt.Errorf("gagal ping DB: %w", err)
	}

	return pool, nil
}
