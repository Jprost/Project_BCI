function topo_plot( data, c_bar )
% datav = vector of values at the corresponding locations.

addpath(genpath('./../toolboxes/eeglab14_1_2b'));
load('./../data/channel_location_16_10-20_mi.mat')
clims=[-4,4];

if c_bar
   
    c = colorbar;
    c.Label.String = 'ERD/ERS [dB]';
    c.Label.FontSize = 15;
end
    
topoplot(data, chanlocs16, 'colormap', 'jet', 'style', 'both', ...
    'electrodes', 'labelpoint', 'maplimits', clims);


    
    
end


