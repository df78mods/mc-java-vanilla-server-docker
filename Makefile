.ONESHELL:
SHELL := /bin/bash
RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(RUN_ARGS):;@:)

MCVERSION := $(firstword $(RUN_ARGS))
IMAGE_NAME = minecraft.vanilla.server
IMAGES := $(shell docker images --filter "reference=$(IMAGE_NAME):*" -q | tr '\n' ' ')

.SILENT: setup-env out-clean

agree-eula:
	echo "eula=TRUE" > out/eula.txt

setup-env:
	./scripts/setup_mc_env.sh -img $(IMAGE_NAME) -mcv $(MCVERSION)

up:
	docker compose up -d && docker compose attach mc-server

down:
	docker compose down

# Clear out the 'out' folder. Only keep the gitignore and eula.txt.
out-clean:
	mv out/.gitignore .gitignore.out
	if [[ -f "out/eula.txt" ]]; then
		mv out/eula.txt eula.out.txt
	fi
	rm -rf out/
	mkdir out
	mv .gitignore.out out/.gitignore
	if [[ -f eula.out.txt ]]; then
		mv eula.out.txt out/eula.txt
	fi

image-clean:
	docker rmi $(IMAGES)

server: setup-env up

new-server: out-clean server

clean: down out-clean

reset: clean image-clean
