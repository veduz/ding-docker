RED=\033[0;31m
GREEN=\033[0;32m
WHITE=\033[1;37m
RESET=\033[0m

die:
	@echo
	@echo "${WHITE}Everything in red marked with 💥  will destroy the local database.${RESET}"
	@echo
	@echo "${WHITE}make install: ${RED}Install and prepare for development. 💥${RESET}"
	@echo "${WHITE}make reset: ${RED}Destroy and rebuild site. 💥${RESET}"
	@echo "${WHITE}make site-reset: ${GREEN}Reset site and prepare for development. ${RESET}"
	@echo

site-reset:
	@./scripts/site-reset.sh

install reset:
	@./scripts/docker-reset.sh

