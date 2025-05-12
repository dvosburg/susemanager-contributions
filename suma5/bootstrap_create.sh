#!/bin/bash
# This interactive script creates a bootstrap script in the MLM server


# Prompt the user for the bootstrap script name
read -p "Please enter the script name (.sh will be appended): " scriptname

# Prompt the user for the Activation Key
read -p "Please enter the Activation Key (e.g 1-15sp6): " activation

# Display the entered values
echo "The bootstrap script name will be: $scriptname.sh"
echo "The Activation Key you chose is: $activation"

# Create the bootstrap script with mgrctl
mgrctl exec -ti "mgr-bootstrap --script=$scriptname.sh --activation-keys=$activation"
