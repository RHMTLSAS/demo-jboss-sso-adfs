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
venv:
	virtualenv venv
	(\
		source venv/bin/activate; \
		pip install -r requirements.txt; \
	)		

.PHONY:
clean:
	rm *.retry
	rm -rf venv

.PHONY:
submodules:
	git submodule sync --recursive
	git submodule update --init --recursive
