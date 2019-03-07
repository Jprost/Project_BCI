function dataRun = load_data_from_one_run(DATA_PATH, CHANNEL_PATH) 
    % This function enables to load EEG data from a .gdf file.
    % INPUT: 
    %   DATA_PATH : string defining the path to the .gdf file to load
    %   CHANNEL_PATH : string defining the path to the .mat file containg
    %   the electrodes localization informations
    % OUTPUT:
    %   return a structure containing 4 elements:
    %       signal : a 2D array containg the EEG signal for the 16 channels
    %       (rows) over time (columns)
    %       sampling_rate: the sampling rate used as an integer
    %       chanel_loc: a structure containing EEG-electrodes position
    %       information as well as electrodes labels
    %       event: structure containing 2 elements : 
    %           - action_type: 1D array containing the code of the action
    %           - action_pos: 1D array containing the time position of the
    %           corresponding action (same index)
    
    % load .gdf file with sload() from biosig toolbox 
    [data, metadata] = sload(DATA_PATH);
    
    % load channel localization 
    chan_locs = load(CHANNEL_PATH);
    
    % build the data structure
    dataRun = struct('signal', data(:,1:16)', ... 
                    'sampling_rate', metadata.SPR, ... 
                    'event', struct('action_type',metadata.EVENT.TYP,'action_pos',metadata.EVENT.POS), ...
                    'channel_loc', chan_locs.chanlocs16);
end