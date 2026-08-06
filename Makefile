.PHONY: check compatibility fmt lint release-parity security verify verify-release

check:
	go run ./internal/qualitygate -mode=check

compatibility:
	go run ./internal/qualitygate -mode=compatibility

fmt:
	go run ./internal/qualitygate -mode=fmt

lint:
	go run ./internal/qualitygate -mode=lint

release-parity: export GOWORK := off
release-parity: export GOPROXY := off
release-parity: export GOTOOLCHAIN := local
release-parity: export GOFLAGS := -mod=vendor
release-parity:
	go run ./internal/qualitygate -mode=release-parity

security:
	go run ./internal/qualitygate -mode=security

verify:
	go run ./internal/qualitygate -mode=verify

verify-release:
	go run ./internal/qualitygate -mode=verify-release
