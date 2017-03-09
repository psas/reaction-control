clear;
close all;

load('lab1_300hz_first_order.mat')

Vin = 2;
R = 25e3;
C = 64e-9;

sys =tf(Vin,[R*C 1]);

[mag,phase,w_sys] = bode(sys);
magp = squeeze(mag);
phasep = squeeze(phase);

bode(sys)


figure
%subplot(2,1,1)
semilogx(w_sys,20*log10(magp),w,20*log10(Vratio),'o')
xlabel('Frequency (rad/sec)')
ylabel('Magnitude(db)')

%{
subplot(2,1,2)
semilogx(w,phasep,w_data,phase_data,'o')
xlabel('Frequency (rad/sec)')
ylabel('Phase (deg)')
%}

