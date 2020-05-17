DOCKER_COMPOSE=docker-compose

.PHONY: up
up:
	$(DOCKER_COMPOSE) up -d
.PHONY: up

down:
	$(DOCKER_COMPOSE) down -v

.PHONY: blog
blog:
	$(DOCKER_COMPOSE) run --rm blog-builder jekyll build --watch