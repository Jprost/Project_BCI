function cat_power = padcat_power(power_cell,dim)
    %UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    
    sizes = [];
    for i=1:size(power_cell,2)
        sizes = cat(1, sizes, size(cell2mat(power_cell(i)),3));
    end
    max_size = max(sizes);
    
    cat_power = [];
    for i=1:size(power_cell, 2)
        cat_power = cat(dim, cat_power, padarray(cell2mat(power_cell(i)), [0,0,max_size-size(cell2mat(power_cell(i)),3)], NaN, 'post'));
    end
end

