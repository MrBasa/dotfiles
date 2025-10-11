# ~/.config/functions/fortune.fish
function fortune --description "Shows custom fortune display"
    if test (count $argv) -gt 0
        command fortune $argv
    else
        set -l RED (set_color red)
        set -l YELLOW (set_color yellow)
        set -l ORANGE (set_color ff8c00)
        set -l DARK_ORANGE (set_color ff4500)
        set -l RESET (set_color normal)
        
        if not command -q cowsay || not command -q fortune
            echo -s $RED "Dependencies 'cowsay' and 'fortune' are required." $RESET
            return 1
        end
        
        # Capture multiline fortune output properly
        set -l fortune_output        
        command fortune -n 200 -ac 2>/dev/null | read -z fortune_output

        if test -z "$fortune_output"
            echo -s $RED "Error running fortune." $RESET
            return 1
        end
        
        # Extract fortune type (first line)
        set -l fortune_type (echo "$fortune_output" | head -n1 | string replace -r '^\((.*)\)$' '$1' | tr '-' ' ' | sed -E 's/\b(.)/\u\1/g')
        
        # Extract fortune text (everything after the % line)
        set -l fortune_text
        echo "$fortune_output" | sed '1,/^%$/d' | read -z fortune_text
        
        # Get random cow and format
        set -l cow (/usr/games/cowsay -l | tail -n +2 | tr ' ' '\n' | shuf -n 1)
        set -l cow_pretty (echo $cow | tr '-' ' ' | sed -E 's/\b(.)/\u\1/g')
        
        # Pass multiline text to cowsay
        set -l formatted
        echo "$fortune_text" | /usr/games/cowsay -f $cow | read -z formatted
        
        # Output
        echo -s $RED "-====================================================================-" $RESET
        echo -s $ORANGE "Today's topic: " $DARK_ORANGE $fortune_type $ORANGE " brought to you by " $DARK_ORANGE $cow_pretty $RESET
        echo -s $YELLOW $formatted $RESET
        echo -s $RED "-====================================================================-" $RESET
    end
end
