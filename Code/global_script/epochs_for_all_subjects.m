function epochs_all_subjects = epochs_for_all_subjects(epochs_cell)
    % concat the epochs array in the cell 'epoch_cell' in the direction of the trials 

    % get the max number of epochs for each array
    sizes = [];
    for i=1:size(epochs_cell,2)
        sizes = cat(1, sizes, size(cell2mat(epochs_cell(i)),1));
    end
    max_size = max(sizes);

    % pad the array with NaN to enable concat
    epochs_all_subjects = [];
    for i=1:size(epochs_cell, 2)
        epochs_all_subjects = cat(4, epochs_all_subjects, padarray(cell2mat(epochs_cell(i)), [max_size-size(cell2mat(epochs_cell(i)),1),0,0], NaN, 'post'));
    end
end

