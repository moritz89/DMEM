function [variant, subType] = GetActiveLast(obj)
%GETACTIVELAST Summary of this function goes here
%   Detailed explanation goes here

subType = 'Real';
variant = 'Null';
for i = fieldnames(obj.Variants.Last.Real)'
    mode = evalin('base', ['LastReal' i{:} 'Mode']);
    if(mode == 1)
        variant = i{:};
    end
end

end

