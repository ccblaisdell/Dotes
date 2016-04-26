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

## QUANTIFY TODO
- let postgresql do its own IDs again. restore match_id as a String (match ids are getting too big for integers)
- nice display of players and matches
- try using prepared statements for match and player creation for faster inserts
- replace async matches with a custom implementation http://www.theerlangelist.com/2015/07/beyond-taskasync.html
  - if any api call times out, the entire process crashes
  - we want to allow some to succeed and some to fail
- access match_cache directly instead of through genserver for better concurrency

## Bugs
- we count some unfetched matches as successful
  - try Fetch All on Hoplyte's user page. After all his matches are fetched, it 
    continues to say 4 were found on successive attempts. These matches were in
    practice lobbies. 4334243, 4305066, 4221977, 4190037

