luajit-gumbo
============

Lua FFI binding for [gumbo-parser], an HTML5 parser written in C. It produces output in [LOM format]. An alternative is [lua-gumbo].

Usage
-----

```lua
local gumbo = require 'gumbo'
local dom = gumbo.parse '<span id="foo">bar</span>'
```

..is equivalent to..

```lua
local dom =
  { tag = 'html',
    attr = {},
    { tag = 'body',
      attr = {},
      { tag = 'span',
        attr = {
          id = 'foo',
          [1] = 'id'
        },
        'bar'
      }
    }
  }
```

Installation
------------

Gumbo will be downloaded and compiled by the Makefile.

```bash
luarocks install https://raw.github.com/pguillory/luajit-gumbo/master/rockspec/luajit-gumbo-0.1-2.rockspec
```

You can also clone this repo and run `make install` manually.

[gumbo-parser]: https://github.com/google/gumbo-parser
[LOM format]: https://matthewwild.co.uk/projects/luaexpat/lom.html
[lua-gumbo]: https://github.com/craigbarnes/lua-gumbo
