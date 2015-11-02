function [ list, mode ] = GetVirtuellHardware(obj)
%VARIANTGETVIRTUELLHARDWARE Return all VirtuellHardware's listed in Variants
%   The list looks as follows: [Null M2Eq5]

list = {'Null'};

variantFields = fieldnames(obj.Variants.VirtuellHardware);
for i = variantFields'
    list = [list i{:}];
end

mode = evalin('base', 'VirtuellHardwareMode;') + 1;

end

