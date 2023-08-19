###################################################################
# Installing zram.sh to /usr/bin directory.
###################################################################

PREFIX=/usr/bin

install:
	cp zram.sh $(PREFIX)
	chmod +x $(PREFIX)/zram.sh
