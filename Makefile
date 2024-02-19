.PHONY: all
all:
	@echo "Nothing to be done. Please use make install or make uninstall"

.PHONY: install
install:
	@echo "Installing dependencies"
	@echo
	@pkg install -y rsync
	@echo "Installing thin_to_thick"
	@echo
	@cp -Rv usr /
	@chmod +x /usr/local/bin/thin_to_thick
	@chmod +x /usr/local/bin/copy_all_jails

.PHONY: uninstall
uninstall:
	@echo "Removing thin_to_thick shell scripts"
	@echo
	@rm -v /usr/local/bin/thin_to_thick
	@rm -v /usr/local/bin/copy_all_jails
	@echo "Removing thin_to_thick examples"
	@echo
	@rm -rvf /usr/local/share/examples/thin_to_thick