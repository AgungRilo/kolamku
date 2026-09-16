package config

import (
	"log"
	"os"

	"github.com/joho/godotenv"
)

// Config menampung nilai dari .env yang dipakai aplikasi.
type Config struct {
	DatabaseURL string
	JWTSecret   string // belum dipakai, buat login nanti
}

// Load membaca .env lalu mengembalikan Config.
func Load() *Config {
	// godotenv cari file .env di folder tempat program dijalankan.
	// Kalau tidak ada (mis. di production), lewati — pakai env sistem.
	if err := godotenv.Load(); err != nil {
		log.Println("info: .env tidak ditemukan, memakai env sistem")
	}

	return &Config{
		DatabaseURL: mustGet("DATABASE_URL"),
		JWTSecret:   os.Getenv("JWT_SECRET"),
	}
}

// mustGet ambil env wajib; kalau kosong, hentikan program dengan pesan jelas.
func mustGet(key string) string {
	val := os.Getenv(key)
	if val == "" {
		log.Fatalf("environment variable %s wajib diisi", key)
	}
	return val
}
