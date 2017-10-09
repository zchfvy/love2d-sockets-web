An example of Networking in love.js
===================================

This is an example of how to use networking in [love.js](https://github.com/TannerRogalsky/love.js)

Usage
=====

First you must install [lua-websockets](https://github.com/lipp/lua-websockets) to run the server

To setup simply do the following:
```
git clone https://github.com/zchfvy/love2d-sockets-web.git
git clone https://github.com/TannerRogalsky/love.js.git
cd love2d-sockets-web
./build.py build
```

Next start the server:
```
lua ./websock.lua
```

And in a separate terminal start the client
```
./build.py run
```

Voila! A browser window should pop open with the example running.
Open more windows to test out he multiplayer aspect!
