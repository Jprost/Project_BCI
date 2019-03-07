function state = load_state_from_event()

% MI = Motor imagery
% EXO = Exoskeleton


state.ST_START = [100 123];
% beginning of the trial, 1st trial is 123

state.ST_HOLD  = 200;
% when the clock hand appears, this event indicates the period when you are supposed to be relaxed, avoid blinking without muscle activity
% this event should correspond to the BASELINE

state.ST_FILL  = 300;
% the gauge being to fill and you start MI, clock hand does not move.

state.ST_MOV   = 400;
% the clock hand start to move, you still do MI

state.ST_STOP  = 555;
% the clock hand cross the red bar(stop cue), you stop MI -> MI_STOP

state.ST_EXO   = 600;
% EXO is activated with a specific grasping degree

state.ST_RELAX = 700;
% RELAX: you are allowed to blink, move, whatever you want to do (except leaving the experiment)


end


