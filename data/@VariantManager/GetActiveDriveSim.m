function [variant] = GetActiveDriveSim(obj)
%GETACTIVEDRIVESIM Summary of this function goes here
%   Detailed explanation goes here

mode = evalin('base', 'DriveSimMode');
if(mode == 0)
    variant = 'Null';
else
    for i = fieldnames(obj.Variants.DriveSim)'
        activeCondition = obj.Variants.DriveSim.(i{:});
        if(mode == activeCondition)
            variant = i{:};
        end
    end
end

end

