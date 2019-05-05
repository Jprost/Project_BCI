function [] = topoplot_gif(matrix,lower_range, upper_range, times, output_path)
% Builds animated gif file made of toptoplots.  
%
%INPUT:
% matrix: a matrix of ERD_ERS (start of stop)
% lower/upper_range :  ranges of frequency that are considered
% times: the times of sampling where freq is computed


    %h = figure;
    %axis tight manual
    nb_time_pts=size(matrix,2); % get the number of time points
    filename=[output_path,'topoplot.gif'];
    MI_time_idx=find(times==3);
    
for t=1.0:1.00:nb_time_pts % undersampling TIMES
    
    mean_=mean(mean(matrix(lower_range:upper_range,t,:,:), 3),1);
    
    topo_plot(squeeze(mean_),true);

    if t < MI_time_idx
        title(['Time before Motor Imagery ',sprintf('%.2f',times(t)-3), ' s'], 'FontSize', 20)
    elseif t > MI_time_idx
        title(['Time after Motor Imagery ',sprintf('%.2f',times(t)-3), ' s'], 'FontSize', 20)
    else
        title('Motor imagery' , 'FontSize', 20)
    end
    
    
    
%     Capture the plot as an image 
%     frame = getframe(h); 
%     im = frame2im(frame); 
%     [imind,cm] = rgb2ind(im,256);
%     
    %Write to the GIF File 
    if t == 1 
        gif(filename, 'nodither', 'frame', gcf,'DelayTime', 0.8)
        %imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
    else
        gif%('clear')
        %imwrite(imind,cm,filename,'gif','WriteMode','overwrite');
    end 
    
    
%topo_plot(squeeze(mean_),true);

end
