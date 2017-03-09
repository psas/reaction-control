clear;
close all;

%define variables
I = 0.0198;
Ftot = 5.5;
fr = 2.75*.0254;
b = 0.002;
ct = 0.1;
Tau = 0.009;
hz = 10;
delay = 2.1;

simout = sim('rotational_system_sim.slx');

time_dc = time(1:length(duty_cycle));


figure
plot(duty_cycle.time,duty_cycle.signals.values)
title('Duty Cycle')
ylim([-.5 1.5])


figure
scatter(dc_in.time,dc_in.signals.values,'.')
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
plot(theta_dot.time,theta_dot.signals.values)
title('Step response of Theta Dot (rad/s)')

figure
plot(error.time,error.signals.values)
title('Disturbance Rejection of Error (rad/s)')   
    
f = force_out/Ftot;

figure
plot(duty_cycle.time,duty_cycle.signals.values,time,f)
title('DC comand compared to Actutators')
legend('DC Command','Actuator Response')
xlim([1 2])
