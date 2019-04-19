##  The MIT License
##
##    Copyright (c) 2019 Dana-Farber Cancer Institute
##
##    Permission is hereby granted, free of charge, to any person obtaining
##    a copy of this software and associated documentation files (the
##    "Software"), to deal in the Software without restriction, including
##    without limitation the rights to use, copy, modify, merge, publish,
##    distribute, sublicense, and/or sell copies of the Software, and to
##    permit persons to whom the Software is furnished to do so, subject to
##    the following conditions:
##
##    The above copyright notice and this permission notice shall be
##    included in all copies or substantial portions of the Software.
##
##    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
##    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
##    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
##    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
##    BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
##    ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
##    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
##    SOFTWARE.
##

{.compile: "cgranges.c".}

type
  cr_ctg_t* {.bycopy.} = object
    name*: cstring             ##  a contig
    ##  name of the contig
    len*: int32              ##  max length seen in data
    root_k*: int32
    n*: int64
    off*: int64              ##  sum of lengths of previous contigs

  cr_intv_t* {.bycopy.} = object
    x*: uint64               ##  an interval
    ##  prior to cr_index(), x = ctg_id<<32|start_pos; after: x = start_pos<<32|end_pos
    y* {.bitsize: 31.}: uint32
    rev* {.bitsize: 1.}: uint32
    label*: int32            ##  NOT used

  cgranges_t* {.bycopy.} = object
    n_r*: int64
    m_r*: int64              ##  number and max number of intervals
    r*: ptr cr_intv_t           ##  list of intervals (of size _n_r_)
    n_ctg*: int32
    m_ctg*: int32            ##  number and max number of contigs
    ctg*: ptr cr_ctg_t          ##  list of contigs (of size _n_ctg_)
    hc*: pointer               ##  dictionary for converting contig names to integers

proc free*(a1: pointer) {.cdecl, importc: "free"}

##  retrieve start and end positions from a cr_intv_t object
proc cr_st*(r: ptr cr_intv_t): int32 {.inline.} =
  return (int32)(r.x shr 32)

proc cr_en*(r: ptr cr_intv_t): int32 {.inline.} =
  return cast[int32](r.x)

proc cr_start*(cr: ptr cgranges_t; i: int64): int32 {.inline.} =
  var c = cast[ptr UncheckedArray[cr_intv_t]](cr.r)[i]
  return cr_st(c.addr)
  #return cr_st(addr(cr.r[i]))

proc cr_end*(cr: ptr cgranges_t; i: int64): int32 {.inline.} =
  var c = cast[ptr UncheckedArray[cr_intv_t]](cr.r)[i]
  return cr_en(c.addr)

proc cr_label*(cr: ptr cgranges_t; i: int64): int32 {.inline.} =
  return cast[ptr UncheckedArray[cr_intv_t]](cr.r)[i].label

##  Initialize

proc cr_init*(): ptr cgranges_t {.importc.}
##  Deallocate

proc cr_destroy*(cr: ptr cgranges_t) {.importc.}
##  Add an interval

proc cr_add*(cr: ptr cgranges_t; ctg: cstring; st: int32; en: int32;
            label_int: int32): ptr cr_intv_t {.importc.}
##  Sort and index intervals

proc cr_index*(cr: ptr cgranges_t) {.importc.}
proc cr_overlap*(cr: ptr cgranges_t; ctg: cstring; st: int32; en: int32;
                b: ptr ptr int64; m_b: ptr int64): int64 {.importc.}
##  Add a contig and length. Call this for desired contig ordering. _len_ can be 0.

proc cr_add_ctg*(cr: ptr cgranges_t; ctg: cstring; len: int32): int32 {.importc.}
##  Get the contig ID given its name

proc cr_get_ctg*(cr: ptr cgranges_t; ctg: cstring): int32 {.importc.}
