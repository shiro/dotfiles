dmm-branch-up () {
  if [ $# -eq 1 ]; then
    branchctl server-replace create $1 --frontend $@
  else
    local branchname
    branchname=$(git branch --show-current) 
    branchctl server-replace create $branchname --frontend $branchname $@
  fi
}

compareRebase () {
  local newbranch oldbranch newcommit oldcommit ancestor
  local opts=()
  if [ "$1" = "-w" ]
  then
    opts+=("-w")
    shift
  fi
  newbranch=${1:-$(git rev-parse --abbrev-ref HEAD)}
  oldbranch=${2:-"${newbranch}@{u}"}
  ancestor=${3:-origin/master}
  oldancestor=${4:-"$ancestor"}
  oldcommit=$(git commit-tree -p "$(git merge-base "${oldancestor}" "${oldbranch}")" "${oldbranch}^{tree}" -m "before rebase")
  newcommit=$(git commit-tree -p "$(git merge-base "${ancestor}" "${newbranch}")" "${newbranch}^{tree}" -m "after rebase")
  git range-diff "${opts[@]}" "${oldcommit}^..${oldcommit}" "${newcommit}^..${newcommit}"
}
