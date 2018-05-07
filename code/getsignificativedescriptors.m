function significativedescriptors = getsignificativedescriptors( alldescriptors, num )
    %num is the number of significative descriptors (in your example, is was 20)
    %In the following, I assume that num and size(alldescriptors,1) are even numbers

    dim = size(alldescriptors, 1);

    if num >= dim
        significativedescriptors = alldescriptors;
    else
        a = (dim/2 - num/2) + 1;
        b = dim/2 + num/2;

        significativedescriptors = alldescriptors(a : b);
    end
end