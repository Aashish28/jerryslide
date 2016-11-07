itab = VALUE #( FOR j = 1 WHILE j <= 100 ( j ) ).
DATA(sum) = REDUCE i( INIT x = 0 FOR wa IN itab NEXT x = x + wa ).
WRITE: / sum.