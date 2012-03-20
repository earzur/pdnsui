# pdnsui

GitHub: https://github.com/earzur/pdnsui/

A PowerDNS UI ThatDoesntSuck™

## Installing

- Create a mysql database, import your data

- Configure the database in models/db_connect.rb

```bash
bundle
MODE=DEV rake server:thin
```
(you might need to 'bundle exec' depending on your configuration)

- Point your browser to: [http://localhost:7000/] (http://localhost:7000/)
- Enjoy

## Credits

Layout & CSS: [http://twitter.github.com/bootstrap/]
(http://twitter.github.com/bootstrap/)
Favicon from: [http://glyphicons.com/] (http://glyphicons.com/)
Apple touch icon from: [http://findicons.com/search/leaf] (http://findicons.com/search/leaf)
