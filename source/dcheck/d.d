/**
*   Fast way to import all modules from $(B dcheck) package.
*
*   Example:
*   -------
*   import dcheck.d;
*   -------
*
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors: NCrashed <ncrashed@gmail.com>
*/
module dcheck.d;

public
{
    import dcheck.arbitrary;
    import dcheck.constraint;
    import dcheck.generator;
    import dcheck.maybe;
}