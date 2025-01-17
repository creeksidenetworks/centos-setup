#!/bin/bash

DEFAULT_GROUP=""

# Loop through each directory in /home
for dir in /home/*; 
do
  # Check if it is a directory
  if [ -d "$dir" ]; then
    # Extract the username from the directory name
    USER=$(basename "$dir")

    #if id "$USER" &>/dev/null; then
    #  read -p "Do you want to proceed with user $USER? (y/n) " -n 1 -r
    #  echo    # move to a new line
    #  if [[ $REPLY =~ ^[Yy]$ ]]; then
    #    echo "  .. Proceeding with user $USER"
    #  else
    #    echo "  .. Skipping user $USER"
    #    continue
    #  fi
    #fi

    # Check if the user exists
    if id "$USER" &>/dev/null; then
      # Define the .ssh directory path
      SSH_DIR="$dir/.ssh"
      
      # Check if the .ssh directory exists
      if [ ! -d "$SSH_DIR" ]; then
        # Create the .ssh directory
        mkdir "$SSH_DIR"
        
        # Set the correct permissions
        chmod 700 "$SSH_DIR"
        
        # Set the correct ownership
        chown "$USER:$DEFAULT_GROUP" "$SSH_DIR"
        
        # Print a message indicating the directory was created
        echo "Created $SSH_DIR for user $USER"
      else
        # Print a message indicating the directory already exists
        echo "$SSH_DIR already exists for user $USER"
      fi

      # Generate an ECDSA SSH key pair if it doesn't exist
      if [ ! -f "$SSH_DIR/id_ecdsa" ]; then
        ssh-keygen -t ecdsa -f "$SSH_DIR/id_ecdsa" -N "" -C "$USER@$(hostname)"
        
        # Set the correct ownership for the key files
        chown "$USER:$DEFAULT_GROUP" "$SSH_DIR/id_ecdsa" "$SSH_DIR/id_ecdsa.pub"
        
        # Print a message indicating the key pair was generated
        echo "Generated ECDSA SSH key pair for user $USER"
      else
        # Print a message indicating the key pair already exists
        # Set the correct ownership for the key files
        chown "$USER:$DEFAULT_GROUP" "$SSH_DIR/id_ecdsa" "$SSH_DIR/id_ecdsa.pub"
        echo "ECDSA SSH key pair already exists for user $USER"
      fi

      # Copy the public key to authorized_keys
      cat "$SSH_DIR/id_ecdsa.pub" >> "$SSH_DIR/authorized_keys"
      
      # Set the correct permissions and ownership for authorized_keys
      chmod 600 "$SSH_DIR/authorized_keys"
      chown "$USER:$DEFAULT_GROUP" "$SSH_DIR/authorized_keys"
      
      # Print a message indicating the public key was added to authorized_keys
      echo "Added public key to authorized_keys for user $USER"

      # Create SSH config file
      SSH_CONFIG="$SSH_DIR/config"
      {
        echo "Host *"
        echo "  IdentityFile $SSH_DIR/id_ecdsa"
        echo "  StrictHostKeyChecking no"
        echo "  UserKnownHostsFile=/dev/null"
      } > "$SSH_CONFIG"
      
      # Set the correct permissions and ownership for the config file
      chmod 600 "$SSH_CONFIG"
      chown "$USER:$DEFAULT_GROUP" "$SSH_CONFIG"
      
      # Print a message indicating the SSH config file was created
      echo "Created SSH config file for user $USER"
    else
      # Print a message indicating the user does not exist
      echo "User $USER does not exist"
    fi
  fi
done