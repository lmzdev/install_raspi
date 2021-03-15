# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize


# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi


# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
COL_PRIM=`tput setaf 4`
COL_SEC=`tput setaf 10` #6
COL_DARK=`tput setaf 25` #0
COL_UL=`tput sgr 0 1`
COL_BOLD=`tput bold`
NC=`tput sgr0`

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# splash raspberry pi logo on login
ctemp=$(vcgencmd measure_temp)
linuxlogo -F "$(whoami)@#H\n$(lsb_release -ds)\n#U\nCPU Temp: ${ctemp:5}"
echo " "$(date +"%d.%m.%y - %H:%M ")" " |  toilet -f term --filter border
unset ctemp


# Prompt Settings
function set_bash_prompt () {
  PROMPT_SYM="$COL_PRIM❯$NC "

  # Set the PYTHON_VIRTUALENV variable.
  if test -z "$VIRTUAL_ENV" ; then
      PYTHON_VIRTUALENV=''
  else
      PYTHON_VIRTUALENV="$COL_DARK[`basename \"$VIRTUAL_ENV\"`]$NC "
  fi

  # Set the BRANCH variable.
  BRANCH=$(git symbolic-ref --short HEAD 2> /dev/null)
  if [ $? == 0 ] ; then
    BRANCH=" $COL_BOLD$COL_SEC$BRANCH$NC "
  fi

  # Set the bash prompt variable.
  PS1='${PYTHON_VIRTUALENV}${debian_chroot:+($debian_chroot)}$COL_PRIM\w$NC${BRANCH}${PROMPT_SYM}'


  # If this is an xterm set the title to user@host:dir
  case "$TERM" in
  xterm*|rxvt*)
      PS1="\[\e]0; \u@\h: \w\a\]$PS1"
      ;;
  *)
      ;;
  esac

}

# Tell bash to execute this function just before displaying its prompt.
PROMPT_COMMAND=set_bash_prompt
