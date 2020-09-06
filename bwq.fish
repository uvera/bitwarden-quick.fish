set -g bitwarden_quick_version 1.0

function bwq -d "Quickly copy a password from bitwarden official server"
    switch "$argv"
        case {,-}-v{ersion,}
            echo bitwarden-quick.fish version $bitwarden_quick_version
        case {,-}-h{elp,} ""
            echo "Usage: bwq [ENTRY NAME]"
        case \*
            if test -e $HOME/.cache/BW_SESSION
            and test -f $HOME/.cache/BW_SESSION
            and test -n (cat $HOME/.cache/BW_SESSION)
                set -g value
                set value (bw get --session (cat $HOME/.cache/BW_SESSION) password $argv)
                if test $status = 1
                    return 1
                end
                if test -z "$value"
                    set -g token (bw login --raw)
                    if test -z $token
                        set token (bw unlock --raw)
                    end
                    echo $token > $HOME/.cache/BW_SESSION
                    set -l ret (bwq $argv)
                    return $ret
                end
            else
                set -l token (bw unlock --raw)
                if test -z $token
                    set token (bw login --raw)
                end
                echo $token > $HOME/.cache/BW_SESSION
                set -l ret (bwq $argv)
                return $ret
            end
            echo 'Copied to clipboard.'
            echo $value | xclip -selection c
            set -e value
    end
    return 0
end
