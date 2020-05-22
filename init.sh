#!/bin/bash
_abort() { echo 'Aborted' && exit 1; }
_error() {
    if [[ $1 != "" ]]; then
        echo "$0: error: $1"
    fi
    echo "usage: $0 -u GitHubUser -e GitHubEmail"
    exit 1
}

# Processing command-line arguments
while getopts u:e: OPT; do
    case ${OPT} in
        u) user=${OPTARG};;
        e) email=${OPTARG};;
        \?) _error;;
    esac
done

if [[ "${user}" == "" || "${email}" == "" ]]; then
    _error 'invalid arguments'
fi

# Generating SSH key
keyfile=~/.ssh/id_rsa
if [[ ! -f "${keyfile}" ]]; then
    ssh-keygen -f "${keyfile}" -t rsa -b 4096 -C "${email}" || _abort
fi

echo 'Updating system'
sudo apt update && sudo apt upgrade --yes || _abort

echo 'Installing packages'
sudo snap install chromium
sudo apt install --yes git ansible

echo 'Configuring git'
git config --global user.name "${user}"
git config --global user.email "${email}"
git config --global push.default current
git config --global push.followTags true

echo 'Configuring ansible'
file=/etc/ansible/hosts
line='localhost ansible_connection=local'
sudo grep -xqF -- "${line}" "${file}" || echo "${line}" | sudo tee --append "${file}" > /dev/null

echo 'Creating projects folder'
mkdir -p ~/Projects

echo 'Initialization complete'
