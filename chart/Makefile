.PHONY: help

help:
	@echo "PrimeHub"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "targets:"
	@echo ""
	@echo "  primehub-controller-update-scripts"
	@echo "	 install-dev-requirements"
	@echo "  test"
	@echo "  clean"

check-yq:
	@if ! command -v yq >> /dev/null; then \
		echo "command yq not found"; \
		exit 1; \
	fi

check-jq:
	@if ! command -v jq >> /dev/null; then \
		echo "command jq not found"; \
		exit 1; \
	fi

primehub-controller-update: primehub-controller-update-scripts

primehub-controller-update-scripts: check-yq check-jq
	@echo "Updating scripts for controller..."
	@mkdir -p scripts/controller/custom_image; \
		cd scripts/controller/custom_image; \
		echo "Syncing 'custom_image'"; \
		curl -s "https://api.github.com/repos/infuseai/primehub-controller/contents/ee/scripts/custom_image?ref=master" | jq -r '.[].download_url' | grep -v -e "^null$$" | xargs -I{} curl -s -OL {}; \
		chmod +x ./*.sh
	@mkdir -p scripts/controller/job; \
		cd scripts/controller/job; \
		echo "Syncing 'job'"; \
		curl -s "https://api.github.com/repos/infuseai/primehub-controller/contents/ee/scripts/job?ref=master" | jq -r '.[].download_url' | grep -v -e "^null$$" | xargs -I{} curl -s -OL {}; \
		chmod +x ./*.sh
	@echo "Done"

# TODO: Now crds are not included under chart root. Should move this target to somewhere else.
primehub-controller-update-crds: check-yq check-jq
	@echo "Updating crds for controller..."
	# We skip image CRD because we place images,instancetypes,datasets CRDs in templates/crd.yaml
	@skip_crds='primehub.io_images.yaml' ;\
	echo "Skipping CRD file: $${skip_crds}" ;\
	crd_yaml='templates/crd-controller.yaml'; \
		rm -f $$crd_yaml; \
		curl -s "https://api.github.com/repos/infuseai/primehub-controller/contents/config/crd/bases"	| jq -r '.[].download_url' | grep -v -e "^null$$" | grep -vE "$${skip_crds}" | xargs -I{} curl -s {} >> $$crd_yaml; \
		curl -s "https://api.github.com/repos/infuseai/primehub-controller/contents/ee/config/crd/bases"	| jq -r '.[].download_url' | grep -v -e "^null$$" | xargs -I{} curl -s {} >> $$crd_yaml; \
		echo "$$crd_yaml updated"

clean:
	rm -rf __pycache__
	rm -rf .pytest_cache/
	rm -rf tests/__pycache__

install-dev-requirements:
	LDFLAGS=-L/usr/local/opt/openssl/lib \
		CPPFLAGS=-I/usr/local/opt/openssl/include \
		PYCURL_SSL_LIBRARY=openssl \
		pip3 install pytest-cov
	LDFLAGS=-L/usr/local/opt/openssl/lib \
		CPPFLAGS=-I/usr/local/opt/openssl/include \
		PYCURL_SSL_LIBRARY=openssl \
		pip3 install -r ../vendor/zero-to-jupyterhub-k8s/images/hub/requirements.txt --upgrade

test:
	TEST_FLAG=true PYTHONPATH=../vendor/zero-to-jupyterhub-k8s/jupyterhub/files/hub:scripts/jupyterhub/config/:../../../modules/primehub-admission/src/ py.test --cov=./ tests/test*.py --cov-report xml:coverage.xml --cov-report html
