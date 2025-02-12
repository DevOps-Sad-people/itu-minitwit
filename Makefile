init:
	ruby -r "./minitwit.rb" -e "init_db"

build:
	gcc flag_tool.c -l sqlite3 -o flag_tool

clean:
	rm flag_tool
