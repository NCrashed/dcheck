DCheck
======
[![Build Status](https://travis-ci.org/NCrashed/dcheck.svg?branch=master)](https://travis-ci.org/NCrashed/dcheck)

Library for generating random data sets and automated checking of test constraints. The library design is inspired by Haskell one - [QuickCheck](http://www.haskell.org/haskellwiki/Introduction_to_QuickCheck2). User define `Arbitrary` template (behaves like typeclass in haskell) for a type to add random generating feature and result shrinking. Then the library can pass random sets of data into special functions called constraints and provide you fancy formatted minimal fail case.

Usage
=====
First, consider simple example:
```D
unittest
{
  checkConstraint!((int a, int b) => a + b == b + a);
}
```
As the provided delegate is always true unittest passes clearly.

Negative result example:
```D
unittest
{
  import std.math;
  checkConstraint!((int a, int b) => abs(a) < 100 && abs(b) < 100)
}
```
DCheck will find the fail case:
```
==============================
Constraint __lambda2 is failed!
Calls count: 1. Shrinks count: 24
Parameters: 
        0: int ""  = -61
        1: int ""  = -30
```
Result shrinking is performed to provide you concise fail case.

DCheck can detect parameter names for regular functions:
```D
bool foo(bool a, bool b)
{
  return a && !b;
}

unittest
{
  checkConstraint!foo;
}
```
Output:
```
core.exception.AssertError: 
==============================
Constraint foo is failed!
Calls count: 1. Shrinks count: 0
Parameters: 
	0: bool "a"  = true
	1: bool "b"  = true
```

Building
========
To use DCheck as dependency in your project add the following in your `dub.json` file:
```JSON
"dependencies": {
  "dcheck": ">=0.1.0"
}
```

To run unittests, clone the repo and run:
```
dub test
```
