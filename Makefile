_site:
	docker-compose run --rm blog-builder jekyll build

.PHONY: blog
blog: _site
	docker-compose up -d
	docker-compose run --rm blog-builder jekyll build --watch

.PHONY: down
down:
	docker-compose down -v