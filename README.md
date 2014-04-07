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

Adding custom types
===================
To be able to use `checkConstrained` function all parameter types of a function should have `Arbitrary!T` instance. This template includes three main components:
* `generate` function that takes nothing and returns range of `T`. The function is used to generate random sets of testing data. Size of required sample isn't passed thus use lazy ranges to generate possible infinite set of data.
* `shrink` function that takes value of `T` and returns range of truncated variations. The function is used to reduce failing case data to minimum possible set. You can return empty array if you like to get large bunch of random data when constraint fails.
* `specialCases` function that takes nothing and returns range of `T`. The function is used to test some special values for particular type like `NaN` or `null` pointer. You can return empty array if no testing on special cases is required. At the moment `specialCases` is not used, but it will change at future releases.

To generate lazy ranges there is handy function from `dcheck.generator`. Consider `Arbitrary!T` implementation for integral types:
```D
template Arbitrary(T)
    if(isIntegral!T)
{
    // Helpfull to check your implementation, will print what exactly goes wrong
    static assert(CheckArbitrary!T);
    
    auto generate()
    {
    	// dcheck.generator wraps delegate to produce finite and infinite lazy ranges
        return (() => Maybe!T(uniform!"[]"(T.min, T.max))).generator;
    }
    
    auto shrink(T val)
    {
    	// functor to encapsulate state
    	// to find minimal test case fast we half number each time 
        class Shrinker
        {
            T saved;
            
            this(T firstVal)
            {
                saved = firstVal;
            }
            
            Maybe!T shrink()
            {
                if(saved == 0) return Maybe!T.nothing;

                saved = saved/2;
                return Maybe!T(saved);
            }
        }
        
        return (&(new Shrinker(val)).shrink).generator;
    }
    
    T[] specialCases()
    {
        return [T.min, 0, T.max];
    }
}
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
