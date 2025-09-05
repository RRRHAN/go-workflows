package postgres

import (
	"database/sql"

	"github.com/cschleiden/go-workflows/backend"
)

type options struct {
	*backend.Options

	PostgresOptions func(db *sql.DB)

	// ApplyMigrations automatically applies database migrations on startup.
	ApplyMigrations bool

	// ssl mode that used in dsn.
	SSlMode sslMode
}

type option func(*options)

type sslMode string

const (
	Disable    sslMode = "disable"
	Allow      sslMode = "allow"
	Require    sslMode = "require" // default
	VerifyCa   sslMode = "verify-ca"
	VerifyFull sslMode = "verify-full"
)

// WithApplyMigrations automatically applies database migrations on startup.
func WithApplyMigrations(applyMigrations bool) option {
	return func(o *options) {
		o.ApplyMigrations = applyMigrations
	}
}

func WithPostgresOptions(f func(db *sql.DB)) option {
	return func(o *options) {
		o.PostgresOptions = f
	}
}

// WithBackendOptions allows to pass generic backend options.
func WithBackendOptions(opts ...backend.BackendOption) option {
	return func(o *options) {
		for _, opt := range opts {
			opt(o.Options)
		}
	}
}

// WithSSLModeOptions allows to pass custom ssl mode.
func WithSSLModeOptions(mode sslMode) option {
	return func(o *options) {
		o.SSlMode = mode
	}
}
