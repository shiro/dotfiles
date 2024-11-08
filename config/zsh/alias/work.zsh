dmm-branch-up () {
  if [ $# -eq 1 ]; then
    branchctl server-replace create $1 --frontend $@
  else
    local branchname
    branchname=$(git branch --show-current) 
    branchctl server-replace create $branchname --frontend $branchname $@
  fi
}
