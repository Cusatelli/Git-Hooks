#
# @author - Cusatelli
# @date - 4/07/2023
# @desc - N/A
#

#!/bin/sh
source command_prompt_styles.sh;
source utilities_file_handler.sh;

issue_prefix="";
issue_pattern="([#]*[\w]*[-]?[_]?[0-9])+";
use_conventional_commits=false;

set_issue_pattern() {
	issue_prefix=""; # Reset

	# FILE: command_prompt_styles.sh
	clean;
	print_character_slow false "What's the issue pattern used by your branches?";
	print_character_slow true "Example branch:";
	print_character_slow true "> 42-the-answer-to-life";
	print_character_slow true "Input your issue/branch pattern (#42): ";
	read -p "" input_issue_pattern;
	if [ "$input_issue_pattern" == "" ]; then
		return 0;
	fi;

	# FILE: command_prompt_styles.sh
	print_debug "Input Pattern: $input_issue_pattern";
	local start_position=$(echo "$input_issue_pattern" | grep -b -o '[0-9]' | head -n1 | cut -d ':' -f1);
	local end_position=$((start_position + 1));
	# FILE: command_prompt_styles.sh
	print_debug "Positions: [$start_position, $end_position]";
	
	local substring_before="${input_issue_pattern:0:end_position-1}";
	local substring_after="${input_issue_pattern:start_position}";
	print_debug 'SubString: {
		before: '$substring_before',
		after: '$substring_after'
	# FILE: command_prompt_styles.sh
	};';

	# Concatenate the substrings with the replacement
	local OUTPUT="((${substring_before})*[-]?[_]?[0-9])+";

	local PATTERN=[$(git rev-parse --abbrev-ref HEAD | grep -Eo $OUTPUT)];
	# FILE: command_prompt_styles.sh
	print_debug "PATTERN=\"$PATTERN\"";
	
	# FILE: command_prompt_styles.sh
	print_character_slow true "Example Commit Message:";
	print_character_slow true "> '$PATTERN This is a new Feature commit message.'";

	# FILE: command_prompt_styles.sh
	clean;
	print_character_slow false "Do you wish to prefix this pattern $PATTERN commit message with $substring_before?";
	
	# FILE: command_prompt_styles.sh
	print_character_slow true "New pattern will be [$substring_before${PATTERN:1} (yes): ";
	read -p "" input_prefix_pattern;
	if [ "$input_prefix_pattern" != "no" ]; then
		issue_prefix="$substring_before";
		# FILE: command_prompt_styles.sh
		print_debug "Setting issue_prefix=\"$substring_before\"";
	fi
	PATTERN=[$issue_prefix$(git rev-parse --abbrev-ref HEAD | grep -Eo $OUTPUT)];
	
	# FILE: command_prompt_styles.sh
	print_debug "PATTERN=\"$PATTERN\"";
	clean;
	print_character_slow false "Issue number found from current branch: $PATTERN";
	print_character_slow true "Example Commit Message:";
	print_character_slow true "> '$PATTERN This is a new Feature commit message.'";
	echo "";
	
	print_character_slow true "Are you happy with this pattern? (no): ";
	read -p "" input_is_happy;
	if [ "$input_is_happy" != "yes" ]; then
		# FILE: command_prompt_styles.sh
		clean;
		set_issue_pattern;
	fi

	issue_pattern=$OUTPUT;
}

set_use_conventional_commits() {
	local is_using_cc=false;

	# FILE: command_prompt_styles.sh
	clean;
	print_character_slow false "Do you wish to use the Conventional Commits v1.0.0? (no): ";
	read -p "" input_use_conventional_commits;
	if [ "$input_use_conventional_commits" == "yes" ]; then
		is_using_cc=true;
		# FILE: command_prompt_styles.sh
		print_character_slow true "Example Commit Message:"
		print_character_slow true "> '$PATTERN feat: This is a new Feature commit message.'";
	else
		is_using_cc=false;
		# FILE: command_prompt_styles.sh
		print_character_slow true "Example Commit Message:";
		print_character_slow true "> '$PATTERN This is a new Feature commit message.'";
	fi

	# FILE: command_prompt_styles.sh
	print_debug "is_using_cc is set to \"$is_using_cc\"";
	print_character_slow true "Are you happy with this format? (no): ";
	read -p "" input_is_happy;
	if [ "$input_is_happy" != "yes" ]; then
		# FILE: command_prompt_styles.sh
		clean;
		set_use_conventional_commits;
	fi;

	use_conventional_commits=$is_using_cc;
}

write_json() {
	local file_name="settings.json";
	# FILE: utilities_file_handler.sh
	# FUNC: escape_special_characters
	local json_object='{
  "SETTINGS": {
    "issue_pattern": "'"$(escape_special_characters "$1")"'",
	"issue_prefix": "'"$2"'",
    "use_conventional_commits": '$3'
  }
}
';

	# FILE: utilities_file_handler.sh
	create_file "$file_name";
	local success=$?;
	if [ $success == -1 ]; then
		print_error "Could not create file!";
	fi;

	write_file "$json_object" "$file_name";
	success=$?;
	if [ $success == -1 ]; then
		print_error "Could not write to file!";
	fi;

	# FILE: command_prompt_styles.sh
	print_debug "$json_object";
}

set_issue_pattern;
set_use_conventional_commits;
write_json "$issue_pattern" "$issue_prefix" $use_conventional_commits;

# FILE: command_prompt_styles.sh
clean;
print_character_slow false "Configuration Setup Complete!";
read -p "";
