# XDG base directory spec
set -x XDG_CONFIG_HOME "$HOME/.config"
set -x XDG_CACHE_HOME "$HOME/.cache"
set -x XDG_DATA_HOME "$HOME/.local/share"

set -x LESSHISTFILE '-'
set -x TERMINFO_DIRS "$XDG_DATA_HOME/terminfo:/usr/share/terminfo"
set -x NPM_CONFIG_USERCONFIG "$XDG_CONFIG_HOME/npm/npmrc"
set -x RANDFILE "$XDG_DATA_HOME/openssl/rnd"
set -x WEECHAT_HOME "$XDG_CONFIG_HOME/weechat"

set -x LANG 'en_GB.UTF-8'
set -x EDITOR 'nvim'

function client-tz
	if set -q SSH_CLIENT_TZ
		echo $SSH_CLIENT_TZ
		return
	end
	if test (uname -s) = 'Darwin'
		readlink /etc/localtime | sed 's#/var/db/timezone/zoneinfo/##'
	else
		timedatectl status | awk '/Time zone:/{ print $3 }'
	end
end

set -x SSH_CLIENT_TZ (client-tz)

function go-arch
	set -l os (uname -s | tr A-Z a-z)
	set -l arch (uname -m)
	if test "$arch" = "x86_64"
		set -l arch 'amd64'
	end
	printf "%s_%s" "$os" "$arch"
end

set -x GOPATH "$HOME/scratch/go"
set -x GOBIN "$HOME/scratch/go/bin/"(go-arch)

set -x HOMEBREW_NO_ANALYTICS 1
set -x HOMEBREW_NO_AUTO_UPDATE 1
set -x HOMEBREW_NO_EMOJI 1

if status is-login
	set -x PATH "$HOME/.local/bin" "$HOME/.cargo/bin" $PATH

	if test (uname) = Darwin
		set -x PATH $PATH "/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources"
		set -x PATH $PATH "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources"
	end

	abbr digs 'dig +short'
end

if test (uname) = Darwin
	set -x MAKEFLAGS "-j"(sysctl -n hw.ncpu)
	bind \e\[5D prevd-or-backward-word
	bind \e\[5C nextd-or-forward-word
else if test (uname) = Linux
	set -x MAKEFLAGS "-j"(nproc --all)
end

set fish_greeting ""
set fish_color_normal "normal"
set fish_color_command "7cafc2"
set fish_color_quote "f7ca88"
set fish_color_redirection "normal"
set fish_color_end "7cafc2"
set fish_color_error "ab4642"
set fish_color_param "ba8baf"
set fish_color_comment "b8b8b8"
set fish_color_match "7cafc2"
set fish_color_search_match "--background=383838"
set fish_color_operator "7cafc2"
set fish_color_escape "a1b56c"
set fish_color_cwd "a1b56c"
set fish_color_cwd_root "ab4642"
set fish_color_autosuggestion "585858"
set fish_color_valid_path "--underline"
set fish_pager_color_prefix "86c1b9"
set fish_pager_color_completion "normal"
set fish_pager_color_description "b8b8b8"
set fish_pager_color_progress "86c1b9"

set fish_prompt_hg_show_informative_status "yes"

set __fish_git_prompt_showdirtystate "yes"
set __fish_git_prompt_showstashstate "yes"
set __fish_git_prompt_showupstream "auto"
set __fish_git_prompt_showuntrackedfiles "yes"
set __fish_git_prompt_color_branch "yellow"
set __fish_git_prompt_char_dirtystate "d"
set __fish_git_prompt_char_stagedstate "s"
set __fish_git_prompt_char_upstream_ahead "+"
set __fish_git_prompt_char_upstream_behind "-"
set __fish_git_prompt_char_upstream_equal "."
set __fish_git_prompt_char_upstream_diverged "X"

if begin test (uname) = Linux; and set -q XDG_SESSION_TYPE; and test $XDG_SESSION_TYPE = wayland; end
	set FISH_CLIPBOARD_CMD wayclip
end

# colour scheme
if status is-login
	if begin test "$TERM_PROGRAM" = "iTerm.app"; or test "$TERM_PROGRAM" = "ghostty"; end
		ccc-base16.py
	end
end

if test -f "$HOME/.config/fish/local.fish"
	source "$HOME/.config/fish/local.fish"
end
