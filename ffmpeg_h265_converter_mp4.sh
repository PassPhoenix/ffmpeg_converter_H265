#! /usr/bin/bash

input_format="mp4"
datasaved=0
SECONDS=0
number_files_converted=0

for file in *."$input_format"; do

  base_name=$(basename "$file" .$input_format)
  output_file="${base_name}_cc.${input_format}"
  
  if [[ $base_name == *"_cc"* ]]; then
    continue
  fi

  size_vid=$(stat --format "%s" "$file")
  echo "Converting file: $file"
  ffmpeg -hide_banner -loglevel error -i "$file" -c:v libx265 -x265-params log-level=none -crf 28 -c:a copy "$output_file" 
  size_vid_after=$(stat --format "%s" "$output_file") 

  echo -n "Converted $file ("
  echo -n "$size_vid"| numfmt --to iec 
  echo -n ") to $output_file ("
  echo -n "$size_vid_after" | numfmt --to iec 
  echo -n ") Reduced by -"
  echo -n $((size_vid - size_vid_after)) | numfmt --to iec
  echo "."
  ((datasaved+= size_vid - size_vid_after))
  echo -n "Size saved so far: "
  echo $datasaved | numfmt --to iec
  
  printf "\n"

  rm "$file"
  number_files_converted++
done

echo -n "Total saved is "
echo $datasaved | numfmt --to iec
duration=$SECONDS
echo "$((duration / 60)) minutes and $((duration % 60)) seconds elapsed for $number_files_converted files converted."
