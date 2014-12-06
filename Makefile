all:
	cat Makefile

build:
	docker pull base/archlinux
	docker build --rm --no-cache -t mdevaev/archlinux .

push: build
	docker push mdevaev/archlinux
