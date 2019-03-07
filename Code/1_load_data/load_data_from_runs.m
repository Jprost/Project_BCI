function data = load_data_from_runs(DATAFOLDER_PATH, CHANNEL_PATH)
    % function loading all the .gdf file contained in the folder specified
    % INPUT:
    %   DATAFOLDER_PATH : the relative path (as a string) to the folder containing the
    %   .gdf data files
    %   CHANNEL_PATH : the relative path (as a string) to the .mat file
    %   containing the channel localization informaion
    % OUTPUT: 
    %   return an array of structure, each structure contains 4 elements : 
    %       signal : a 2D array containg the EEG signal for the 16 channels
    %       (rows) over time (columns)
    %       sampling_rate: the sampling rate used as an integer
    %       chanel_loc: a structure containing EEG-electrodes position
    %       information as well as electrodes labels
    %       event: structure containing 2 elements : 
    %           - action_type: 1D array containing the code of the action
    %           - action_pos: 1D array containing the time position of the
    %           corresponding action (same index)
    
    data = [];
    
    dinfo = dir(fullfile(DATAFOLDER_PATH, '*.gdf'));
    
    for K = 1 : length(dinfo)
        filename = dinfo(K).name;  %just the name
        data = [data, load_data_from_one_run(strcat(DATAFOLDER_PATH ,filename), CHANNEL_PATH)];
    end  
end

