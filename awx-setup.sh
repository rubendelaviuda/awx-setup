#!/bin/bash


# --------------
# Script  made by Rubén de la Viuda Redondo that installs AWX, awxctl and all its dependencies in the system
# This script is a final degree project for 'ASIR' at IES Gaspar Melchor de Jovellanos in Fuenlabrada
# Free use
# --------------





# Delete set-up function
# Uninstall the process if something goes wrong during the set-up
function deletesetup {

	sudo rm -rf minikube-linux-amd64 2>&1> /dev/null
	sudo rm -rf kustomize_v4.5.7_linux_amd64.tar 2>&1> /dev/null
	sudo rm -rf kustomize_v4.5.7_linux_amd64.tar.gz 2>&1> /dev/null
	sudo rm -rf kustomize 2>&1> /dev/null
	sudo rm -rf kustomization.yaml 2>&1> /dev/null
	sudo rm -rf kubectl.sha256 2>&1> /dev/null
	sudo rm -rf kubectl 2>&1> /dev/null
	sudo rm -rf awx-demo.yaml 2>&1> /dev/null
	sudo chmod 755 /etc/ 2>&1> /dev/null 2>&1> /dev/null
	sudo chmod 755 /etc/systemd/system/ 2>&1> /dev/null
	sudo chmod 755 /bin/ 2>&1> /dev/null
	sudo chmod 755 /etc/bash_completion.d/ 2>&1> /dev/null
	echo ""
	exit 1

}

# Checks if it is being run as an administrator
if [[ $EUID -eq 0 ]]; then
	# Informs the user about the error and exits the script with errors
	echo ""
	printf '\033[1m🔨  AWX SET UP  🔨\n-------------------\033[0m\n'
	echo ""
	echo "❗  This script must be executed WITHOUT administrator privileges"
	echo ""
	exit 1
fi

# Gets the amount of available memory in the system in kilobytes
mem_kb=$(free | awk 'NR==2{print $2}')
# Converts the kilobytes to mebibytes (MiB)
mem_mib=$(echo "scale=2; $mem_kb/1024" | bc)
# Checks if the final value is less than 6144 MiB
if (( $(echo "$mem_mib < 6144" | bc -l) )); then
	# Informs the user about the error and exits the script with errors
	echo ""
	printf '\033[1m🔨  AWX SET UP  🔨\n-------------------\033[0m\n'
	echo ""
	echo "❌  Your computer has "$mem_mib"MB of RAM and at least 6144MB are needed"
	if [ "$(nproc)" -lt 4 ]; then
		echo "❌  Your computer has $(nproc) processors and at least 4 are needed"
	fi
	echo ""
	exit 1
fi

# Checks if the system has 4 processors or more.
if [ "$(nproc)" -lt 4 ]; then
	# Informs the user about the error and exits the script with errors
	echo ""
	printf '\033[1m🔨  AWX SET UP  🔨\n-------------------\033[0m\n'
	echo ""
	echo "❌  Your computer has $(nproc) processors and at least 4 are needed"
	if (( $(echo "$mem_mib < 6144" | bc -l) )); then
		echo "❌  Your computer has "$mem_mib"MB of RAM and at least 6144MB are needed"
	fi
	echo ""
	exit 1
fi

# Checks if AWX is already installed
if [ -e "/var/lib/awx/awx-installed" ]; then
	# Ask the user if they want to reinstall awxctl
	echo ""
	printf '\033[1m🔨  AWX SET UP  🔨\n-------------------\033[0m\n'
	echo ""
	echo "❗  It looks like AWX is already installed on your system"
	echo "❓  Do you want to proceed with the installation anyway? (y/N)"
	read -p "⏩  " answer
	# If the user enters an invalid command, repeats the question.
	while [[ $answer != "s" && $answer != "S" && $answer != "y" && $answer != "Y" && $answer != "" && $answer != "n" && $answer != "N" ]]
	do
		echo ""
		echo "❗  It looks like AWX is already installed on your system"
		echo "❓  Do you want to proceed with the installation anyway? (y/N)"
		read -p "⏩  " answer
	done
	# If the answer is 'n', 'N' or enter, exits the script
	if [[ $answer == "n" || $answer == "N" || $answer == "" ]]
	then
		echo ""
		exit 0
	fi
	# Requests the user's system password
	if ! sudo true; then
		# Informs the user about the error and exits the script with errors
		echo ""
		echo "❌  You need to be a sudoer to run this script"
		echo ""
		exit 1
	fi
	sudo rm -r /var/lib/awx
fi

# Checks if AWX dependencies have not yet been installed
if ! [ -d "/var/lib/awx" ]; then

# --------------
# Script 1 made by Rubén de la Viuda Redondo that install all AWX dependencies
# This script is a final degree project for 'ASIR' at IES Gaspar Melchor de Jovellanos in Fuenlabrada
# Free use
# --------------





# Script title
echo ""
printf '\033[1m🔨  AWX SET UP - PART 1  🔨\n----------------------------\033[0m\n'
echo ""

# Asks the user if they are sure about the installation
echo "❓  This script will install AWX dependencies on your system and reboot it when finished. Do you want to continue? (Y/n)"
read -p "⏩  " answer
# Loop to validate user response
while [[ $answer != "s" && $answer != "S" && $answer != "y" && $answer != "Y" && $answer != "" && $answer != "n" && $answer != "N" ]]
do
	echo ""
	echo "❓  This script will install AWX dependencies on your system and reboot it when finished. Do you want to continue? (Y/n)"
	read -p "⏩  " answer
done
# If the answer is 'n' or 'N', exits the script
if [[ $answer == "n" || $answer == "N" ]]
then
	echo ""
	exit 0
fi

# Requests the user's system password
if ! sudo true; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  You need to be a sudoer to run this script"
	echo ""
	exit 1
fi

echo ""
echo "👤  Enter the system user that will run AWX (Press Enter to use the current user):"
read -p "⏩  " username

if [[ -z "$username" ]]; then
	username=$(whoami)
fi
# Checks that the username exists and is not root
while ! id -u "$username" >/dev/null 2>&1 || [[ "$username" == "root" ]]
do
	if [[ "$username" == "root" ]]; then
		echo ""
		echo "❗  The user \"root\" is not allowed. Enter another user:"
	else
		echo ""
		echo "❗  The user \"$username\" does not exist on the system. Enter another user:"
	fi
	read -p "⏩  " username
	
	if [[ -z "$username" ]]; then
	username=$(whoami)
fi
done

echo ""
echo ""

printf '\033[1m🔨  SET UP 1 - STATUS  🔨\n--------------------------\033[0m\n'

echo ""

# Checks the internet connection by pinging Google
ping -c4 google.com > /dev/null

# If it doesn't work...
if ! [ $? -eq 0 ]; then
	# Informs the user about the error and exits the script with errors
	echo "❌  Failed to access internet"
	exit 1
fi

echo "🔃  Updating repositories list..."
if ! sudo apt-get update > /dev/null
then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error checking the repositories list"
	exit 1
fi

# Installs curl
echo "🔧  Installing curl..."
if ! sudo apt-get install -y curl > /dev/null
then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error installing curl"
	exit 1
fi

# Downloads minikube
echo "⏬  Downloading minikube..."
if ! sudo curl -LOs https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 > /dev/null; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error downloading minikube"
	deletesetup
fi

# Installs minikube in /usr/local/bin
echo "🔧  Installing minikube..."
if ! sudo install minikube-linux-amd64 /usr/local/bin/minikube > /dev/null; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error installing minikube"
	deletesetup
fi

# Installs docker
echo "🔧  Installing docker..."
if ! sudo apt-get install -y docker.io > /dev/null; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error installing docker"
	deletesetup
fi

# Adds the selected user to the docker group.
if sudo usermod -aG docker "$username"; then
	:
else
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error adding user to docker group"
	deletesetup
fi

# Downloads kustomize
echo "⏬  Downloading kustomize..."
if ! sudo curl --silent --location --remote-name https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv4.5.7/kustomize_v4.5.7_linux_amd64.tar.gz; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error downloading kustomize"
	deletesetup
fi

# Unpacks kustomize
echo "📚  Unpacking kustomize..."
if ! sudo gunzip --force kustomize_v4.5.7_linux_amd64.tar.gz; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error unpacking kutomize"
	deletesetup
fi
if ! sudo tar -tvf kustomize_v4.5.7_linux_amd64.tar > /dev/null; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error unpacking kutomize"
	deletesetup
fi
if ! sudo tar -xvf kustomize_v4.5.7_linux_amd64.tar kustomize > /dev/null; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error unpacking kutomize"
	deletesetup
fi

# Copies kustomize.
echo "🚚  Copying kustomize..."
if ! sudo cp kustomize /usr/local/bin; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error copying kustomize"
	deletesetup
fi

# Downloads kubectl
echo "⏬  Downloading kubectl..."
if ! sudo curl --silent -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error downloading kubectl"
	deletesetup
fi
# Downloads kubectl checksum
if ! sudo curl --silent -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error downloading kubectl"
	deletesetup
fi
# Checks if kubectl has been downloaded correctly
if ! sudo echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check > /dev/null; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error downloading kubectl"
	deletesetup
fi

# Installs kubectl
echo "🔧  Installing Kubectl..."
if ! sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl > /dev/null; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error installing kubectl"
	deletesetup
fi
# Checks if kubectl has been installed correctly
if ! sudo kubectl version --short 2> /dev/null | grep -qE '(Client|Server|Kustomize) Version' > /dev/null; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error installing kubectl"
	deletesetup
fi

# Copies control commands
echo "🚚  Copying control command..."
if ! sudo chmod 777 /etc/ > /dev/null; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error copying control commands"
	deletesetup
fi
if ! sudo chmod 777 /etc/systemd/system/ > /dev/null; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error copying control commands"
	deletesetup
fi
if ! sudo chmod 777 /bin/ > /dev/null; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error copying control commands"
	deletesetup
fi
if ! sudo chmod 777 /etc/bash_completion.d/ > /dev/null; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error copying control commands"
	deletesetup
fi
# Creates the folder /var/lib/awx/
if ! sudo mkdir -p /var/lib/awx/ > /dev/null; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error copying control commands"
	deletesetup
fi
# Changes the permissions of the folder /var/lib/awx/
if ! sudo chmod 777 /var/lib/awx/ > /dev/null; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error copying control commands"
	deletesetup
fi
# Creates the file /var/lib/awx/awx-user
if ! sudo echo "$username" > /var/lib/awx/awx-user; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error copying control commands"
	deletesetup
fi
# Changes the permissions of the file /var/lib/awx/awx-user
if ! sudo chmod 777 /var/lib/awx/awx-user > /dev/null; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error copying control commands"
	deletesetup
fi
# Creates the file /var/lib/awx/awx-status
if ! sudo touch /var/lib/awx/awx-status > /dev/null; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error copying control commands"
	deletesetup
fi
# Changes the permissions of the file /var/lib/awx/awx-status
if ! sudo chmod 777 /var/lib/awx/awx-status > /dev/null; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error copying control commands"
	deletesetup
fi

# Creates the file /bin/awxctl
if ! sudo cat > /bin/awxctl <<'EOF'
#!/bin/bash


# --------------
# Script made by Ruben de la Viuda Redondo for managing a Docker container with AWX
# This script is a final degree project for 'ASIR' at IES Gaspar Melchor de Jovellanos in Fuenlabrada
# Free use
# --------------

# Information variables
version="1.0.0"
repository="https://github.com/rubendelaviuda/awx-setup"





# --------------
# The following are functions and commands that awxctl will be able to execute
# You can add your own functions. You just need to include them in the show_help and the final case
# --------------

# Show title function
# Displays the header and title of the used command
function show_title {

	# Hyphens function
	# Calculates the number of hyphens we will need to write later on
	function hyphens {
		hyphens=""
		for ((counter=0; counter<$1; counter++)); do
			hyphens+="-"
		done
		echo "$hyphens"
	}

	# Declares the parameter variables
	param_num=$1
	command=$2
	parameter=$3
	state=$4
	
	# A variable that will allow us to know if the execution of show_title should be aborted
	should_stop=0
	
	# Checks the command selected by the user and saves its title
	case $command in
		help|-h|--help)
		title="🤝  AWX HELP  🤝"
		;;
		version|-v|--version)
		title="📆  AWX VERSION  📆"
		;;
		info|-i|--info)
		title="💡  AWX INFORMATION  💡"
		;;
		start|-s|--start)
		title="🚀  STARTING AWX CONTAINER  🚀"
		;;
		stop|-t|--stop)
		title="🚩  STOPPING AWX CONTAINER  🚩"
		;;
		restart|-r|--restart)
		title="🔁  RESTARTING AWX CONTAINER  🔁"
		;;
		config|-c|--config)
		title="🔧  CONFIGURE AWX  🔧"
		;;
		list|-l|--list)
		title="📋  LIST AWX PLAYBOOKS  📋"
		;;
		read|-e|--read)
		title="📜  READ AWX PLAYBOOK  📜"
		# Checks if the 'read' command was executed successfully
		if [ $state -eq 0 ]; then
			# Writes the title in bold and saves the length of the parameter in a variable
			printf '\n\033[1m'
			echo "$title"
			param_length=${#parameter}
			# "Checks if the length of the parameter is less than 25
			if [ "$param_length" -le 25 ]; then
				# Calculates half of the difference between the length of the title and the length of the parameter
				title_length=$((${#title} + 2))
				result=$((param_length - title_length))
				divided_length=$((result / 2))
				printf -v spaces "%${divided_length}s" ""
				# Displays the header of the parameter
				hyphens "$title_length"
				echo -n "$spaces"
				echo "$parameter"
				hyphens "$title_length"
			else
				# Displays the header of the parameter
				hyphens "$param_length"
				echo "$parameter"
				hyphens "$param_length"
			fi
			# Stops writing in bold and indicates that the loop should stop
			printf '\033[0m\n'
			should_stop=1
		fi
		;;
		add|-a|--add)
		title="➕  ADD AWX PLAYBOOK  ➕"
		;;
		delete|-d|--delete)
		title="🧹  DELETE AWX CONTAINER  🧹"
		;;
		uninstall|-u|--uninstall)
		title="🚮  UNINSTALL AWX  🚮"
		;;
		*)
		title="🤝  AWX HELP  🤝"
		;;
	esac

	# Checks if the value of 'should_stop' has not been raised
	if [ "$should_stop" -eq 0 ]; then
		# Writes the title in bold
		printf '\n\033[1m'
		echo "$title"
		title_length=$((${#title} + 2))
		hyphens "$title_length"
		printf '\033[0m\n'
	fi

}

# Good exit function
# Exits the script properly
function good_exit {
	echo ""
	exit 0
}

# Bad exit function
# Exit the script with errors
function bad_exit {
	echo ""
	exit 1
}

# Check user function
# Checks if the user executing the script is the same as the one used for installation
function check_user {

	# Declares the parameter variables
	param_num=$1
	command=$2
	parameter=$3

	# Checks if the file /var/lib/awx/awx-user exists and if it has content
	if [ -f "/var/lib/awx/awx-user" ] && [ -s "/var/lib/awx/awx-user" ]; then
		# Saves the content of the file into the variable '$username'
		username=$(cat /var/lib/awx/awx-user)
	else
		# Informs the user about the error and exits the script with errors
		show_title "$param_num" "$command" "$parameter"
		echo "❌  Your installation has errors. Try reinstalling awxctl"
		bad_exit
	fi
	# Stores the current user in the variable '$current_user'
	current_user=$(whoami)
	# Checks if the installation user and the current user are not the same
	if [ "$current_user" != "$username" ]; then
		# Informs the user about the error and exits the script with errors
		show_title "$param_num" "$command" "$parameter"
		echo "❌  You must run this script with the user '$username'"
		bad_exit
	fi

}

# Show help function
# Displays the list of available parameters to use in the command and their function
function show_help {

	# Declares the parameter variables
	param_num=$1
	command=$2
	parameter=$3

	show_title "$param_num" "$command" "$parameter"
	printf '\033[1m⬇️   This is the list of commands that can be used to control the AWX container:\033[0m\n'
	printf '\033[1m -  🤝  awxctl help | awxctl --help | awxctl -h\033[0m - Shows help about managing the AWX container\n'
	printf '\033[1m -  💡  awxctl info | awxctl --info | awxctl -i\033[0m - Shows the current status of the AWX container and access credentials\n'
	printf '\033[1m -  🚀  awxctl start | awxctl --start | awxctl -s\033[0m - Starts the AWX container\n'
	printf '\033[1m -  🚩  awxctl stop | awxctl --stop | awxctl -t\033[0m - Stops the AWX container\n'
	printf '\033[1m -  🔁  awxctl restart | awxctl --restart | awxctl -r\033[0m - Restarts the AWX container\n'
	printf '\033[1m -  🔧  awxctl config [playbook] | awxctl --config [playbook] | awxctl -c [playbook]\033[0m - Enter the AWX container terminal\n'
	printf '\033[1m -  📋  awxctl list | awxctl --list | awxctl -l\033[0m - Displays the list of playbooks in AWX\n'
	printf "\033[1m -  📜  awxctl read [playbook] | awxctl --read [playbook] | awxctl -e [playbook]\033[0m - Displays the content of a specific playbook. It must be accompanied by the playbook's name\n"
	printf "\033[1m -  ➕  awxctl add [playbook] | awxctl --add [playbook] | awxctl -a [playbook]\033[0m - Add a playbook to AWX. It must be accompanied by the playbook's path\n"
	printf "\033[1m -  🧹  awxctl delete [playbook] | awxctl --delete [playbook] | awxctl -d [playbook]\033[0m - Remove a playbook from AWX. You need to specify the playbook file's name to be deleted\n\n"
	printf '\033[1m -  📆  awxctl version | awxctl --version | awxctl -v\033[0m - Shows the current version of the awxctl command\n'
	printf '\033[1m -  📆  awxctl uninstall | awxctl --uninstall | awxctl -u\033[0m - Uninstalls AWX and awxctl\n'
	printf '\033[1m⬇️   List of additional commands for AWX:\033[0m\n'
	printf '\033[1m -  💡  sudo systemctl status auto-awx.service\033[0m - Checks the status of AWX automatic startup when the system starts\n'
	printf '\033[1m -  🤖  sudo systemctl enable auto-awx.service\033[0m - Enables AWX automatic startup when the system starts\n'
	printf '\033[1m -  📴  sudo systemctl disable auto-awx.service\033[0m - Disables AWX automatic startup when the system starts\n'

}

# Show version function
# Displays the version of the command and other related information
function show_version {

	# Declares the parameter variables
	param_num=$1
	command=$2
	parameter=$3
	
	show_title "$param_num" "$command" "$parameter"
	printf '\033[1m'; echo "Version"; printf '\033[0m'; echo "$version"; echo ""
	printf '\033[1m'; echo "Repository"; printf '\033[0m'; echo "$repository"; echo ""
	printf '\033[1m'; echo "AWXCTL"; printf '\033[0m'; echo "Ruben de la Viuda Redondo"
	good_exit

}

# Check status function
# Checks the current status of the AWX container
function check_status {

	# Checks if the container is currently stopped
	if minikube status 2> /dev/null | grep -q "host: Stopped" && minikube status 2> /dev/null | grep -q "kubelet: Stopped" && minikube status 2> /dev/null | grep -q "apiserver: Stopped"; then
		# Declares the parameter variables
		param_num=$1
		command=$2
		parameter=$3
		state=1

		# Informs the user about the error and exits the script with errors
		show_title "$param_num" "$command" "$parameter" "$state"
		echo -e "❗  AWX container is currently stopped"
		bad_exit
	fi

}

# Check network function
# Checks if there is a proper internet connection
function check_net {

	# Checks the internet connection by pinging Google
	ping -c4 google.com > /dev/null

	# If it doesn't work...
	if ! [ $? -eq 0 ]; then

		# Declares the parameter variables
		param_num=$1
		command=$2
		parameter=$3
		state=1

		# Informs the user about the error and exits the script with errors
		show_title "$param_num" "$command" "$parameter"
		echo "❌  Failed to access internet"
		bad_exit
	fi

}

# Search path function
# Searchs for the path of the container where AWX playbooks are stored
function search_path {

	# Checks if the file /var/lib/awx/awx-path does not exist
	if [ ! -s /var/lib/awx/awx-path ]; then
		echo ""
		echo "🔍  Looking for the path of playbooks..."
		echo "🕔  This will only happen the first time. It may take a few minutes"
		# Searchs for the path
		awxpath=$(docker exec minikube find / -name "hello_world.yml" -type f 2>/dev/null | head -n 1)
		# Checks if any result has been found
		if [ -n "$awxpath" ]; then
			# Saves the result in the file
			awxpath=$(dirname "$awxpath")
			echo "$awxpath" > /var/lib/awx/awx-path
		else
			# Informs the user about the error and exits the script with errors
			show_title "$param_num" "$command" "$parameter"
			echo "❌  Failed to access the AWX playbook directory"
			bad_exit
		fi
	fi

}

# Show info function
# Displays the current information of the AWX container such as its status, credentials, and other related data
function show_info {

	# Declares the parameter variables
	param_num=$1
	command=$2
	parameter=$3

	# Checks if there is any 'tail' process running on the system and if so, kills it
	if pgrep tail > /dev/null; then
		pkill tail
	fi
	# Creates an error control
	# If the user presses CTRL+C, kills the 'tail' process
	cleanup() {
		pkill tail
		exit 0
	}
	trap cleanup SIGINT SIGTERM SIGHUP
	# Checks the status of the AWX container
	check_status "$param_num" "$command" "$parameter"
	# Reads the real-time status of AWX executions until they finish
	if ! grep -q "Done!" /var/lib/awx/awx-status; then
		tail -f /var/lib/awx/awx-status &
		while true
		do
				if grep -q "Done!" "/var/lib/awx/awx-status"; then
				pkill tail
				break
			else
				sleep 1
			fi
		done
	fi
	check_status "$param_num" "$command" "$parameter"
	show_title "$param_num" "$command" "$parameter"
	echo -n -e "\033[1m🔗 AWX URL:\033[0m " ; minikube service -n awx awx-demo-service --url
	echo -e "\033[1m👤 User:\033[0m admin"
	echo -n -e "\033[1m🔑 Password:\033[0m " ; kubectl get secret awx-demo-admin-password -o jsonpath="{.data.password}" | base64 --decode ; echo
	good_exit

}

# Start awx function
# Starts the AWX container
function start_awx {

	# Declares the parameter variables
	param_num=$1
	command=$2
	parameter=$3

	show_title "$param_num" "$command" "$parameter" | tee /var/lib/awx/awx-status
	sleep 5
	minikube start --cpus=4 --memory=6g --addons=ingress | tee -a /var/lib/awx/awx-status
	kubectl config set-context --current --namespace=awx > /dev/null 2>&1
	echo "" | tee -a /var/lib/awx/awx-status
	exit 0

}

# Stop awx function
# Stops the AWX container
function stop_awx {

	# Declares the parameter variables
	param_num=$1
	command=$2
	parameter=$3

	show_title "$param_num" "$command" "$parameter" | tee /var/lib/awx/awx-status
	minikube stop | tee -a /var/lib/awx/awx-status && echo "✅  Done! AWX stopped succesfully" | tee -a /var/lib/awx/awx-status
	echo "" | tee -a /var/lib/awx/awx-status
	exit 0

}

# Restart awx function
# Stops awx container and then starts it
function restart_awx {

	# Declares the parameter variables
	param_num=$1
	command=$2
	parameter=$3
	
	show_title "$param_num" "$command" "$parameter" | tee /var/lib/awx/awx-status
	sleep 5
	printf '\033[1m🚩  Stopping the AWX container\033[0m\n'  | tee -a /var/lib/awx/awx-status
	minikube stop | tee -a /var/lib/awx/awx-status && printf '✅  AWX stopped succesfully\n\n' | tee -a /var/lib/awx/awx-status
	printf '\033[1m🚀  Starting the AWX container again\033[0m\n'  | tee -a /var/lib/awx/awx-status
	minikube start --cpus=4 --memory=6g --addons=ingress | tee -a /var/lib/awx/awx-status
	kubectl config set-context --current --namespace=awx > /dev/null 2>&1
	echo "" | tee -a /var/lib/awx/awx-status
	exit 0

}

# Configure awx
# Enters into the terminal of the AWX container
function config_awx {

	# Declares the parameter variables
	param_num=$1
	command=$2
	parameter=$3

	check_status "$param_num" "$command" "$parameter"
	show_title "$param_num" "$command" "$parameter"
	echo "⚠️   To exit the configuration terminal, type 'exit'"
	echo ""
	docker exec -it minikube bash
	good_exit

}

# Show list function
# Shows the list of available playbooks in AWX
function show_list {

	# Declares the parameter variables
	param_num=$1
	command=$2
	parameter=$3

	check_status "$param_num" "$command" "$parameter"
	search_path
	awxpath=$(cat /var/lib/awx/awx-path)
	show_title "$param_num" "$command" "$parameter"
	docker exec minikube ls "$awxpath" | grep -v "README.md"
	#Checks if the 'ls' command could be executed
	if [ $? -eq 0 ]; then
		good_exit
	else
		# Informs the user about the error and exits the script with errors
		show_title "$param_num" "$command" "$parameter"
		echo "❌  Failed to access the AWX playbook directory"
		bad_exit
	fi
	bad_exit

}

# Read playbook function
# Shows the content of a specified AWX playbook
function read_playbook {

	# Declares the parameter variables
	param_num=$1
	command=$2
	parameter=$3
	state=0

	check_status "$param_num" "$command" "$parameter" "$state"
	# Checks if only one parameter has been entered
	if [ $param_num -eq 1 ]; then
		state=1
		# Informs the user about the error and exits the script with errors
		show_title "$param_num" "$command" "$parameter" "$state"
		echo "❌  Provide the name of the file to read"
		bad_exit
	fi
	# Checks if more than two parameters have been entered
	if [ $param_num -gt 2 ]; then
		state=1
		# Informs the user about the error and exits the script with errors
		show_title "$param_num" "$command" "$parameter" "$state"
		echo "❌  Only one file can be read at a time"
		bad_exit
	fi
	# Checks if the specified file exists
	search_path
	awxpath=$(cat /var/lib/awx/awx-path)
	files=$(docker exec minikube ls "$awxpath")
	file_exists=0
	if [[ $files =~ (^|[[:space:]])"$parameter"($|[[:space:]]) ]]; then
		# Checks if the specified file has the .yml extension
		if [[ "$3" != *".yml" ]]; then
			state=1
			# Informs the user about the error and exits the script with errors
			show_title "$param_num" "$command" "$parameter" "$state"
			echo "❌  The file must have the '.yml' extension"
			bad_exit
		else
			show_title "$param_num" "$command" "$parameter" "$state"
			docker exec minikube cat "$awxpath/$parameter"
			file_exists=1
		fi
	fi
	# Checks if the command was executed successfully
	if [ $file_exists -eq 1 ]; then
		good_exit
	else
		state=1
		# Informs the user about the error and exits the script with errors
		show_title "$param_num" "$command" "$parameter" "$state"
		echo "❌  The file '$parameter' does not exist."
		bad_exit
	fi
	
}

# Add playbook function
# Adds a playbook into AWX
function add_playbook {

	# Declares the parameter variables
	param_num=$1
	command=$2
	parameter=$3
	
	check_status "$param_num" "$command" "$parameter"
	# Checks if only one parameter has been entered
	if [ $param_num -eq 1 ]; then
		# Informs the user about the error and exits the script with errors
		show_title "$param_num" "$command" "$parameter"
		echo "❌  You must provide the name of the file to copy"
		bad_exit
	fi
	# Checks if more than two parameters have been entered
	if [ $param_num -gt 2 ]; then
		# Informs the user about the error and exits the script with errors
		show_title "$param_num" "$command" "$parameter"
		echo "❌  Only one file can be copied at a time"
		bad_exit
	fi
	# Checks if the specified file exists
	if [ ! -f "$parameter" ]; then
		# Informs the user about the error and exits the script with errors
		show_title "$param_num" "$command" "$parameter"
		echo "❌  The file '$parameter' does not exist"
		bad_exit
	fi
	# Checks if the specified file has the .yml extension
	ext="${parameter##*.}"
	if [ "$ext" != "yml" ]; then
		# Informs the user about the error and exits the script with errors
		show_title "$param_num" "$command" "$parameter"
		echo "❌  The file must have the '.yml' extension"
		bad_exit
	fi
	# Checks if the specified file is named 'hello_world.yml'
	if [ "$(basename "$parameter")" = "hello_world.yml" ]; then
		# Informs the user about the error and exits the script with errors
		show_title "$param_num" "$command" "$parameter"
		echo "❌  Copying files named 'hello_world.yml' is not allowed"
		bad_exit
	fi
	abs_path="$(realpath "$parameter")"
	filename="$(basename "$abs_path")"
	search_path
	awxpath=$(cat "/var/lib/awx/awx-path")
	docker cp "$abs_path" minikube:"$awxpath"/"$filename"
	# Checks if the command was executed successfully
	if [ $? -eq 0 ]; then
		exit 0
	else
		# Informs the user about the error and exits the script with errors
		show_title "$param_num" "$command" "$parameter"
		echo "❌  Failed to copy the playbook to the AWX directory"
		bad_exit
	fi

}

# Delete playbook function
# Deletes a playbook from AWX
function delete_playbook {

	# Declares the parameter variables
	param_num=$1
	command=$2
	parameter=$3

	check_status "$param_num" "$command" "$parameter"
	# Checks if only one parameter has been entered
	if [ $param_num -eq 1 ]; then
		# Informs the user about the error and exits the script with errors
		show_title "$param_num" "$command" "$parameter"
		echo "❌  Provide the name of the file to delete"
		bad_exit
	fi
	# Checks if more than two parameters have been entered
	if [ $param_num -gt 2 ]; then
		# Informs the user about the error and exits the script with errors
		show_title "$param_num" "$command" "$parameter"
		echo "❌  Only one file can be deleted at a time"
		bad_exit
	fi
	# Checks if the specified file is named 'hello_world.yml'
	if [ "$parameter" == "hello_world.yml" ]; then
		# Informs the user about the error and exits the script with errors
		show_title "$param_num" "$command" "$parameter"
		echo "❌  Deleting files named 'hello_world.yml' is not allowed."
		bad_exit
	fi
	# Checks if the specified file exists
	search_path
	awxpath=$(cat /var/lib/awx/awx-path)
	files=$(docker exec minikube ls "$awxpath")
	file_exists=0
	if [[ $files =~ (^|[[:space:]])"$parameter"($|[[:space:]]) ]]; then
		# Checks if the specified file has the .yml extension
		if [[ "$parameter" != *".yml" ]]; then
			# Informs the user about the error and exits the script with errors
			show_title "$param_num" "$command" "$parameter"
			echo "❌  The file must have the '.yml' extension"
			bad_exit
		else
			docker exec minikube rm "$awxpath/$parameter"
			file_exists=1
		fi
	fi
	# Checks if the command was executed successfully
	if [ $file_exists -eq 1 ]; then
		exit 0
	else
		# Informs the user about the error and exits the script with errors
		show_title "$param_num" "$command" "$parameter"
		echo "❌  The file '$parameter' does not exist."
		bad_exit
	fi

}

# Uninstall AWX function
# Uninstall AWX and awxctl from the system
function uninstall_awx {

	# Declares the parameter variables
	param_num=$1
	command=$2
	parameter=$3

	show_title "$param_num" "$command" "$parameter"

	# Asks the user if they are sure about the uninstallation
	echo "❗  This command will uninstall AWX and awxctl from your system"
	echo "❓  Do you want to proceed with the installation anyway? (y/N)"
	read -p "⏩  " answer
	# Loop to validate user response
	while [[ $answer != "s" && $answer != "S" && $answer != "y" && $answer != "Y" && $answer != "" && $answer != "n" && $answer != "N" ]]
	do
		echo ""
		echo "❗  This command will uninstall AWX and awxctl from your system"
		echo "❓  Do you want to proceed with the installation anyway? (y/N)"
		read -p "⏩  " answer
	done
	# If the answer is 'n', 'N' or enter, exits the script
	if [[ $answer == "n" || $answer == "N" || $answer == "" ]]
	then
		good_exit
	fi

	# Asks the user if they also want to uninstall the dependencies
	echo ""
	echo "❓  Do you want to uninstall all dependencies as well? (y/N)"
	read -p "⏩  " answer
	# Saves the response in a variable
	while [[ $answer != "s" && $answer != "S" && $answer != "y" && $answer != "Y" && $answer != "" && $answer != "n" && $answer != "N" ]]
	do
		echo ""
		echo "❓  Do you want to uninstall all dependencies as well? (y/N)"
		read -p "⏩  " answer
	done

	# Requests the user's system password
	if ! sudo true; then
		echo ""
		echo "❌  You need to be a sudoer to run this script"
		bad_exit
	fi

	echo ""

	# Checks the internet connection
	check_net "$param_num" "$command" "$parameter"

	# Uninstalls the service
	echo "🔨  Uninstalling systemd service..."
	if ! sudo rm /etc/systemd/system/auto-awx.service > /dev/null; then
		echo ""
		echo "❌  Error uninstalling systemd service"
		bad_exit
	fi
	if ! sudo rm /etc/auto-awx.sh > /dev/null; then
		echo ""
		echo "❌  Error uninstalling systemd service"
		bad_exit
	fi

	# Updates service list
	echo "🔄  Updating service list..."
	if ! sudo systemctl daemon-reload > /dev/null; then
		echo ""
		echo "❌  Error updating service list"
		bad_exit
	fi

	# Removes the command tabulation entry
	echo "🗑️  Removing command tabulation entry..."
	if ! sudo rm /etc/bash_completion.d/awxctl > /dev/null; then
		echo ""
		echo "❌  Error removing command tabulation entry"
		bad_exit
	fi

	# Unmounts the AWX container
	echo "🔧  Unmounting the AWX container..."
	if ! minikube delete; then
		echo ""
		echo "❌  Error unmounting the AWX container"
		bad_exit
	fi

	# Deletes the temporary files
	echo "🗑️  Deleting temporary files..."
	if ! sudo rm -r /var/lib/awx > /dev/null; then
		echo ""
		echo "❌  Error deleting temporary files"
		bad_exit
	fi

	# Deletes set-up files
	echo "🗑️  Deleting setup-files..."
	awx_setup_file > echo /var/lib/awx/awx-setup-file
	sudo rm -rf "$awx_setup_file/minikube-linux-amd64" 2>&1> /dev/null
	sudo rm -rf "$awx_setup_file/kustomize_v4.5.7_linux_amd64.tar" 2>&1> /dev/null
	sudo rm -rf "$awx_setup_file/kustomize_v4.5.7_linux_amd64.tar.gz" 2>&1> /dev/null
	sudo rm -rf "$awx_setup_file/kustomize" 2>&1> /dev/null
	sudo rm -rf "$awx_setup_file/kustomization.yaml" 2>&1> /dev/null
	sudo rm -rf "$awx_setup_file/kubectl.sha256" 2>&1> /dev/null
	sudo rm -rf "$awx_setup_file/kubectl" 2>&1> /dev/null
	sudo rm -rf "$awx_setup_file/awx-demo.yaml" 2>&1> /dev/null
	sudo rm -rf "$awx_setup_file/awx-setup.sh" 2>&1> /dev/null

	# If the user wanted the dependencies to be uninstalled...
	if [[ $answer == "s" || $answer == "S" || $answer == "y" || $answer == "Y" ]]
	then
		# Uninstalls curl
		echo "🔨  Uninstalling curl..."
		if ! sudo apt-get remove -y curl > /dev/null; then
			echo ""
			echo "❌  Error uninstalling curl"
			bad_exit
		fi
		
		# Uninstalls minikube
		echo "🔨  Uninstalling minikube..."
		minikube stop > /dev/null
		if ! sudo rm -r /usr/local/bin/minikube > /dev/null; then
			echo ""
			echo "❌  Error uninstalling minikube"
			bad_exit
		fi

		# Uninstalls docker
		echo "🔨  Uninstalling docker..."
		if ! sudo apt-get remove -y docker.io > /dev/null; then
			echo ""
			echo "❌  Error uninstalling docker"
			bad_exit
		fi

		# Removes the docker group
		echo "🗑️  Removing docker group..."
		if ! sudo groupdel docker > /dev/null; then
			echo ""
			echo "❌  Error removing docker group"
			bad_exit
		fi

		# Uninstalls kustomize
		echo "🔨  Uninstalling kustomize..."
		if ! sudo rm -r /usr/local/bin/kustomize > /dev/null; then
			echo ""
			echo "❌  Error uninstalling kustomize"
			bad_exit
		fi

		# Uninstalls kubectl
		echo "🔨  Uninstalling kubectl..."
		if ! sudo rm -r /usr/local/bin/kubectl > /dev/null; then
			echo ""
			echo "❌  Error uninstalling kubectl"
			bad_exit
		fi

	fi

	# Uninstalls awxctl
	echo "🔨  Uninstalling awxctl..."
	if ! sudo rm -r "$0" > /dev/null; then
		echo ""
		echo "❌  Error uninstalling kubectl"
		bad_exit
	fi

	echo "✅  Done! AWX and awxctl have been successfully uninstalled from your system"

	good_exit		

}

# Declares the parameter variables
param_num=$#
command=$1
parameter=$2

# Checks if the user executing the script is the same as the one used for installation
check_user "$param_num" "$command" "$parameter"

while [[ $param_num -gt 0 ]]
do
	# Checks the command selected by the user
	case $command in
		help|-h|--help)
		show_help "$param_num" "$command" "$parameter"
		good_exit
		;;
		version|-v|--version)
		show_version "$param_num" "$command" "$parameter"
		;;
		info|-i|--info)
		show_info "$param_num" "$command" "$parameter"
		;;
		start|-s|--start)
		start_awx "$param_num" "$command" "$parameter"
		;;
		stop|-t|--stop)
		stop_awx "$param_num" "$command" "$parameter"
		;;
		restart|-r|--restart)
		restart_awx "$param_num" "$command" "$parameter"
		;;
		config|-c|--config)
		config_awx "$param_num" "$command" "$parameter"
		;;
		list|-l|--list)
		show_list "$param_num" "$command" "$parameter"
		;;
		read|-e|--read)
		read_playbook "$param_num" "$command" "$parameter"
		;;
		add|-a|--add)
		add_playbook "$param_num" "$command" "$parameter"
		;;
		delete|-d|--delete)
		delete_playbook  "$param_num" "$command" "$parameter"
		;;
		uninstall|-u|--uninstall)
		uninstall_awx  "$param_num" "$command" "$parameter"
		;;
		*)
		show_help "$param_num" "$command" "$parameter"
		bad_exit
		;;
	esac
done

show_help
bad_exit
EOF
then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error copying control command"
	deletesetup
fi
# Changes the permissions of the file /bin/awxctl
if ! sudo chmod 777 /bin/awxctl; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error copying control command"
	deletesetup
fi

# Creates the file /etc/bash_completion.d/awxctl
if ! sudo cat > /etc/bash_completion.d/awxctl <<'EOF'
_awxctl()
{
	local cur prev opts
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"
	opts="-i --info -v --version -s --start -t --stop -r --restart -h --help -c --config -l --list -e --read -a --add -d --delete -u --uninstall"

	case "${prev}" in
		-i|--info)
			return 0
			;;
		-v|--version)
			return 0
			;;
		-s|--start)
			return 0
			;;
		-t|--stop)
			return 0
			;;
		-r|--restart)
			return 0
			;;
		-h|--help)
			return 0
			;;
		-c|--config)
			return 0
			;;
		-l|--list)
			return 0
			;;
		-e|--read)
			return 0
			;;
		-a|--add)
			return 0
			;;
		-d|--delete)
			return 0
			;;
		-u|--uninstall)
			return 0
			;;
		esac
    
	if [[ ${cur} == -* ]]; then
		COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
		return 0
	else
		COMPREPLY=( $(compgen -W "info version start stop restart help config list read add delete uninstall" -- ${cur}) )
		return 0
	fi
}

complete -F _awxctl awxctl
EOF
then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error copying control command"
	deletesetup
fi
# Changes the permissions of the file /etc/bash_completion.d/awxctl
if ! sudo chmod 777 /etc/bash_completion.d/awxctl; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error copying control command"
	deletesetup
fi
if ! source /etc/bash_completion.d/awxctl; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error copying control command"
	deletesetup
fi

# Create the systemd service so that the AWX container can be started automatically
echo "💻  Creating automatic startup service..."
# Creates the file /etc/auto-awx.sh
if ! sudo cat > /etc/auto-awx.sh <<EOF
#!/bin/bash


# --------------
# Script made by Ruben de la Viuda Redondo that starts the AWX container on docker in minikube in the background
# This script is a final degree project for 'ASIR' at IES Gaspar Melchor de Jovellanos in Fuenlabrada
# Free use
# --------------





# Script title
echo "" > /var/lib/awx/awx-status
printf '\033[1m🚀  STARTING AWX CONTAINER  🚀\n----------------------------\n\033[0m' >> /var/lib/awx/awx-status
echo "" >> /var/lib/awx/awx-status

sleep 5

# Initializes the container
minikube start --cpus=4 --memory=6g --addons=ingress 2>&1 | tee -a /var/lib/awx/awx-status >/dev/null
# Insert a line break
printf '\n' >> /var/lib/awx/awx-status

# Adjusts environment variables
kubectl config set-context --current --namespace=awx > /dev/null

echo "" >> /var/lib/awx/awx-status

# Exits the script
exit 0
EOF
then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error creating automatic startup service"
	deletesetup
fi
# Changes the permissions of the file /etc/auto-awx.sh
if ! sudo chmod 777 /etc/auto-awx.sh; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error creating automatic startup service"
	deletesetup
fi
# Creates the file /etc/systemd/system/auto-awx.service
if ! sudo cat > /etc/systemd/system/auto-awx.service <<EOF
# --------------
# Systemd service made by Ruben de la Viuda Redondo for automatic start of AWX container on docker in minikube
# This service is a final degree project for 'ASIR' at IES Gaspar Melchor de Jovellanos in Fuenlabrada
# Free use
# --------------





# Information variables
version="1.0.0"
repository="https://github.com/rubendelaviuda/awx-setup"



# Service description
[Unit]
Description=Auto-AWX Service
After=network.target docker.service
Requires=docker.service

# Service configuration
[Service]
User=ruben
Environment=LANG=en_US.UTF-8
Environment=LC_ALL=en_US.UTF-8
ExecStart=/bin/bash /etc/auto-awx.sh

# When the service should be started
[Install]
WantedBy=default.target
EOF
then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error creating automatic startup service"
	deletesetup
fi
# Changes the permissions of the file /etc/systemd/system/auto-awx.service
if ! sudo chmod 777 /etc/systemd/system/auto-awx.service; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error creating automatic startup service"
	deletesetup
fi
# Creates the file /var/lib/awx/awx-setup-file
script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
file_name=$(basename "$script_path")
directory=$(dirname "$script_path")
if ! sudo echo "$directory" > /var/lib/awx/awx-setup-file
then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error creating automatic startup service"
	deletesetup
fi
# Changes the permissions of the file /var/lib/awx/awx-setup-file
if ! sudo chmod 777 /var/lib/awx/awx-setup-file; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error creating automatic startup service"
	deletesetup
fi

# Notifies the user that the script has finished and the computer is going to reboot
echo "✅  Dependencies installation complete"
echo "💡  The computer is going to reboot. You must run the installer again to continue with the installation of AWX"
echo "🕔  Rebooting in 5 seconds..."
# Waits for 5 seconds and reboots the computer
sleep 5
echo ""
sudo reboot

# If the dependencies are already installed, moves on to part 2 of the script	    
else

# SCRIPT THAT INSTALLS AWX
# Script created by Ruben de la Viuda

#!/bin/bash

# Script title
echo ""
printf '\033[1m🔨  AWX SET UP - PART 2  🔨\n----------------------------\033[0m\n'
echo ""

# Asks the user if they are sure about the installation
echo "❓  This script will install AWX on your system. Do you want to continue? (Y/n)"
read -p "⏩  " answer
# Loop to validate user response
while [[ $answer != "s" && $answer != "S" && $answer != "y" && $answer != "Y" && $answer != "" && $answer != "n" && $answer != "N" ]]
do
	echo ""
	echo "❓  This script will install AWX on your system. Do you want to continue? (Y/n)"
	read -p "⏩  " answer
done
# If the answer is 'n' or 'N', exits the script
if [[ $answer == "n" || $answer == "N" ]]
then
	exit 1
fi

if [ -f "/var/lib/awx/awx-user" ] && [ -s "/var/lib/awx/awx-user" ]; then
	username=$(cat /var/lib/awx/awx-user)
else
	# Informs the user about the error and exits the script with errors
	echo "❌  Your installation has errors. Try reinstalling awxctl"
	bad_exit
fi
current_user=$(whoami)

# Checks if the user is in the "docker" group
if [ "$current_user" != "$username" ]; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  You must run this script with the user $username"
	deletesetup
fi

# Requests the user's system password
if ! sudo true; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  You need to be a sudoer to run this script"
	echo ""
	exit 1
fi

echo ""
echo ""
printf '\033[1m🔨  SET UP 2 - STATUS  🔨\n--------------------------\033[0m\n'
echo ""

# Checks the internet connection by pinging Google
ping -c4 google.com > /dev/null

# If it doesn't work...
if ! [ $? -eq 0 ]; then
	# Informs the user about the error and exits the script with errors
	echo "❌  Failed to access internet"
	deletesetup
fi

# Starts minikube
echo "🚀  Starting minikube..."
if ! minikube start --cpus=4 --memory=6g --addons=ingress; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error starting minikube..."
	deletesetup
fi

# Creates alias for kubectl
echo "🟰  Creating alias..."
if ! alias kubectl="minikube kubectl --"; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error creating alias..."
	deletesetup
fi

# Configures AWX container
echo "🔧  Configuring AWX container"
# Creates the file kustomization.yaml
if ! cat > kustomization.yaml <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  # Find the latest tag here: https://github.com/ansible/awx-operator/releases
  - github.com/ansible/awx-operator/config/default?ref=2.0.0

# Set the image tags to match the git version from above
images:
  - name: quay.io/ansible/awx-operator
    newTag: 2.0.0

# Specify a custom namespace in which to install AWX
namespace: awx
EOF
then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error configuring AWX container"
	deletesetup
fi

# Runs configuration
echo "🚀  Running configuration..."
if ! kustomize build . | kubectl apply -f - > /dev/null; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error running configuration..."
	deletesetup
fi

# Changes default namespace
echo "🔄  Changing default namespace..."
if ! kubectl config set-context --current --namespace=awx > /dev/null; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error changing default namespace..."
	deletesetup
fi

# Configures AWX container
echo "🔧  Configuring AWX container..."
# Creates the file awx-demo.yaml
if ! cat > awx-demo.yaml <<EOF
---
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: awx-demo
spec:
  service_type: nodeport
EOF
then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error configuring AWX container"
	deletesetup
fi
# Creates the file kustomization.yaml
if ! cat >> kustomization.yaml <<EOF

resources:
  - github.com/ansible/awx-operator/config/default?ref=2.0.0
  - awx-demo.yaml

EOF
then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error configuring AWX container"
	deletesetup
fi

# Runs configuration
echo "🚀  Running configuration..."
if ! kustomize build . | kubectl apply -f - > /dev/null; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error running configuration"
	deletesetup
fi

# Updates service list...
echo "🔄  Updating service list..."
if ! sudo systemctl daemon-reload > /dev/null; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error updating service list"
	deletesetup
fi
if ! sudo systemctl enable -q auto-awx.service > /dev/null; then
	# Informs the user about the error and exits the script with errors
	echo ""
	echo "❌  Error updating service list"
	deletesetup
fi

# Create a file indicating that AWX has been successfully installed on the computer
sudo touch /var/lib/awx/awx-installed

echo ""

# Messages indicating to the user that AWX has been successfully installed
echo "✅  Done! AWX has been installed successfully"
echo "🕔  It will take several minutes before you can access AWX"
echo "🤔  You can check the installation status by running: kubectl logs -f deployments/awx-operator-controller-manager -c awx-manager"

echo ""

# Informs the user how they can receive help
echo "❓  Do you need help managing the AWX container?"
echo "💡  Type 'awx help' in the terminal to access instructions"

echo ""

# Asks the user if they want to delete the temporary files that have been used for the installation
echo "🗑️   Would you like to remove the temporary files used for the set up? (y/N)"
read -p "⏩  " answer
# If the user enters an invalid command, repeats the question.
while [[ $answer != "s" && $answer != "S" && $answer != "y" && $answer != "Y" && $answer != "" && $answer != "n" && $answer != "N" ]]
do
	echo ""
	echo "🗑️   Would you like to remove the temporary files used for the installation? (y/N)"
	read -p "⏩  " answer
done
# If the answer is 'n', 'N' or enter, exits the script
if [[ $answer == "n" || $answer == "N" || $answer == "" ]]
then
	echo ""
	exit 0
fi

deletesetup

fi

exit 1
