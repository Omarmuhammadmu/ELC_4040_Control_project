%{
* FILE DESCRIPTION
* File: controlProjectCode.m
* Control project
* Description of the porject:
    Designing a compensator such that the closed-loop sampled data system has a phase margin
    of at least 50° and a gain margin of at least 10 dB. It is required to have a velocity error
    constant of 10. Plot and comment on the step-response of the compensated system.
* Author:Omar Muhammad Mustafa
* Date: 20th December 2023
%}
%% clear all WorkSpace Variables and Command Window
clc;
clear ;
close all;
%% Create the transfer function in dicrete domain
s = tf('s');
Ts = 0.1;   %Sampling time.
fprintf('**********************************************************\n')
fprintf('                 Original System response                 \n')
fprintf('**********************************************************\n')
%Create the plant continuous time transfer function
fprintf('   --- Plant continuous transfer funtion --- ')
Gp_s =(2*s+1)/(s*(s+1)*(0.2*s+1))
SD_Feedback = Gp_s / (1 + Gp_s);           %Create Feedback responde in S-domain
fprintf('   --- Continuous Feedback transfer funtion --- ')
SD_Feedback = minreal(SD_Feedback)
%Create the discrete transfer function for both the open loop
fprintf('   --- Plant discrete transfer funtion --- ')
Gp_z = c2d(Gp_s ,Ts,'zoh')                 %Convert GpH from S-domain to Z-domain
ZD_Feedback = Gp_z/(1+Gp_z);               %Create Feedback responde in Z-domain
fprintf('   --- Discrete Feedback transfer funtion --- ')
ZD_Feedback = minreal(ZD_Feedback)
%Create the Plant transfer funtion in W domain
GH_w = d2c(Gp_z,'Tustin');                  %Convert GpH from Z-domain to W-domain
WD_Feedback = d2c(ZD_Feedback,'Tustin');    %Get the feedback function in W_domain (Continuous domain)
fprintf('   --- Poles of the orginial discrete system --- ')
Poles_orginalSystem = pole(WD_Feedback)
%% Calculating old Kv
fprintf('   --- Velocity error constant (Kv)  --- ')
syms S
oldSys = S*((2*S+1)/(S*(S+1)*(0.2*S+1)));
Kv_old = limit(oldSys, S, 0)
%% Plotting the GM and PM of the already existing system and the step reponse of it.
figure('Name','Step response and Bode plot of the original system');
subplot(2,1,1) % 2 rows, 1 column, first position
step(WD_Feedback,5); %Plotting step response of the continuous system 
hold on
step(ZD_Feedback,5); %Plotting step response of the discrete system
subplot(2,1,2) % 2 rows, 1 column, second position
margin(GH_w)         %Plotting the PM and GM of the system 
%% Mulipling the system with a gain
fprintf('**********************************************************\n')
fprintf('     Original System multiplied by a gain response        \n')
fprintf('**********************************************************\n')

k = 10;
fprintf('   --- Plant continuous transfer funtion --- ')
Gp_s_With_Gain = k * (2*s+1)/(s*(s+1)*(0.2*s+1))
SD_Feedback_Gain = Gp_s_With_Gain / (1 + Gp_s_With_Gain);           %Create Feedback responde in S-domain
fprintf('   --- Continuous Feedback transfer funtion --- ')
SD_Feedback_Gain = minreal(SD_Feedback_Gain)

%Create the discrete transfer function for both the open loop
fprintf('   --- Plant discrete transfer funtion --- ')
Gp_z_Gain = c2d(Gp_s_With_Gain ,Ts,'zoh')                 %Convert GpH from S-domain to Z-domain
ZD_Feedback_Gain = Gp_z_Gain/(1+Gp_z_Gain);               %Create Feedback responde in Z-domain
fprintf('   --- Discrete Feedback transfer funtion --- ')
ZD_Feedback_Gain = minreal(ZD_Feedback_Gain)

%Create the Plant transfer funtion in W domain
GH_w_Gain = d2c(Gp_z_Gain,'Tustin');           %Convert GpH from Z-domain to W-domain
WD_Feedback_Gain = d2c(ZD_Feedback_Gain,'Tustin');    %Get the feedback function in W_domain (Continuous domain)

%% Calculating Kv after multiplying the system by 10
fprintf('   --- Velocity error constant (Kv)  --- ')
Kv_Gain = limit((k * oldSys), S, 0)

%% Plotting the GM and PM of the already existing system yet multipled by a gain and the step reponse of it.

figure('Name','Step response and Bode plot of the original system multiplied by a gain');
subplot(2,1,1) % 2 rows, 1 column, first position
step(WD_Feedback_Gain,10); %Plotting step response of the continuous system 
hold on
step(ZD_Feedback_Gain,10); %Plotting step response of the discrete system
subplot(2,1,2) % 2 rows, 1 column, second position
margin(GH_w_Gain)         %Plotting the PM and GM of the system

%% Designing compensator
fprintf('*****************************************************************************************\n')
fprintf('     Original System multiplied by a gain and add to it the lag conpensator response     \n')
fprintf('*****************************************************************************************\n')

%This line is to be uncommented when the lag compensator is being designed
%sisotool(GH_w_Gain)
fprintf('   --- Lag compensator in w-domain  --- \n')
fprintf('SISO tool returns the compensator in continuous domain which is W but it converts variable W to S as it has no W.\n')
Gd_W = (1 + 7.6*s)/(1 + 34 * s)
fprintf('   --- Lag compensator in Z-domain  --- ')
Gd_Z = c2d(Gd_W ,Ts,'Tustin')
compensatedSystem_z = Gd_Z * Gp_z_Gain ;
compensatedSystem_w = d2c(compensatedSystem_z,'Tustin');

compensatedSystem_z_Feedback = compensatedSystem_z / (1 + compensatedSystem_z);
compensatedSystem_w_Feedback = d2c(compensatedSystem_z_Feedback,'Tustin');
compensatedSystem_w_Feedback = minreal(compensatedSystem_w_Feedback);

fprintf('   --- Poles of the Compensated system --- ')
Poles_compensatedSystem = pole(compensatedSystem_w_Feedback)

%% Plotting the GM and PM of the compensated system and the step reponse of it.
figure('Name','Step response and Bode plot of the compensated system ');
subplot(2,1,1) % 2 rows, 1 column, first position
step(compensatedSystem_w_Feedback,10); %Plotting step response of the continuous system 
hold on
step(compensatedSystem_z_Feedback,10); %Plotting step response of the discrete system
subplot(2,1,2) % 2 rows, 1 column, second position
margin(compensatedSystem_w)         %Plotting the PM and GM of the system

%End of the code
