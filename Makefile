SHELL=/bin/bash 

OKD_NAME=minishift
OKD_VERSION=1.34.3
OKD_ARCHITECTURE=amd64

NAME=$(OKD_NAME)
VERSION=$(OKD_VERSION)
ARCHITECTURE=$(OKD_ARCHITECTURE)

TAR_FILE=$(OKD_NAME)-$(OKD_VERSION)-linux-$(OKD_ARCHITECTURE).tgz
SHA_FILE=$(TAR_FILE).sha256

clean: 
	rm -rf ./tmp ./src 

init: clean
	mkdir -p ./src ./target ./tmp 

download: init 
	wget https://github.com/minishift/minishift/releases/download/v$(OKD_VERSION)/$(TAR_FILE) -P ./tmp
	wget https://github.com/minishift/minishift/releases/download/v$(OKD_VERSION)/$(SHA_FILE) -P ./tmp

verify: download
	echo $$(cat ./tmp/$(SHA_FILE)) ./tmp/$(TAR_FILE) | sha256sum --check 

	
build: verify
	tar -zxvf ./tmp/$(TAR_FILE) -C ./src
	rm -f ./src/README.md
	fpm --input-type dir \
		--output-type deb \
		--name $(NAME) \
		--version $(VERSION) \
		--architecture $(ARCHITECTURE) \
		--chdir ./src \
		--package ./target/ \
		--maintainer yves.vindevogel@asynchrone.com \
		--prefix /usr/local/bin \
		--force 

install: build 
	apt install -y ./target/$(NAME)_$(VERSION)_$(ARCHITECTURE).deb

remove: 
	apt remove -y $(NAME)
