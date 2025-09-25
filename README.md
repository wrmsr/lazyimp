# Overview

Extracted from [omlish](https://github.com/wrmsr/omlish/tree/master/omlish#readme).

This library provides easy to use lazy import mechanisms powered in various ways by
[PEP-562](https://peps.python.org/pep-0562/) module-level `__getattr__` hooks.

# Mechanisms

## proxy_import

Returns anonymous `types.ModuleType` instances with `__getattr__` hooks to lazily import requested contents upon access.

For relative imports, `__package__` must be provided.

Additional 'extra' submodules to be imported may be specified with the `extras` kwarg.

Limited to importing whole modules (as opposed to importing individual items out of an imported module's globals), but
usable anywhere. The reason for this limitation is that module-level `__getattr__` hooks
[cannot be used](https://peps.python.org/pep-0562/#specification) to intercept access to intra-module globals:

> Looking up a name as a module global will bypass module __getattr__. This is intentional, otherwise calling
> __getattr__ for builtins will significantly harm performance.

As a result the module globals provided by `proxy_import` must remain 'fixed' in the globals dict. While it would be
technically possible to return 'proxy' (or otherwise radically polymorphic) objects to simulate lazy attr imports, I
don't consider that a good idea.

For typechecking and other tooling, the real imports should be diligently duplicated above the `proxy_import`s in a
conditional `TYPE_CHECKING` block.

```python
if typing.TYPE_CHECKING:
    import foo
    
    import thing.a
    import thing.b.c
    
    from . import bar
    from .baz import qux
    
else:
    foo = lazyimp.proxy_import('foo')
    
    thing = lazyimp.proxy_import('thing', extras=['a', 'b.c'])
    
    bar = lazyimp.proxy_import('.bar', __package__)
    qux = lazyimp.proxy_import('.bar.qux', __package__)
```

## auto_proxy_import

Powered by `proxy_import`, but uses the
[import capture mechanism](https://github.com/wrmsr/lazyimp/blob/master/lazyimp/capture.py) to automatically capture and
proxy imported modules. No `TYPE_CHECKING` conditional block is necessary, but still limited to importing whole modules.

```python
with lazyimp.auto_proxy_import(globals()):
    import foo
    
    import thing.a
    import thing.b.c
    
    from . import bar
    from .baz import qux
```

## proxy_init

Intended for use primarily in package `__init__.py` modules. Installs a
[lazy globals](https://github.com/wrmsr/lazyimp/blob/master/lazyimp/lazyglobals.py) module-level `__getattr__` hook and
uses it to appropriately redirect imported items to underlying anonymous `types.ModuleType` instances. Unlike
`proxy_import` it is capable of importing individual attrs from imported modules.

It is passed `globals()` for installing its hook, and thus doesn't need to be passed `__package__` for relative imports.

It may safely be called multiple times without overwriting a previously installed hook.

It supports import aliases by being passed a `(real_name, alias_name)` pair, but does not support star imports.

```python
if typing.TYPE_CHECKING:
    from math import pi, theta as not_theta
    
    from . import foo
    from .bar import baz, qux

else:
    lazyimp.proxy_init(globals(), 'math', [
        'pi',
        ('theta', 'not_theta'),
    ])

    lazyimp.proxy_init(globals(), '.foo')

    lazyimp.proxy_init(globals(), '.bar', [
        'baz',
        'qux',
    ])
```

## auto_proxy_init

Powered by `proxy_init`, but uses the
[import capture mechanism](https://github.com/wrmsr/lazyimp/blob/master/lazyimp/capture.py) to automatically capture and
proxy imported modules. As with `auto_proxy_import` no `TYPE_CHECKING` conditional block is necessary.

```python
with lazyimp.auto_proxy_init(globals()):
    from math import pi, theta as not_theta
    
    from . import foo
    from .bar import baz, qux
```
