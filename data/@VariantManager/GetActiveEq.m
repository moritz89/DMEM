function [variant, subType] = GetActiveEq(obj, slot)
%GETACTIVEEQ Return the active variant and respective subType for the Eq
%   with the selected slot number

% Range check. Exit with error status if it fails
if(slot < 1 || slot > obj.VariantsInfo.EqVirtuellAnzahl)
    error('Out-of-bounds slot value in GetActiveAtm');
end

mode = evalin('base',['EqVirtuell' num2str(slot) 'Mode']);
mux = evalin('base',['EqVirtuell' num2str(slot) 'Mux']);
if(mux == 1)
    % When Mux == 1, a virtuell or null Eq is active
    subType = 'Virtuell';
    if(mode == 0)
        % When Mode == 0, a null Eq is active
        variant = 'Null';
    else
        % When Mode >= 1, a virtuell Eq is active
        for i = fieldnames(obj.Variants.Eq.Virtuell)'
            activeCondition = obj.Variants.Eq.Virtuell.(i{:});
            if(mode == activeCondition)
                variant = i{:};
            end
        end
    end
else
    subType = 'Real';
    for i = fieldnames(obj.Variants.Eq.Real)'
        activeCondition = obj.Variants.Eq.Real.(i{:}) + 1;
        if(mux == activeCondition)
            variant = i{:};
        end
    end
end

end

