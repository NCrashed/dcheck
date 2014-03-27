/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors: NCrashed <ncrashed@gmail.com>
*/
module dcheck.generator;

import std.range;
import dcheck.maybe;

/**
*   Transforms delegate into lazy range. Generation is stopped, when
*   $(B genfunc) returns $(B Maybe!T.nothing).
*/
auto generator(T)(Maybe!T delegate() genfunc)
{
    struct Sequencer
    {
        private Maybe!T currvalue;
        
        T front()
        {
            assert(!currvalue.isNothing, "Generator range is empty!");
            return currvalue.get;
        }
        
        bool empty()
        {
            return currvalue.isNothing;
        }
        
        void popFront()
        {
            currvalue = genfunc();
        }
    }
    static assert(isInputRange!Sequencer);
    
    auto s = Sequencer();
    s.popFront;
    return s;
}
/// Example
unittest
{
    assert( (() => Maybe!int(1)).generator.take(10).equal(1.repeat.take(10)) );
    assert( (() => Maybe!int.nothing).generator.empty);
    assert( (() 
            {
                static size_t i = 0;
                return i++ < 10 ? Maybe!int(1) : Maybe!int.nothing;
            }
            ).generator.equal(1.repeat.take(10)));
    
    class A {}
    auto a = new A();
    
    assert( (() => Maybe!A(a)).generator.take(10).equal(a.repeat.take(10)) );
    assert( (() => Maybe!A.nothing).generator.empty);
    assert( (() 
            {
                static size_t i = 0;
                return i++ < 10 ? Maybe!A(a) : Maybe!A.nothing;
            }
            ).generator.equal(a.repeat.take(10)));
}