#!/bin/bash

# attempt to start ssh-agent, check exit status

if eval "$(ssh-agent)"; then
	echo "Started ssh-agent successfully (PID: $SSH_AGENT_PID)"
else
	echo "Error failed to start ssh-agent"
	exit 1
fi

#prompt fo SSH key path (private)
read -p "Enter your private ssh key absolute path: " KEY_PATH

#check if prompt returns empty
if [ -z "$KEY_PATH" ]; then
	echo "Key path cannot be empty. Please provide the path to your private key."
	exit 1
fi

# check if github ssh key is added to ssh-agent
if ssh-add -l | grep -q "$(basename "$KEY_PATH")"; then
	echo "GitHub SSH key at '$KEY_PATH'..."
else
	if [ -f "$KEY_PATH" ]; then
		echo "Adding GitHub SSH key from '$KEY_PATH'..."
		ssh-add "$KEY_PATH"
		if [ $? -eq 0 ]; then
			echo "GitHub key added successfully."
		else
			echo "Error adding SSH key, ensure the SSH key exists, is valid, and you've entered the correct passphrase if required"
			exit 1
		fi
	else
		echo "GitHub SSH private key not found at: $KEY_PATH"
		echo "Please make sure the path is correct or generate an SSH key and add it to your GitHub account."
		echo "You can follow GitHub's guide: https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent"
		exit 1
	fi
fi

echo "Checking GitHub connection..."

ssh -T git@github.com
