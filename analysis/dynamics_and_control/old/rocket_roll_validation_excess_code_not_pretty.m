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
%{
% Setup model parameters
m = 15/2.2 ;%appoximation in kg
r = 3*.0254; %approximation in m
fr = 2.75*.0254;%force radius
I= 1/2*m*r^2;  %moment of inertia  kg*cm^2
b=.02;  %TBD damping
tau = .009; %time constant for actuator lag  = 63% of open response
Ts = .001; %sampling time - continuous
Td = 0:.1:5; %discretized samping time;
Kp =.2;
c = .5;      %conversion factor from rad/s to DC%
Kp = Kp*c;


%Roll and solenoid transfer functions
%{
s=tf('s');
G=fr/(I*s+b); 
act = 1/(tau*s+1);
Gi = G*act;
%}

%%
%set up tf to compare
%{
%{ 
%not what we want at all. huge oscillations before stableizes

H_output_delay_1 = tf(fr,[I b],Ts,'OutputDelay',1); %discrete delay
H_output_delay_2 = tf(fr,[I*tau (I+tau*b) b],Ts,'OutputDelay',1);
%}

H_cs_1 = tf(fr,[I b]);
H_cs_2 = tf(fr,[I*tau (I+tau*b) b]);


H_ts_1 = tf(fr,[I b]);
H_ts_1 = c2d(H_ts_1,Ts);
H_ts_2 = tf(fr,[I*tau (I+tau*b) b]);
H_ts_2 = c2d(H_ts_2,Ts);


H_ts2_1 = tf(fr,[I b]);
H_ts2_1 = c2d(H_ts2_1,Ts*2);
H_ts2_2 = tf(fr,[I*tau (I+tau*b) b]);
H_ts2_2 = c2d(H_ts2_2,Ts*2);


%get the close loop responses
%{
HC_output_delay_1 = feedback(H_output_delay_1*Kp,1);
HC_output_delay_2 = feedback(H_output_delay_2*Kp,1);
%}

HC_cs_1 = feedback(H_cs_1*Kp,1);
HC_cs_2 = feedback(H_cs_2*Kp,1);

HC_ts_1 = feedback(H_ts_1*Kp,1);
HC_ts_2 = feedback(H_ts_2*Kp,1);

HC_ts2_1 = feedback(H_ts2_1*Kp,1);
HC_ts2_2 = feedback(H_ts2_2*Kp,1);

test = feedback(H_cs_1,Kp);
test1 = feedback(H_cs_2,Kp);
%}
%}
%%
%{
%Graph that stuff
close all;

figure
hold on
impulse(HC_cs_1,HC_ts_1,HC_ts2_1) %HC_output_delay_1
plot(time0,vel0,time0,state0,time11,vel11,time11,state11)
legend('continuous','roll','roll*act','vel0','state0','vel11','state11')
xlim([0 1])
ylim([-1 2])

figure
step(HC_ts_1,HC_ts2_1)  %HC_output_delay_1,

figure
step(test,test1)
%}

%%
%{
%Run simulation
%define variables
%I = 0.00075;
Ftot = 11;
fr = 2.75*.0254;
b = 0.002;
ct = 0.1;
Tau = 0.009;
hz = 10;
delay = 2.1;

a = 2   %I/(Ftot*ct*fr)
kp = .205;


simout = sim('simple_roll.slx');

%{

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
%}


 figure
plot(theta_dot.time,theta_dot.signals.values)
title('Step response of Theta Dot (rad/s)')

figure
plot(error.time,error.signals.values,time0,vel0,time11,vel11)
legend('Simulation','Experimental 1','Experimental 2')
title('Disturbance Rejection of Error (rad/s)')   

%{

f = force_out/Ftot;

figure
plot(duty_cycle.time,duty_cycle.signals.values,time,f)
title('DC comand compared to Actutators')
legend('DC Command','Actuator Response')
xlim([1 2])

%}

%}
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

%%
%unused, and did not want to delete
%{
%opt = stepDataOptions('InputOffset',0,'StepAmplitude',5);
%step(HC_output_delay_1,opt)
%///////////////////////////////////////////////////////////////////
padeG = pade(G,3);
padeGc = feedback(padeG,1);
%///////////////////////////////////////////////////////////////////
delay = exp(-s*.2)
sys_ss = ss(G);
q = 1;
Q = diag(1);
Q1 = Q*q;
R = 1;
%}

