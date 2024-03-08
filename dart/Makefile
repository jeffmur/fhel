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
	@flutter pub publish

.PHONY: publish-dry
publish-dry:
	@flutter pub publish --dry-run

.PHONY: publish-force
publish-force:
	@flutter pub publish --force