function title {
    case "$TERM" in
    xterm*|rxvt*)
        echo -en "\033]2;$1\007"
        ;;
    *)
        ;;
    esac
}

print_pre_prompt() {
    PS1R=$(date)
    PS1L_exp="${PS1L//\\u/$USER}"
    PS1L_exp="${PS1L_exp//\\h/$HOSTNAME}"
    SHORT_PWD=${PWD/$HOME/~}
    PS1L_exp="${PS1L_exp//\\w/$SHORT_PWD}"
    PS1L_clean="$(sed -r 's:\\\[([^\\]|\\[^]])*\\\]::g' <<<$PS1L_exp)"
    PS1L_exp=${PS1L_exp//\\\[/}
    PS1L_exp=${PS1L_exp//\\\]/}
    PS1L_exp=$(eval echo '"'$PS1L_exp'"')
    PS1L_clean=$(eval echo -e $PS1L_clean)
    title $PS1L_clean
    printf "%b%$(($COLUMNS-${#PS1L_clean}))b\n" "$PS1L_exp" "$PS1R"
}
