#!/usr/bin/env bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
PHROOT=$(dirname $(dirname $DIR))

IMAGE_SEARCH=()

OUTPUT_IMG=true
OUTPUT_TXT=true
GROUP=

print_usage() {
  echo "Build the image tarball"
  echo ""
  echo "Usage: "
  echo "  `basename $0` [<options>] <group>"
  echo ""
  echo "Options: "
  echo "  -h  --help          print this help"
  echo "      --list-groups   list group"
  echo "      --list-images   list images"
  echo "  -o                  output to a specific file basename (e.g. primehub-images-ee-v1.0.0)"
  echo "  -f                  read from a specific yaml file (e.g. ./my-images.yaml)"
  echo ""
  echo "Examples: "
  echo "  # list groups"
  echo "  `basename $0` -f my-images.yaml --list-groups"
  echo ""
  echo "  # list images for one group"
  echo "  `basename $0` -f my-images.yaml --list-images primehub-ee"
  echo ""
  echo "  # build images for one group"
  echo "  `basename $0` -f my-images.yaml primehub-ee"
  echo ""
  echo "  # build images to a output prefix"
  echo "  `basename $0` -f my-images.yaml -o primehub-images-ee-v1.0.0 primehub-ee"
  echo ""
  echo "  # build images with a specific yaml file"
  echo "  `basename $0` -f my-images.yaml --list-groups"
  echo ""
}

list_groups() {
  local -a groups=()
  local yq_version=$(yq -V| awk '{print $3}')

  for file in ${IMAGE_SEARCH[@]}; do
    if [[ ! -f $file ]]; then
      echo "$file not found"
      exit -1
    fi

    if [[ "$yq_version" =~ ^4\.[0-9]+\.[0-9]+$ ]]; then
      # For yq@4
      for group in $(yq e "${file}" -j | jq -r '. | keys[]'); do
        groups+=("$group")
      done
    else
      # For yq@2 or yq@3
      for group in $(yq r "${file}" -j | jq -r '. | keys[]'); do
        groups+=("$group")
      done
    fi
  done
  echo "${groups[@]}" | xargs -n1 | sort -u
}

output_name() {
  local git_head=$(git rev-parse HEAD | cut -c 1-8)
  local timestamp=$(date +%Y%m%d-%H%M)
  echo "primehub-images-${GROUP}-${timestamp}-${git_head}"
}

function main() {
  local -a positional
  local opt_list_groups
  local opt_list_images
  local opt_infile
  local opt_outfile

  # Parse the options
  while [[ $# -gt 0 ]]
  do
  key="$1"
  case "$key" in
      -o|--output)
        opt_outfile="$2"
        shift; shift
        ;;
      -h|--help)
        print_usage
        exit 0
        ;;
      --list-groups)
        opt_list_groups="true"
        shift;
        ;;
      --list-images)
        opt_list_images="true"
        shift;
        ;;
      -f|--file)
        opt_infile="$2"
        shift; shift
        ;;
      *)    # unknown option
        positional+=("$1") # save it in an array for later
        shift # past argument
        ;;
  esac
  done
  if [[ ${#positional} -gt 0 ]]; then
    set -- "${positional[@]}" # restore positional parameters
  fi

  # prerequisites
  if ! command -v jq > /dev/null; then
    echo "Require jq to run this script"
    exit 1
  fi

  if ! command -v yq > /dev/null; then
    echo "Require yq to run this script"
    exit 1
  fi

  # Images yaml from specific file
  if [[ -n ${opt_infile} ]]; then
    IMAGE_SEARCH=( "${opt_infile}" )
  else
    echo "Error: No file specified"
    print_usage
    exit 1
  fi

  # List group
  if [[ $opt_list_groups == "true" ]]; then
    list_groups
    exit
  fi

  # Positional argument
  if [[ $# -ne 1 ]]; then
    echo "Error: No group specified"
    print_usage
    exit 1
  fi
  GROUP=$1


  if [[ -n "${opt_outfile}" ]]; then
    OUTPUT="${opt_outfile}"
  else
    OUTPUT=$(output_name)
  fi

  # Iterate all files
  IMAGES=()
  for file in ${IMAGE_SEARCH[@]}; do
    if [[ ! -f $file ]]; then
      echo "$file not found"
      exit -1
    fi

    for image in $(yq r "${file}" -j | jq -r ".[\"${GROUP}\"] // {} | to_entries | .[].value"); do

      IMAGES+=("$image")

    done
  done

  if [[ ${#IMAGES[@]} -eq 0 ]]; then
    echo "No image found"
    exit
  fi

  if [[ $opt_list_images == "true" ]]; then
    echo "${IMAGES[@]}" | xargs -n1 | sort -u
    exit
  fi

  # sort and unique
  IMAGES=($(echo ${IMAGES[@]} | xargs -n1 | sort -u))

  # Pulling image
  echo "pulling image.."
  echo ${IMAGES[@]} | xargs -n1 -P3 docker pull

  # Output
  echo
  echo "saving image..."
  for i in ${IMAGES[@]}; do
    size=$(docker images $i --format={{.Size}})
    echo "  $i ($size)"
  done
  docker save ${IMAGES[@]} | gzip -c > $OUTPUT.tgz

  for image in ${IMAGES[@]}; do
    echo $image >> $OUTPUT.txt
  done

  # Complete
  echo
  echo "complete"
  echo "   tarball: ${OUTPUT}.tgz"
  echo "   txt:     ${OUTPUT}.txt"
  echo
}

main "$@"


