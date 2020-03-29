#!/bin/sh

DRY_RUN=0
NOT_UPDATED=1
GITHUB_URL="https://api.github.com"
MY_PATH="`dirname \"$0\"`"
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

function print_help() {
   # Display Help
   echo "Installs basic development setup with needed functionality."
   echo
   echo "Syntax: basic-install.sh [-u|-d|-h]"
   echo "options:"
   echo "-d --dry-run       Run in dry-run mode."
   echo "-u --no-update     Do not update apt-get package list."
   echo "-h --help          Print this Help."
}

case $key in
    -d|--dry-run)
    DRY_RUN=1
    echo "Running as a dry run, will use example_dir to hold what would be the installed configuration."
    shift 1
    ;;
    -u|--no-update)
    NOT_UPDATED=0
    echo "Not updating package list, will pull packages based on the current package list."
    shift 1
    ;;
    -g|--github-url)
    GITHUB_URL=$2
    echo "Using $GITHUB_URL for github endpoint."
    shift 2
    ;;
    -h|--help)
    print_help
    shift 1
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters


function install_package() {
    if [[ $NOT_UPDATED -ne 0 ]]; then
        NOT_UPDATED=0
        if [[ $DRY_RUN -ne 0 ]]; then
            echo "sudo apt-get update"
        else
            sudo apt-get update
        fi
    fi
    PROGRAM_NAME=${2:-$1}
    if  hash $PROGRAM_NAME 2> /dev/null; then
        echo "$PROGRAM_NAME is installed!"
    else
        if [[ $DRY_RUN -ne 0 ]]; then
            echo "sudo apt-get install $1"
        else
            sudo apt-get install $1 || exit $?
        fi
    fi
}

function with_confirmation() {
	read -p "$1 [y/n]" -n 1 -r
	echo    # (optional) move to a new line
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		${*:2}
	fi
}

function add_github_sshkey() {
	ssh-keygen -q -t rsa -b 4096 -f "$HOME/.ssh/id_rsa"
	curl -u "$2" --data "{\"title\":\"$(hostname)\",\"key\":\"$(cat ~/.ssh/id_rsa.pub)\"}" "$1/user/keys"
}

function install_omz() {
    $(sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k ) &
}


install_package zsh
install_package tmux
install_package git
install_package ack
install_package hub
install_package fzf
install_package curl
install_package tree
install_package vim-nox vim
install_package cookiecutter
with_confirmation "Would you like to install oh-my-zsh?" install_omz
cat templatedcookiecutter.json | sed "s/\"user_name\": ".*",/\"user_name\": \"$USER\",/g" > conf/cookiecutter.json
cookiecutter "$MY_PATH"/conf -o "$MY_PATH"/output
GENERATED_DIR="$(ls output)"
GIT_USERNAME=$(grep "git_username" conf/cookiecutter.json | sed "s/\"git_username\": \"//g" | sed s/\",\$//g)
with_confirmation "Would you like to add and push a new ssh key to $GITHUB_URL?" add_github_sshkey "$GITHUB_URL" "$GIT_USERNAME"
cp -r "$MY_PATH"/output/"$GENERATED_DIR"/. ~/.
rm -Rf "$MY_PATH"/output
