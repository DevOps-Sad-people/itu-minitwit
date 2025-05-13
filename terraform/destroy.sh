
set -e

result=${PWD##*/} 
# check if current directory is terraform
if [ "$result" != "terraform" ]; then
    echo -e "\n--> Please run this script from the terraform directory\n"
    exit 1
fi

# ask for confirmation so don't destroy by accident
echo -e "\n--> Destroying Minitwit Infrastructure\n"
echo -e "\n--> This will destroy all resources created by terraform\n"
echo -e "\n--> This will also destroy the database and all data in it\n"
echo -e "\n--> A dump file of the database will be created in the temp folder and saved to the bucket\n"
echo -e "\n--> Are you sure you want to continue? (y/n)\n"
read -r -p "Enter your choice: " choice
if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
    echo -e "\n--> Aborting...\n"
    exit 1
fi


echo -e "\n--> Loading environment variables from secrets file\n"
source secrets

echo -e "\n--> Checking that environment variables are set\n"
# check that all variables are set
[ -z "$TF_VAR_do_token" ] && echo "TF_VAR_do_token is not set" && exit
[ -z "$SPACE_NAME" ] && echo "SPACE_NAME is not set" && exit
[ -z "$STATE_FILE" ] && echo "STATE_FILE is not set" && exit
[ -z "$AWS_ACCESS_KEY_ID" ] && echo "AWS_ACCESS_KEY_ID is not set" && exit
[ -z "$AWS_SECRET_ACCESS_KEY" ] && echo "AWS_SECRET_ACCESS_KEY is not set" && exit


echo -e "\n--> Destroying Infrastructure\n"
terraform destroy -auto-approve
