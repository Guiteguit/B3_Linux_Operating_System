.PHONY: help syntax day1 day2

help:
	@echo "make syntax  - vérifie la syntaxe Bash des scripts"
	@echo "make day1    - lance les validateurs du Jour 1"
	@echo "make day2    - lance les validateurs du Jour 2"

syntax:
	@find scripts -type f -name '*.sh' -print0 | xargs -0 -n1 bash -n
	@echo "Syntaxe Bash : OK"

day1:
	sudo ./scripts/checks/check-all-day1.sh

day2:
	sudo ./scripts/checks/check-all-day2.sh
