close all;
clear;


%load('matlab 200ms 50 duty.mat');
filename = '\\khensu\Home04\jlouke\My Documents\RCS\RCS Single Stream Test (03-12-2015)\Wet Runs\wet run 100 percent duty cycle at 150 psi valve closed 100 open 1750 init2015-03-12 15-12.xlsx';
% column 1 = time, 2 = Force(N), 3 = Pressure(psi), 4 = Temperature(C), 8 =
% solenoid raw
data = xlsread(filename);
time = data(1:length(data),1);
VoltageSolenoid = data(1:length(data),8);
Force = data(1:length(data),2);
Pressure = data(1:length(data),3);
Temp = data(1:length(data),4);
figure
plot(time,VoltageSolenoid,time,Force)
title('Unfiltered Data')

Solenoid = VoltageSolenoid(1:end);
LoadCell = Force(1:end);
time = time(1:end);

%{

Sole = fft(VoltageSolenoid);
Load = fft(LoadcellVoltage);


figure
hold on
plot(time,Sole,time,Load)
legend('Sole','Load')
title('Filtered Data')
hold off
%}

%
%best fc for butterworth
%Using Residual Analysis


%unblock to see graph for determining fc
fs=1000; %sampling frequency
fc= 1:.1:100;
n=7;   %number of series

for i=1:length(fc)
    [b,a] = butter(n,fc(i)/(fs/2),'low');
    y= filter(b,a,LoadCell);
    res(i)=sqrt(sum((LoadCell-y).^2)/length(y));
    i=i+1;
end

figure
plot(fc,res)
title('Residuals Plot')
grid on

%implement lowpass butterworth filter for 1000hz

fc=10;  %cutoff frequency

[b,a] = butter(n,fc/(fs/2),'low');
LoadCell = filter(b,a,LoadCell);
Solenoid = filter(b,a,Solenoid);
PressureFilt = filter(b,a,Pressure);
Temperature = filter(b,a,Temp);
FilteredData = [time LoadCell PressureFilt Temperature Solenoid];
%Solenoid = filter(b,a,Solenoid);
%Solenoid = filter(b,a,Solenoid);

outputfile = '\\khensu\Home04\jlouke\My Documents\RCS\RCS Single Stream Test (03-12-2015)\filtered data\wet run 100 percent duty cycle at 150 psi valve closed 100 open 1750 init.csv';
csvwrite(outputfile,FilteredData);

figure
hold on
plot(time,Solenoid,time,LoadCell)
legend('Solenoid','LoadCell')
title('Filtered Data')
hold off

%LoadCell = (207.56*LoadCell-0.656)*-1;
Solenoid = Solenoid*-1+.8;

figure
plot(time,Solenoid,time,LoadCell)
legend('Solenoid','LoadCell')
title('Filtered Data')

figure
plot(time,Solenoid,time,PressureFilt)
legend('Solenoid','Pressure')
title('Filtered Data')

figure
plot(time,Solenoid,time,Temperature)
legend('Solenoid','Temperature')
title('Filtered Data')

%{
%find peaks(ampl) to analyze freq and period
%findpeaks returns sequence, not time vaule
[pks_l,loc_l]=findpeaks(LoadCell,'minpeakheight',.035); 
[pks_s,loc_s]=findpeaks(Solenoid,'minpeakheight',.8);

%invert the data to find the valleys
LoadCell_inv = 1.01*max(LoadCell) - LoadCell;
Solenoid_inv = 1.01*max(Solenoid) - Solenoid;

[pks_l_inv,loc_l_inv]=findpeaks(LoadCell_inv);%,'minpeakheight',.035); 
[pks_s_inv,loc_s_inv]=findpeaks(Solenoid_inv);%,'minpeakheight',.8);

pks_l_inv = LoadCell(loc_l_inv);
pks_s_inv = Solenoid(loc_s_inv);


figure
hold on
plot(time,LoadCell,time,Solenoid)
scatter(time(loc_l),pks_l)
scatter(time(loc_s),pks_s)
scatter(time(loc_l_inv),pks_l_inv)
scatter(time(loc_s_inv),pks_s_inv)
title('Lowpass Butterworth Filter with Optimal Fc')
legend('Load cell Voltage','Solenoid Voltage')

%Analyze only first three complete cycles
loc_s = loc_s([2 6 7 11 12 16]);
pks_s = pks_s([2 6 7 11 12 16]);

loc_l = loc_l([1 3 4 6 7 10]);
pks_l = pks_l([1 3 4 6 7 10]);

pks_l_inv = [pks_l_inv([4 7]);LoadCell(280);pks_l_inv([13 17 21])];
loc_l_inv = [loc_l_inv([4 7]);280;loc_l_inv([13 17 21])];

pks_s_inv = pks_s_inv([2 7 11 16 20 25]);
loc_s_inv = loc_s_inv([2 7 11 16 20 25]);

time = time(1:600);
LoadCell = LoadCell(1:length(time));
Solenoid = Solenoid(1:length(time));


figure
hold on
plot(time,LoadCell,time,Solenoid)
scatter(time(loc_l),pks_l)
scatter(time(loc_s),pks_s)
scatter(time(loc_l_inv),pks_l_inv)
scatter(time(loc_s_inv),pks_s_inv)
%title('Lowpass Butterworth Filter with Optimal Fc')
legend('Load cell Voltage','Solenoid Voltage')
xlabel('Time (s)')
ylabel('Voltage (V)')
grid on
grid minor

time(loc_l)
time(loc_s)

total_time_loadcell_on_off = diff(time(loc_l_inv))
total_time_solenoid_on_off = diff(time(loc_s_inv))

fully_developed_loadcell_on_off = diff(time(loc_l))
fully_developed_solenoid_on_off = diff(time(loc_s))


%}

%{
%find valleys?
[Maxima,MaxIdx] = findpeaks(Data);
DataInv = 1.01*max(Data) - Data;
[Minima,MinIdx] = findpeaks(DataInv);
Minima = Data(MinIdx);
%}

%}



