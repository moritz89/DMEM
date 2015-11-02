function variants = GetAllActive(obj)
%GETALLACTIVE Summary of this function goes here
%   Detailed explanation goes here

variants = {};

% DriveSim
name = obj.GetActiveDriveSim();
if(not(strcmp(name, 'Null')))
    variant = Variant(name, 'DriveSim', '', 0);
    variants = [variants variant];
end
% Ems
name = obj.GetActiveEms();
if(not(strcmp(name, 'Null')))
    variant = Variant(name, 'Ems', '', 0);
    variants = [variants variant];
end
% HardwareIo
name = obj.GetActiveHardwareIo();
if(not(strcmp(name, 'Null')))
    variant = Variant(name, 'HardwareIo', '', 0);
    variants = [variants variant];
end
% VirtuellHardware
name = obj.GetActiveVirtuellHardware();
if(not(strcmp(name, 'Null')))
    variant = Variant(name, 'VirtuellHardware', '', 0);
    variants = [variants variant];
end
% Atm
for i = 1:obj.VariantsInfo.AtmLastVirtuellAnzahl
    [name, subType] = obj.GetActiveAtm(i);
    if(not(strcmp(name, 'Null')))
        variant = Variant(name, 'Atm', subType, i);
        variants = [variants variant];
    end
end
% Eq
for i = 1:obj.VariantsInfo.EqVirtuellAnzahl
    [name, subType] = obj.GetActiveEq(i);
    if(not(strcmp(name, 'Null')))
        variant = Variant(name, 'Eq', subType, i);
        variants = [variants variant];
    end
end

end

