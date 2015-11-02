function McuSimpleSdiRunEdit(experimentRun)
%MCUSIMPLESDIPREP Modifies the ExperimentRun's SimOut signals for the SDI
% The vehicle acceleration is calculated by retrieving preset variables 
% (vehicle mass and wheel radius), motor torque and brake force, combining 
% them and then creating a new signal. This signal is then exported into
% the Simulation Data Inspector tool

% Retrieve required signal data
simOut = experimentRun.SimOut;
logsout = simOut.get('logsout');
istMotorMomentSignal = logsout.get('M_istMotor in Nm'); % Motor Torque in Nm
istBremsKraftSignal = logsout.get('F_brems in N'); % Braking Force in N
% Check if all signals were found
if(isempty(istMotorMomentSignal) || isempty(istBremsKraftSignal))
    return;
end
istMotorMoment = istMotorMomentSignal.Values.Data;
istBremsKraft = istBremsKraftSignal.Values.Data;

% Retrieve required variable values
auto = experimentRun.GetComponent('Auto', '', 'V9');
leermasse = auto.Variables.Leermasse.Value; % Empty Mass
zuladung = auto.Variables.Zuladung.Value; % Additional load
gesamtmasse = leermasse + zuladung;
radradius = auto.Variables.Radradius.Value; % Radius of the wheels

% Convert the Wheel Torque to Acceleration
motorBeschleunigung = istMotorMoment / (gesamtmasse * radradius); % Motor Acceleration
bremsBeschleunigung = istBremsKraft / gesamtmasse; % Braking Acceleration
gesamtBeschleunigung = motorBeschleunigung + bremsBeschleunigung;

% Create new signal
beschleunigungSignal = Simulink.SimulationData.Signal;
beschleunigungTimeSeries = istMotorMomentSignal.Values;
beschleunigungTimeSeries.Name = 'Beschleunigung in m/s^2';
beschleunigungTimeSeries.Data = gesamtBeschleunigung;
% Package Signal in a Simulink.SimulationOutput object
beschleunigungSignal.Values = beschleunigungTimeSeries;
beschleunigungOutput = Simulink.SimulationOutput(beschleunigungSignal);
% Import signal into SDI with this run's SdiRunId
Simulink.sdi.addToRun(experimentRun.SdiRunId, 'vars', beschleunigungOutput);

end

