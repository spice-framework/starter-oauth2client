.PHONY: check compatibility fmt lint security verify

check:
	go run ./internal/qualitygate -mode=check

compatibility:
	go run ./internal/qualitygate -mode=compatibility

fmt:
	go run ./internal/qualitygate -mode=fmt

lint:
	go run ./internal/qualitygate -mode=lint

security:
	go run ./internal/qualitygate -mode=security

verify:
	go run ./internal/qualitygate -mode=verify
