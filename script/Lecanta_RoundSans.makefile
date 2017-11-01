#
# author : MichinariNukazawa / "project daisy bell"
# 	mailto: michinari.nukazawa@gmail.com
# 	https://github.com/MichinariNukazawa/
# license : 2-clause BSD license
#

FONTNAME	:= Lecanta_RoundSans
TARGET		:= releases/$(FONTNAME).otf
DATE		:= $(shell date +'%Y%m%d')

RUNE_AMN_PATH	:= ../RuneAMN_Pro_Series_Fonts
CARTELET_PATH	:= ../Cartelet
SVG_SPLITTER	:= $(RUNE_AMN_PATH)/scripts/build_mods/svg_splitter.py
SVG_RESIZER	:= $(CARTELET_PATH)/scripts/build_mods/svg_resizer.py
FONT_GENERATOR	:= $(RUNE_AMN_PATH)/scripts/build_mods/font_generate.py

all: $(TARGET)

$(TARGET): font_source/$(FONTNAME).svg font_source/$(FONTNAME)_*.txt
	cp font_source/$(FONTNAME)*.svg $(RUNE_AMN_PATH)/font_source/
	cp font_source/$(FONTNAME)*.txt $(RUNE_AMN_PATH)/font_source/
	cd $(RUNE_AMN_PATH) && make
	# success
	#rm -rf font_source/$(FONTNAME)*
	mv $(RUNE_AMN_PATH)/releases/$(FONTNAME)* releases/
	# backup
	mv releases/$(FONTNAME)_1.$(DATE).otf $(TARGET)
	cp $(TARGET) $(TARGET)_$(DATE)

open: $(TARGET)
	fontforge $(TARGET) > /dev/null

clean:
	rm -rf $(TARGET)

