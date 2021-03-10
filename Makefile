.PHONY: up
up:
	docker-compose up -d

.PHONY: down
down:
	docker-compose down -v

.PHONY: blog
blog: up
	docker-compose run --rm blog-builder jekyll build --watch