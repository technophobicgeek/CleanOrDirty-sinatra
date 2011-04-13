Ruby/Sinatra developers, I'd appreciate any feedback you've got.

The server is very simple and spec-ed out, though the specs could perhaps be more compact. My main question here is:

- Is there a standard algorithm/convention/pattern for synchronizing data between and mobile client and a server via HTTP requests? This particular app only has one data model with a few fields, so I'm just sending a simple JSON string representation back and forth. But for more complex data models, I want syncing to be efficient and incremental. 
