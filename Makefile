RED=\033[0;31m
GREEN=\033[0;32m
WHITE=\033[1;37m
RESET=\033[0m

die:
	@echo "${WHITE}make reset: ${RED}Destroy and rebuild site. 💥${RESET}"
	@echo "${WHITE}make site-reset: ${GREEN}Reset site and prepare for development. ${RESET}"
	@echo "${WHITE}make logs: ${GREEN}Tails logs for the stack. ${RESET}"

site-reset:
	@./scripts/site-reset.sh

reset:
	@./scripts/docker-reset.sh

logs:
	@./scripts/docker-logs.sh
