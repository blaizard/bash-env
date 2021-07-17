# Only output to interactive shell. This is important as some commadn might need a clean
# stdout, for example rsync...
if echo "$-" | grep i > /dev/null; then
	echo -n "Setting-up bash environment..."
fi

# Import aliases
test -s ~/.alias && . ~/.alias || true

# Import local configuration if any
test -s ~/.bashrc.local && . ~/.bashrc.local || true

# Only output to interactive shell.
if echo "$-" | grep i > /dev/null; then

	# Load command line fuzzy finder
	if [ -f ~/.fzf.bash ]; then
		source ~/.fzf.bash
	else
		echo "Command line fuzzy finder (fzf) is not installed."
	fi

	# Set the prompt
	parse_git_branch()
	{
		branch=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
		if [ ! -z "${branch}" ]; then
			origin=`git for-each-ref --format='%(upstream:short)' $(git symbolic-ref -q HEAD) 2> /dev/null | head -n1`
			extra=""
			if [ ! -z "${origin}" ]; then
				distance=`git rev-list --left-right --count ${origin}...${branch} 2> /dev/null`
				if [ ! -z "${distance}" ]; then
					behind=`echo -n "${distance}" | awk '{print $1}'`
					ahead=`echo -n "${distance}" | awk '{print $2}'`
					if [ ${behind} -gt 0 ]; then extra=" -${behind}"; fi
					if [ ${ahead} -gt 0 ]; then extra="${extra} +${ahead}"; fi
				fi
			fi
			echo -en " (${branch}${extra})"
		fi
	}
	export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "

	echo -e "\tdone"
fi
