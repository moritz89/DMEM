function [status] = SetGsq(obj, field)
%SetGsq Sets the state of the Gleichstromquelle (Gsq). This function
% does not support virtuell Gsq. Virtuell Gsq's are not used
status = 1;

if(strcmp(field, 'Null'))
    % Set the variant mode to the null variant
    evalString = ['GsqRealBimaqMode = 0;'];
    evalin('base', evalString);
    status = 0;

elseif(strcmp(field(1:4), 'Real'))
    % Check if it is a legal operation with VariantsInfo
    if(not(obj.IsRealGsqSet(field)))
        % Set the real mode variable to the selected variant
        evalString = ['GsqReal' field(5:numel(field)) 'Mode = 1;'];
        evalin('base', evalString);
        status = 0;
    end
end

end

