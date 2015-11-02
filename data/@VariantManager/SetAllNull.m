function [ output_args ] = SetAllNull(obj)
%SETALLNULL Summary of this function goes here
%   Detailed explanation goes here

% Set Top Level Subsystems to null   
obj.SetDriveSim('Null');
obj.SetEms('Null');
obj.SetHardwareIo('Null');
obj.SetVirtuellHardware('Null');

% Set Atm/Last/Eq/Gsq to Null
for i = 1:obj.VariantsInfo.AtmLastVirtuellAnzahl
    obj.SetAtm('Null', i);
end

for i = 1:obj.VariantsInfo.EqVirtuellAnzahl
    obj.SetEq('Null', i);
end

obj.SetGsq('Null');
obj.SetLast('Null');

end

