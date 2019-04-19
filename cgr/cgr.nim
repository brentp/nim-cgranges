import ./cgrsys

type CGR* = ref object
  c: ptr cgranges_t
  must_index: bool
  b: ptr int64
  n_b: int64

proc destroy_cgr(c: CGR) =
  if c != nil and c.c != nil:
    cr_destroy(c.c)
    free(c.b)
    c.c = nil

proc initCGR*(): CGR =
  ## create a new CGR object
  new(result, destroy_cgr)
  result.c = cr_init()
  result.must_index = true

proc add*(c:CGR, contig: string, start: int32|int, stop: int32|int, idx: int32|int) {.inline.} =
  ## add position to a CGR
  doAssert c.must_index
  doAssert c.c.cr_add(contig, start.int32, stop.int32, idx.int32) != nil

proc index*(c:CGR) =
  ## index the CGR. this must be done before getting overlaps.
  cr_index(c.c)
  c.must_index = false

type interval* = object
  start*:int32
  stop*:int32
  label*:int32

iterator overlap*(c:CGR, contig: string, start:int32, stop: int32): interval =
  doAssert not c.must_index
  for i in 0..<cr_overlap(c.c, contig, start, stop, c.b.addr, c.n_b.addr):
    var cp = cast[ptr UncheckedArray[int64]](c.b)[i]
    yield interval(start:c.c.cr_start(cp),
                   stop:c.c.cr_end(cp),
                   label: c.c.cr_label(cp))

proc count*(c:CGR, contig: string, start:int32, stop: int32): int {.inline.} =
  ## count number of overlaps in given region.
  doAssert not c.must_index
  return cr_overlap(c.c, contig, start, stop, c.b.addr, c.n_b.addr).int

when isMainModule:

  import unittest
  var tree = initCGR()

  tree.add("chr1", 22, 33, 0)
  tree.add("chr1", 28, 45, 1)
  tree.add("chr1", 2, 5, 2)
  tree.index()

  suite "cgrsuite":
    test "that 2 intervals overlap":
      var i = 0
      for v in tree.overlap("chr1", 25, 29):
        if i == 0:
          check v.start == 22
          check v.stop == 33
        else:
          check v.start == 28
          check v.stop == 45
        i += 1
    test "that bookends don't overlap":
      var i = 0
      for v in tree.overlap("chr1", 1, 2):
        i += 1
      check i == 0

    test "that first interval overlaps":
      for v in tree.overlap("chr1", 1, 3):
        check v.start == 2
        check v.label == 2

    test "that differnt chromosome does not overlap":
      var i = 0
      for v in tree.overlap("chr2", 1, 3):
        i += 1
      check i == 0

    test "count":
      check tree.count("chr1", 25, 29) == 2
      check tree.count("chr1", 15, 19) == 0
      check tree.count("chr1", 1, 900000000) == 3
