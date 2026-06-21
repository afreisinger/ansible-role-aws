# Runs molecule inside the project venv so the system apt Ansible
# (which bundles ~48 collections and triggers "Another version" warnings)
# is never used. Always use these targets instead of calling molecule directly.

VENV := .venv
ACTIVATE := . $(VENV)/bin/activate

.PHONY: test converge verify destroy lint login venv

test: $(VENV)        ## Full molecule test sequence
	$(ACTIVATE) && molecule test

converge: $(VENV)    ## Create + converge only
	$(ACTIVATE) && molecule converge

verify: $(VENV)      ## Run verify playbook
	$(ACTIVATE) && molecule verify

destroy: $(VENV)     ## Tear down the instance
	$(ACTIVATE) && molecule destroy

lint: $(VENV)        ## Run ansible-lint + yamllint
	$(ACTIVATE) && ansible-lint . && yamllint .

login: $(VENV)       ## Shell into the running instance
	$(ACTIVATE) && molecule login

venv: $(VENV)        ## Create venv and install tooling if missing

$(VENV):
	python3 -m venv $(VENV)
	$(ACTIVATE) && pip install --upgrade pip ansible-core molecule 'molecule-plugins[docker]' ansible-lint yamllint passlib
