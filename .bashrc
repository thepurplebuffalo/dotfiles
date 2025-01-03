PATH=$PATH:/usr/local/sbin
# fix color LS on the Mac:
export CLICOLOR=1

# change the directory color in LS to bold blue.  See "man ls" for details:
export LSCOLORS="Exfxcxdxbxegedabagacad"
export BC_ENV_ARGS=~/.bcrc

# prepend the history with the ISO date and time that the command was used:
HISTTIMEFORMAT="%F_%T "
# make the history very large:
HISTSIZE=
HISTFILESIZE=
# Don't log multiple duplicate entries:
HISTCONTROL="ignorespace:ignoredups"
# don't record the "history" command to the history.  Also, nothing starting
# with whitespace:
HISTIGNORE="history*"
# Sync the history to disk after each command (useful when multiple shells
# are open at the same time):
PROMPT_COMMAND='history -a'
export EDITOR=vi
export TERM=xterm-256color
LS_COLORS=$LS_COLORS:'di=0;35:' ; export LS_COLORS
#color()(set -o pipefail;"$@" 2>&1>&3|sed $'s,.*,\e[31m&\e[m,'>&2)3>&1

# Color chart: https://en.wikipedia.org/wiki/ANSI_escape_code#Colors

# Make the prompt pretty:
#PS1='$(checkuser $?)@\e[0;35m\h\e[m:\e[1;34m\w\e[m[$(checkretval $?)] \e[1;33mDays: \e[1;36m$(days-to-event) $(check-branch) \e[m\n\$ '
PS1='$(checkuser $?)@\e[0;35m\h\e[m:\e[1;34m\w\e[m[$(checkretval $?)] $(check-branch) \e[m\n\$ '

alias mtr='mtr -o "LSDR NABWV"'
alias wget='wget --content-disposition'
alias rot13="tr '[A-Za-z]' '[N-ZA-Mn-za-m]'"
alias digs='dig +short'
alias ggv='git grep -Ovim'
alias sortip='sort -n -t . -k 1,1n -k 2,2n -k 3,3n -k4,4n'

if [[ ${OSTYPE} == "darwin"* ]] ; then
  # We're on a mac.
  # fix bash tab completion:
  source ~/dot-files/_ssh.sh
elif [[ ${OSTYPE} == "openbsd"* ]] ; then
  alias vi=vim
else
  # We're not on a Mac.  ls should work.
  alias ls='ls --color=auto'
  alias du='du -x -m -c --max-depth=1'
fi

function checkdns() {
  for i in $(cat ~/etc/dns_servers.txt ~/etc/ext_dns_servers.txt)
  do
    echo "== $i =="
    dig @"$i" "$@"
  done
}

function checkretval() {
  # This function checks the return value of the last shell command.
  # It adjusts the color green==good==0 or red otherwise.
  if [ ${1} -eq 0 ]
  then
    echo -en "\033[0;32m${1}\033[m"
  else
    echo -en "\033[1;31m${1}\033[m"
  fi
}

function checkuser() {
  # Print username in yellow if non-root, or red if root.
  if [ ${USER} == "root" ]
  then
    echo -en "\033[1;31m${USER}\033[m"
  else
    echo -en "\033[1;33m${USER}\033[m"
  fi
  # we must exit with the same return value we were passed to preserve "$?"
  exit $1
}

function days-to-event() {
  eventdate="2020-05-15"
  if [[ ${OSTYPE} != "darwin"* ]] ; then
    echo -en "$(( ( $(date -d ${eventdate} '+%s') - $(date '+%s') ) / 86400 ))"
  else
    echo -en "$(( ( $(date -j -f '%Y-%m-%d' ${eventdate} '+%s') - $(date '+%s') ) / 86400 ))"
  fi
  # we must exit with the same return value we were passed to preserve "$?"
  exit $1
}

function check-branch() {
  if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" == "true" ]
  then
    BRANCH=$(git branch -v | grep '^*' | awk '{print $2}')
    if [ ${BRANCH} == "master" ]
    then
      echo -en "\033[m[\033[92;41m ${BRANCH} \033[m]"
    else
      echo -en "\033[m[\033[92;44m${BRANCH}\033[m]"
    fi
  fi
  # we must exit with the same return value we were passed to preserve "$?"
  exit $1
}

function STAMP() {
  echo -n "$(date +%FT%T%z)"
}
# Export the STAMP function so that we can use it in other scripts:
export -f STAMP

# if there is a local bashrc, include it:
[ -r ~/dot-files-local/bashrc ] && source ~/dot-files-local/bashrc

#[ -z "$TMUX"  ] && { tmux attach || exec tmux new-session && exit;}
if [[ -n "$PS1" ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_CONNECTION" ]]; then
    exec tmux -u new-session -A -s ssh_tmux
fi
