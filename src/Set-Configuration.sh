#
# @author - Cusatelli
# @date - 4/07/2023
# @desc - N/A
#

#!/bin/sh
IS_DEBUG_MODE=true;
ISSUE_PREFIX="";
ISSUE_PATTERN="([#]*[\w]*[-]?[_]?[0-9])+";
USE_CONVENTIONAL_COMMITS=false;

print_character_slow() {
	local input_string="$1"
	local length=${#input_string}

	for ((i = 0; i < length; i++)); do
		local character="${input_string:i:1}"
		printf "$character"
		sleep 0.005;
	done
}

set_issue_pattern() {
	ISSUE_PREFIX=""; # Reset

	# clear;
	echo "What's the issue pattern used by your branches?";
	echo "Example branch:"
	printf "> ";
	print_character_slow "42-the-answer-to-life" "";
	echo "";
	read -p "Input your issue/branch pattern (#42): " input_issue_pattern;
	if [ "$input_issue_pattern" != "" ]; then
		echo "$input_issue_pattern"
		start_position=$(echo "$input_issue_pattern" | grep -b -o '[0-9]' | head -n1 | cut -d ':' -f1);
		end_position=$((start_position + 1));
		
		substring_before="${input_issue_pattern:0:end_position-1}";
		substring_after="${input_issue_pattern:start_position}";

		# Concatenate the substrings with the replacement
		OUTPUT="((${substring_before})*[-]?[_]?[0-9])+";

		PATTERN=[$(git rev-parse --abbrev-ref HEAD | grep -Eo $OUTPUT)];
		echo "Example Commit Message:"
		echo "> '$PATTERN This is a new Feature commit message.'";
		sleep 1;

		# clear;
		# read -p "Is the key of the ticket always $substring_before? (yes): " input_always_same_key;
		# if [ "$input_always_same_key" == "no" ]; then
		# 	OUTPUT="([#]*[\w]*[-]?[_]?[0-9])+";
		# fi
		# clear;
		echo "Do you wish to prefix this pattern $PATTERN commit message with $substring_before?";
		read -p "New pattern will be [$substring_before${PATTERN:1} (yes): " input_prefix_pattern;
		if [ "$input_prefix_pattern" != "no" ]; then
			ISSUE_PREFIX="$substring_before";
		fi
		PATTERN=[$ISSUE_PREFIX$(git rev-parse --abbrev-ref HEAD | grep -Eo $OUTPUT)];

		# clear;
		echo "Issue number found from current branch: $PATTERN";
		echo "Example Commit Message:"
		echo "> '$PATTERN This is a new Feature commit message.'";
		echo "";
		sleep 1;
		read -p "Are you happy with this pattern? (no): " input_is_happy;
		if [ "$input_is_happy" != "yes" ]; then
			# clear;
			set_issue_pattern;
		fi

		ISSUE_PATTERN=$OUTPUT;
	fi
}

set_use_conventional_commits() {
	is_using_conv_commits=false;
	# clear;
	read -p "Do you wish to use the Conventional Commits v1.0.0? (no): " input_use_conventional_commits;
	if [ "$input_use_conventional_commits" == "yes" ]; then
		is_using_conv_commits=true;
		echo "Example Commit Message:"
		echo "> '$PATTERN feat: This is a new Feature commit message.'";
	else
		is_using_conv_commits=false;
		echo "Example Commit Message:";
		echo "> '$PATTERN This is a new Feature commit message.'";
	fi

	read -p "Are you happy with this format? (no): " input_is_happy;
	if [ "$input_is_happy" != "yes" ]; then
		# clear;
		set_use_conventional_commits;
	fi

	USE_CONVENTIONAL_COMMITS=$is_using_conv_commits;
}

escape_special_characters() {
	value="$1";

	# Escape special characters: \
	# Do slash twice for JSON file:
	value="${value//\\/\\\\}";
	value="${value//\\/\\\\}";

	# Escape special characters: " /
	value="${value//\"/\\\"}";
	value="${value//\//\\/}";
	
	# Return (std-out):
	echo "$value";
}

write_json() {
	FILE_NAME="settings.json";
	JSON_OBJECT='{
  "SETTINGS": {
    "ISSUE_PATTERN": "'"$(escape_special_characters "$1")"'",
	"ISSUE_PREFIX": "'"$2"'",
    "USE_CONVENTIONAL_COMMITS": '$3'
  }
}
'
	if [ $IS_DEBUG_MODE ]; then
		# clear;
		echo "$JSON_OBJECT";
	fi;

	printf "$JSON_OBJECT" > $FILE_NAME;
}

set_issue_pattern;
set_use_conventional_commits;
write_json "$ISSUE_PATTERN" "$ISSUE_PREFIX" $USE_CONVENTIONAL_COMMITS;

clear;
read -p "Configuration Setup Complete!";
