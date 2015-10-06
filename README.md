# Dotes

To start your Phoenix app:

  1. Install dependencies with `mix deps.get`
  2. Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  3. Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: http://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix

## API TODO
- http://dev.dota2.com/showthread.php?t=58317
- automate fetching of hero and item images -> dota_api?
- add new hero and items -> dota_api
- update hero and item names -> dota_api

## QUANTIFY TODO
- nice display of players and matches
- genserver to hold recent match ids so we don't refetch them
	- maybe some smarter way to keep from stepping on toes
	- maybe a server to manage multiuser batch operations
- try using prepared statements for match and player creation for faster inserts
- rename? Dota (API module) & Dotes?
- insert matches and players into repo from Dota.History, then update them from Dota.Match
  - faster initial load, (1 less api call)
  - slower overall (2x inserts)
  - or consider not fetching full matches at all?
