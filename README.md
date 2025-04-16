# Raffley


## 🗃️ Database

The local database is being ran with a pod using podman.

```bash
podman run --rm -p 5432:5432 -e POSTGRES_PASSWORD=mysecretpassword -e POSTGRES_DB=raffley_dev -v $HOME/pods/raffley:/var/lib/postgresql/data postgres -d postgres
```

## 🌐 Web Server

Start interactive server

```
iex -S mix phx.server
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.


