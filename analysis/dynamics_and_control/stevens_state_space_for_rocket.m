clear;
close all;

%Constants
psi = pi/2;
theta = .1;
phi = .05;

wx = 7.27e-5;           %earth angular rotation rad/sec

p = 1;
q = 1;
r = 10;

g = 9.81;               %gravity m/s


%instrumentation and payload mass
m_inst=3.8; %kg

%fuel mass
m_fuel=19; %kg

%mass flow rate/rocket burn rate
burn=0.25; %kg/s

%rocket burn time
burntime=m_fuel/burn; %seconds

%thrust
thrust=444.8; %N

%gravity
g=9.81; %kg*m/s^2

%First order time constant for servo thrusters
tau=0.05;



%Moment of Inertia
Jxx = 1.2634e6;
Jxy = 1.5925e3;
Jxz = 5.5250e4;
Jyy = 2.8797e8;
Jyz = 1.5263e3;
Jzz = 2.8798e8;

J = [Jxx -Jxy -Jxz; -Jxy Jyy -Jyz; -Jxz -Jyz Jzz]; 


%Inverse Moment of Inertia
delta = Jxx*Jyy*Jzz-2*Jxy*Jyz*Jxz-Jxx*Jyz^2-Jyy*Jxz^2-Jzz*Jxy^2;

k1 = (Jyy*Jzz-Jyz^2)/delta;
k2 = (Jyz*Jxz+Jxy*Jzz)/delta;
k3 = (Jxy*Jyz+Jxz*Jyy)/delta;
k4 = (Jzz*Jxx-Jxz^2)/delta;
k5 = (Jxy*Jxz+Jyz*Jxx)/delta;
k6 = (Jxx*Jyy-Jxy^2)/delta;

J_inv = [k1 k2 k3; k2 k4 k5; k3 k5 k6];


%Quarternions

%{
z=psi=yaw
x=theta=pitch
y=phi=roll
%}

q0 = cos(phi/2)*cos(theta/2)*cos(psi/2)+sin(phi/2)*...
    sin(theta/2)*sin(psi/2);
q1 = sin(phi/2)*cos(theta/2)*cos(psi/2)-cos(phi/2)*...
    sin(theta/2)*sin(psi/2);
q2 = cos(phi/2)*sin(theta/2)*cos(psi/2)+sin(phi/2)*...
    cos(theta/2)*sin(psi/2);
q3 = cos(phi/2)*cos(theta/2)*sin(psi/2)-sin(phi/2)*...
    sin(theta/2)*cos(psi/2);


%Governing Equations
B = [q0^2+q1^2-q2^2-q3^2 2*(q1*q2+q0*q3) 2*(q1*q3-q0*q2);...
    2*(q1*q2-q0*q3) q0^2-q1^2+q2^2-q3^2 2*(q2*q3+q0*q1);...
    2*(q1*q3+q0*q2) 2*(q2*q3-q0*q1) q0^2-q1^2-q2^2+q3^2];
Bt = transpose(B);

omega_e = [0 0 0; 0 0 -wx; 0 wx 0];
omega_b = [0 -r q; r 0 -p; -q p 0];
omega_q = [0 p q r; -p 0 -r q; -q r 0 -p; -r -q p 0];

q_dot = -1/2*omega_q*[q0;q1;q2;q3]

body_angle_rates = 2*[-q1 q0 q3 -q2; -q2 -q3 q0 q1; -q3 q2 -q1 q0]*q_dot
P = body_angle_rates(1)
Q = body_angle_rates(2)
R = body_angle_rates(3)

wb = [p;q;r];

Fb = [1;1;1];
Tb = [5;5;5];
m = 10;


%State Space Matricies
a = [omega_e Bt zeros(3) zeros(3,4);...
    B*g*p-B*omega_e^2 -(omega_b+B*omega_e) zeros(3) zeros(3,4);...
    zeros(3) zeros(3) -J_inv*omega_b*J zeros(3,4);...
    zeros(4,3) zeros(4,3) zeros(4,3) -1/2*omega_q];

b = [zeros(3,1); Fb/m; J^-1*Tb; zeros(4,1)];

c = [0 0 0 0 0 0 1 0 0 0 0 0 0; 0 0 0 0 0 0 0 1 0 0 0 0 0;...
    0 0 0 0 0 0 0 0 1 0 0 0 0];


d = 0;

ts = .01;

sys = ss(a,b,c,d);
sys_d = c2d(sys,ts,'zoh');

figure
pzmap(sys_d)

[pole zero] = pzmap(sys_d)

figure
step(sys_d)

figure
impulse(sys_d)


%{
% omit position, velocity, and quarternions
a = [-J_inv*omega_b*J];

b = [J^-1*Tb];

c = [1 0 0; 0 1 0; 0 0 1];


d = 0;

ts = .01;

sys = ss(a,b,c,d);
sys_d = c2d(sys,ts,'zoh');

figure
pzmap(sys)
title('sys')

figure
step(sys)
title('sys')

%new pole placement
p = [-.3 -.25 -.2]

k = place(sys.a,sys.b,p);

Acl = sys.a-sys.b*k;

sys_cl = ss(Acl,sys.b,sys.c,sys.d);

figure
step(sys_cl)

figure
impulse(sys_cl)
%}

%{
figure
pzmap(sys_d)
title('sys_d')

[poles zeros] = pzmap(sys_d)

figure
step(sys_d)
title('sys_d')


figure
impulse(sys_d)



%Fix it

pd = [.8 .2 -.1]

kd = place(sys_d.a,sys_d.b,pd);

Acl = sys_d.a-sys_d.b*kd;

sys_cld = ss(Acl,sys_d.b,sys_d.c,sys_d.d,ts);

figure
step(sys_cld)


%}


