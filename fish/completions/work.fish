# Complete `work` with zoxide's known directories (by basename).
complete -c work -f -a "(zoxide query -l 2>/dev/null | xargs -n1 basename 2>/dev/null | sort -u)"