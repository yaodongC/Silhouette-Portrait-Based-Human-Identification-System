function descriptors = fourierdescriptor( boundary )
    %I assume that the boundary is a N x 2 matrix
    %Also, N must be an even number
    np = size(boundary, 1);
    s = boundary(:, 1) + i*boundary(:, 2);
    descriptors = fft(s);
    descriptors = [descriptors((1+(np/2)):end); descriptors(1:np/2)];
end