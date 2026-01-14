.ONESHELL:
SHELL := /bin/bash

# Commands where rest of the args is treated as one argument.
CMDS_ALL_ARGS_IS_ONE_LIST = find setup-env server new-server image
FIRST_ARG = $(firstword $(MAKECMDGOALS))
ifeq ($(FIRST_ARG),$(filter $(FIRST_ARG),$(CMDS_ALL_ARGS_IS_ONE_LIST)))
  # use the rest as arguments to supply the cmds.
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_ARGS):;@:)
endif

IMAGE_NAME = minecraft.vanilla.server
IMAGES := $(shell docker images --filter "reference=$(IMAGE_NAME):*" -q | tr '\n' ' ')

.SILENT: setup-env out-clean find

find:
	./scripts/find_versions.sh "$(RUN_ARGS)"

agree-eula:
	echo "eula=TRUE" > out/eula.txt

setup-env:
	./scripts/setup_mc_env.sh -img $(IMAGE_NAME) -mcv "$(RUN_ARGS)"

up:
	docker compose up -d && docker compose attach mc-server

down:
	docker compose down

build:
	docker compose build

rebuild:
	docker compose build --no-cache

# Clear out the 'out' folder. Only keep the gitignore and eula.txt.
out-clean:
	mv out/.gitignore .gitignore.out
	if [[ -f "out/eula.txt" ]]; then
		mv out/eula.txt eula.out
	fi
	rm -rf out/
	mkdir out
	mv .gitignore.out out/.gitignore
	if [[ -f eula.out ]]; then
		mv eula.out out/eula.txt
	fi

image-clean:
	docker rmi $(IMAGES)

server: setup-env up

image: setup-env build

new-server: out-clean setup-env rebuild up

clean: down out-clean

reset: clean image-clean
