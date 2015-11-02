function [variant] = GetActiveEms(obj)
%GETACTIVEEMS Summary of this function goes here
%   Detailed explanation goes here

mode = evalin('base', 'EmsMode');
if(mode == 0)
    variant = 'Null';
else
    for i = fieldnames(obj.Variants.Ems)'
        activeCondition = obj.Variants.Ems.(i{:});
        if(mode == activeCondition)
            variant = i{:};
        end
    end
end

