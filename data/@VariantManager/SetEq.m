function [status] = SetEq(obj, field, slot)
%VariantSetEq Activate the selected Eq for the specified EqSlot
%   Check if it is Real or Virtuell and then set the proper value for the
%   respective Mode and Mux Variables. If the request is legal, 0 is
%   returned. Else 1 or higher is returned. It is illegal for a real Eq to
%   be active in more than one slot.

status = 1;

% Range check. Exit with error status if it fails
if(slot < 1 || slot > obj.VariantsInfo.EqVirtuellAnzahl)
    warning('Out-of-bounds slot value in GetActiveAtm');
    return;
end

if(strcmp(field, 'Null'))
    % Disable the real Eq if it was enabled
    mux = evalin('base', ['EqVirtuell' num2str(slot) 'Mux']);
    % Real Eq is enabled
    if(mux > 1)
        for i = fieldnames(obj.Variants.Eq.Real)'
            % Find the Eq that was connected to that slot
            if(obj.Variants.Eq.Real.(i{:}) == mux - 1)
                % Disable the real Eq
                evalString = ['EqReal' i{:} 'Mode = 0;'];
                evalin('base', evalString);
            end
        end
    end
    % Set the variant mode to the null variant
    evalString = ['EqVirtuell' num2str(slot) 'Mode = 0;'];
    evalin('base', evalString);
    % Set the variant mux to the virtuell variant
    evalString = ['EqVirtuell' num2str(slot) 'Mux = 1;'];
    evalin('base', evalString);
    status = 0;

elseif(strcmp(field(1:4), 'Real'))
    % Set the mux to the +1 of the mode
    % Check if it is a legal operation with VariantsInfo
    if(not(obj.IsRealEqSet(field)))
        % Set the real mode variable to the selected variant
        evalString = ['EqReal' field(5:numel(field)) 'Mode = 1;'];
        evalin('base', evalString);
        % Set the virtuell mode variable to null
        evalString = ['EqVirtuell' num2str(slot) 'Mode = 0;'];
        evalin('base', evalString);
        % Set the mux variable to the selected real variant
        muxPort = obj.Variants.Eq.Real.(field(5:numel(field))) + 1;
        evalString = ['EqVirtuell' num2str(slot) 'Mux = ' num2str(muxPort) ';'];
        evalin('base', evalString);
        status = 0;
    end

elseif(strcmp(field(1:8), 'Virtuell'))
    % Disable the real Eq if it was enabled
    mux = evalin('base', ['EqVirtuell' num2str(slot) 'Mux']);
    % Real Eq is enabled
    if(mux > 1)
        for i = fieldnames(obj.Variants.Eq.Real)'
            % Find the Eq that was connected to that slot
            if(obj.Variants.Eq.Real.(i{:}) == mux - 1)
                % Disable the real Eq
                evalString = ['EqReal' i{:} 'Mode = 0;'];
                evalin('base', evalString);
            end
        end
    end
    % Set the virtuell mode variable to the eqField value
    eqMode = obj.Variants.Eq.Virtuell.(field(9:numel(field)));
    evalString = ['EqVirtuell' num2str(slot) 'Mode = ' num2str(eqMode) ';'];
    evalin('base', evalString);
    % Set the mux variable to the selected real variant
    evalString = ['EqVirtuell' num2str(slot) 'Mux = 1;'];
    evalin('base', evalString);
    status = 0;
end

end

