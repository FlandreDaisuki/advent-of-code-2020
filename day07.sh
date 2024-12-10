#!/usr/bin/env bash

set -e

FILE_INPUT='day07.txt'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# usage: test_line <TARGET> <REST_FILEDS[*]> <RESULT>
test_line() {
  local TARGET
  TARGET="${1}"
  local REST_FILEDS
  read -r -a REST_FILEDS <<<"${2}"
  local RESULT
  RESULT="${3}"

  REST="${REST_FILEDS[0]}"
  if [ "${#REST_FILEDS[*]}" = '1' ]; then
    [ "${TARGET}" = "$((RESULT + REST))" ] || [ "${TARGET}" = "$((RESULT * REST))" ]
    return
  fi

  if [ "${RESULT}" -gt "${TARGET}" ]; then
    false
    return
  fi

  local HOR
  HOR="${REST_FILEDS[0]}"
  test_line "${TARGET}" "${REST_FILEDS[*]:1}" "$((RESULT + HOR))" ||
    test_line "${TARGET}" "${REST_FILEDS[*]:1}" "$((RESULT * HOR))"
}

SUM_OF_EQUATION=0
while read -r LINE; do
  read -r -a TOK_LIST <<<"${LINE}"
  TARGET="${TOK_LIST[0]//:/}"
  if test_line "${TARGET}" "${TOK_LIST[*]:2}" "${TOK_LIST[1]}"; then
    SUM_OF_EQUATION="$((SUM_OF_EQUATION + TARGET))"
  fi
done <"${FILE_INPUT}"

ANSWER1="${SUM_OF_EQUATION}"

echo -e "answer1 ${YELLOW}${ANSWER1}${NC}"

ANSWER2=""

echo -e "answer2 ${YELLOW}${ANSWER2}${NC}"
