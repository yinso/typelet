# a type hierarchy is defined by the way the types sort.
#
# typeHierarchy level
#   variable - 1
#   scalar - 2
#   property - 3
#   object - 4
#   array - 5 # this one is a bit special due to the way JS works. ideally it's the same as object
#   trait - 6
#   procedure - 7

# multiple level exists for compound types.
# array(scalar) > array(variable) -> for example.
# 5.2 > 5.1

# constraints also causes additional sort info.
# constraint should have its own number separated from the pure type info?
# it is truly
#
# if we can get every type to generate a unique signature, we can sort them.
#
# the question is - how do we deal with the following
# 1 - constraints
# 2 - base type (not all base type are legal)

# we also need to deal with constructor of the types... can we sort constructors?
# (we can do so by figuring out if the prototype

# it's now easy to create an unique type signature.
# 
