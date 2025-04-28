# ssh-to-git-key-automation
This script automatically runs the ssh-agent and adds the specified private key to it! saving you the time of having to ssh-agent -s and ssh-add your key manually. 
This scripts assume you alreay have git installed on your linux system, and have already configured the ssh key for your account

To run the script simply do:
  ./sshscript.sh

It will prompt you for your SSH key path, please enter the absolute path e.g: /home/user/.ssh/<name of private key>

The supported git commands currently are:
- fetch
- pull
- merge
- push

other commands:
- test (will test your SSH connection)
- exit (will terminate the script and ssh instance)
