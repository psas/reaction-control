clear;
close all;

%Make Your Declarations Known

m_inst = 3;                     %instrumentation and payload mass (kg)
m_fuel = 10;                    %fuel mass (kg)
burn = 0.25;                    %mass flow rate/rocket burn rate (kg/s)
burntime = m_fuel/burn;         %rocket burn time (s)
thrust = 4440.8;                 %thrust (N)
thrust_lag = 1.5;               %thrust (s)
g = 9.81;                       %gravity (kg*m/s^2)

F_roll = 7;                     %total nozzle force (N)
F_pitch = 5.5;                  %total nozzle force (N)
F_yaw = 5.5;                    %total nozzle force (N)
fr = 2.75*.0254;                %nozzle leaver arm (m)
b = 0.002;                      %air damping coefficient
a = 2;                          %Duty Cycle conversion factor
tau = 0.02;                     %solenoid time constant
hz = 5;                         %PWM cycle duration (hz)

Ixx = .05;                        %Inertia (kg*m^2)
Ixy = 0.02;
Ixz = 0.05;
Iyy = .05;
Iyz = 0.02;
Izz = 0.0169;

%inertia matrix
Inertia =[Ixx -Ixy -Ixz; -Ixy Iyy -Iyz; -Ixz -Iyz Izz];


theta = 0*pi/180;               %initial rocket orientation (rad)
phi = 0*pi/180;
psi = 0*pi/180;

theta_in = 90*pi/180;           %desired pitch angle (rad)
theta_in_ramp = 2;              %Ramp up to set roll angle (s)


%set up initial quarternions
q1 = cos(psi/2)*cos(theta/2)*cos(phi/2)... 
    + sin(psi/2)*sin(theta/2)*sin(phi/2);
q2 = cos(psi/2)*cos(theta/2)*sin(phi/2)... 
    - sin(psi/2)*sin(theta/2)*cos(phi/2);
q3 = cos(psi/2)*sin(theta/2)*cos(phi/2)... 
    + sin(psi/2)*cos(theta/2)*sin(phi/2);
q4 = sin(psi/2)*cos(theta/2)*cos(phi/2)... 
    - cos(psi/2)*sin(theta/2)*sin(phi/2);



%%
%Control Parameters
roll_disturbance = 1*pi/180;    %disturbance in roll, pitch, yaw (rad)
ts = .003;                      % sampling time

%controller gains
kp_phi = .001;                    %Yaw
kp_theta = .001;                  %Pitch
kp_psi = .2;                    %Roll


%%
%run simulink diagram
sim('PSAS_Rocket_sim')

%3D trajectory plot over time
figure(1)
plot3(x_out.signals.values/1000,y_out.signals.values/1000,... 
    z_out.signals.values/1000+30)
xlabel('x-distance (km)')
ylabel('y-distance (km)')
zlabel('Altitude (km)')
title('3D Trajectory Plot')
axis([-10 10 -10 10 20 120])
grid on

%plot of roll, pitch, and yaw angle over time
figure(2)
subplot(3,1,1)
plot(Phi_out.time,Phi_out.signals.values)
xlabel('Time (seconds)')
ylabel('Roll Angle (rad)')
grid on
subplot(3,1,2)
plot(Theta_out.time,Theta_out.signals.values)
xlabel('Time (seconds)')
ylabel('Pitch Angle (rad)')
grid on
subplot(3,1,3)
plot(Psi_out.time,Psi_out.signals.values)
xlabel('Time (seconds)')
ylabel('Yaw Angle (rad)')
grid on