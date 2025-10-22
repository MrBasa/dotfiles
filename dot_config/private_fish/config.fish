#!/usr/bin/env fish
# Fish Shell Configuration ::  ~/.config/fish/config.fish

# Commands to run in interactive sessions can go here
if status is-interactive

	# --- Configure Text Browser ---
	if not set -q DISPLAY and type -q lynx
	    set -x BROWSER lynx
	end

    # --- Set Default Editors ---
	set -l MY_EDITOR micro
	set -l MY_VISUAL_EDITOR kate

    if set -q SSH_CONNECTION
        # In an SSH session, use a terminal-based editor.
        set -x EDITOR $MY_EDITOR
        set -x VISUAL $MY_EDITOR
    else if set -q DISPLAY
        # In a local graphical session, use Kate.
        set -x EDITOR $MY_EDITOR
        set -x VISUAL $MY_VISUAL_EDITOR
    else
        # In a local non-graphical session, use a terminal editor.
        set -x EDITOR $MY_EDITOR
        set -x VISUAL $MY_VISUAL_EDITOR
    end

    # --- Bat Config ---
    if type -q bat or type -q batcat
        alias cat='bat'

        # - Set bat as a colorizing pager for man -
	    export MANPAGER="sh -c 'awk '\''{ gsub(/\x1B\[[0-9;]*m/, \"\", \$0); gsub(/.\x08/, \"\", \$0); print }'\'' | bat -p -lman'"

	    # Alias to pipe help output to bat for syntax highlighting
	    alias bathelp 'bat --plain --language=help'
    end

    # --- Zoxide ---
    if type -q zoxide
        zoxide init fish | source
    end
    
	# --- LSD Directory Lister ---
	if type -q lsd
		alias ls="lsd"
		# Long format list
		alias ll="ls -l"
		# Long format including hidden files
		alias la="ll --almost-all"
		# Default l
		alias l="lsd -l --almost-all"
		# Tree view
		alias lt="lsd -l --tree --depth=2"
	else
        alias l="ls"
        alias ll="l -l"
        alias la="ll -a"
	end

    # --- File List Colors ---
    if type -q vivid
    	set -x LS_COLORS (vivid generate molokai)
    end

    # --- Aliases ---
    # FastFetch
	if type -q fastfetch
		alias ff="fastfetch"
	end

	# Please - Run last command with sudo and remove it from history
	alias please='echo (set_color -o yellow) "Go do that sudo that you do!"; commandline -i "sudo $history[1]"; history delete --exact --case-sensitive "$history[1]"'

	# --- Tide Config ---
    # Including some commonly tweaked Tide configs
	#set -g tide_prompt_transient_enabled true
	#set -g tide_add_newline_before true
	#set -g tide_context_always_display false
    #set -g tide_prompt_icon_connection '·'
	#set -g tide_prompt_color_frame_and_connection 282828
    # Make OS icon prominent
    #set -g tide_os_color brwhite --bold
    # When the user is root, make the context bold red.
    #set -g tide_context_color_root brred --bold

    # --- CLI Trash ---
    if type -q trash-put
        alias trash='trash-put'
        #alias rm='echo (set_color brred)"This is not the command you are looking for. "(set_color normal)"(Try \'"(set_color brcyan)"trash-put"(set_color normal)"\')"; false'

        # A safer rm function that confirms before permanent deletion.
        function rm --wraps rm -d "Wrapped 'rm' command with confirmation"
            # If no files are specified, let the original rm handle it.
            if test -z "$argv"; command rm; return; end
        
            echo -e "\e[1;31mYou are using 'rm' for permanent deletion.\e[0m"
            read -P "Are you sure? (use 'trash' to be safer) [y/N] " -l reply
        
            if test (string lower -- $reply) = "y"
                echo "Proceeding with permanent deletion..."
                command rm $argv # Pass all original arguments to the real rm command
            else
                echo "Aborted."
                return 1
            end
        end
    end

    # --- Welcome Message ---
	function fish_greeting -d 'Prints a welcome message with shell version'
	    # --- Remote Display Only ---
	    if set -q SSH_CLIENT
    	    if type -q figlet
    	        set_color brblue
    	        hostname -f | string upper | figlet -f slant -c -w 76 #(tput cols)
                set_color normal
            end
        end

        # --- Always Display ---
	    if type -q fastfetch
	        fastfetch
	    end

		echo (set_color blue)🐟(set_color normal) (fish --version)
		echo -e (set_color cyan)'\e[2A\e[2C°\e[1A.\e[1A◯\e[3B'
	end
end
