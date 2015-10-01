.PHONY: run test

run: moai
	./moai main.lua

moai: moai-dev
	chmod a+x moai-dev/bin/build-linux-sdl.sh
	./moai-dev/bin/build-linux-sdl.sh
	cp moai-dev/cmake/build/host-sdl/moai moai

moai-dev:
	git clone -b 1.5-stable --single-branch --depth 1 git@github.com:theypsilon/moai-dev.git
	rm -rf $(find moai-dev/ -name .git)

test:
	@busted test/
