function [status] = SetAtm(obj, field, slot)
%SetAtm(field, slot) Activates the selected Atm for the specified AtmSlot
%   Check if it is Real or Virtuell and then set the proper value for the
%   respective Mode and Mux Variables. If the request is legal, 0 is
%   returned. Else 1 or higher is returned. It is illegal for a real Atm to
%   be active in more than one slot.

status = 1;

% Range check. Exit with error status if it fails
if(slot < 1 || slot > obj.VariantsInfo.AtmLastVirtuellAnzahl)
    warning('Out-of-bounds slot value in GetActiveAtm');
    return;
end

if(strcmp(field, 'Null'))
    % Disable the real Atm if it was enabled
    mux = evalin('base', ['AtmLastVirtuell' num2str(slot) 'Mux']);
    % Real Atm is enabled
    if(mux > 1)
        for i = fieldnames(obj.Variants.Atm.Real)'
            % Find the Atm that was connected to that slot
            if(obj.Variants.Atm.Real.(i{:}) == mux - 1)
                % Disable the real Atm
                evalString = ['AtmReal' i{:} 'Mode = 0;'];
                evalin('base', evalString);
            end
        end
    end
    % Set the variant mode to the null variant
    evalString = ['AtmLastVirtuell' num2str(slot) 'Mode = 0;'];
    evalin('base', evalString);
    % Set the variant mux to the virtuell variant
    evalString = ['AtmLastVirtuell' num2str(slot) 'Mux = 1;'];
    evalin('base', evalString);
    status = 0;

elseif(strcmp(field(1:4), 'Real'))
    % Set the mux to the +1 of the mode
    % Check if it is a legal operation with VariantsInfo
    if(not(obj.IsRealAtmSet(field)))
        % Set the real mode variable to the selected variant
        evalString = ['AtmReal' field(5:numel(field)) 'Mode = 1;'];
        evalin('base', evalString);
        % Set the virtuell mode variable to null
        evalString = ['AtmLastVirtuell' num2str(slot) 'Mode = 0;'];
        evalin('base', evalString);
        % Set the mux variable to the selected real variant
        muxPort = obj.Variants.Atm.Real.(field(5:numel(field))) + 1;
        evalString = ['AtmLastVirtuell' num2str(slot) 'Mux = ' num2str(muxPort) ';'];
        evalin('base', evalString);
        status = 0;
    end
    
elseif(strcmp(field(1:8), 'Virtuell'))
    % Disable the real Atm if it was enabled
    mux = evalin('base', ['AtmLastVirtuell' num2str(slot) 'Mux']);
    % Real Atm is enabled
    if(mux > 1)
        for i = fieldnames(obj.Variants.Atm.Real)'
            % Find the Atm that was connected to that slot
            if(obj.Variants.Atm.Real.(i{:}) == mux - 1)
                % Disable the real Atm
                evalString = ['AtmReal' i{:} 'Mode = 0;'];
                evalin('base', evalString);
            end
        end
    end
    % Set the virtuell mode variable to the atmField value
    atmMode = obj.Variants.Atm.Virtuell.(field(9:numel(field)));
    evalString = ['AtmLastVirtuell' num2str(slot) 'Mode = ' num2str(atmMode) ';'];
    evalin('base', evalString);
    % Set the mux variable to the selected real variant
    evalString = ['AtmLastVirtuell' num2str(slot) 'Mux = 1;'];
    evalin('base', evalString);
    status = 0;
end

end

