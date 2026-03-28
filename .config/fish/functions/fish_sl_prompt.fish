set -g fish_color_sl_clean green
set -g fish_color_sl_modified yellow
set -g fish_color_sl_dirty red

set -g fish_color_sl_added green
set -g fish_color_sl_deleted red
set -g fish_color_sl_missing red
set -g fish_color_sl_untracked yellow

set -g fish_prompt_sl_status_added '✚'
set -g fish_prompt_sl_status_modified '*'
set -g fish_prompt_sl_status_deleted '✖'
set -g fish_prompt_sl_status_missing '!'
set -g fish_prompt_sl_status_untracked '?'

set -g fish_prompt_sl_status_order added modified deleted missing untracked

function fish_print_sl_root --description 'Print the .sl directory of the current repository'
    set -l dir $PWD
    while test $dir != /
        if test -d $dir/.sl
            echo $dir/.sl
            return 0
        end
        set dir (path dirname -- $dir)
    end
    return 1
end

function fish_sl_prompt --description 'Write out the sl prompt'
    if not command -sq sl
        return 1
    end

    fish_print_sl_root >/dev/null
    or return 1

    set -l log_info (sl log -r . --template '{branch}\n{activebookmark}\n' 2>/dev/null)
    set -l branch $log_info[1]
    set -l bookmark $log_info[2]

    set -l display $branch
    if test -n "$bookmark"
        set display "$branch|$bookmark"
    end

    if not set -q fish_prompt_sl_show_informative_status
        set_color normal
        echo -n " ($display)"
        return
    end

    echo -n '|'

    set -l repo_status (sl status 2>/dev/null | string sub -l 2 | sort -u)

    if test -z "$repo_status"
        set_color $fish_color_sl_clean
        echo -n "($display)"'✓'
        set_color normal
    else
        set -l sl_statuses
        set -l dq '?'

        for line in $repo_status
            switch $line
                case 'A '
                    set -a sl_statuses added
                case 'M '
                    set -a sl_statuses modified
                case 'R '
                    set -a sl_statuses deleted
                case '! '
                    set -a sl_statuses missing
                case "$dq "
                    set -a sl_statuses untracked
            end
        end

        if string match -qr '^[AM]' $repo_status
            set_color $fish_color_sl_modified
        else
            set_color $fish_color_sl_dirty
        end

        echo -n "($display)"'✗'

        for i in $fish_prompt_sl_status_order
            if contains -- $i $sl_statuses
                set -l color_name fish_color_sl_$i
                set -l status_name fish_prompt_sl_status_$i

                set_color $$color_name
                echo -n $$status_name
            end
        end

        set_color normal
    end
end
