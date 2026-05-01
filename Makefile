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
OUT_DIR = out

.SILENT: setup-env out-clean find

find:
	./scripts/find_versions.sh "$(RUN_ARGS)"

agree-eula:
	@mkdir -p $(OUT_DIR)
	echo "eula=TRUE" > $(OUT_DIR)/eula.txt

setup-env:
	./scripts/setup_mc_env.sh -img $(IMAGE_NAME) -mcv "$(RUN_ARGS)"

up:
	@mkdir -p $(OUT_DIR)
	docker compose up -d && docker compose attach mc-server

down:
	docker compose down

build:
	docker compose build

rebuild:
	docker compose build --no-cache

# Clear out the OUT_DIR folder. Only keep the eula.txt if exists.
out-clean:
	mkdir -p $(OUT_DIR)
	if [[ -f "$(OUT_DIR)/eula.txt" ]]; then
		mv $(OUT_DIR)/eula.txt eula.out
	fi
	rm -rf $(OUT_DIR)/{*,.*}
	if [[ -f eula.out ]]; then
		mv eula.out $(OUT_DIR)/eula.txt
	fi

image-clean:
	docker rmi $(IMAGES)

server: setup-env up

image: setup-env build

new-server: out-clean setup-env rebuild up

clean: down out-clean

reset: clean image-clean
