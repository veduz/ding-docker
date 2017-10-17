RED=\033[0;31m
WHITE=\033[1;37m
RESET=\033[0m

die:
	@echo "${WHITE}make reset: ${RED}Destroy and rebuild site. 💥${RESET}"

reset:
	@./scripts/docker-reset.sh

