function [name, subType] = GetActiveVariant(obj, type, slot)
%GETACTIVEVARIANT Wrapper function for getting the active variant and subtype
%   If the slot is not required, enter 0. If there is no subType for a
%   type, '' will be returned (empty string).

subType = '';

switch type
    case 'Auto'
        name = obj.GetActiveDriveSim();
    case 'Strecke'
        name = obj.GetActiveDriveSim();
    case 'Ems'
        name = obj.GetActiveEms();
    case 'Atm'
        [name, subType] = obj.GetActiveAtm(slot);
    case 'Last'
        [name, subType] = obj.GetActiveLast();
    case 'Eq'
        [name, subType] = obj.GetActiveEq(slot);
    case 'Gsq'
        [name, subType] = obj.GetActiveGsq();
end

end

