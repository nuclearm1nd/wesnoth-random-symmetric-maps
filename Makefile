.PHONY: test print lua deploy
ADDON_DIR := ~/.local/share/wesnoth/1.16/data/add-ons/Random_Symmetric_Maps/
SRCS := $(wildcard fnl/*.fnl)
TST  := ./test
OUTS := $(SRCS:fnl/%.fnl=lua/%.lua)

test: $(TST)/*_test.fnl
	@for file in $^ ; do \
	  fennel $${file} ; \
	done

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

