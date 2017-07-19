all:
	cp functions/j.fish ~/.config/fish/functions/
	cp completions/j.fish ~/.config/fish/completions/

uninstall:
	rm -f ~/.config/fish/functions/j.fish
	rm -f ~/.config/fish/completions/j.fish
