########################################
# Bash Prompt Escape Sequence Reference
# (the below is just an example)
########################################

# \[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n\$

# # The first part sets the xterm title (usually shows in the titlebar of the window).

# \[        -Starts a sequence of escapes.
# \e]0;     -Starts the xterm title prompt expression.
# \w        -Display the current working directory.
# \a        -Equal to \007 (system bell).  In this case used to end the xterm title prompt.
# \]        -End escape sequence.

# # The second part sets the actual PS1 prompt

# \n        -Start with a newline.
# \[        -Start another sequence of escapes.
# \e[32m    -Sets the color to green.
# \]        -End escape sequence.

# \u@\h     -User at host name.  This and the \w below are the visible parts of the prompt.

# \[        -Begin another escape sequence.
# \e[33m    -Set color to red.
# \]        -End escape sequence.

# \w        -Display working directory in prompt.

# \[        -Begin another sequence.
# \e[0m     -Reset escape formatting to default.
# \]        -End sequence.

# \n        -Another newline.
# \$        -The final command line prompt character.

########################################
# For more information on prompt escape sequences, see:
# https://tldp.org/HOWTO/Bash-Prompt-HOWTO/bash-prompt-escape-sequences.html
# https://wiki.archlinux.org/title/Bash/Prompt_customization
########################################
