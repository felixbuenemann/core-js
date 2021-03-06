QUnit.module 'core-js $for'
{from} = Array
test '$for' !->
  ok typeof $for is \function, 'Is function'
  ok Symbol?iterator of $for::
  set = new Set <[1 2 3 2 1]>
  iter = $for set
  ok iter instanceof $for
  ok typeof! iter[Symbol?iterator]! is 'Set Iterator'
  deepEqual <[1 2 3]>, from iter
test '$for#filter' !->
  ok typeof $for::filter is \function, 'Is function'
  set = new Set <[1 2 3 2 1]>
  iter = $for set .filter (% 2)
  ok iter instanceof $for
  deepEqual <[1 3]>, from iter
  deepEqual [[1 2]], from $for([1 2 3]entries!, on).filter (k, v)-> k % 2
  $for [1] .filter ->
    ok @ is o
  , o = {}
test '$for#map' !->
  ok typeof $for::map is \function, 'Is function'
  set = new Set <[1 2 3 2 1]>
  iter = $for set .map (* 2)
  ok iter instanceof $for
  deepEqual [2 4 6], from iter
  deepEqual [[0 1], [2 4], [4 9]], from $for([1 2 3]entries!, on).map (k, v)-> [k * 2, v * v]
  $for [1] .map ->
    ok @ is o
  , o = {}
test '$for#array' !->
  ok typeof $for::array is \function, 'Is function'
  set = new Set [1 2 3 2 1]
  deepEqual([[1 1], [2 2], [3 3]], $for set.entries! .array!)
  deepEqual([2 4 6], $for set .array (* 2))
  deepEqual([[0 1], [2 4], [4 9]], $for([1 2 3]entries!, on).array (k, v)-> [k * 2, v * v])
  $for [1] .array ->
    ok @ is o
  , o = {}
test '$for#of' !->
  ok typeof $for::of is \function, 'Is function'
  set = new Set <[1 2 3 2 1]>
  counter1 = 0
  string1  = ''
  # get iterator from iterable object
  $for set .of !->
    counter1++
    string1 += it
  ok counter1 is 3
  ok string1 is \123
  counter2 = 0
  string2  = ''
  # use iterator
  $for set.entries! .of !->
    counter2++
    string2 += it[0] + it[1]
  ok counter2 is 3
  ok string2 is \112233
  # additional args
  $for [1]entries!, on  .of (key, val)->
    ok @ is o
    ok key is 0
    ok val is 1
  , o = {}
test '$for chaining' !->
  deepEqual([2, 10], $for [1 2 3]
    .map (^ 2)
    .filter (% 2)
    .map (+ 1)
    .array!)
  deepEqual([[1, 1], [3, 9]], $for [1 2 3]entries!, on
    .map (k, v)-> [k, v ^ 2]
    .filter (k, v)-> v % 2
    .map (k, v)-> [k + 1, v]
    .array!)
  
test '$for.isIterable' !->
  {isIterable} = $for
  ok typeof isIterable is \function, 'Is function'
  ok !isIterable {}
  ok isIterable []
  ok isIterable (->&)!
  
  _Symbol = Symbol
  I = Math.random!
  o = {0: \a, 1: \b, 2: \c, length: 3}
  o[I] = Array::values
  ok !isIterable o
  global.Symbol = {iterator: I}
  ok isIterable o
  global.Symbol = _Symbol
  ok !isIterable o
  
test '$for.getIterator' !->
  {getIterator} = $for
  ok typeof getIterator is \function, 'Is function'
  throws (!-> getIterator {}), TypeError
  iter = getIterator []
  ok \next of iter
  iter = getIterator (->&)!
  ok \next of iter
  
  _Symbol = Symbol
  I = Math.random!
  O = {0: \a, 1: \b, 2: \c, length: 3}
  O[I] = Array::values
  throws (!-> getIterator O), TypeError
  global.Symbol = {iterator: I}
  try
    getIterator O
    ok on
  catch => ok no
  deepEqual from(O), <[a b c]>
  global.Symbol = _Symbol
  throws (!-> getIterator O), TypeError