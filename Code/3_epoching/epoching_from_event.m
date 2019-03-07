function epochs_struct = epoching_from_event(runData,eventOfInterest,timeBeforeEvent,timeAfterEvent)
    %EPOCHING_FROM_EVENT 
    % extract the trials in a 3D matrix (trials x channels x time) from runData aligned with
    % a specific event (eventOfInterest) and between the interval
    % [-timeBeforeEvent timeAfterEvent].

    % Inputs: 
    % runData, the structure that you built before containined your data with
    % all the runs
    % eventOfInterest = state/event you want to align (at t = 0 you will have this event)
    % timeBeforeEvent, timeAfterEvent: interval of time in seconds
    % ex: [-2 2] timeBeforeEvent = 2, timeAfterEvent = 2

    % Outputs:
    % epochs is a structure containing similar info that your runData structure
    % it contains the data (trials x channels x time)

    epochs = [];
    time = -timeBeforeEvent:1/runData(1).sampling_rate:timeAfterEvent-1/runData(1).sampling_rate;

    % loop over the runData
    for i=1:1:length(runData)
        % get the event position on the runData
        event_pos = runData(i).event.action_pos(runData(i).event.action_type == eventOfInterest);

        % get number of point to take before/after the event
        pt_before_event = timeBeforeEvent * runData(i).sampling_rate;
        pt_after_event = timeAfterEvent * runData(i).sampling_rate-1;

        % loop over the event_pos (= trials)
        for j = 1:1:length(event_pos)     
            % get the data around the event position for all 16 channels
            trial_data = runData(i).signal(:,event_pos(j)-pt_before_event:event_pos(j)+pt_after_event);
            % add the trial to the epoch matrix
            epochs = cat(3, epochs, trial_data);
        end
    end
    
    % Rearange dimension to trials x channels x time
    epochs = permute(epochs, [3,1,2]);
    
    % put it as a structure
    epochs_struct = struct('trial',epochs, 'time', time);
end

