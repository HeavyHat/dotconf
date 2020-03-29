#!/bin/sh

git clone https://github.com/HeavyHat/dotconf.git
cd dotconf
sh basic-install.sh
cd ..
rm -Rf dotconf
