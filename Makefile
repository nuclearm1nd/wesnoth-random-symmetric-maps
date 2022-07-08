.PHONY: test print lua deploy
ADDON_DIR := ~/.local/share/wesnoth/1.16/data/add-ons/Random_Symmetric_Maps/
SRCS := $(wildcard fnl/*.fnl)
TST  := $(wildcard test/*_test.fnl)
OUTS := $(SRCS:fnl/%.fnl=lua/%.lua)

test: $(TST)
	fennel $?

lua-dir:
	mkdir -pv lua/

clean-lua:
	rm -rfv lua/

lua/%.lua: fnl/%.fnl
	fennel --compile $< > $@

lua: clean-lua lua-dir $(OUTS)

clean-addon:
	rm -rfv $(ADDON_DIR)

deploy: clean-addon lua
	mkdir -pv    $(ADDON_DIR)
	cp -vr wml/* $(ADDON_DIR)
	cp -vr lua/  $(ADDON_DIR)

