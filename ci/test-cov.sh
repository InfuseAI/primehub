#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

stmts=$(cat $DIR/../chart/htmlcov/status.json | jq '([.files[].index.nums[1]]| add)')
stmts=$((stmts+$(cat $DIR/../chart/htmlcov/status.json | jq '([.files[].index.nums[1]]| add)')))

miss=$(cat $DIR/../chart/htmlcov/status.json | jq '([.files[].index.nums[3]]| add)')

total=$(echo {'"'s'"':$stmts, '"'m'"': $miss} | jq '100 * ( ( .s - .m ) / .s ) + 0.5 | floor ')
echo "TOTAL                         $stmts    $miss    $total%"
