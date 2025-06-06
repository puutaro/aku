#!/bin/bash

readonly FILES_LIB_PATH="$(pwd)"
readonly USER_NAME=$(\
	echo "${FILES_LIB_PATH}" \
	| awk '{
		split($0, path_array, "/")
		print path_array[3]
	}'\
)
readonly HOME_PATH="/home/${USER_NAME}"
readonly AKU_HIDE_DIR_PATH="${HOME_PATH}/.aku"
readonly AKU_INSTALL_DIR_PATH="${AKU_HIDE_DIR_PATH}/aku"
rm -rf "${AKU_INSTALL_DIR_PATH}"
mkdir -p "${AKU_INSTALL_DIR_PATH}"
git clone "https://github.com/puutaro/aku.git"  "${AKU_INSTALL_DIR_PATH}"
sudo chmod 777 -R "${AKU_HIDE_DIR_PATH}"
sudo chown ${USER_NAME}:${USER_NAME} -R "${AKU_HIDE_DIR_PATH}"

readonly AKU_CMD_DIR_PATH="${AKU_INSTALL_DIR_PATH}/cmd"
readonly USR_LOCAL_BIN="/usr/local/bin"

sudo cp -arf \
	"${AKU_CMD_DIR_PATH}"/* \
	"${USR_LOCAL_BIN}"/