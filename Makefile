.PHONY: install
install:
	npm install

.PHONY: unit-tests
unit-tests:
	npm test

.PHONY: docker
docker: 
	docker build -t $(TRAVIS_REPO_SLUG) .
	docker login --username $(DOCKER_HUB_USERNAME) --password $(DOCKER_HUB_PASSWORD)
	docker tag $(TRAVIS_REPO_SLUG) $(TRAVIS_REPO_SLUG):latest
	docker push $(TRAVIS_REPO_SLUG):latest
	docker tag $(TRAVIS_REPO_SLUG) $(TRAVIS_REPO_SLUG):$(TRAVIS_COMMIT)
	docker push $(TRAVIS_REPO_SLUG):$(TRAVIS_COMMIT)

.PHONY: build
build: docker