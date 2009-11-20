Personify : personalisation template language
=============================================

Personfify is meant for use in environments where templates just need
to be personalized.

Basic syntax
------------

Alle expressions are wrapped in brackets ([ ]). All code outside
of brackets will not be evaluated.

If the return statement of an expression is nil, it won't be replaced
by it's output.

All whitespace within expressions is ignored.

Simple substitution
-------------------

The simplest use of the personify template language is to just use
the standard substitution expressions. A substitution expression
exists of a key which will be replaced if it's found in the context.

With context:

    {"key" => "value"}

Examples:

    [KEY] => value
    [UNKNOWN] => [UNKNOWN]
    
Substitutions with fallback
--------------------------- 

A more advanced feature is to use fallbacks on missing keys. If a key can't
be found in the context, all alternative keys (separated by a pipe (|))
will be tried until a non-nil value is found. If a the last alternative
returns nil, the original expression won't be replaced.

You can also specify strings as fallbacks, they will always return the string.
See also the note on strings below.

With context:

    {"key" => "value"}

Examples:
    
    [UNKNOWN | KEY] => value
    [UNKNOWN1 | UNKNOWN2 | "default"] => default
    [UNKNOWN1 | UNKNOWN2 | default] => default

Function calls
--------------

For more flexibility, it is possible to put functions in
the context by means of lamda's and procs. However you need to be very
carefull with accepting parameters as Personify will just splat all
parameters into the proc's call method. If an expected function
doesn't respond to a call method, it just works like a normal substitution.

With context:

    {
      "key1" => "v1", 
      "key2" => "v2" 
      "ampersandize" => Proc.new{|*c| c.join(" & ") }
    }

Examples:
    
    [AMPERSANDIZE(KEY1,KEY2)] => v1 & v2
    [AMPERSANDIZE(KEY1 , "default")] => v1 & default
    [AMPERSANDIZE("1","2","3")] => 1 & 2 & 3
    [AMPERSANDIZE("1",2,3)] => 1 & 2 & 3    

Strings
-------

Strings can be used either as parameters for a function or in an expression
as an alternative. Strings don't necessarily need to be quoted as long
as they don't contain any of these characters: "]),|

Strings cannot ever contain double qoutes (").