#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
# disable history expand in shell script
set +o histexpand

finish() {
    printf "%s\n" "Something went wrong, exiting..."
}

trap finish ERR

#Set time zone corresponding to /usr/share/zoneinfo format
TIMEZONE="Asia/Shanghai"

# os detection
os_detect() {
    if grep -i debian /etc/os-release; then
        printf debian
    elif grep -i centos /etc/os-release; then
        printf centos
    else
        printf 'unknown os'
    fi
}

OS=$(os_detect)
if [[ "${OS}" == 'debian' ]]; then
    pkgs=(
        vim 
        vim-gtk
        wget 
        curl
        tmux 
        openssh-client
        openssh-server
        proxychains
    )

    for pkg in "${pkgs[@]}"; do
        { dpgk -s "${pkg}" >/dev/null || which "${pkg}" &>/dev/null; }  || { apt update && apt -y install "${pkg}"; }
    done
elif [[ "${OS}" == 'centos' ]]; then
    pkgs=(
        vim 
        vimx
        wget 
        curl
        tmux 
        openssh-client
        openssh-server
        proxychains
        epel-release
    )

    for pkg in "${pkgs[@]}"; do
        { rpm -q "${pkg}" || which "${pkg}" &>/dev/null; }  || yum -y install "${pkg}"
    done
else
    echo 'uknown os, please make sure it is debian or centos'
    exit 1
fi

#Alternatively: timedatectl set-timezone Asia/Shanghai
ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime

#Add [ ] otherwise will report errors
cat > /etc/profile.d/alias.sh <<'EOF'
#Common aliases
# alias cls='printf \\x1bc'
alias ls='ls --color=auto'
alias ll='ls -hlF'
alias la='ll -a'
alias lA='ll -A'
alias ld='ll -d'
alias l='ls -Fp'
alias lt='ll -t --time-style=+"%F %T"'
alias lr='lt -r'
alias l.='ls -d .[^.]*' # column format
alias l..=$'ls -al | awk \'$NF ~ /^\.[^\.]+/\'' # listing format
alias l1='ls -1tr'
alias li='ls -i'
alias rm='rm -iv' # 加提示防止误操作
alias mv='mv -v'
alias cp='cp -v'
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
alias vimrc='vi ~/.vimrc'

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

cls() {
    printf '\x1bc'
    cd ~
}

# one-liner 编译c文件
gcc() 
{
    if grep -q "^/" <<<${1}; then
        # 针对vim编译
        local -r source="$1"
        command -p gcc ${source} \
        -o ${source%.c} &&
        chmod +x ${source%.c} && 
        ${source%.c}
    elif grep -q "^\." <<<${1}; then
        # 针对当前目录编译, 终端使用
        local -r source="$1"
        command -p gcc ${source} \
        -o ${source%.c} &&
        chmod +x ${source%.c} && 
        ${source%.c}
    else
        # 针对当前目录编译, 终端使用
        local -r source="./$1"
        echo $source
        command -p gcc ${source} \
        -o ${source%.c} &&
        chmod +x ${source%.c} && 
        ${source%.c}
    fi
}

EOF


cat >/etc/profile.d/misc.sh <<'EOF'
# history related items
# no need to export, bashrc is read in every invocation
shopt -s histappend
HISTFILE=~/.bash_history
HISTIGNORE=cls:h
#ignoreboth=ignoredups:ignorespace
HISTCONTROL=ignoredups:ignorespace:erasedups
HISTTIMEFORMAT='%F %T '
HISTSIZE= # unlimited
HISTFILESIZE= #unlimited
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a;history -c;history -r"

# stty command is executed only if a tty is attached to the process.
# stty istrip : Strip input characters to 7 bits
# sets the tty driver to strip input characters to 7bit ascii. ASCII is formally defined as having only 7 bits. "8 bit" ASCII is sometimes called "extended ascii".
tty -s && stty istrip

# 允许ctrl-s前滚历史记录搜索
[[ $- == *i* ]] && stty -ixon

# useful environment variables for visudo, sudoedit, fc
export VISUAL="$(which vim)"
export EDITOR="$(which vim)"
export FCEDIT="$(which vim)"

# 设置mysql，man默认分页器
# mysql 最好使用pager less -S -X -i -n -F
# -F, --quit-if-one-screen: quit less of output fit on screen
# -X, --no-init, disable termcap initialization, deinitialization
# -S, --chop-long-lines, not wrap longer lines than screen width
# -i, ignore case, but if with one uppercase, not ignore
# termcap may clear sreen unnecessarily
# 不然输出会很松散
export PAGER="$(which less) -i -N"
export MANPAGER="$(which less) -s"

# 确保LINES, COLUMNS变量是最新的
trap 'export LINES COLUMNS' DEBUG
EOF
