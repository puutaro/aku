#!/bin/bash

readonly FILES_LIB_PATH="$(dirname "${0}")"
readonly USER_NAME=$(\
	echo "${FILES_LIB_PATH}" \
	| awk '{
		split($0, path_array, "/")
		print path_array[3]
	}'\
)
readonly HOME_PATH="/home/${USER_NAME}"
readonly AKU_INSTALL_DIR_PATH="${HOME_PATH}/.aku/aku"
rm -rf "${AKU_INSTALL_DIR_PATH}"
mkdir -p "${AKU_INSTALL_DIR_PATH}"
git clone "https://github.com/puutaro/aku.git"  "${AKU_INSTALL_DIR_PATH}"

readonly AKU_CMD_ROOT_PATH="${AKU_INSTALL_DIR_PATH}/cmd/aku"
readonly AKU_CMD_LIMK_PATH="/usr/local/bin/aku"

sudo rm "${AKU_CMD_LIMK_PATH}"
sudo ln -s \
	"${AKU_CMD_ROOT_PATH}" \
	"${AKU_CMD_LIMK_PATH}"