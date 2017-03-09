m = 15/2.2 ;%appoximation in kg
r = 3*.0254; %approximation in m
fr = 2.75*.0254;%force radius
I= 1/2*m*r^2;  %moment of inertia  kg*cm^2
b=.02;  %TBD damping
tau = .009; %time constant for actuator lag  = 63% of open response
Ts = .001; %sampling time - continuous
Td = 0:.1:5; %discretized samping time;
Kp =.2;
c = 2;      %conversion factor from rad/s to DC%
Kp = Kp*c;


%Roll and solenoid transfer functions
s=tf('s');
G=fr/(I*s+b); 
act = 1/(tau*s+1);
Gi = G*act;