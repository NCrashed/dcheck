/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors: NCrashed <ncrashed@gmail.com>
*/
module dcheck.maybe;

import std.traits;
import std.exception;

/**
*   Struct-wrapper to handle result of computations,
*   that can fail.
*/
struct Maybe(T)
    if(is(T == class) || is(T == interface) 
        || isPointer!T || isArray!T) 
{
    private T value;
    
    /// Alias to stored type
    alias T StoredType;
    
    /**
    *   Constructing Maybe from $(B value).
    *   If pointer is $(B null) methods: $(B isNothing) returns true and 
    *   $(B get) throws Error.
    */
    this(T value) pure
    {
        this.value = value;
    }
    
    /**
    *   Constructing empty Maybe.
    *   If Maybe is created with the method, it is considred empty
    *   and $(B isNothing) returns false.
    */
    static Maybe!T nothing()
    {
        return Maybe!T(null);
    } 
    
    /// Returns true if stored value is null
    bool isNothing() const
    {
        return value is null;
    }
    
    /**
    *   Unwrap value from Maybe.
    *   If stored value is $(B null), Error is thrown.
    */
    T get()
    {
        assert(value !is null, "Stored reference is null!");
        return value;
    }
    
    /**
    *   Unwrap value from Maybe.
    *   If stored value is $(B null), Error is thrown.
    */
    const(T) get() const
    {
        assert(value !is null, "Stored reference is null!");
        return value;
    }
    
    /**
    *   If struct holds $(B null), then $(B nothingCase) result
    *   is returned. If struct holds not $(B null) value, then
    *   $(justCase) result is returned. $(B justCase) is fed
    *   with unwrapped value.
    */
    U map(U)(U delegate() nothingCase, U delegate(T) justCase)
    {
        return isNothing ? nothingCase() : justCase(value);
    }
    
    /**
    *   If struct holds $(B null), then $(B nothingCase) result
    *   is returned. If struct holds not $(B null) value, then
    *   $(justCase) result is returned. $(B justCase) is fed
    *   with unwrapped value.
    */
    U map(U)(U delegate() nothingCase, U delegate(const T) justCase) const
    {
        return isNothing ? nothingCase() : justCase(value);
    }
}
/// Example
unittest
{
    class A {}
    
    auto a = new A();
    auto ma = Maybe!A(a);
    auto mb = Maybe!A(null);
    
    assert(!ma.isNothing);
    assert(mb.isNothing);
    
    assert(ma.get == a);
    assertThrown!Error(mb.get);
    
    bool ncase = false, jcase = false;
    ma.map(() {ncase = true;}, (v) {jcase = true;});
    assert(jcase && !ncase);
    
    ncase = jcase = false;
    mb.map(() {ncase = true;}, (v) {jcase = true;});
    assert(!jcase && ncase);
}

/**
*   Struct-wrapper to handle result of computations,
*   that can fail.
*/
struct Maybe(T)
    if(is(T == struct) || isAssociativeArray!T || isBasicType!T) 
{
    private bool empty;
    private T value;
    
    /// Alias to stored type
    alias T StoredType;
    
    /**
    *   Constructing empty Maybe.
    *   If Maybe is created with the method, it is considred empty
    *   and $(B isNothing) returns false.
    */
    static Maybe!T nothing()
    {
        Maybe!T ret;
        ret.empty = true;
        return ret;
    } 
    
    /**
    *   Constructing Maybe from $(B value).
    *   If Maybe is created with the constructor, it is considered non empty
    *   and $(B isNothing) returns false.
    */
    this(T value) pure
    {
        this.value = value;
        empty = false;
    }
    
    /// Returns true if stored value is null
    bool isNothing() const
    {
        return empty;
    }
    
    /**
    *   Unwrap value from Maybe.
    *   If the Maybe is empty, Error is thrown.
    */
    T get()
    {
        assert(!empty, "Stored value is null!");
        return value;
    }
    
    /**
    *   Unwrap value from Maybe.
    *   If the Maybe is empty, Error is thrown.
    */
    const(T) get() const
    {
        assert(!empty, "Stored value is null!");
        return value;
    }
    
    /**
    *   If struct holds $(B null), then $(B nothingCase) result
    *   is returned. If struct holds not $(B null) value, then
    *   $(justCase) result is returned. $(B justCase) is fed
    *   with unwrapped value.
    */
    U map(U)(U delegate() nothingCase, U delegate(T) justCase)
    {
        return isNothing ? nothingCase() : justCase(value);
    }
    
    /**
    *   If struct holds $(B null), then $(B nothingCase) result
    *   is returned. If struct holds not $(B null) value, then
    *   $(justCase) result is returned. $(B justCase) is fed
    *   with unwrapped value.
    */
    U map(U)(U delegate() nothingCase, U delegate(const T) justCase) const
    {
        return isNothing ? nothingCase() : justCase(value);
    }
}
/// Example
unittest
{
    struct A {}
    
    auto ma = Maybe!A(A());
    auto mb = Maybe!A.nothing;
    
    assert(!ma.isNothing);
    assert(mb.isNothing);
    
    assert(ma.get == A());
    assertThrown!Error(mb.get);
    
    bool ncase = false, jcase = false;
    ma.map(() {ncase = true;}, (v) {jcase = true;});
    assert(jcase && !ncase);
    
    ncase = jcase = false;
    mb.map(() {ncase = true;}, (v) {jcase = true;});
    assert(!jcase && ncase);
}