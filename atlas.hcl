env "ci" {
  src = "file://supabase/migrations"
  dev = "postgres://postgres:postgres@localhost:5432/postgres?sslmode=disable"

  lint {
    destructive {
      error = true
    }
    incompatible {
      error = true
    }
  }
}
