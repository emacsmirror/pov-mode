#!/bin/bash
# Copyright (C) 2008  Marco Pessotto
# <marco.erika@gmail.com>
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# check if povray is in your path
which povray 1>/dev/null 2>/dev/null
if [ ! $? -eq 0 ]; then
    echo "povray is not in your PATH. Why?"
    exit 1
fi

# I assume the share directory is here
povshare=$(echo $(dirname $(which povray)) | sed -e "s|bin|share/povray-3.6|")
echo  "Where is the share directory of povray? "
echo -n "Should be $povshare >>>  "
read povshare
if [ "$povshare" == "" ]; then
    povshare=$(echo $(dirname $(which povray)) | sed -e "s|bin|share/povray-3.6|")
    echo "Using default: $povshare "
fi


povlib=$(pwd)
# I assume that you are already untar this in the right directory
echo "Where are the emacs libs, where you are going to extract this files?" 
echo -n "I assume here, in $povlib >>>   "
read povlib
if [ "$povlib" == "" ]; then
    povlib=$(pwd)
    echo "Using default: $povlib "
fi
#get rid of slashes
povshare=$(echo $povshare | sed -e "s|//* *\$||")
povlib=$(echo $povlib | sed -e "s|//* *\$||")

sed -e "s|SHARELIBSPOVRAY|$povshare|" \
    -e "s|EMACSLISPLIBRARY|$povlib|" pov-mode.el > pov-mode-new.el

cp pov-mode.el pov-mode.el.backup
mv pov-mode-new.el pov-mode.el
echo "pov-mode.el has been updated, ready to run"
echo 
echo
append_me () {
echo "(autoload 'pov-mode \"${povlib}/pov-mode.el\" "
echo "          \"PoVray scene file mode\" t) "
echo "         (setq auto-mode-alist (append '((\"\\\\.pov\$\" . pov-mode)" 
echo "		  (\"\\\\.inc\$\" . pov-mode))"
echo "                auto-mode-alist))"
}

echo "You must add some lines on your .emacs, usually $HOME/.emacs"
echo
echo ";; =====CUT HERE======"
append_me
echo ";; =====CUT HERE====="
# 
# echo "Can I modify your $HOME/.emacs, appending a few lines, "
# echo "setting the load-path and the autoload, so you can use"
# echo "pov-mode now, after restarting emacs? Avoid this if you"
# echo -n " are upgrading an existent pov-mode.el (y/n) >>> "
# read i
# case $i in 
#     y|Y)
# 	if [ ! -f $HOME/.emacs ]; then
# 	    touch $HOME/.emacs
# 	fi
# 	cp $HOME/.emacs $HOME/.emacs_backup
# 	append_me >> $HOME/.emacs
# 	;;
#     *) 
# 	echo "giving up"
# 	;;
# esac
# 
exit 0
