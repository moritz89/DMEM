function [variant, subType] = GetActiveGsq(obj)
%GETACTIVEGSQ Summary of this function goes here
%   Detailed explanation goes here

subType = 'Real';
variant = 'Null';
for i = fieldnames(obj.Variants.Gsq.Real)'
    % Only Real Gsq's exist
    mode = evalin('base', ['GsqReal' i{:} 'Mode']);
    if(mode == 1)
        variant = i{:};
    end
end

end

