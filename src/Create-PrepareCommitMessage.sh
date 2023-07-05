# ----------------------------
#
# @author
#		einar.vandevelde
# @date
#		05-07-2023
# @desc
#		A script to setup prepare-commit-msg for automatic prefixing commits with correct branch/ticket number.
# 		Additionally it tries to add the feat/refactor/fix/chore types to the commit based on the first entry of the staged items.
#		This is based on the "Conventional Commits v1.0.0" found here: https://www.conventionalcommits.org/en/v1.0.0/#summary
#
# ----------------------------

#!/bin/bash

SLEEP_TIME_DOTS=0.03;
GIT_HOOKS_DIRECTORY="../.git/hooks";
FILE_NAME="prepare-commit-msg";

EXIT_MESSAGE="Press 'Enter' to exit...";
func_exit() {
	echo "";
	read -p "$EXIT_MESSAGE";
}

echo_loop() {
	for index in $3
	do
		echo "$1";
		sleep $2;
		clear;
		echo "$1.";
		sleep $2;
		clear;
		echo "$1..";
		sleep $2;
		clear;
		echo "$1...";
		sleep $2;
		clear;
	done
}

clear;
echo "Navigating to $GIT_HOOKS_DIRECTORY directory.";
cd $GIT_HOOKS_DIRECTORY

clear;
if [ -e "$FILE_NAME" ]; then
    echo "File: "$FILE_NAME" already exists.";
	read -p "Would you like to override contents of file? (no): " INPUT_OVERRIDE_CONTENT;
	if [ "$INPUT_OVERRIDE_CONTENT" != "yes" ]; then
		func_exit;
		exit 0;
	fi
else
	# Create File in .git hooks directory
	echo_loop "File does not exist. Creating $FILE_NAME" $SLEEP_TIME_DOTS "1";
    touch "$FILE_NAME";
    echo "File: $FILE_NAME created.";
fi

# Write the bash script to the new file. (To read it replace surrounding quotes and all "\n" with "new lines" in vs-code)
clear;

# Read the JSON file content
# Get the directory path of the script
script_dir="$(dirname "$0")"
# Concatenate the file name to the directory path
settings_file="$script_dir/settings.json"
# Read the contents of the settings file
settings=$(cat "$settings_file")

# Extract values using string manipulation
ISSUE_PATTERN=$(grep -oP '(?<=ISSUE_PATTERN": ")[^"]*' <<< "$settings");
ISSUE_PREFIX=$(grep -oP '(?<=ISSUE_PREFIX": ")[^"]*' <<< "$settings");
USE_CONVENTIONAL_COMMITS=$(grep -oP '(?<=USE_CONVENTIONAL_COMMITS": )[^,}]*' <<< "$settings");

echo "$ISSUE_PATTERN $ISSUE_PREFIX $USE_CONVENTIONAL_COMMITS";
echo_loop "Writing bash-script to newly created $FILE_NAME file" $SLEEP_TIME_DOTS "1 2 3";
SCRIPT='#!/bin/bash

FEAT="feat";
REFACTOR="refactor";
CHORE="chore";
FIX="fix";

FILE=$1;
MESSAGE=$(cat $FILE);
echo "$ISSUE_PATTERN";
TICKET=[';
SCRIPT+="$ISSUE_PREFIX";
SCRIPT+='$(git rev-parse --abbrev-ref HEAD | grep -Eo ';
SCRIPT+='"'$ISSUE_PATTERN'")];
STATUS=$(git status --short | grep ^[MARCD]);
STAGED_STATUS_LOCATION=$(git status --short | grep ^[MARCD]);
TYPE="";';

if [[ $USE_CONVENTIONAL_COMMITS == true ]]; then
	SCRIPT+='
if [[ $TICKET == "[]" || "$MESSAGE" == "$TICKET"* ]]; then
	exit 0;
fi;

if [[ "${STAGED_STATUS_LOCATION:3:6}" == *"tests/"* ]]; then
	TYPE=" test";
elif [[ "${STAGED_STATUS_LOCATION:3:14}" == *"documentation/"* ]]; then
	TYPE=" docs";
else
	# Just grab the first staged file and check if refactor, feat, chore, docs etc.
	# this needs to be refined later, but it will suffice for now:
	if [[ "${STATUS:0:1}" == "A" ]]; then
		TYPE=" feat";
	elif [[ "${STATUS:0:1}" == "M" ]]; then
		TYPE=" refactor";
	elif [[ "${STATUS:0:1}" == "C" ]]; then
		TYPE=" fix";
	elif [[ "${STATUS:0:1}" == "R" ]]; then
		TYPE=" chore";
	fi;
fi;
';
fi;

SCRIPT+='
echo "$TICKET$TYPE: $MESSAGE" > $FILE;
exit 0;
';

printf "$SCRIPT" > $FILE_NAME;
echo "$SCRIPT";
read -p "Press 'Enter' to continue...";

# Initialize the file so git can use it to prefix git commit messages.
# If this isn't done it won't do anything.
clear;
echo_loop "Initialize file with chmod +x so it can be used to prefix commit messages" $SLEEP_TIME_DOTS "1 2";
chmod +x ./$FILE_NAME;
sleep 1;

clear;
echo "Automatic Issue Tagging has been successfuly enabled for this project!";
func_exit;
