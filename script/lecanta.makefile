#
# author : MichinariNukazawa / "project daisy bell"
# 	mailto: michinari.nukazawa@gmail.com
# 	https://github.com/MichinariNukazawa/
# license : 2-clause BSD license
#

FONTNAME	:= Lecanta_ScriptManeuvers
TARGET		:= releases/$(FONTNAME).otf
DATE		:= $(shell date +'%Y%m%d')

RUNE_AMN_PATH	:= ../RuneAMN_Pro_Series_Fonts
CARTELET_PATH	:= ../Cartelet
SVG_SPLITTER	:= $(RUNE_AMN_PATH)/scripts/build_mods/svg_splitter.py
SVG_RESIZER	:= $(CARTELET_PATH)/scripts/build_mods/svg_resizer.py
FONT_GENERATOR	:= $(RUNE_AMN_PATH)/scripts/build_mods/font_generate.py

# SPLITTER_FLAG is dummy target. (base svg split to svg for glyphs).
OBJECT_DIR		:= ./object
GLYPHS_SVG_DIR		:= $(OBJECT_DIR)/glyphs_$(FONTNAME)
SPLITTER_FLAG		:= $(OBJECT_DIR)/$(FONTNAME)_splitterflag.txt
WORKINGFONTFILE_PATH	:= $(OBJECT_DIR)/$(FONTNAME).otf

VERSION			:= $(DATE).0
FONT_GENERATOR_ARGS	:= $(FONTNAME) $(VERSION) \
				 1000 1000 300 no \
				 $(GLYPHS_SVG_DIR)

all: $(TARGET)

$(SPLITTER_FLAG): font_source/$(FONTNAME).svg font_source/$(FONTNAME)_*.txt
	mkdir -p $(GLYPHS_SVG_DIR)
	python3 $(SVG_SPLITTER) \
		 font_source/$(FONTNAME).svg font_source/$(FONTNAME)_list.txt \
		 --output_dir="$(GLYPHS_SVG_DIR)/"
	find "$(GLYPHS_SVG_DIR)/" -name "*.svg" | \
		xargs -L 1 python3 $(SVG_RESIZER) 2.0
	# update dummy target.
	touch $(SPLITTER_FLAG)

$(TARGET): $(BASEFONTFILE_PATH) $(SPLITTER_FLAG) font_source/$(FONTNAME)_*.txt
	mkdir -p $(shell dirname $(TARGET))
	## Central Trick!
	fontforge -lang=py -script $(FONT_GENERATOR) $(FONT_GENERATOR_ARGS)
	mv releases/$(FONTNAME)_$(VERSION).otf $(WORKINGFONTFILE_PATH)
	fontforge -lang=py -script $(CARTELET_PATH)/scripts/build_mods/rewidth_glyphs.py \
		$(WORKINGFONTFILE_PATH) \
		font_source/$(FONTNAME)_width_list.txt
#	fontforge -lang=py -script $(CARTELET_PATH)/scripts/build_mods/referenced_glyphs.py \
#		$(WORKINGFONTFILE_PATH) \
#		font_source/$(FONTNAME)_referenred_list.txt
	# success
	mv $(WORKINGFONTFILE_PATH) $(TARGET)
	# backup
	cp $(TARGET) $(TARGET)_$(DATE)

open: $(TARGET)
	fontforge $(TARGET) > /dev/null

clean:
	rm -rf $(TARGET)
	rm -rf $(OBJECT_DIR)

