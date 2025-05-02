#!/bin/bash

# attempt to start ssh-agent, check exit status
cleanup_ssh_agent() {
	if [ -n "$SSH_AGENT_PID" ] && kill -0 "$SSH_AGENT_PID" > /dev/null 2>&1; then
		echo "Terminating ssh-agent (PID: $SSH_AGENT_PID) ... "
		kill "$SSH_AGENT_PID"
		wait "$SSH_AGENT_PID" 2> /dev/null #wait for process to terminate
		echo "ssh-agent terminated."
	fi
}

trap cleanup_ssh_agent EXIT

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

echo "Successfully set up SSH to GitHub authentication"

while true; do
	read -p "What would you like to do next? (clone, fetch, push, test, status, merge, commit, pull, exit):" ACTION

	case "$ACTION" in
		pull)
			read -p "Enter the remote name (default: origin): " NAME
			NAME="${NAME:-origin}"
			read -p "Enter the branch (defaut: current): " BRANCH
			BRANCH="${BRANCH:-$(git rev-parse HEAD)}"
			git pull "$NAME" "$BRANCH"
			;;
		clone)
			read -p "Enter SSH URL of the repository to clone: " CLONE_URL
			if [ -n "$CLONE_URL" ]; then
				git clone "$CLONE_URL"
			else
				echo "Clone URL cannot be empty."
			fi
			;;
		fetch)
			read -p "Enter the remote name (defaults to: origin): " REMOTE_FETCH
			REMOTE_FETCH="${REMOTE_FETCH:-origin}"
			git fetch "$REMOTE_FETCH"
			;;
		push)
			read -p "Enter the remote name (defaults to: origin): " REMOTE_PUSH
			REMOTE_PUSH="${REMOTE_PUSH:-origin}"
			read -p "Enter the remote branch to push to (e.g., main): " BRANCH_PUSH
			if [ -n "$BRANCH_PUSH" ]; then
				git push "$REMOTE_PUSH" "$BRANCH_PUSH"
			
			else
				echo "Branch name cannot be empty"
			fi
			;;
		status)
			git status
			;;
		test)
			ssh -T git@github.com
			;;
		merge)
			read -p "Enter branch to merge into main: " MERGE_BRANCH
			if [ -n "$MERGE_BRANCH" ]; then
				echo "Checking out main.."
				git checkout main
				if [ $? -eq 0 ]; then
					echo "Merging branch $MERGE_BRANCH to main"
					git merge "$MERGE_BRANCH" --allow-unrelated-histories
					if [ $? -eq -0 ]; then
						echo "Successfully merged branch '$MERGE_BRANCH' into main locally"
					
						read -p "Would you like to push the updated main to the remote? (yes/no): " PUSH_MAIN
						PUSH_MAIN="${PUSH_MAIN,,}"
						if [[ "$PUSH_MAIN" == "yes" || "$PUSH_MAIN" == "y" ]]; then
							read -p "Enter the remote name (defaults to: origin): " REMOTE_PUSH_MAIN
							REMOTE_PUSH_MAIN="${REMOTE_PUSH_MAIN:-origin}"
							git push "$REMOTE_PUSH_MAIN" main
							echo "Pushed updated main to '$REMOTE_PUSH_MAIN'"
						elif [[ "$PUSH_MAIN" == "no" || "$PUSH_MAIN" == "n" ]]; then
							echo "Not pushing the updated main."
						else 
							echo "Error: Invalid input, not pushing updated main."
						fi
					else
						echo "Error: Error during merge, you may need to manually resolve conflicts."
					fi
				else
					echo "Error: Error with checking out main branch"
				fi
			else
				echo "Error: Branch name to merge cannot be empty."

						
			fi
			;;


		exit)
			echo "Exiting."
			break
			;;
		*)
			echo "Invalid action. Please choose from clone, fetch, push, status, test, or exit."
			;;
	esac
done


				
