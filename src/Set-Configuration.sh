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

set_issue_pattern() {
	ISSUE_PREFIX=""; # Reset

	clean;
	print_character_slow "What's the issue pattern used by your branches?";
	echo "";
	print_character_slow "Example branch:"
	echo "";
	print_character_slow "> 42-the-answer-to-life";
	echo "";
	echo "";
	print_character_slow "Input your issue/branch pattern (#42): "
	read -p "" input_issue_pattern;
	if [ "$input_issue_pattern" == "" ]; then
		return;
	fi;

	echo "$input_issue_pattern"
	start_position=$(echo "$input_issue_pattern" | grep -b -o '[0-9]' | head -n1 | cut -d ':' -f1);
	end_position=$((start_position + 1));
	if [ $IS_DEBUG_MODE ]; then
		echo "[DEBUG] positions=[$start_position, $end_position]";
	fi;
	
	substring_before="${input_issue_pattern:0:end_position-1}";
	substring_after="${input_issue_pattern:start_position}";
	if [ $IS_DEBUG_MODE ]; then
		printf '[DEBUG]
	substring: {
		before: '$substring_before',
		after: '$substring_after'
	};';
		echo "";
	fi;

	# Concatenate the substrings with the replacement
	OUTPUT="((${substring_before})*[-]?[_]?[0-9])+";

	PATTERN=[$(git rev-parse --abbrev-ref HEAD | grep -Eo $OUTPUT)];
	if [ $IS_DEBUG_MODE ]; then
		echo "[DEBUG] PATTERN=\"$PATTERN\"";
	fi;
	echo "";
	print_character_slow "Example Commit Message:"
	echo "";
	print_character_slow "> '$PATTERN This is a new Feature commit message.'";
	sleep 1;

	clean;
	print_character_slow "Do you wish to prefix this pattern $PATTERN commit message with $substring_before?";
	echo "";
	print_character_slow "New pattern will be [$substring_before${PATTERN:1} (yes): "
	read -p "" input_prefix_pattern;
	if [ "$input_prefix_pattern" != "no" ]; then
		ISSUE_PREFIX="$substring_before";
		if [ $IS_DEBUG_MODE ]; then
			echo "[DEBUG] Setting ISSUE_PREFIX=\"$substring_before\"";
		fi;
	fi
	PATTERN=[$ISSUE_PREFIX$(git rev-parse --abbrev-ref HEAD | grep -Eo $OUTPUT)];
	if [ $IS_DEBUG_MODE ]; then
		echo "[DEBUG] PATTERN=\"$PATTERN\"";
	fi;

	clean;
	print_character_slow "Issue number found from current branch: $PATTERN";
	echo "";
	print_character_slow "Example Commit Message:"
	echo "";
	print_character_slow "> '$PATTERN This is a new Feature commit message.'";
	echo "";
	echo "";
	print_character_slow "Are you happy with this pattern? (no): ";
	read -p "" input_is_happy;
	if [ "$input_is_happy" != "yes" ]; then
		clean;
		set_issue_pattern;
	fi

	ISSUE_PATTERN=$OUTPUT;
}

set_use_conventional_commits() {
	is_using_conv_commits=false;
	clean;
	print_character_slow "Do you wish to use the Conventional Commits v1.0.0? (no): "
	read -p "" input_use_conventional_commits;
	if [ "$input_use_conventional_commits" == "yes" ]; then
		is_using_conv_commits=true;
		echo "";
		print_character_slow "Example Commit Message:"
		echo "";
		print_character_slow "> '$PATTERN feat: This is a new Feature commit message.'";
	else
		is_using_conv_commits=false;
		echo "";
		print_character_slow "Example Commit Message:";
		echo "";
		print_character_slow "> '$PATTERN This is a new Feature commit message.'";
	fi

	if [ $IS_DEBUG_MODE ]; then
		echo "[DEBUG] is_using_conv_commits is set to \"$is_using_conv_commits\"";
	fi;

	echo "";
	print_character_slow "Are you happy with this format? (no): "
	read -p "" input_is_happy;
	if [ "$input_is_happy" != "yes" ]; then
		clean;
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
		echo "$JSON_OBJECT";
	fi;

	printf "$JSON_OBJECT" > $FILE_NAME;
}

set_issue_pattern;
set_use_conventional_commits;
write_json "$ISSUE_PATTERN" "$ISSUE_PREFIX" $USE_CONVENTIONAL_COMMITS;

clean;
print_character_slow "Configuration Setup Complete!"
read -p "";
