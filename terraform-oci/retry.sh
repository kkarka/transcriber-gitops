#!/bin/bash

# Loop infinitely
while true; do
  echo "Attempting to provision node pool at $(date)..."
  
  # Run terraform apply automatically approving the prompt
  terraform apply -auto-approve
  
  # Check if the command was successful (Exit code 0)
  if [ $? -eq 0 ]; then
    echo "SUCCESS! Oracle finally gave you the server."
    break
  else
    echo "Data center still full. Waiting 60 seconds before retrying..."
    sleep 60
  fi
done