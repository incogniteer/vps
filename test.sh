# hisotry entries
h() {
    #Positional parameter and special can't assign in ${var:=} use if [ -n $var ]
    #Or ${var:-}
    declare -i num
    local num=${1:-15}
    if [[ ! $num =~ [[:digit:]]+ ]]; then
        echo "Usage: h n(numeric argument!)..."
    else
    history $num
fi
}
