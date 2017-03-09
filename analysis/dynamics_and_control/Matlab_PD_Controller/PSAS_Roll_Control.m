clear;
close all;


%constants taken from http://psas.pdx.edu/rollcontrol/
Izz = 0.08594;       %m2*kg
kd = .002;           %damping coefficient
kt = .9141;          %Nm/rad  torsion rod spring constant exper. determined
lf = .0762;          %m distance from fin to z axis


%State Space equation
%assuming partial-state feedback (angular vel.)
%model equation from http://psas.pdx.edu/rollcontrol/
a = [-kd/Izz 0; 1 0];
b = [lf/Izz; 0];
c = [0 1];
d = 0;

sys_ss = ss(a,b,c,d,'statename',{'Angular Accel','Angular Vel'});

%Check it out
figure
pzmap(sys_ss)
title('Pole and Zero map of State Space Model')

figure
step(sys_ss)
title('Initial Step Response of State Space Equation')

%convert State Space to Laplace Transfer Function
[num den] = ss2tf(a,b,c,d);

%create root locus plot 
figure
rlocus(num,den)
title('Continuous Initial Root locus')


%Create proportional controller

s = tf('s');

Gp = tf(num,den)                %Gp is the system process

kp = .000153;                   %proportional gain chosen from rl graph

Gc = kp;                        %Gc is the Controller process

cltf = feedback(Gc*Gp,1);       %closed loop response

figure
step(cltf)
title('Continuous system with kp')


%Now add a derivitive gain to speed things up

figure
rlocus(Gc*Gp)
title('Continuous system kp Root Locus')


kd = 100;                       %derivitave gain

Gc = kp+kd*s                    %new controller process

cltf = feedback(Gc*Gp,1)        %new closed loop response

figure
step(cltf)
title('Continuous system PD controller Step Response')

figure
impulse(cltf)
title('Continuous system PD controller Impulse Response')

%{
No Integrator required
Sys is arleady type 2, 
steady state error goes to zero
if integrator is added the sys blows up
%}


%now model as discrete time and hope we can get close to the continuous


Ts = .01;                       %sample time of 10 ms chosen.
                                %Not sure what the actual sensors can do

z = tf('z',Ts);

sysd = c2d(Gp,Ts,'zoh')         %convert continous to discrete

figure
rlocus(sysd)
title('Initial Discrete System Root locus')

kp = .000153;                   %new proportional gain chosen from rl graph

Gc = kp;                        %new controller process

cltf = feedback(Gc*sysd,1)      %new closed loop response

figure
step(cltf)
title('Discrete system P controller Step Response')



%Now add a derivitive gain to speed things up

figure
rlocus(Gc*sysd)
title('Discrete system kp Root Locus')

kd = 1000;                      %new derivative gain chosen from rl graph
                                %acceptable values are 100-9000
                                %they depened on the systems capabilities
                                %larger value = faster rise time

Gc = kp+kd*((z-1)/z)            %new controller process

cltf = feedback(Gc*sysd,1)      %new closed loop response

figure
step(cltf)
title('Discrete system PD controller Step Response')

figure
impulse(cltf)
title('Discrete system PD controller Impulse Response')

final_gp = d2c(sysd,'tustin')
final_gc = d2c(Gc,'tustin')


