function title {
    case "$TERM" in
    xterm*|rxvt*)
        echo -en "\033]2;$1\007"
        ;;
    *)
        ;;
    esac
}

function expand_psvar {
    local expanded=$1
    expanded="${expanded//\\u/$USER}"
    expanded="${expanded//\\h/$HOSTNAME}"
    local SHORT_PWD=${PWD/$HOME/~}
    expanded="${expanded//\\w/$SHORTPWD}"
    # remove \[ and \], keep everything between
    expanded=${expanded//'\['/}     # ']} appease vim syntax highlighting
    expanded=${expanded//'\]'/}
    expanded=$(eval echo '"'$expanded'"')
    echo -n $expanded
}

function clean_psvar {
    local cleaned=$1
    cleaned="${cleaned//\\u/$USER}"
    cleaned="${cleaned//\\h/$HOSTNAME}"
    local SHORT_PWD=${PWD/$HOME/~}
    cleaned="${cleaned//\\w/$SHORT_PWD}"
    # remove \[ and \] and everything between
    cleaned="$(sed -r 's:\\\[([^\\]|\\[^]])*\\\]::g' <<<$cleaned)"
    cleaned=$(eval echo -e $cleaned)
    echo -n $cleaned
}

function print_pre_prompt {
    local PS1L_exp=$(expand_psvar $PS1L)
    local PS1L_clean=$(clean_psvar $PS1L)
    local PS1R_exp=$(expand_psvar $PS1R)
    title $PS1L_clean
    printf "%b%$(($COLUMNS-${#PS1L_clean}))b\n" "$PS1L_exp" "$PS1R_exp"
}
