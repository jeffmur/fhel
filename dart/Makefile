.PHONY: deps
deps:
	@dart pub get

.PHONY: test
test:
	@dart test --concurrency=1

.PHONY: docs
docs:
	@dart doc

.PHONY: publish
publish:
	@dart pub publish

.PHONY: publish-dry
publish-dry:
	@dart pub publish --dry-run

.PHONY: publish-force
publish-force:
	@dart pub publish --force