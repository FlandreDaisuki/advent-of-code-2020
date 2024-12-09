#!/usr/bin/env bash

set -e

FILE_INPUT='day04.txt'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# ABC    ADGJ
# DEF => BEHK
# GHI    CFIL
# JKL
transpose() {
  # shellcheck disable=SC2001
  sed 's/\(.\)/\1 /g' <<<"${1}" |
    awk '
    {
      for(f = 1; f <= NF; f++) {
        matrix[f, NR] = $f
        width = NF
      }
      height += 1
    }
    END {
      for(r = 1; r <= width; r++) {
        for(c = 1; c <= height; c++) {
          printf("%s", matrix[r, c])
        }
        print ""
      }
    }'
}

# ABC    A
# DEF => DB
# GHI    GEC
# JKL    JHF
#         KI
#          L
skew() {
  # shellcheck disable=SC2001
  sed 's/\(.\)/\1 /g' <<<"${1}" |
    awk '
    {
      for(f = 1; f <= NF; f++) {
        matrix[NR, f] = $f
        width = NF
      }
      height += 1
    }
    END {
      for(r = 1; r <= (height + width - 1); r++) {
        for(c = 1; c <= width; c++) {
          if (r < width) {
            if (c <= r) { printf("%s", matrix[r + 1 - c, c]) }
            else { printf " " }
          } else if (width <= r && r <= height) {
            printf("%s", matrix[r + 1 - c, c])
          } else if (r > height) {
            if (c <= (r - height)) { printf " " }
            else { printf("%s", matrix[r + 1 - c, c]) }
          }
        }
        print ""
      }
    }'
}

MAP="$(cat "${FILE_INPUT}")"
MAP_TP="$(transpose "${MAP}")"
MAP_SK_D="$(skew "${MAP}")"
MAP_SK_U="$(skew "$(rev <<<"${MAP}")" | rev)"

# 7 8 9
# 4 x 6
# 1 2 3

DIR1="$(grep -o 'SAMX' <<<"${MAP_SK_D}" | wc -l)"
DIR2="$(grep -o 'XMAS' <<<"${MAP_TP}" | wc -l)"
DIR3="$(grep -o 'XMAS' <<<"${MAP_SK_U}" | wc -l)"
DIR4="$(grep -o 'SAMX' <<<"${MAP}" | wc -l)"
DIR6="$(grep -o 'XMAS' <<<"${MAP}" | wc -l)"
DIR7="$(grep -o 'SAMX' <<<"${MAP_SK_U}" | wc -l)"
DIR8="$(grep -o 'SAMX' <<<"${MAP_TP}" | wc -l)"
DIR9="$(grep -o 'XMAS' <<<"${MAP_SK_D}" | wc -l)"

ANSWER1="$(bc <<<"${DIR1}+${DIR2}+${DIR3}+${DIR4}+${DIR6}+${DIR7}+${DIR8}+${DIR9}")"

echo -e "answer1 ${YELLOW}${ANSWER1}${NC}"

# usage: crop3x3 x y
# x := 1..width-2; y := 1..height-2
crop3x3() {
  sed -n "${2},+2p" <<<"${3}" | awk "{print substr(\$0, ${1}, 3);}"
}

rotate90() {
  transpose "${1}" | rev
}

rotate180() {
  rotate90 "$(rotate90 "${1}")"
}

rotate270() {
  rotate90 "$(rotate180 "${1}")"
}

has_xmas() {
  if grep -q 'M.M' <<<"$(sed -n '1p' <<<"${1}")"; then
    if grep -q '.A.' <<<"$(sed -n '2p' <<<"${1}")"; then
      if grep -q 'S.S' <<<"$(sed -n '3p' <<<"${1}")"; then
        true
        return
      fi
    fi
  fi

  false
}

HEIGHT="$(wc -l <<<"${MAP}")"
WIDTH="$(head -n 1 <<<"${MAP}" | awk '{print length}')"

# ref: https://stackoverflow.com/a/29535256
parallel_task() {
  if has_xmas "${1}" || has_xmas "$(rotate90 "${1}")" || has_xmas "$(rotate180 "${1}")" || has_xmas "$(rotate270 "${1}")"; then
    exit 0
  else
    exit 1
  fi
}

PIDS=""
for H_I in $(seq 1 "$((HEIGHT - 2))"); do
  for W_I in $(seq 1 "$((WIDTH - 2))"); do
    CROPPED="$(crop3x3 "${W_I}" "${H_I}" "${MAP}")"
    parallel_task "${CROPPED}" &
    PIDS+=" $!"
  done
done

X_MAS_COUNT=0
read -r -a PID_LIST <<<"${PIDS}"
for PID in "${PID_LIST[@]}"; do
  if wait "${PID}"; then
    X_MAS_COUNT="$((X_MAS_COUNT + 1))"
  fi
done

ANSWER2="${X_MAS_COUNT}"

echo -e "answer2 ${YELLOW}${ANSWER2}${NC}"
