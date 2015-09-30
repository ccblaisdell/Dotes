# DotaQuantify

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

## TODO
- use match_id as primary key for match
- user dotaid as primary key for user
- paginate matches and players
- batch get for individual users
- batch get for all users
- scrape dotabuff for match ids
- automate fetching of hero and item images -> dota_api?
- add new hero and items -> dota_api
- update hero and item names -> dota_api
- nice display of players and matches
