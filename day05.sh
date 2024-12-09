#!/usr/bin/env bash

set -e

FILE_INPUT='day05.txt'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# pages number are in 10 ~ 99
# do not need consider substring

SEP_LINE="$(awk '! NF { print NR; exit }' "${FILE_INPUT}")"
PAGE_RULE_LINES="$(head -n "$((SEP_LINE - 1))" <"${FILE_INPUT}")"
PAGE_SEQ_LINES="$(tail -n +"$((SEP_LINE + 1))" <"${FILE_INPUT}")"

# usage: is_valid_rule_in_page_seq <PAGE_RULE_LINE> <PAGE_SEQ_LINE>
is_valid_rule_in_page_seq() {
  PRL="$(cut -d '|' -f 1 <<<"${1}")" # page rule left
  PRR="$(cut -d '|' -f 2 <<<"${1}")" # page rule right

  if ! grep -q "${PRL}" <<<"${2}" || ! grep -q "${PRR}" <<<"${2}"; then
    true
    return
  fi

  if grep -q "${PRL}.*${PRR}" <<<"${2}"; then
    true
  else
    false
  fi
}

# usage: get_mid_page_seq <PAGE_SEQ_LINE>
get_mid_page_seq() {
  awk -F ',' '{
    mid=(NF + 1) / 2
    print $mid
  }' <<<"${1}"
}

parallel_task() {
  while read -r PAGE_RULE_LINE; do
    if ! is_valid_rule_in_page_seq "${PAGE_RULE_LINE}" "${1}"; then
      exit 0
    fi
  done <<<"${PAGE_RULE_LINES}"

  # exit code can only be 0 ~ 255
  # input (10 ~ 99) can be in range
  exit "$(get_mid_page_seq "${1}")"
}

PIDS=''
while read -r PAGE_SEQ_LINE; do
  parallel_task "${PAGE_SEQ_LINE}" &
  PIDS+=" $!"
done <<<"${PAGE_SEQ_LINES}"

SUM_OF_MID=0
read -r -a PID_LIST <<<"${PIDS}"
for PID in "${PID_LIST[@]}"; do
  RET=0
  wait "${PID}" || RET="$?"
  SUM_OF_MID="$((SUM_OF_MID + RET))"
done

ANSWER1="${SUM_OF_MID}"

echo -e "answer1 ${YELLOW}${ANSWER1}${NC}"

ANSWER2=""

echo -e "answer2 ${YELLOW}${ANSWER2}${NC}"
