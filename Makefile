.PHONY: blog
blog:
	docker-compose run --rm blog-builder jekyll build --watch
	docker-compose up -d

.PHONY: down
down:
	docker-compose down -v