zmodload -i zsh/complist


unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol
setopt auto_menu         # show completion menu on successive tab press
setopt complete_in_word  # middle of word completion
setopt always_to_end



# case, hypthen insensitive completion
# zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' matcher-list '' \
	'r:|?=** m:{a-z\-}={A-Z\_}'


# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path ~/.localbin/zsh_comp_cache
zstyle ':completion::complete:*' cache-path ~/.local/share/misc/.zsh_comp_cache

# Don't complete uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
        clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
        gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
        ldap lp mail mailman mailnull man messagebus  mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
        operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
        usbmux uucp vcsa wwwrun xfs '_*'

# ... unless we really want to.
zstyle '*' single-ignored show

# enable menu select
zstyle ':completion:*' menu select
zmodload zsh/complist

# Ignore certail extensions
# zstyle ':completion:*:-command-:*' ignored-patterns '(#i)*.exe' '(#i)*.dll'
zstyle ':completion:*:-command-:*' ignored-patterns '(#i)*.dll'

# navigate dirs without cd
setopt auto_cd

# match files without explicitly specifying the dot
setopt GLOBDOTS

# custom comp defs
compdef _git ga=git-add
compdef _git gac=git-add
compdef _git gacp=git-add
compdef _git gb=git-branch
compdef _git ggo=git-checkout
compdef _git gf=git-fetch
compdef _git gl=git-log
compdef _git gm=git-merge
compdef _git gpl=git-pull
compdef _git gp=git-push
compdef _git gr=git-rebase
compdef _git gre greh=git-reset
compdef _git grm=git-rm
