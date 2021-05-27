#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
PHROOT=$(dirname $(dirname $DIR))
DEST=(
  ${PHROOT}/modules
  ${PHROOT}/charts
)
DRYRUN=false

function print_usage() {
  echo "Replace image in files"
  echo ""
  echo "Usage: "
  echo "  `basename $0` <images.txt> [<dest> <dest2> ..]"
  echo ""
  echo "Options: "
  echo "  -h  print this help"
  echo "  -d  dry run mode"
}

while getopts "dh" OPT; do
  case $OPT in
    h)
      print_usage
      exit      
      ;;
    d)
      DRYRUN=true
      ;;
  esac
done
shift $(expr $OPTIND - 1 )
  
# Input file  
if [[ $# -eq 0 ]]; then
  print_usage
  exit
fi
IMAGES=$1
if [[ ! -f $IMAGES ]]; then
  echo "$IMAGES not found or not a regular file"
  exit
fi
shift

# Destination directory
if [[ $# -gt 0 ]]; then
  DEST=($@)
fi
for d in ${DEST[@]}; do
  if [[ ! -d $d ]]; then
    echo "$d not found or not a directory"
    exit -1
  fi
done

function replace_file {
  local file=$1
  local i=$2

  if $DRYRUN; then
    echo "  dryrun $file"
  else
    echo "  replace $file"
    perl -p -i -e "s{(?<!primehub\.airgap:5000\/)\Q$i\E}{primehub.airgap:5000/$i}g" $file
  fi
}

# unit test
function test_replace_file {
  local image="registry.gitlab.com/infuseai/keycloak-theme:theme-only"
  local file=/tmp/test-replace
  echo "image: $image" > $file
  replace_file $file $image
  local result=$(cat $file)
  local expect="image: primehub.airgap:5000/$image"

  if [[ $result = $expect ]]; then
    echo "pass"
  else
    echo "failed"
  fi
  rm $file
}

for i in $(cat $IMAGES); do
  echo "Searching '$i'";
  for f in $(grep -R -l --exclude=\*.example --exclude=\*.txt $i ${DEST[@]}); do
    replace_file $f $i
  done
done



