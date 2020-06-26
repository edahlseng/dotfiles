alias cls='clear' # Good 'ol Clear Screen command

alias e='edit'

alias kubectl='kubectl ${KUBECTL_NAMESPACE/[[:alnum:]-]*/--namespace=${KUBECTL_NAMESPACE}}'

alias make='gmake'

alias pr='pull-request'

alias reload!='. ~/.zshrc'

alias rm='echo "Use the \"trash\" command instead" && :'

alias task='task-wrapper'

alias terraform='terraform-wrapper'

alias ubuntu='docker run --rm --interactive --tty --volume "$(pwd)":"$(pwd)" --workdir "$(pwd)" ubuntu:latest'
