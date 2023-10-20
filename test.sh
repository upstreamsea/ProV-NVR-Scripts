#!/bin/bash

CHOICE=$(whiptail --menu "Choose an option" 18 100 10 \
  "Tiny" "A description for the tiny option." \
  "Small" "A description for the small option." \
  "Medium" "A description for the medium option." \
  "Large" "A description for the large option." \
  "Huge" "A description for the huge option." 3>&1 1>&2 2>&3)

if [ -z "$CHOICE" ]; then
  echo "No option was chosen (user hit Cancel)"
else
  echo "The user chose $CHOICE"
fi