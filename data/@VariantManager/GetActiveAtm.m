function [variant, subType] = GetActiveAtm(obj, slot)
%GETACTIVEATM Return the active variant and respective subType for the Atm
%   with the selected slot number

% Range check. Exit with error status if it fails
if(slot < 1 || slot > obj.VariantsInfo.AtmLastVirtuellAnzahl)
    error('Out-of-bounds slot value in GetActiveAtm');
end

mode = evalin('base', ['AtmLastVirtuell' num2str(slot) 'Mode']);
mux = evalin('base', ['AtmLastVirtuell' num2str(slot) 'Mux']);
if(mux == 1)
    % When Mux == 1, a virtuell or null Atm is active
    subType = 'Virtuell';
    if(mode == 0)
        % When Mode == 0, a null Atm is active
        variant = 'Null';
    else
        % When Mode >= 1, a virtuell Atm is active
        for i = fieldnames(obj.Variants.Atm.Virtuell)'
            activeCondition = obj.Variants.Atm.Virtuell.(i{:});
            if(mode == activeCondition)
                variant = i{:};
            end
        end
    end
else
    subType = 'Real';
    for i = fieldnames(obj.Variants.Atm.Real)'
        activeCondition = obj.Variants.Atm.Real.(i{:}) + 1;
        if(mux == activeCondition)
            variant = i{:};
        end
    end
end

