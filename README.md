# pdnsui

GitHub: https://github.com/earzur/pdnsui/

A PowerDNS UI ThatDoesntSuck™

## Installing

- Create a mysql database, import your data, then

```bash
bundle
rake db:configure
MODE=DEV rake server:thin
```

- Point your browser to: http://localhost:7000/
- Enjoy

