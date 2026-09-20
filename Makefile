# Deploy dotfiles with GNU Stow.

# Every top-level directory is a stow package except:
EXCLUDE := portage
PKGS := $(filter-out $(EXCLUDE),$(patsubst %/,%,$(wildcard */)))

.PHONY: deploy undeploy redeploy check list

deploy:
	stow --dotfiles $(PKGS)

undeploy:
	stow --dotfiles -D $(PKGS)

redeploy:
	stow --dotfiles -R $(PKGS)

check:
	stow --dotfiles -n -v $(PKGS)

list:
	@echo $(PKGS)

test:
	@echo $(wildcard */)
