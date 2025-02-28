run:
	docker compose up -d

build:
	gcc flag_tool.c -l sqlite3 -o flag_tool

clean:
	rm flag_tool
