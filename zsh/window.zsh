# Xterm control sequences, https://www.x.org/docs/xterm/ctlseqs.pdf
xtermChangeWindowTitle="\e]2;"
xtermBell="\a"

truncatedWorkingDirectory="%55<...<%~"

# TODO: understand what these are doing ========================================
# escape '%' chars in $1, make nonprintables visible
a=${(V)1//\%/\%\%}

# Truncate command, and join lines.
a=$(print -Pn "%40>...>$a" | tr -d "\n")
# ==============================================================================


# Set the window title nicely no matter where you are
case $TERM in
    screen)
        setTitle() {
            # TODO: understand what this is doing
            print -Pn "\ek$a:$3\e\\" # screen title (in ^A")
        }
        ;;
    xterm*|rxvt)
        setTitle() {
            print -Pn "$xtermChangeWindowTitle$truncatedWorkingDirectory$xtermBell"
        }
        ;;
esac
