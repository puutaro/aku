#!/bin/bash

# macOSとLinuxの両方に対応したユーザー名とホームディレクトリの取得
readonly USER_NAME="${SUDO_USER:-$(whoami)}"
if [[ "$OSTYPE" == "darwin"* ]]; then
    readonly HOME_PATH="/Users/${USER_NAME}"
    # macOSでは標準グループが異なるため動的に取得（通常はstaffなど）
    readonly GROUP_Name=$(id -gn "${USER_NAME}")
else
    readonly HOME_PATH="/home/${USER_NAME}"
    readonly GROUP_Name="${USER_NAME}"
fi

readonly AKU_HIDE_DIR_PATH="${HOME_PATH}/.aku"
readonly AKU_INSTALL_DIR_PATH="${AKU_HIDE_DIR_PATH}/aku"

rm -rf "${AKU_INSTALL_DIR_PATH}"
mkdir -p "${AKU_INSTALL_DIR_PATH}"
git clone "https://github.com/puutaro/aku.git" "${AKU_INSTALL_DIR_PATH}"

sudo chmod 777 -R "${AKU_HIDE_DIR_PATH}"
sudo chown "${USER_NAME}:${GROUP_Name}" -R "${AKU_HIDE_DIR_PATH}"

readonly AKU_CMD_DIR_PATH="${AKU_INSTALL_DIR_PATH}/cmd"
readonly USR_LOCAL_BIN="/usr/local/bin"

sudo cp -arf \
    "${AKU_CMD_DIR_PATH}"/* \
    "${USR_LOCAL_BIN}"/
