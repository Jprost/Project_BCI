function cat_mat = padcat_ERDERS(mat_cell, dim)
    %UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    
    sizes = [];
    for i=1:size(mat_cell,2)
        sizes = cat(1, sizes, size(cell2mat(mat_cell(i)),3));
    end
    max_size = max(sizes);
    
    cat_mat = [];
    for i=1:size(mat_cell, 2)
        cat_mat = cat(dim, cat_mat, padarray(cell2mat(mat_cell(i)), [0, 0, max_size-size(cell2mat(mat_cell(i)),3),0], NaN, 'post'));
    end
end

