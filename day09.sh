#!/usr/bin/env bash

set -e

FILE_INPUT='day09.txt'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

FILE_ID=0
IS_SPACE='no'
DISK_SEQ_STATE=()
while read -r CHAR; do
  if [ "${IS_SPACE}" = 'yes' ]; then
    DISK_SEQ_STATE+=("x,${CHAR}")
  else
    DISK_SEQ_STATE+=("${FILE_ID},${CHAR}")
    FILE_ID=$((FILE_ID + 1))
  fi

  if [ "${IS_SPACE}" = 'yes' ]; then
    IS_SPACE='no'
  else
    IS_SPACE='yes'
  fi
done <<<"$(grep -o . ${FILE_INPUT})"

SUM=0
OFFSET=0
INDEX=0
LEN="${#DISK_SEQ_STATE[*]}"
R_INDEX="$((LEN - 1))"

while [ "${INDEX}" -le "${R_INDEX}" ]; do
  C_FID="${DISK_SEQ_STATE["${INDEX}"]%,*}"
  C_COUNT="${DISK_SEQ_STATE["${INDEX}"]#*,}"
  R_FID="${DISK_SEQ_STATE["${R_INDEX}"]%,*}"
  R_COUNT="${DISK_SEQ_STATE["${R_INDEX}"]#*,}"

  if [ "${C_FID}" != 'x' ]; then
    SUM="$((SUM + OFFSET * C_FID))"
  else
    SUM="$((SUM + OFFSET * R_FID))"
    R_COUNT="$((R_COUNT - 1))"
    DISK_SEQ_STATE["${R_INDEX}"]="${R_FID},${R_COUNT}"
  fi

  C_COUNT="$((C_COUNT - 1))"
  DISK_SEQ_STATE["${INDEX}"]="${C_FID},${C_COUNT}"

  while grep -q ',0$' <<<"${DISK_SEQ_STATE["${INDEX}"]}"; do
    INDEX="$((INDEX + 1))"
  done

  while grep -q ',0$' <<<"${DISK_SEQ_STATE["${R_INDEX}"]}"; do
    R_INDEX="$((R_INDEX - 2))"
  done

  OFFSET="$((OFFSET + 1))"
done

ANSWER1="${SUM}"

echo -e "answer1 ${YELLOW}${ANSWER1}${NC}"

ANSWER2=""

echo -e "answer2 ${YELLOW}${ANSWER2}${NC}"
