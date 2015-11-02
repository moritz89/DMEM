function [Variants, VariantsInfo] = variant_variables()
%VARIANT_VARIABLES Summary of this function goes here
%   Detailed explanation goes here

% Whether a type has or does not have subTypes
hasSubType = struct('HardwareIo', 0, 'VirtuellHardware', 0, 'DriveSim', 0, ...
                    'Ems', 0, 'Atm', 1, 'Last', 1, 'Eq', 1, 'Gsq', 1);
% Number of virtuell Atm's and Eq's in use
VariantsInfo = struct('AtmLastVirtuellAnzahl', 2, ...
                      'EqVirtuellAnzahl', 5, ...
                      'HasSubType', hasSubType);

% Top-Level blocks
HardwareIo = struct('Sample', 1);
VirtuellHardware = struct('M2Eq5', 1);
DriveSim = struct('V1', 1);
Ems = struct('M2Eq5', 1);

% The value denotes the order used for the mux ports in the VirtuellHardware(De)Mux
% blocks. The individual blocks only hava a true or false variant
AtmReal = struct('Sample', 1, 'Sample2', 2);
LastReal = struct('Sample', 1);
EqReal = struct('Sample', 1, 'Sample2', 2);
GsqReal = struct('Sample', 1);

% The value denotes the mode for selection in the Virtuell AtmLast /
% Energiequelle (Eq) Interfaces. The value is incremented with each
% variant. The Last and Gsq structs are only placeholders.
AtmVirtuell = struct('Sample', 1, 'Sample2', 2);
LastVirtuell = struct();
EqVirtuell = struct('Sample', 1);
GsqVirtuell = struct();

Gsq = struct('Real', GsqReal, 'Virtuell', GsqVirtuell);
Atm = struct('Real', AtmReal, 'Virtuell', AtmVirtuell);
Last = struct('Real', LastReal, 'Virtuell', LastVirtuell);
Eq = struct('Real', EqReal, 'Virtuell', EqVirtuell);

Variants = struct('HardwareIo', HardwareIo, ...
                  'VirtuellHardware', VirtuellHardware, ...
                  'DriveSim', DriveSim, ...
                  'Ems', Ems, ...
                  'Gsq', Gsq, 'Atm', Atm, 'Last', Last, 'Eq', Eq);
end

