REGISTRY = ameba.eax.pl:5000

DOCKER_HOST := tcp://
export DOCKER_HOST
docker := bin/docker
mount_prefix := /media
running_containers := $(shell bin/docker ps 2>&1)
container_definitions := postgresql-dev ruby
private_container_definitions := ruby-local
BACKUP = $(shell ls -r1 backup | head -n1)
quiet := &>/dev/null

docker_run := bin/docker run -v /tmp/ssh-agent.sock:/tmp/ssh-agent.sock

define build-image
	$(docker) build -rm -t=$(REGISTRY)/$1 containers/$1 && \
	$(docker) push $(REGISTRY)/$1
endef

define vm_shell
	vagrant ssh -c $1
endef

# Lifecycle
up: vagrant-up restore-inner apps forward-ssh-agent
destroy: backup-inner vagrant-destroy
destroy-void: vagrant-destroy
clean: destroy
	rm -fr backup/* apps/*
forward-ssh-agent:
	(ps aux | grep -E 'ssh.*forward-ssh-agent' | grep -qv grep) || (vagrant ssh -- -f '/vagrant/bin/forward-ssh-agent' && sleep 3)

apps: postgresql

# Backup
backup-inner:
	$(call vm_shell,'sudo cp -r /apps $(mount_prefix)/backup/$(shell date +"%Y%m%d%H%M")')
	@echo Bakcup done
restore-inner:
	@echo Restoring $(BACKUP)
	$(call vm_shell,'sudo [ "$$(ls -A /apps)" ] && echo "inner /apps storage is not empty. skipping." || sudo cp -r $(mount_prefix)/backup/$(BACKUP) /apps')

# Building images and pushing to repository

rebuild-images:
	$(foreach container, $(container_definitions), $(call build-image,$(container));)

# Projects
apps/%:
	$(docker_run) -rm -t -v /media/apps:/apps $(REGISTRY)/ruby /bin/bash -l -c "git clone git@github.com:bonusboxme/$*.git /apps/$*"

run-%: apps/%
	bin/containerize_bundle $* && $(docker_run) --name=app-$* -rm -t -i -v /media/apps/$*:/app app-$*-container

# helpers

vagrant-up:
	vagrant up
vagrant-destroy:
	vagrant destroy -f

# services

postgresql:
	$(call vm_shell,'sudo mkdir -p /apps/postgresql/data /apps/postgresql/logs')
	$(docker) run \
	-d \
	-p 5432:5432 \
	-v /apps/postgresql/data:/data \
	-v /apps/postgresql/logs:/var/logs \
	-name postgresql \
	$(REGISTRY)/postgresql-dev $(quiet) || \
	$(docker) start postgresql $(quiet) || echo "Already running"

retailers:
