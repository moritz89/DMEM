function [status] = SetLast(obj, field)
%VARIANTSETLAST Sets the state of the Lastmaschine (Last). This function
% does not support virtuell Last. Virtuell Lasts are integrated into
% virtuell atms and therefore do not require a seperate variant

status = 1;

if(strcmp(field, 'Null'))
    % Set the variant mode to the null variant
    evalString = ['LastRealBimaqMode = 0;'];
    evalin('base', evalString);
    status = 0;

elseif(strcmp(field(1:4), 'Real'))
    % Check if it is a legal operation with VariantsInfo
    if(not(obj.IsRealLastSet(field)))
        % Set the real mode variable to the selected variant
        evalString = ['LastReal' field(5:numel(field)) 'Mode = 1;'];
        evalin('base', evalString);
        status = 0;
    end
end

end

