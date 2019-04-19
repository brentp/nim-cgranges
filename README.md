`nimble install https://github.com/brentp/nim-cgranges`

The code below demonstrates the entirety of the API, but
docs are also available [here](https://brentp.github.io/nim-cgranges/)

```Nim
  import cgr
  var tree = initCGR()

  tree.add("chr1", 22, 33, 0)
  tree.add("chr1", 28, 45, 1)
  tree.add("chr1", 2, 5, 2)
  tree.index()

  for v in tree.overlap("chr1", 25, 29):
     echo v.start, " ", v.stop, " ", v.label

  assert tree.count("chr1", 25, 29) == 2
  # different chromosome
  assert tree.count("chr2", 25, 29) == 0
```


## Speed

preliminary timings relative to [lapper](https://github.com/brentp/nim-lapper) which uses an array
sorted by start along with knowledge of the longest interval:

```
lapify time to make:0.8376100260000001
lapify time to search with 100% hit-rate:16.802157967
lapify time to search with 10.04% hit-rate:3.384523169000001
CGR time to make:0.1248294489999999
CGR time to search with 100% hit-rate:26.677901295
CGR time to search with 10.04% hit-rate:4.667564442999996
```

code in: https://github.com/brentp/nim-cgranges/blob/master/tests/speed2.nim

