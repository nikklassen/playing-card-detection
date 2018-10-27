#!/bin/bash
root="$(dirname "$0" | xargs realpath)"

x_offset=479
y_offset=1400
suit_order=shcd
rank_b_order=kqjt98765432a
rank_f_order=a23456789tjqk
rank_order=$rank_f_order

landscape=3000x2250
portrait=2250x3000
frame=$landscape

usage() {
    cat <<EOF 1>&2
Usage: $(basename $0) [-x x_offset] [-y y_offset] [-o f|b] [-s suits] [-r l|p] [-n] [-h]
EOF
    exit 1
}

while getopts ":x:y:o:s:r:h" arg; do
    case "$arg" in
        x) x_offset=$OPTARG ;;
        y) y_offset=$OPTARG ;;
        o) order=$OPTARG ;;
        s) suit_order=$OPTARG ;;
        r) rot=$OPTARG ;;
        h) usage ;;
        *) ;;
    esac
done
shift $((OPTIND-1))

if [[ $order == "f" ]]; then
    rank_order=$rank_f_order
elif [[ $order == "b" ]]; then
    rank_order=$rank_b_order
fi

if [[ $rot == "l" ]]; then
    frame=$landscape
elif [[ $rot == "b" ]]; then
    frame=$portrait
fi

cd "${1?}"
mkdir -p small
rm -rf small/*
fd -d 1 -e jpg -x convert -crop $frame+$x_offset+$y_offset -resize 960x720 "{}" "small/{}" ";"

cd small
python <<EOF
import os

rank_orders = {
    'c': '$rank_order',
    'h': '$rank_order',
    's': '$rank_order',
    'd': '$rank_order',
}

renames = zip(
    os.listdir('.'),
    [rank + suit for suit in '$suit_order'
                 for rank in rank_orders[suit]]
)

for (img, card) in renames:
    os.rename(img, card + '.jpg')
EOF

rm -rf "$root/data/import"
mkdir -p "$root/data/import"
cp * "$root/data/import"
