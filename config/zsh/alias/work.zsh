dmm-branch-up () {
  if [ $1 ]
  then
    branchctl server-replace create $1 --frontend $1
  else
    local branchname
    branchname=$(git branch --show-current) 
    branchctl server-replace create $branchname --frontend $branchname
  fi
}
