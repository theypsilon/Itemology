.PHONY: all

run: moai
	./moai main.lua

moai:
	./moai-dev/bin/build-linux-sdl.sh
	cp moai-dev/cmake/build/host-sdl/moai moai

test:
	@busted test/
