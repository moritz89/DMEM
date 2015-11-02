function [ list, mode ] = GetHardwareIo(obj)
%VARIANTGETHARDWAREIO Return all HardwareIo's listed in Variants
%   The list looks as follows: [Null Rti1103]

list = {'Null'};

variantFields = fieldnames(obj.Variants.HardwareIo);
for i = variantFields'
    list = [list i{:}];
end

mode = evalin('base', 'HardwareIoMode;') + 1;

end

