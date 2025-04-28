# prerequisites

This script is assuming you already have generated your GitHub SSH keys and set them up. If you have not please follow the instructions from the official GitHub docs: https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent .



Insure that you have the package less installed on your Linux machine, and that your private SSH key has the correct permissions


# ssh-to-git-key-automation
This script automatically runs the ssh-agent and adds the specified private key to it! saving you the time of having to ssh-agent -s and ssh-add your key manually. 
This scripts assume you alreay have git installed on your linux system, and have already configured the ssh key for your account

To run the script:

chmod +x [path to script goes here no brackets]


./[path to script]

It will prompt you for your SSH key path, please enter the absolute path e.g: /home/user/.ssh/[name of private key]

The supported git commands currently are:
- fetch
- pull
- merge
- status
- push

other commands:
- test (will test your SSH connection)
- exit (will terminate the script and ssh instance)
