#!/bin/bash
source command_prompt_styles.sh;

file_exist() {
	local file_name="$1";
	if [ -e "$file_name" ]; then
		print_character_slow false "File: "$file_name" already exists.";
		return 1;
	fi

	return 0;
}

read_file() {
	local format="$1";
	return 0;
}

read_file_json() {
	# Read the JSON file content
	# Get the directory path of the script
	local script_dir="$(dirname "$1")"; # --> $0
	# Concatenate the file name to the directory path
	local settings_file="$script_dir/settings.json";
	
	# Read the contents of the settings file
	return $(cat "$settings_file");

	# Extract values using string manipulation
	# return $settings;
	# ISSUE_PATTERN=$(grep -oP '(?<=ISSUE_PATTERN": ")[^"]*' <<< "$settings");
	# ISSUE_PREFIX=$(grep -oP '(?<=ISSUE_PREFIX": ")[^"]*' <<< "$settings");
	# USE_CONVENTIONAL_COMMITS=$(grep -oP '(?<=USE_CONVENTIONAL_COMMITS": )[^,}]*' <<< "$settings");
}

get_data_from_json() {
	local json_file=$1;
	local type="$2";
	local variable_name="$3";
	local pattern='"[^"]*"';
	# Extract values using string manipulation
	if [ "$type" == "boolean" || "$type" == "integer" ]; then
		pattern='[^,}]*';
	elif [ "$type" == "string" ]; then
		pattern='"[^"]*"';
	fi;

	return $(grep -oP "(?<=$variable_name\": \")$pattern" <<< "$json_file");
}

write_file() {
	local file_content="$1";
	local file_name="$2";
	file_exist "$file_name";
	local does_exist=$?;

	if [[ $does_exist == 1 ]]; then
		printf "$file_content" > $file_name;
		return 1;
	fi;

	return -1;
}

create_file() {
	local file_name="$1";
	file_exist "$file_name";
	local does_exist=$?;
	if [[ $does_exist == 1 ]]; then
		print_character_slow true "Would you like to override contents of file? (no): ";
		read -p "" input_override_contents;
		if [ "$input_override_contents" != "yes" ]; then
			return 0;
		fi
		return 0;
	fi

	# Create File in .git hooks directory
	print_character_slow false "File does not exist. Creating $file_name";
	touch "$file_name";
	print_character_slow true "File: $file_name created.";
	return 1;
}

delete_file() {
	return -1;
}

escape_special_characters() {
	local value="$1";

	# Escape special characters: \
	# Do slash twice for JSON file:
	value="${value//\\/\\\\}";
	value="${value//\\/\\\\}";

	# Escape special characters: " /
	value="${value//\"/\\\"}";
	value="${value//\//\\/}";
	
	# Return (std-out):
	printf "$value"; # when using printf instead of return make sure you wrap the func in $().
}
