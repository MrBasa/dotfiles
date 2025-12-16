#!/usr/bin/env fish
#
# A safer 'rm' wrapper with trash and destructive-op checks
#

if not type -q trash-put; return; end

alias trash='trash-put'

# A multi-stage safe 'rm' wrapper
function rm --wraps rm -d "Safe 'rm' wrapper with trash and destructive-op checks"
    # --- Configuration ---
    set -l wide_delete_threshold 5 # How large of a delete is considered 'dangerous'

    # --- Color Variables ---
    set -l c_m (set_color bryellow)     # Main prompt text
    set -l c_cmd (set_color brwhite)    # Command/code text
    set -l c_warn (set_color brred)     # DANGER/Warning text
    set -l c_abort (set_color yellow)   # Abort/cancel text
    set -l c_path (set_color brcyan)    # File paths
    set -l c_hl (set_color brblue)      # Highlighted info (numbers, reasons)
    set -l c_faint (set_color --dim)    # Faint/dim text
    set -l c_norm (set_color normal)    # Reset

    # --- Pre-flight checks ---
    if status --is-command-substitution; return; end
    if test -z "$argv"; command rm; return $status; end
    if contains -- --help $argv; or contains -- --version $argv; command rm $argv; return $status; end

    # --- Parse Arguments (Moved to Top) ---
    # We do this early so we can separate flags from files for the 'trash' command
    set -l is_recursive 0
    set -l options
    set -l targets

    for arg in $argv
        if string match -q -- '-*' "$arg"
            set -a options $arg
            # Check for -r, --recursive, or combined flags like -rf
            if string match -q -- '*r*' "$arg"; or string match -q -- '--recursive' "$arg"
                set is_recursive 1
            end
        else
            set -a targets $arg
        end
    end

    # --- Choose trash vs rm ---
    echo $c_abort" "$c_m"You are using '"$c_cmd"rm"$c_m"' ("$c_warn"permanent delete"$c_m"). Use '"$c_cmd"trash-put"$c_m"' instead?"$c_norm
    read -n 1 -P $c_m"("$c_cmd"Y"$c_m")es use 'trash', ("$c_cmd"n"$c_m")o continue with rm, or ("$c_cmd"a"$c_m")bort? ["$c_cmd"Y"$c_m"/"$c_cmd"n"$c_m"/"$c_cmd"a"$c_m"]: "$c_norm" " reply

    switch (string lower -- $reply)
        case y ''
            # User chose 'Y'. Replace with trash-put.
            # CRITICAL FIX: Only use $targets (files), ignoring $options (flags like -rf)
            echo $c_m"↪ Replacing with 'trash-put'..."$c_norm
            
            # Escape targets to handle spaces/special chars safely
            set -l cmd_list trash (string escape -- $targets)
            
            # Use 'string join --' to prevent parsing errors
            commandline --replace (string join -- " " $cmd_list)
            return
        case n
            # User confirmed 'yes'. Proceed to Stage 2.
            echo $c_m"Proceeding with 'rm'..."$c_norm
        case '*' # 'a', or anything else
            # User aborted. Restore the ORIGINAL rm command (with flags).
            echo $c_abort"🚫 Aborted."$c_norm
            
            set -l cmd_list rm (string escape -- $argv)
            commandline --replace (string join -- " " $cmd_list)
            return 1
    end

    # --- Check for destructive operation ---
    # We already parsed options/targets above, so we just check logic here.
    
    # Check if we're in The Danger Zone!
    set -l is_dangerous 0
    set -l danger_reason ""

    if test $is_recursive -eq 1; and contains -- . ~ "$HOME" $targets
        set is_dangerous 1
        set danger_reason "Recursive deletion on critical path (., ~, or HOME)."
    else if test (count $targets) -gt $wide_delete_threshold
        set is_dangerous 1
        set danger_reason "Deleting "$c_hl(count $targets)$c_abort" items (threshold is $wide_delete_threshold)."
    end

    # If not dangerous, just run the command.
    if test $is_dangerous -eq 0
        command rm $argv
        return $status
    end

    # --- Destructive command operation prompt ---
    echo $c_warn"⚠  DESTRUCTIVE COMMAND DETECTED"$c_norm
    echo "You are attempting to run: "$c_cmd"rm $argv"$c_norm
    echo $c_abort"Reason: "$c_hl$danger_reason$c_norm

    # Be smart about listing targets. Don't list 10,000 files.
    set -l target_count (count $targets)
    if test $target_count -gt 20
        echo $c_m"Listing first 10 targets:"$c_norm
        set -l targets_to_show $targets[1..10]
    else
        echo $c_m"Listing all "$c_hl$target_count$c_m" targets:"$c_norm
        set -l targets_to_show $targets
    end

    for target in $targets_to_show
        if test -e "$target"
            echo "  "$c_path" "(realpath -- "$target" 2>/dev/null)$c_norm
        else
            echo "  "$c_faint"👻 $target (path not found)"$c_norm
        end
    end

    if test $target_count -gt 20
            echo "  "$c_faint"... and "$c_hl(math $target_count - 10)$c_faint" more."$c_norm
    end

    read -P $c_warn"Are you absolutely sure you want to proceed? [y/N] "$c_norm" " confirm

    switch (string lower -- $confirm)
        case y yes
            command rm $argv
            return $status
        case '*'
            echo $c_abort"🚫 Operation aborted by user."$c_norm
            return 1
    end
end
