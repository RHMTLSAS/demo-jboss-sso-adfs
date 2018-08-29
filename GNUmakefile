#ANSIBLE-VAULT = configs/shared/ansible_vault
#ANSIBLE-PLAYBOOK = ansible-playbook --ask-vault-pass --vault-id $(ANSIBLE-VAULT)
ANSIBLE-PLAYBOOK = ansible-playbook 


.PHONY:
all: requirements

%: %.yml requirements
	$(ANSIBLE-PLAYBOOK) $*.yml
	@if [ -a $*.retry ]; \
	then \
		rm $*.retry ; \
	fi;  

.PHONY:
requirements:
	ansible-galaxy install -r roles/requirements.yml -p ./roles/ --force

.PHONY:
clean:
	rm *.retry

.PHONY:
submodules:
	git submodule sync --recursive
	git submodule update --init --recursive
