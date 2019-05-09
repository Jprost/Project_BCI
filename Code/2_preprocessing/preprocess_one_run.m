function preprocessed_data = preprocess_one_run(raw_data, Laplacian, CAR, filtering)
    
    % Preprocess the data by a Spatial filtering
    %INPUT : raw_data : input data 16x... array
    %        Laplacian : filtering matrix : pass an empty matrix if using CAR
    %        CAR : Boolean defining whether to do a CAR spatial filter, it will do a Laplacian filtering instead false
    %OUTPUT : Preprocessed data
    
    if CAR
        % Global averaging
        spatial_filter = eye(16,16)-1/16;
    else
        % neigbor averging
        spatial_filter = Laplacian;
    end

    preprocessed_data = spatial_filter * raw_data;
    
    if filtering
        [b,a] = butter(6,[7,35]/256,'bandpass');
        preprocessed_data = (filter(b,a,preprocessed_data.')).';
    end
end

