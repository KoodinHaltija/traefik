# Author: mika.nokka1@gmail.com  January 2018, Nov 2020:
#
# usage: make all -> build(everytime) and run 
# usage: make logs --> start flask server log following (use in different shell)
# usage: make log --> fetch every images docker logs
# usage: make -B --> force build everything 
#
# Flask server uses sentenvs defined variables in code (-e parameter transfers as env into container /env file)
#
# defines env variables for Flask server code
HOSTDIR=/home/mika/tmp
CONTAINERDIR=/tmp
MOUNTDIR = $(HOSTDIR):$(CONTAINERDIR)
APPNAME = dockerserver
SHELLLOGFILE= flask.log
LOCAPORT=9090
YMLFILE=traefik_whoami.yml
BUILDDATE=`date`

default: all

# left for historical reference 
run: envs build 
	sudo docker run -e CONTAINERDIR=$(CONTAINERDIR) -e SHELLLOGFILE=$(SHELLLOGFILE) -it -v $(MOUNTDIR) -p $(LOCAPORT):$(LOCAPORT) $(APPNAME) 
	
build: envs Dockerfile app.py
	@echo ===============================================================================================
	@echo BULDING DOCKER IMAGE FOR PYTHON APP.PY
	@echo
	sudo docker build -t $(APPNAME) . 
	touch build

all: dockerserver redis whoami reverse-proxy

envs: makefile
	@echo ===============================================================================================
	@echo SETTING UP ENV VARIABLES -FOR APP.PY- AND ENV VARIABLES FILE -FOR YAML FILE-
	@echo
	echo HOSTDIR=$(HOSTDIR) > envs.env
	echo CONTAINERDIR=$(CONTAINERDIR) >> envs.env
	echo MOUNTDIR=$(HOSTDIR):$(CONTAINERDIR) >> envs.env
	echo APPNAME=$(APPNAME) >> envs.env
	echo SHELLLOGFILE=$(SHELLLOGFILE) >> envs.env
	echo LOCAPORT=$(LOCAPORT) >> envs.env
	echo YMLFILE=$(YMLFILE) >> envs.env
	echo BUILDDATE=$(BUILDDATE) >> envs.env
	touch envs



dockerserver: envs build app.py $(YMLFILE)
	$(call composeit,dockerserver)
	touch dockerserver

redis: $(YMLFILE) 
	$(call composeit,redis)
	touch redis

whoami: $(YMLFILE)
	$(call composeit,whoami)
	touch whoami
	
reverse-proxy: $(YMLFILE)
	$(call composeit,reverse-proxy)
	touch reverse-proxy	

log:
	@echo ===============================================================================================
	$(call log,whoami)
	$(call log,redis)
	$(call log,reverse-proxy)
	$(call log,dockerserver)
	@echo ===============================================================================================
	
stop:
	@echo ===============================================================================================
	$(call stop,whoami)
	$(call stop,redis)
	$(call stop,reverse-proxy)
	$(call stop,dockerserver)
	@echo ===============================================================================================		


remove:
	@echo ===============================================================================================
	$(call remove,whoami)
	$(call remove,redis)
	$(call remove,reverse-proxy)
	$(call remove,dockerserver)
	@echo ==============================================================================================
	
logs: 
	@echo "Starting logging of Flask server. CTRL-C to break"
	sudo tail -f $(HOSTDIR)/$(SHELLLOGFILE)

.PHONY: run logs 

#paremeter=name of the image to be booted up
define composeit
	@echo ===============================================================================================
	@echo SETTING UP DOCKERIMAGE: $(1)
	@echo 	
	sudo docker-compose -f $(YMLFILE) up -d $(1)
endef

define log
    @echo ----------- LOGS FOR: $(1) -------------------------------------------------------------------------------
	sudo docker ps | grep $(1) | awk '{print $$1}' | xargs sudo docker logs
endef

## needs checking existance of running image
define stop
	@echo ===============================================================================================
	@echo STOPPING DOCKERIMAGE: $(1)
	@echo 	
	sudo docker ps | grep $(1) | awk '{print $$1}' | xargs sudo docker stop 
	rm $(1)
endef

## needs checking of existance
define remove
	@echo ===============================================================================================
	@echo REMOVING DOCKERIMAGE: $(1)
	@echo 	
	sudo docker images | grep $(1) | awk '{print $$3}' | xargs sudo docker rmi -f
endef

