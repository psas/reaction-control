clear;
close all;

%define variables
I = 0.075;
Ftot = 5.5;
fr = 2.5*.0254;
b = 0.02;
ct = 0.1;
Tau = 0.009;
hz = 10;
delay = 2.1;

simout = sim('rotational_system_sim.slx');

time_dc = time(1:length(duty_cycle));


figure
plot(time_dc,duty_cycle)
title('Duty Cycle')
ylim([-.5 1.5])

figure
scatter(dc_in.time,dc_in.signals.values)
title('DC in')



force_avg = mean(force_out)
force_tracker = 0;

for i = 1:length(force_out)
    force_tracker = (force_tracker+force_out(i));
    force(i) = force_tracker/i;
    i = i + 1;
end
 
figure
plot(time,force_out,time,force)
legend('Instantaneous Force', 'Average Force')
title('Force out (N)')



 figure
plot(time,theta_dot)
title('Step response of Theta Dot (rad/s)')

figure
plot(time,error)
title('Disturbance Rejection of Error (rad/s)')   
    
    


