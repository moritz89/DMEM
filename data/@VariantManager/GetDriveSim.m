function [list, mode] = GetDriveSim(obj)
%VARIANTGETDRIVESIM Return all DriveSim's listed in Variants
%   The list looks as follows: [Null DriveSim]

list = {'Null'};

variantFields = fieldnames(obj.Variants.DriveSim);
for i = variantFields'
    list = [list i{:}];
end

mode = evalin('base', 'DriveSimMode;') + 1;

end

