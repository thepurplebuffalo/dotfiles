# This file is used on first login.
SSH_ENV="${HOME}/.ssh/environment"

function SSH_start_agent {
     echo "Initialising new SSH agent..."
     /usr/bin/ssh-agent -s | sed 's/^echo/#echo/' > "${SSH_ENV}"
     echo succeeded
     chmod 600 "${SSH_ENV}"
     . "${SSH_ENV}" > /dev/null
     /usr/bin/ssh-add
}

if [[ ${OSTYPE} == "darwin"* ]]
then
  echo "Mac detected."
  # We're on a Mac.
  # turn off mouse accelleration.  I want speed, not a lack of precision.
  defaults write -g com.apple.mouse.scaling -1
  defaults write .GlobalPreferences com.apple.scrollwheel.scaling -1
else
  # We're not on a Mac.  There's no sketchy ssh-agent running.
  # Check to see if we're already SSH'd in with agent forwarding:
  if [ -z "${SSH_AUTH_SOCK}" ] ; then
    # There's no agent, let's start one.
    # Source SSH settings, if applicable
    if [ -f "${SSH_ENV}" ]; then
      . "${SSH_ENV}" > /dev/null
      #ps ${SSH_AGENT_PID} doesn't work under cywgin
      ps -ef | grep ${SSH_AGENT_PID} | grep 'ssh-agent -s$'> /dev/null || {
        SSH_start_agent;
      }
    else
      SSH_start_agent;
    fi
  else
    echo "SSH-agent forwarding detected."
  fi
fi

[ -r ~/.bashrc ] && source ~/.bashrc

#git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
#vim +PluginInstall +qall
#vim +BundleUpdate +qall
#mkdir -p ~/.vim/autoload ~/.vim/bundle && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
