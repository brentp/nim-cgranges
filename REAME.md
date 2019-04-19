`nimble install https://github.com/brentp/nim-cgranges

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
