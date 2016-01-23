# implement of http://sahandsaba.com/understanding-sat-by-implementing-a-simple-sat-solver-in-python.html
#

# comparison of equations to see if one can satisfy another.
# the satisfaction basically is *assignable*.
# for example, a natural number (integer >= 0) can be assigned to integer, but not the other way around.
#
# x >= 0
#
# x >= 0 and x % 2 == 0 (Even Natural Number) can be assigned to x >= 0 alone. so on.
# 
# 
# x > 0 can be assigned to x > 0 just because one has a larger range than another.
#
# That means for comparisons we need to deal with the range. Things must be orderable (i.e. sortable).
# 
# 


