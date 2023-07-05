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

IS_DEBUG_MODE=true;
SLEEP_TIME_DOTS=0.03;
GIT_HOOKS_DIRECTORY="../.git/hooks";
FILE_NAME="prepare-commit-msg";

EXIT_MESSAGE="Press 'Enter' to exit...";

clean() {
	if [ $IS_DEBUG_MODE == false ]; then
		clear;
	fi;
}

print_character_slow() {
	local input_string="$1"
	local length=${#input_string}

	for ((i = 0; i < length; i++)); do
		local character="${input_string:i:1}"
		printf "$character"
		sleep 0.00001;
	done
}

func_exit() {
	echo "";
	echo "";
	print_character_slow "$EXIT_MESSAGE"
	read -p "";
}

dotdot() {
	printf ".";
	sleep $SLEEP_TIME_DOTS;
	printf ".";
	sleep $SLEEP_TIME_DOTS;
	printf ".";
	sleep $SLEEP_TIME_DOTS;
}

clean;
print_character_slow "Navigating to $GIT_HOOKS_DIRECTORY directory.";
cd $GIT_HOOKS_DIRECTORY

clean;
if [ -e "$FILE_NAME" ]; then
	echo "";
    print_character_slow "File: "$FILE_NAME" already exists.";
	echo "";
	print_character_slow "Would you like to override contents of file? (no): "
	read -p "" INPUT_OVERRIDE_CONTENT;
	if [ "$INPUT_OVERRIDE_CONTENT" != "yes" ]; then
		func_exit;
		exit 0;
	fi
else
	# Create File in .git hooks directory
	echo "";
	print_character_slow "File does not exist. Creating $FILE_NAME"
	dotdot;
    touch "$FILE_NAME";
	echo "";
    print_character_slow "File: $FILE_NAME created.";
fi

# Write the bash script to the new file. (To read it replace surrounding quotes and all "\n" with "new lines" in vs-code)
clean;

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

if [ $IS_DEBUG_MODE == true ]; then
	echo "[DEBUG] ISSUE_PATTERN=$ISSUE_PREFIX $USE_CONVENTIONAL_COMMITS";
	echo "[DEBUG] ISSUE_PREFIX=$ISSUE_PREFIX $USE_CONVENTIONAL_COMMITS";
	echo "[DEBUG] USE_CONVENTIONAL_COMMITS=$ISSUE_PREFIX $USE_CONVENTIONAL_COMMITS";
fi;
echo "";
print_character_slow "Writing bash-script to newly created $FILE_NAME file"
dotdot;
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
if [ $IS_DEBUG_MODE == true ]; then
	echo "$SCRIPT";
fi;

echo "";
print_character_slow "Press 'Enter' to continue...";
read -p "";

# Initialize the file so git can use it to prefix git commit messages.
# If this isn't done it won't do anything.
clean;
print_character_slow "Initialize file with chmod +x so it can be used to prefix commit messages"
dotdot;
echo "";
chmod +x ./$FILE_NAME;
sleep 1;

clean;
print_character_slow "Automatic Issue Tagging has been successfuly enabled for this project!";
func_exit;
