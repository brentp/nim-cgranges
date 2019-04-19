# Package

version = "0.0.1"
description   = "nim wrapper for https://github.com/lh3/cgranges"
author        = "Brent Pedersen"
license       = "MIT"
#installFiles  = @["src/kexpr.nim", "src/kexpr-c.c", "src/kexpr-c.h"]
#
srcDir = "cgr"

requires "nim >= 0.19.0"

task test, "tests":
    exec "nim c -r cgr/cgr.nim"

task docs, "make the docs":
    exec "nim doc cgr/cgr.nim"
    exec "mkdir -p docs; mv cgr.html docs/index.html"
