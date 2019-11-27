#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

finish() {
    printf "%s\n" "Something went wrong, exiting..."
}

trap finish ERR

pkgs=(wget screen vim epel-release)
for pkg in "${pkgs[@]}"; do
    rpm -q "${pkg}" || yum -y install "${pkg}"
done

#Alternatively: timedatectl set-timezone Asia/Shanghai
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

#Add [ ] otherwise will report errors
cat >> /etc/bashrc <<EOF

#User defined bash configs
alias ls='ls -h --color=auto'
alias l='ls -CF'
alias la='ls -al'
alias ld='ls -dl'
alias l1='ls -1'
alias lt='l -t'
alias lr='lt -r'
alias li='ls -i'
alias rm='rm -v'
alias mv='mv -v'
alias cp='cp -v'
alias rmdir='rmdir -v'
alias cls="echo -en '\\x1bc'"
alias vi=vim
alias py='python3'
alias sudo='sudo ' #Enable alias in sudo

alias rmdir='rmdir -pv'
alias path='echo -e ${PATH//:/\\n}'
alias grep='grep --color=auto'
alias egrep='grep -E --color=auto'
alias fgrep='grep -F --color=auto'
alias less='less -RN'
alias sys='systemctl'
alias syss='sys status -l'
alias now='date +%T'
alias nowd='date +%F'

alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias .3='cd ../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../../'
alias r='fc -s'
alias ret='echo $?'
alias type='type -a'

#Alternatively, [ -t 0 ] or if tty -s >/dev/null 2>&1; then
[[ $- == *i* ]] && stty -ixon
# stty command is executed only if a tty is attached to the process.
# stty istrip : Strip input characters to 7 bits
tty -s && stty istrip
# Turn on "Ctrl-s" for forward history search
stty -ixon

export VISUAL="$(command -pv vim)"
export EDITOR="$(command -pv vim)"

EOF

[ $? -eq 0 ] && . /etc/bashrc
