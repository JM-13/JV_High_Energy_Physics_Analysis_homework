#!/bin/bash

file="events.csv"

echo "p1_0,p1_1,p1_2,p1_3,p2_0,p2_1,p2_2,p2_3,an_event" > $file
while IFS="," read -r p1_0 p1_1 p1_2 p1_3 p2_0 p2_1 p2_2 p2_3 # p1 p2 are 4-momenta
do
    # finding p^2 = p1^2 + p2^2 which is m^2 = m1^2 + m2^2 + 2*p1*p2
    # m^2 is invariant mass
    let m1=$p1_0^2-$p1_1^2-$p1_2^2-$p1_3^2 # m1^2
    let m2=$p2_0^2-$p2_1^2-$p2_2^2-$p2_3^2 # m2^2
    let p1_p2=$p1_0*$p2_0-$p1_1*$p2_1-$p1_2*$p2_2-$p1_3*$p2_3 # p1*p2
    let m=$m1+$m2+2*$p1_p2 # m^2

    echo "$p1_0,$p1_1,$p1_2,$p1_3,$p2_0,$p2_1,$p2_2,$p2_3,$m" >> $file
done < "vector-8.csv"
