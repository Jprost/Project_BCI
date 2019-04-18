function cat_vect = padcat1D(vect_cell,dim)
    %UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    
    sizes = [];
    for i=1:size(vect_cell,2)
        sizes = cat(1, sizes, size(cell2mat(vect_cell(i)),1));
    end
    max_size = max(sizes);
    
    cat_vect = [];
    for i=1:size(vect_cell, 2)
        cat_vect = cat(dim, cat_vect, padarray(cell2mat(vect_cell(i)), [max_size-size(cell2mat(vect_cell(i)),1),0], NaN, 'post'));
    end
end

