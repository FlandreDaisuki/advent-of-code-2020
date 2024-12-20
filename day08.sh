#!/usr/bin/env bash

set -e

FILE_INPUT='day08.txt'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# usage: find_antinodes <PA> <PB>
# P{A,B,J,K} := `X,Y`
# PJ--PA--PB--PK
# return:
#   PJ PK
find_antinodes() {
  local PA
  PA="${1}"
  local PB
  PB="${2}"
  PAX="$(cut -d ',' -f 1 <<<"${PA}")"
  PAY="$(cut -d ',' -f 2 <<<"${PA}")"
  PBX="$(cut -d ',' -f 1 <<<"${PB}")"
  PBY="$(cut -d ',' -f 2 <<<"${PB}")"

  # VAB = PB - PA
  VABX="$((PBX - PAX))"
  VABY="$((PBY - PAY))"

  PJ="$((PAX - VABX)),$((PAY - VABY))"
  PK="$((PBX + VABX)),$((PBY + VABY))"
  echo "${PJ} ${PK}"
}

# usage: find_antinodes <MAP>
# <MAP> coord := left top (1, 1)
# return:
#   <S1>|P1 <S1>|P2 <S2>|P1 <S1>|P3 ....
collect_same_freq_antennas() {
  awk -F '' '{
    for(i = 1; i <= NF; i++) {
      if($i != ".") {
        printf("%s|%s,%s ", $i, i, NR)
      }
    }
  }' <<<"${1}"
}

MAP="$(cat "${FILE_INPUT}")"
HEIGHT="$(wc -l <<<"${MAP}")"
WIDTH="$(head -n 1 <<<"${MAP}" | awk '{print length}')"
read -r -a ANTENNA_LIST <<<"$(collect_same_freq_antennas "${MAP}")"
read -r -a ANTENNA_FREQ_LIST <<<"$(grep -E -o '.\|' <<<"${ANTENNA_LIST[*]}" | sort -u | sed 's/|//g' | tr '\n' ' ')"

ANTINODES=''
for AF in "${ANTENNA_FREQ_LIST[@]}"; do
  read -r -a SAME_AF_ANTENNA_LIST <<<"$(grep -E -o "${AF}\|[0-9,]+" <<<"${ANTENNA_LIST[*]}" | sed 's/.|//g' | tr '\n' ' ')"
  for IDX_I in $(seq 1 "${#SAME_AF_ANTENNA_LIST[*]}"); do
    for IDX_J in $(seq "${IDX_I}" "${#SAME_AF_ANTENNA_LIST[*]}"); do
      if [ "${IDX_I}" != "${IDX_J}" ]; then

        PA="${SAME_AF_ANTENNA_LIST[$((IDX_I - 1))]}"
        PB="${SAME_AF_ANTENNA_LIST[$((IDX_J - 1))]}"
        ANTINODES+=" $(find_antinodes "${PA}" "${PB}")"
      fi
    done
  done
done

VALID_ANTINODES="$(
  awk -v height="${HEIGHT}" -v width="${WIDTH}" '{
    for(i = 1; i <= NF; i++) {
      split($i, p, ",")
      x=p[1]
      y=p[2]
      if(x >= 1 && x <= width && y >= 1 && y <= height) {
        print $i
      }
    }
  }' <<<"${ANTINODES}" | sort -u
)"

ANSWER1="$(wc -l <<<"${VALID_ANTINODES}")"

echo -e "answer1 ${YELLOW}${ANSWER1}${NC}"

# usage: find_expand_antinodes <PA> <PB>
# P{A,B,J,K} := `X,Y`
# PJ<--PA--PB-->PK
# return:
#   PJ PK
find_expand_antinodes() {
  local PA
  PA="${1}"
  local PB
  PB="${2}"
  PAX="$(cut -d ',' -f 1 <<<"${PA}")"
  PAY="$(cut -d ',' -f 2 <<<"${PA}")"
  PBX="$(cut -d ',' -f 1 <<<"${PB}")"
  PBY="$(cut -d ',' -f 2 <<<"${PB}")"

  # VAB = PB - PA
  VABX="$((PBX - PAX))"
  VABY="$((PBY - PAY))"

  local COLLECTION
  COLLECTION=''

  # collect BAJ direction
  local T
  T=0
  local PJX
  PJX="$((PAX - VABX * T))"
  local PJY
  PJY="$((PAY - VABY * T))"
  while [ "${PJX}" -ge 1 ] && [ "${PJX}" -le "${WIDTH}" ] && [ "${PJY}" -ge 1 ] && [ "${PJY}" -le "${HEIGHT}" ]; do
    COLLECTION+=" ${PJX},${PJY}"
    T="$((T + 1))"
    PJX="$((PAX - VABX * T))"
    PJY="$((PAY - VABY * T))"
  done

  # collect ABK direction
  T=0
  local PKX
  PKX="$((PBX + VABX * T))"
  local PKY
  PKY="$((PBY + VABY * T))"
  while [ "${PKX}" -ge 1 ] && [ "${PKX}" -le "${WIDTH}" ] && [ "${PKY}" -ge 1 ] && [ "${PKY}" -le "${HEIGHT}" ]; do
    COLLECTION+=" ${PKX},${PKY}"
    T="$((T + 1))"
    PKX="$((PBX + VABX * T))"
    PKY="$((PBY + VABY * T))"
  done

  echo "${COLLECTION}"
}

EXPAND_ANTINODES=''
for AF in "${ANTENNA_FREQ_LIST[@]}"; do
  read -r -a SAME_AF_ANTENNA_LIST <<<"$(grep -E -o "${AF}\|[0-9,]+" <<<"${ANTENNA_LIST[*]}" | sed 's/.|//g' | tr '\n' ' ')"
  for IDX_I in $(seq 1 "${#SAME_AF_ANTENNA_LIST[*]}"); do
    for IDX_J in $(seq "${IDX_I}" "${#SAME_AF_ANTENNA_LIST[*]}"); do
      if [ "${IDX_I}" != "${IDX_J}" ]; then

        PA="${SAME_AF_ANTENNA_LIST[$((IDX_I - 1))]}"
        PB="${SAME_AF_ANTENNA_LIST[$((IDX_J - 1))]}"
        EXPAND_ANTINODES+=" $(find_expand_antinodes "${PA}" "${PB}")"
      fi
    done
  done
done

VALID_EXPAND_ANTINODES="$(
  awk '{
    for(i = 1; i <= NF; i++) {
      print $i
    }
  }' <<<"${EXPAND_ANTINODES}" | sort -u
)"

ANSWER2="$(wc -l <<<"${VALID_EXPAND_ANTINODES}")"

echo -e "answer2 ${YELLOW}${ANSWER2}${NC}"
