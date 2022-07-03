destroy_nwfilter() {
	nwfilter_name="$1"
	virsh nwfilter-destroy "${nwfilter_name}"
}

undefine_nwfilter() {
	nwfilter_name="$1"
	virsh nwfilter-undefine "${nwfilter_name}"
}

define_nwfilter() {
	nwfilter_file="$1"
	virsh nwfilter-define "${nwfilter_file}"
}

get_nwfilter_name() {
	nwfilter_file="$1"

	# Match any filter except for filterref lines (should yield a single definition line)
	regex_match_filter=$(grep '<\s*filter' ${nwfilter_file} | grep -v 'filterref')
	
	regex_match_filter_single_spaced=$(echo "$regex_match_filter" | sed -e "s/[[:space:]]\+/ /g" -)
	
	# Split on space into array
	array=( ${regex_match_filter_single_spaced} )

	for iter in "${array[@]}"; do
		grep_name=$(echo "$iter" | grep 'name')
		if [ -n "$grep_name" ]; then
			filter_name_definition="$grep_name"
		fi
	done

	if [ -z "$filter_name_definition" ]; then
		echo 'Error no name field'
		exit 1;
	fi

	# Gets last character of the above match (an ' or ")
	filter_name_quote="${filter_name_definition: -1}"

	echo "$filter_name_definition" | cut -d "$filter_name_quote" -f 2
}

redefine_nwfilter() {
	nwfilter_file="$1"

	nwfilter_name=$(get_nwfilter_name "$nwfilter_file")

	echo --------

	destroy_nwfilter "$nwfilter_name" 2>/dev/null
	undefine_nwfilter "$nwfilter_name" 2>/dev/null

	define_nwfilter "$nwfilter_file"
}

import_path="$1"

if [ -z "$import_path" ]; then
	echo "Must provide an import path (e.g. '.')"
	exit 1
fi

nwfilter_file_array="$(find "${import_path}" -type f -name nwfilter-\*.xml)"

for iter in ${nwfilter_file_array[@]}; do
	redefine_nwfilter $iter
done
