tst:
	lua test/test_generator.lua

deploy:
	rm -rfv ~/.local/share/wesnoth/1.16/data/add-ons/Random_Symmetric_Maps/
	mkdir -pv ~/.local/share/wesnoth/1.16/data/add-ons/Random_Symmetric_Maps/
	cp -vr wml/* ~/.local/share/wesnoth/1.16/data/add-ons/Random_Symmetric_Maps/
	cp -vr lua/ ~/.local/share/wesnoth/1.16/data/add-ons/Random_Symmetric_Maps/

