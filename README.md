* Linux
* Windows
* OSX

## Description
A Ruby interface for getting memory information.

## Installation
`gem install sys-memory`

## Synopsis
```
require 'sys-memory'

p Sys::Memory.memory                # Hash of all information

p Sys::Memory.total                 # Total memory, no swap
p Sys::Memory.total(extended: true) # Total memory, include swap
```

There's also the `free`, `used` and `load` module methods.

## Adding the trusted cert
`gem cert --add <(curl -Ls https://raw.githubusercontent.com/djberg96/sys-memory/ffi/certs/djberg96_pub.pem)`

## Known Bugs
None that I'm aware of. Please report bugs on the project page at:

https://github.com/djberg96/sys-cpu

## License
Apache-2.0

## Copyright
(C) 2021 Daniel J. Berger, All Rights Reserved

## Warranty
This package is provided "as is" and without any express or
implied warranties, including, without limitation, the implied
warranties of merchantability and fitness for a particular purpose.

## Author
Daniel J. Berger
