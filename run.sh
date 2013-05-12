#/bin/sh

echo ''
echo '## STARTING ITEMOLOGY ##'
echo ''

command_exists () {
    type "$1" &> /dev/null ;
}

runThisAndExit () {
	if command_exists $1 ; then
		echo '#  GO!!'
		echo ''
		$1 moai.lua;
		exit 1; 
	else
		echo '! "'$1'" not present in the system'
	fi
}

runThisAndExit './lib/moai-dev/cmake/moai/moai'
runThisAndExit 'moai'

echo ''
echo '## compiling moai... ##'
echo ''

pushd lib/moai-dev/cmake
cmake . && make
popd

runThisAndExit './lib/moai-dev/cmake/moai/moai'

echo ''
echo '## cant initialize itemology, cause moai could not be compiled! ##'
echo ''