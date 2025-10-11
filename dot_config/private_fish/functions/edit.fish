# ~/.config/fish/functions/edit.fish
function edit --description "Edits files, selecting appropriately between $EDITOR for SSH/remote sessions and $VISUAL otherwise. Checks for chezmoi management."
    # Check if any file in the arguments is managed by chezmoi
    for file in $argv
        # Use `command` to bypass potential aliases and call chezmoi directly
        if command chezmoi verify "$file" >/dev/null 2>&1
            echo "Warning: The file '$file' is managed by chezmoi."
            read -l -P "Do you still want to edit it? [y/N] " confirm
            switch $confirm
                case Y y
                    echo "Proceeding to edit '$file'."
                case '' N n
                    echo "Edit cancelled for '$file'."
                    return 1
            end
        end
    end

    # --- Original editor selection logic ---
    # Prioritize checking for an SSH session.
    if set -q SSH_CONNECTION
        # --- SSH Session ---
        # Always use the terminal-based editor.
        if set -q EDITOR
            $EDITOR $argv
        else
            echo "Error: \$EDITOR is not set for this SSH session." >&2
            return 1
        end
    else if set -q DISPLAY
        # --- Graphical Session (Local) ---
        # Prefer $VISUAL, fall back to $EDITOR.
        if set -q VISUAL
            $VISUAL $argv
        else if set -q EDITOR
            echo "Notice: \$VISUAL not set; falling back to \$EDITOR."
            $EDITOR $argv
        else
            echo "Error: Neither \$VISUAL nor \$EDITOR is set." >&2
            return 1
        end
    else
        # --- Non-Graphical Session (Local TTY) ---
        # Use $EDITOR only.
        if set -q EDITOR
            $EDITOR $argv
        else
            echo "Error: \$EDITOR is not set for this non-graphical session." >&2
            return 1
        end
    end
end
