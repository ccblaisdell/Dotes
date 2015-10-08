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
- automate fetching of hero and item images
  - http://elixir-lang.readthedocs.org/en/new-guides/mix/3/
  - https://github.com/phoenixframework/phoenix/blob/v1.0.3/lib/mix/tasks/phoenix.gen.model.ex
  - https://github.com/phoenixframework/phoenix/blob/v1.0.3/priv/templates/phoenix.gen.model/model.ex
  - mix dota.items
  - mix dota.heroes # make this auto update heroes from the API?
  - mix dota.images --path ./priv/static/images

## QUANTIFY TODO
- nice display of players and matches
- try using prepared statements for match and player creation for faster inserts
- replace async matches with a custom implmentation http://www.theerlangelist.com/2015/07/beyond-taskasync.html
  - right if any api call times out, the entire process crashes
  - we want to allow some to succeed and some to fail
