_site:
	docker-compose run --rm blog-builder jekyll build --config _config.yml,_config_development.yml

.PHONY: blog
blog: _site
	docker-compose up -d
	docker-compose run --rm blog-builder jekyll build --watch --config _config.yml,_config_development.yml

.PHONY: down
down:
	docker-compose down -v