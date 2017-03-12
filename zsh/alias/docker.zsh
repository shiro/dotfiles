alias dockrun='winpty docker run -it'
alias dockrund='docker run -d'
alias dockstop='docker stop $(docker ps -a -q)'
alias dockrma='docker stop $(docker ps -aq) > /dev/null; docker rm $(docker ps -aq)'
alias dockrm='docker rm $(docker ps -qa --no-trunc --filter "status=exited")'
alias dockrmi='docker rmi $(docker images --filter "dangling=true" -q --no-trunc)'
alias dockat='t	docker attach'

alias dockc='docker-compose'
alias dockce='t docker-compose exec'
alias dockcup='winpty docker-compose up'
alias dockcupd='docker-compose up -d'
alias dockcb='docker-compose build'
alias dockcg='docker-compose start'
alias dockcs='docker-compose stop'
alias dockcp='docker-compose pause'
alias dockck='docker-compose kill'
alias dockce='winpty docker-compose exec'
