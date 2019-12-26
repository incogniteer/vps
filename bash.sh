#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o histexpand

finish() {
    printf "%s\n" "Something went wrong, exiting..."
}

trap finish ERR

#Set time zone corresponding to /usr/share/zoneinfo format
TIMEZONE="Asia/Shanghai"
pkgs=(wget 
      screen 
      vim 
      epel-release
)

for pkg in "${pkgs[@]}"; do
    { rpm -q "${pkg}" || which "${pkg}" &>/dev/null; }  || yum -y install "${pkg}"
done

#Alternatively: timedatectl set-timezone Asia/Shanghai
ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime

#Add [ ] otherwise will report errors
cat > /etc/profile.d/alias.sh <<'EOF'
#Common aliases
alias ls='ls --color=auto'
alias l.='ls -d .*'
alias l='ls -CF'
alias ll='ls -Fhl'
alias la='ls -ahFl'
alias lA='ls -AhFl'
alias ld='ls -dhFl'
alias l1='ls -1'
alias lt='ll -t --time-style=+"%F %T"'
alias lr='lt -r'
alias li='ls -i'
alias rm='rm -v'
alias mv='mv -v'
alias cp='cp -v'
alias cls='printf \\x1bc'
alias vi=vim
alias py='py ' #Note the trailing space
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

alias cd..='cd ../'
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias .3='cd ../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../../'
alias r='fc -s'
alias ret='echo $?'
alias path='echo -e ${PATH//:/\\n}'
alias type='type -a'
alias r='fc -s' #Use fc alias fc -s pat=rep cmd
alias chown='chown -v'
alias chmod='chmod -v'

EOF

#EOF should be quoted to avoid parameter expansion on EOF
#And avoid unbound variable prompt
cat >/etc/profile.d/func.sh <<'EOF'
#Bash functions definitions
# kill bash sessions
killbash () {
    local pids=( $(pgrep bash | grep -v $$) )
    for pid in "${pids[@]}"; do kill -9 $pid; done
} 2>/dev/null

# hisotry entries
h() {
    #Positional parameter and special can't assign in ${var:=} use if [ -n $var ]
    #Or ${var:-}
    local num=${1:-15}
    if [[ ! $num =~ [[:digit:]]+ ]]; then
        echo "Usage: h n(numeric argument!)..."
    else
    history $num
fi
}

#Aliase for one word, func preferred over alias, esp. for +2 words
git() {
    command git commit -a -m "miscellaneous" &&
    command git push
}


#below is incorret will fall into resurive call
#mkdir() {
#    mkdir -p $1
#    cd $1
#}

mkdir() {
    command mkdir -p $1 &&
    cd -P $1
}

#Or
mkcd() {
    command mkdir -p $1 &&
    cd -P $1
    #work in command linecd -P $1
}
EOF


cat >/etc/profile.d/misc.sh <<'EOF'
# history related items
shopt -s histappend
HISTFILE=~/.bash_history
HISTIGNORE=cls:h
HISTCONTROL=ignoredups:erasedupsi:ignorespace
HISTTIMEFORMAT='%F %T '
HISTSIZE=
HISTFILESIZE=
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a;history -c;history -r"

# stty command is executed only if a tty is attached to the process.
# stty istrip : Strip input characters to 7 bits
tty -s && stty istrip

[[ $- == *i* ]] && stty -ixon

# useful environment variables for visudo, sudoedit, fc
export VISUAL="$(command -pv vim)"
export EDITOR="$(command -pv vim)"
export FCEDIT="$(command -pv vim)"
EOF
