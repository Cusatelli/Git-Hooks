#!/bin/bash
is_debug_mode=false;
is_fast_mode=true;

clean() {
	if [ $is_debug_mode == false ]; then
		clear;
	fi;
}

print_character_slow() {
	local start_with_newline=$1;
	local input_string="$2"
	local length=${#input_string};

	if [ $start_with_newline == true ]; then
		echo "";
	fi;

	if [ $is_fast_mode == true ]; then
		printf "$input_string";
		return 0;
	fi;

	for ((i = 0; i < length; i++)); do
		local character="${input_string:i:1}"
		printf "$character"
		sleep 0.00001;
	done
	return 1;
}

func_exit() {
	echo "";
	print_character_slow true "$EXIT_MESSAGE"
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

print_error() {
	echo "";
	printf "[ERROR] ";
	for arg in "$@"; do
		printf "$arg "
	done;
	echo "";
}

print_debug() {
	if [ $is_debug_mode == false ]; then
		return 0;
	fi;
	
	echo "";
	printf "[DEBUG] ";
	for arg in "$@"; do
		printf "$arg "
	done;
	echo "";
}
