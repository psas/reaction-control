close
clear all
%///////////////////////////////////////////////////////////////////
%System parameters
m = 15/2.2 ;%appoximation in kg
r = 3*.0254; %approximation in m
fr = 2.75*.0254;%force radius
I= 1/2*m*r^2;  %moment of inertia  kg*cm^2
b=.02;  %TBD damping
tau = .009; %time constant for actuator lag  = 63% of open response
Ts = .01; %sampling time - continuous
Td = 0:.1:5; %discretized samping time;
K =.22;
%///////////////////////////////////////////////////////////////////
s=tf('s');
G=fr/(I*s+b);
act = 1/(tau*s+1);
Gi = G*act
%///////////////////////////////////////////////////////////////////

H = tf(fr,[I b],0.1,'OutputDelay',1) %discrete delay

HC = feedback(H*K,1);
opt = stepDataOptions('InputOffset',0,'StepAmplitude',1);
step(HC,opt)
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

%[K,S,E] = lqr(sys_ss,Q,R,0)
%step(padeGc)
%impulse(HC)
%Acl = sys_ss.a - sys_ss.b*K;
%Gcl = ss(Acl, sys_ss.b, sys_ss.c, sys_ss.d);
%rlocus(H)
%step(Gcl)
%blue = feedback(G*act*delay,K);
%step(blue);
%mdl = estimate(G,Ts)
%impulse(mdl)
%[Gm,Pm,Wgm,Wpm] = margin(H*K)
%margin(G*K*act*delay)
%bode(Gcl*K);
%[sysd,G] = c2d(Gcl,Ts,'zoh')
%step(sysd);
%bode(Gcl)

%S = stepinfo(Gcl);
%S.RiseTime
%S.Overshoot
%S.Undershoot
%S.SettlingTime
%step(Gcl);
%{
while S.RiseTime < 3 %&& S.Overshoot < .05
    
    Q1 = Q*q;
    K = lqr(sys_ss,Q1,R);
    q = q + 10;
    Acl = sys_ss.a - sys_ss.b*K;
    Gcl = ss(Acl, sys_ss.b, sys_ss.c, sys_ss.d);
    S = stepinfo(Gcl);
    Q1(1);
    S       

end

%figure 
%impulse(Gcl)
%}
