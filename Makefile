.DEFAULT_GOAL := help

###### Development

compile-requirements: ## Compile requirements files
	pip-compile -o requirements/base.txt requirements/base.in
	pip-compile -o requirements/dev.txt requirements/dev.in
	pip-compile -o requirements/docs.txt requirements/docs.in

test: ## Run unit tests
	nosetests --nocapture tests/

###### Deployment

bundle: ## Bundle the tutor package in a single "dist/tutor" executable
	pyinstaller --onefile --name=tutor --add-data=./tutor/templates:./tutor/templates ./bin/main
dist/tutor:
	$(MAKE) bundle

nightly: ## Create a "nightly" release
	$(MAKE) tag TAG=nightly

release: ## Create a release tag and push it to origin
	$(MAKE) tag TAG=v$(shell make version)

tag:
	@echo "=== Creating tag $(TAG)"
	git tag -d $(TAG) || true
	git tag $(TAG)
	@echo "=== Pushing tag $(TAG)"
	git push origin :$(TAG) || true
	git push origin $(TAG)

###### Continuous integration tasks

ci-info: ## Print info about environment
	python3 --version
	pip3 --version

ci-test: ## Run unit tests but without nosetests, which is not available on Mac OS in travis-ci
	python3 -m unittest discover tests

ci-bundle: ## Create bundle and run basic tests
	pip3 install -U setuptools
	pip3 install -r requirements/dev.txt
	$(MAKE) ci-test
	$(MAKE) bundle
	mkdir -p releases/
	cp ./dist/tutor ./releases/tutor-$$(uname -s)_$$(uname -m)
	./dist/tutor --version
	./dist/tutor config printroot
	./dist/tutor config save --yes --set ACTIVATE_NOTES=true --set ACTIVATE_XQUEUE=true

ci-images: ## Build and push docker images to hub.docker.com
	python setup.py develop
	tutor images build all
	tutor local databases
	docker login -u "$$DOCKER_USERNAME" -p "$$DOCKER_PASSWORD"
	tutor images push all

ci-pypi: ## Push release to pypi
	pip install twine
	python setup.py sdist
	twine upload dist/*.tar.gz

###### Additional commands

version: ## Print the current tutor version
	@python -c 'import io, os; about = {}; exec(io.open(os.path.join("tutor", "__about__.py"), "rt", encoding="utf-8").read(), about); print(about["__version__"])'

ESCAPE = 
help: ## Print this help
	@grep -E '^([a-zA-Z_-]+:.*?## .*|######* .+)$$' Makefile \
		| sed 's/######* \(.*\)/\n               $(ESCAPE)[1;31m\1$(ESCAPE)[0m/g' \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[33m%-30s\033[0m %s\n", $$1, $$2}'
