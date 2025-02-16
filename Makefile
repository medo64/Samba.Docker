#~ Docker Project

.PHONY: default docker publish
default: docker

docker:                 # Build the docker image
	@./make.sh docker

publish:                # Publish the docker image
	@./make.sh publish
