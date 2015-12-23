src = main.lua
target = gobang.zip

all:
	zip -r $(target) $(src)

clean:
	rm $(target)

run: all
	love $(target)

.PHONY: all clean run
