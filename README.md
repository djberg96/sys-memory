[![Ruby](https://github.com/djberg96/sys-memory/actions/workflows/ruby.yml/badge.svg)](https://github.com/djberg96/sys-memory/actions/workflows/ruby.yml)

## Description
A Ruby interface for getting memory information.

## Supported Platforms
* Linux
* Windows
* OSX
* BSD

Note that only DragonflyBSD has been tested. I am not sure about other flavors yet.

## Installation
`gem install sys-memory`

## Adding the trusted cert
`gem cert --add <(curl -Ls https://raw.githubusercontent.com/djberg96/sys-memory/main/certs/djberg96_pub.pem)`

## Synopsis
```ruby
require 'sys-memory'

p Sys::Memory.memory                # Hash of all information

p Sys::Memory.total                 # Total memory, no swap
p Sys::Memory.total(extended: true) # Total memory, include swap
```

There's also the `free`, `used` and `load` module methods.

## Notes
I realize there are some philosophical differences about what constitutes
"available memory". I've tried to accomodate both of the common approaches to
it that I saw debated online. In short, you can choose to include swap memory
as part of memory calculations or not as you see fit via an optional argument.

You can also just use `Sys::Memory.memory` and collate the various hash data
pieces as you see fit.

## Known Bugs
None that I'm aware of. Please report bugs on the project page at:

https://github.com/djberg96/sys-memory

## License
Apache-2.0

## Copyright
(C) 2021-2024 Daniel J. Berger, All Rights Reserved

## Warranty
This package is provided "as is" and without any express or
implied warranties, including, without limitation, the implied
warranties of merchantability and fitness for a particular purpose.

## Author
Daniel J. Berger
