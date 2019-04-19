import lapper
import cgr
import tables
import strformat
import strutils
import random
import times
import os

var
  N = 3_000_000
  chrom_size = 100_000_000
  min_interval_size = 500
  max_interval_size = 80000

type interval = object
  istart: int
  istop: int
  val: int

proc randomi(imin:int, imax:int): int =
    return imin + random(imax - imin)

proc make_random(n:int, range_max:int, size_min:int, size_max:int): seq[interval] =
  result = new_seq[interval](n)
  for i in 0..<n:
    var s = randomi(0, range_max)
    var e = s + randomi(size_min, size_max)
    result[i] = interval(istart:s, istop:e, val:i)

var intervals = make_random(N, chrom_size, min_interval_size, max_interval_size)
var other_intervals = make_random(N, 10 * chrom_size, 1, 2)


proc start(m: interval): int {.inline.} = return m.istart
proc stop(m: interval): int {.inline.} = return m.istop
proc `$`(m:interval): string = return "(start:$#, stop:$#, val:$#)" % [$m.start, $m.stop, $m.val]

var t = cpuTime()
var L = lapify(intervals)
echo "lapify time to make:", cpuTime() - t

# USE a table to mimic behavior of CGR
var tbl = newTable[string, Lapper[interval]]()
tbl["chr1"] = L
t = cpuTime()
for i in intervals:
  doAssert tbl["chr1"].count(i.start, i.stop) > 0
echo "lapify time to search with 100% hit-rate:", cpuTime() - t

t = cpuTime()
var n = 0
for i in other_intervals:
  if tbl["chr1"].count(i.start, i.stop) > 0:
    n += 1
var hr = n.float / other_intervals.len.float * 100
echo &"lapify time to search with {hr:.2f}% hit-rate:", cpuTime() - t



var c = initCGR()
t = cpuTime()
for i in intervals:
  c.add("chr1", i.istart, i.istop, i.val)
c.index
echo "CGR time to make:", cpuTime() - t

t = cpuTime()
for i in intervals:
  doAssert c.count("chr1", i.start, i.stop) > 0
echo "CGR time to search with 100% hit-rate:", cpuTime() - t

t = cpuTime()
n = 0
for i in other_intervals:
  if c.count("chr1", i.start, i.stop) > 0:
    n += 1
hr = n.float / other_intervals.len.float * 100
echo &"CGR time to search with {hr:.2f}% hit-rate:", cpuTime() - t
