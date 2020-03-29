# Dotconf

A repo containing basic scripts that can automate the typical setup I use for devlopment, complete with:
* Vim config
* tmux config
* gitconfig
* zshrc
* oh-my-zsh instalation
* ssh key gen and submission to github

When you run the script it will ask for confirmation at each step and you can opt into parts of the configuration without others. As part of the instalation process it will push a new ssh key to github for the machine allowing you to begin using the git protocol straight out of the box. Currently this only supports Debian based distributions.

## Instalation

**via curl**
```bash
sh $(curl -fsSL "https://raw.githubusercontent.com/HeavyHat/dotconf/master/install.sh")
```

**via wget**
```bash
sh $(wget -O- "https://raw.githubusercontent.com/HeavyHat/dotconf/master/install.sh")
```

## Contents
```bash
.
├── basic-install.sh
├── conf
│   ├── cookiecutter.json
│   └── {{cookiecutter.user_name}}
├── install.sh
├── README.md
└── templatedcookiecutter.json
2 directories, 5 files
```
