# Log in first:
#   echo $GITHUB_PAT | sudo docker login ghcr.io -u <user> --password-stdin
# 
# Usage:
#   make build-all REF=<logseq-commit/tag> TAG=<image-tag>   build images
#   make push-all  ALIAS="latest stable"   TAG=<image-tag>   push images, with optional aliases

REGISTRY ?= ghcr.io/almkx
IMAGES   := sync publish web

.PHONY: build-all push-all $(addprefix build-,$(IMAGES)) $(addprefix push-,$(IMAGES))

build-all: $(addprefix build-,$(IMAGES))
push-all: $(addprefix push-,$(IMAGES))

$(addprefix build-,$(IMAGES)): build-%:
	@test -n "$(REF)" || { echo "REF is required (logseq commit or tag)"; exit 1; }
	@test -n "$(TAG)" || { echo "TAG is required (image tag)"; exit 1; }
	sudo docker build -f $*/Dockerfile --build-arg LOGSEQ_REF=$(REF) -t $(REGISTRY)/logseq-$*:$(TAG) .

$(addprefix push-,$(IMAGES)): push-%:
	@test -n "$(TAG)" || { echo "TAG is required (image tag)"; exit 1; }
	sudo docker push $(REGISTRY)/logseq-$*:$(TAG)
	@for a in $(ALIAS); do \
	  sudo docker tag $(REGISTRY)/logseq-$*:$(TAG) $(REGISTRY)/logseq-$*:$$a && \
	  sudo docker push $(REGISTRY)/logseq-$*:$$a || exit 1; \
	done
