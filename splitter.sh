#!/bin/bash

function usage {
  echo "usage:"
  echo "  1st argument - file location"
  echo "  2nd argument - number of the lines per split file except headers (must be greater than 0)"
  echo "  3rd argument - number of header lines from the input file (must be greater than or equal to 0)"
}

# check arguments
file=$1
number_of_lines_per_file=$2
number_of_header_lines=$3
number_regex="^[0-9]+$"
if ! [[ $# -eq 3 && $number_of_lines_per_file =~ $number_regex && $number_of_lines_per_file -gt 0 && $number_of_header_lines =~ $number_regex ]]
  then
    usage
    exit 1
fi

# extract file name and extension
file_name=$(basename -- ${file})
file_extension=${file_name##*.}
file_name=${file_name%.*}

# split file
tail -n '+'$((${number_of_header_lines}+1)) ${file} | split -l ${number_of_lines_per_file}

# move header lines to each of split files if applicable and rename split files
i=1
mkdir -p .split
for split_file in `ls x* | sort`
  do
    if [ ${number_of_header_lines} -gt 0 ]
      then
        head -n ${number_of_header_lines} ${file} > tmp_file
    	cat ${split_file} >> tmp_file
    	rm ${split_file}
    	split_file=tmp_file
    fi
  mv -f ${split_file} .split/${file_name}'_'${i}.${file_extension}
  i=$(($i+1))
done
