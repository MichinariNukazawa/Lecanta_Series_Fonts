
#
# @brief proxy of lecantas makefile.
# author: Michinari.Nukazawa@gmail.com
#

all:
	$(MAKE) -f ./script/lecanta.makefile

$(MAKECMDGOALS):
	$(MAKE) -f ./script/lecanta.makefile $(MAKECMDGOALS)

package: all
	bash script/mkzip_retail_distribution.sh Lecanta 1.$(shell date +'%Y%m%d')

