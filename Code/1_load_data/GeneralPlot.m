% Generates the general plot for every run in a distinct figure

% Load the data
load_script

%% Plot 

%for every run ...
for i=1:length(RunsData)
    time=linspace(0,length(RunsData(i).signal)/RunsData(i).sampling_rate,length(RunsData(i).signal));
    
    %avoid lines overlapping
    plot_spacing=max(max(RunsData(i).signal));


    figure(i)
    % --- Electrodes --- 
    subplot(2,1,1)
    hold on;
    yticklabels({RunsData(i).channel_loc.labels});
    yticks(0:plot_spacing:plot_spacing*size(RunsData(i).signal,1)...
            + mean(RunsData(i).signal,2) )
    ylabel('Electrodes')
    xlabel('time [s]')
    
    title(['Relative electrode behavior in time (run ', num2str(i),')'])
    
    for plt=1:size(RunsData(i).signal,1)
        plot(downsample(time,10),downsample(RunsData(i).signal(plt,:), 10)...
            +plot_spacing*(plt-1), '-')
    end
    
    % --- EVENTS ---
    fprintf('Run %d, there are %d events.\n',i,length(unique(RunsData(i).event.action_type)));
    
    subplot(2,1,2)
    plot(RunsData(i).event.action_pos/RunsData(i).sampling_rate, RunsData(i).event.action_type,'-o')
    yticks(unique(RunsData(i).event.action_type))
    ylabel('Events')
    xlabel('time [s]')
end