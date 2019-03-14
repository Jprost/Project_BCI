function preprocess_runs = preprocess_all_run(runs_data, Laplacian, CAR)
    % Preprocess the all the runs data by a Spatial filtering
    %INPUT : runs_data : structure containg the run data
    %        Laplacian : filtering matrix : pass an empty matrix if using CAR
    %        CAR : Boolean defining whether to do a CAR spatial filter, it will do a Laplacian filtering instead false
    %OUTPUT : Preprocessed runs_data as structure (same structure as input with fitered signal)
    
    preprocess_runs = [];
    
    for i=1:1:size(runs_data,2)
        struct_tmp = struct('signal', preprocess_one_run(runs_data(i).signal, Laplacian, CAR), ... 
                           'sampling_rate', runs_data(i).sampling_rate, ... 
                           'event', runs_data(i).event, ...
                           'channel_loc', runs_data(i).channel_loc);
                       
        preprocess_runs = [preprocess_runs, struct_tmp];
    end
end

