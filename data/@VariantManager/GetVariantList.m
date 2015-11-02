function [list, mode] = GetVariantList(obj, type, slot)
%GETVARIANTLIST Wrapper function for the get list of variants functions
%   Use the output of GetVariantTypes as the input

switch type
    case 'Atm'
        [list, mode] = obj.GetAtm(slot);
    case 'DriveSim'
        [list, mode] = obj.GetDriveSim();
    case 'Ems'
        [list, mode] = obj.GetEms();
    case 'Eq'
        [list, mode] = obj.GetEq(slot);
    case 'Gsq'
        [list, mode] = obj.GetGsq();
    case 'HardwareIo'
        [list, mode] = obj.GetHardwareIo();
    case 'Last'
        [list, mode] = obj.GetLast();
    case 'VirtuellHardware'
        [list, mode] = obj.GetVirtuellHardware();
end

end

