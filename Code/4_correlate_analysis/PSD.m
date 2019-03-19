% load the data from the outputs folder
load('./../outputs/RunsData.mat')

[test,f] = pwelch(RunsData(2).signal(1,:),RunsData(2).sampling_rate);
time = linspace(0,length(RunsData(2).signal)/RunsData(2).sampling_rate,length(RunsData(2).signal));
subplot(4,5,3)
plot(f,10*log(test))
%plot(time,RunsData(1).signal(1,:))
0.5*RunsData(1).sampling_rate

for i=2:16
    [test,f] = pwelch(RunsData(1).signal(i,:),RunsData(1).sampling_rate,0.5*RunsData(1).sampling_rate,[],RunsData(1).sampling_rate);
    time = linspace(0,length(RunsData(1).signal)/RunsData(1).sampling_rate,length(RunsData(1).signal));
    subplot(4,5,i+4)
    plot(f,10*log(test));
end