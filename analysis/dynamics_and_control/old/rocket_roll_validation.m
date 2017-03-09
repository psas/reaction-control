close all
clear 


%%
%import all trial data and split the runs and time start at zero

data = importdata('C:\Users\kenny\Desktop\Rotational Rocket Model Validation\data.txt');
state0 = data(:,1);
state0 = state0(8:end);
time0 = data(:,3);
time0 = time0(8:end);
time0 = time0 - time0(1); 
vel0 = data(:,2)*-1;
vel0 = vel0(8:end);

data = importdata('C:\Users\kenny\Desktop\Rotational Rocket Model Validation\impulse1.txt');
state1 = data(:,1);
time1 = data(:,3); 
vel1 = data(:,2);

state11 = state1(8:2924);
time11 = time1(8:2924);
time11 = time11 - time11(1);
vel11 = vel1(8:2924)*-1;

state12 = state1(2925:end);
time12 = time1(2925:end);
time12 = time12 - time12(1);
vel12 = vel1(2925:end);


data = importdata('C:\Users\kenny\Desktop\Rotational Rocket Model Validation\impulse2.txt');
state2 = data(:,1);
time2 = data(:,3);
time2 = time2 - time2(1);
vel2 = data(:,2);

data = importdata('C:\Users\kenny\Desktop\Rotational Rocket Model Validation\impulse3.txt');
state3 = data(:,1);
time3 = data(:,3); 
vel3 = data(:,2);

state31 = state3(1:2945);
time31 = time3(1:2945);
time31 = time31 - time31(1);
vel31 = vel3(1:2945);

state32 = state3(2946:end);
time32 = time3(2946:end);
time32 = time32 - time32(1);
vel32 = vel3(2946:end);


%%
%Graph all the collected data
figure
plot(time0,vel0,time0,state0)
legend('Velocity (rad/s)','Duty Cycle State')
title('Impulse Data')

figure
plot(time11,vel11,time11,state11)
legend('Velocity (rad/s)','Duty Cycle State')
title('Impulse Data 11')

figure
plot(time12,vel12,time12,state12)
legend('Velocity (rad/s)','Duty Cycle State')
title('Step Data 12')

figure
plot(time2,vel2,time2,state2)
legend('Velocity (rad/s)','Duty Cycle State')
title('Step Data 2')

figure
plot(time31,vel31,time31,state31)
legend('Velocity (rad/s)','Duty Cycle State')
title('Step Data 3')

figure
plot(time32,vel32,time32,state32)
legend('Velocity (rad/s)','Duty Cycle State')
title('Step Data 3')


%%
%define variables
I = 0.0198;
Ftot = 11;
fr = 2.75*.0254;
b = 0.002;
a = 2;   %I/(Ftot*ct*fr)
ct = 0.2;
Tau = 0.02;
hz = 10;
delay = 2.1;

simout = sim('rotational_system_sim.slx');

 figure
plot(theta_dot.time,theta_dot.signals.values)
title('Step response of Theta Dot (rad/s)')

figure
plot(error.time,error.signals.values,time0,vel0,time11,vel11)
legend('Simulation','Experimental 1','Experimental 2')
title('Disturbance Rejection of Error (rad/s)') 
xlim([0 .5])

