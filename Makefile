.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

#
# If you want to see the full commands, run:
#   NOISY_BUILD=y make
#
ifeq ($(NOISY_BUILD),)
    ECHO_PREFIX=@
    CMD_PREFIX=@
else
    ECHO_PREFIX=@\#
    CMD_PREFIX=
endif

.PHONY: md-lint
md-lint: ## Lint markdown files
	$(ECHO_PREFIX) printf "  %-12s ./...\n" "[MD LINT]"
	$(CMD_PREFIX) podman run --rm -v $(CURDIR):/workdir docker.io/davidanson/markdownlint-cli2:v0.6.0 > /dev/null

.PHONY: shellcheck
shellcheck: ## Run shellcheck on scripts/*.sh
	$(ECHO_PREFIX) printf "  %-12s ./...\n" "[SHELLCHECK] scripts/*.sh"
	$(CMD_PREFIX) shellcheck scripts/*.sh

.PHONY: ansible-lint
ansible-lint: ## Run ansible-lint on playbooks/*.yml
	$(CMD_PREFIX) if ! which ansible-galaxy >/dev/null 2>&1; then \
		echo "Please install ansible-galaxy." ; \
		echo "See: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html" ; \
		exit 1 ; \
	fi
	$(CMD_PREFIX) if ! which ansible-lint >/dev/null 2>&1; then \
		echo "Please install ansible-lint." ; \
		echo "See: https://ansible.readthedocs.io/projects/lint/installing/#installing-the-latest-version" ; \
		exit 1 ; \
	fi
	$(CMD_PREFIX) ansible-galaxy install -r ./deploy/ansible/requirements.yml
	$(ECHO_PREFIX) printf "  %-12s ./...\n" "[ANSIBLE LINT]"
	$(CMD_PREFIX) ansible-lint

.PHONY: png-lint
png-lint: ## Lint the png files from excalidraw
	$(ECHO_PREFIX) printf "  %-12s ./...\n" "[PNG LINT]"
	$(CMD_PREFIX) for file in $^; do \
		if echo "$$file" | grep -q --basic-regexp --file=.excalidraw-ignore; then continue ; fi ; \
		if ! grep -q "excalidraw+json" $$file; then \
			echo "$$file was not exported from excalidraw with 'Embed Scene' enabled." ; \
			echo "If this is not an excalidraw file, add it to .excalidraw-ignore" ; \
			exit 1 ; \
		fi \
	done

bot-image: bot/Containerfile ## Build container image for the bot
	$(ECHO_PREFIX) printf "  %-12s bot/Containerfile\n" "[PODMAN]"
	$(CMD_PREFIX) podman build -f bot/Containerfile -t quay.io/instruct-lab-bot/bot:latest .

gobot-image: gobot/Containerfile ## Build continaer image for the Go bot
	$(ECHO_PREFIX) printf "  %-12s gobot/Containerfile\n" "[PODMAN]"
	$(CMD_PREFIX) podman build -f gobot/Containerfile -t quay.io/instruct-lab-bot/gobot:latest .

worker-test-image: worker/Containerfile.test ## Build container image for a test worker
	$(ECHO_PREFIX) printf "  %-12s worker/Containerfile.test\n" "[PODMAN]"
	$(CMD_PREFIX) podman build -f worker/Containerfile.test -t quay.io/instruct-lab-bot/worker-test:latest .

.PHONY: gobot
gobot: gobot/gobot ## Build gobot

gobot/gobot: $(wildcard gobot/*.go) $(wildcard gobot/*/*.go)
	$(CMD_PREFIX) $(MAKE) -C gobot gobot

.PHONY: worker
worker: worker/worker ## Build worker

worker/worker: $(wildcard worker/*.go) $(wildcard worker/cmd/*.go)
	$(CMD_PREFIX) $(MAKE) -C worker worker
