#!/usr/bin/env bash

#Backup common files

sudo rsync  --delete -azvhP ~/{bin,git,python,.ssh} /etc/{vimrc,bashrc,ssh_config,host,sudoers}
