#/bin/sh

echo ''
echo '## starting itemology! ##'
echo ''

command_exists () {
    type "$1" &> /dev/null ;
}

runThisAndExit()
{
	if command_exists $1 ; then
		echo ''
		echo '#  GO!!'
		echo ''
		$1 src/main.lua;
		exit 1; 
	else
		echo '! "'$1'" not present in the system'
	fi
}

runThisAndExit './lib/moai-dev/cmake/moai/moai'
runThisAndExit 'moai'

echo ''
echo '## cant initialize itemology, cause moai was not found! ##'
echo ''