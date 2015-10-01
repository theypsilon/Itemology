.PHONY: all

moai:
	./moai-dev/bin/build-linux-sdl.sh
	ln -s moai-dev/cmake/build/host-sdl/moai moai

test:
	@busted test/

run:
	./moai main.lua