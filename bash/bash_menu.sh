#!/usr/bin/env bash


source ../exports/_bash

options=()
for i in "${!function_names[@]}"; do
  options+=("$i" "${function_names[$i]}")
done

choice=$(dialog --menu "Pick one" 15 40 5 "${options[@]}" 3>&1 1>&2 2>&3)

clear
eval ${function_names[$choice]}


