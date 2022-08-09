THIS_DIR:=$(shell dirname $(realpath $(lastword ${MAKEFILE_LIST})))

WHISPER_VERSION_RELEASE_NAME?=$(shell ${THIS_DIR}/whisper_version.sh -t whisper-beaglebone)
WHISPER_VERSION_RELEASE_NAME_BL?=$(shell ${THIS_DIR}/whisper_version.sh -t whisper-beaglebone -f=bootloader)
WHISPER_VERSION_ENV_VARS?=$(shell ${THIS_DIR}/whisper_version.sh -t whisper-beaglebone -f=export)

.PHONY: releasename
releasename:
	@echo ${WHISPER_VERSION_RELEASE_NAME}

.PHONY: releasename_bl
releasename_bl:
	@echo ${WHISPER_VERSION_RELEASE_NAME_BL}

.PHONY: whisper_version_env_vars
whisper_version_env_vars:
	@echo ${WHISPER_VERSION_ENV_VARS}
