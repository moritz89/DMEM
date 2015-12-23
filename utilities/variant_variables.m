function [Variants, VariantsInfo] = variant_variables()
%VARIANT_VARIABLES Summary of this function goes here
%   Detailed explanation goes here

% Whether a type has or does not have subTypes
hasSubType = struct('HardwareControl', 0, 'Hardware', 0, 'DriveSim', 0, ...
                    'Ems', 0, 'Atm', 1, 'Last', 1, 'Eq', 1, 'Gsq', 1);
% Number of virtuell Atm's and Eq's in use
VariantsInfo = struct('AtmLastAnzahl', 2, ...
                      'EqAnzahl', 5, ...
                      'HasSubType', hasSubType);

% Top-Level blocks
Hardware = struct('M2Eq5', 1);
HardwareControl = struct('Sample', 1);
DriveSim = struct('V1', 1);
Ems = struct('M2Eq5', 1);

% The value denotes the order used for the mux ports in the VirtuellHardware(De)Mux
% blocks. The individual blocks only hava a true or false variant
AtmReal = struct('DcMotor', 1, 'AcMotor', 2);
LastReal = struct('SyncMotor', 1);
EqReal = struct('NiMH', 1, 'ZincAir', 2);
GsqReal = struct('HighVolt', 1);

% The value denotes the mode for selection in the Virtuell AtmLast /
% Energiequelle (Eq) Interfaces. The value is incremented with each
% variant. The Last and Gsq structs are only placeholders.
AtmVirtuell = struct('Simple', 1);
LastVirtuell = struct();
EqVirtuell = struct('Simple', 1);
GsqVirtuell = struct();

Gsq = struct('Real', GsqReal, 'Virtuell', GsqVirtuell);
Atm = struct('Real', AtmReal, 'Virtuell', AtmVirtuell);
Last = struct('Real', LastReal, 'Virtuell', LastVirtuell);
Eq = struct('Real', EqReal, 'Virtuell', EqVirtuell);

Variants = struct('Hardware', Hardware, ...
                  'HardwareControl', HardwareControl, ...
                  'DriveSim', DriveSim, ...
                  'Ems', Ems, ...
                  'Gsq', Gsq, 'Atm', Atm, 'Last', Last, 'Eq', Eq);
end

