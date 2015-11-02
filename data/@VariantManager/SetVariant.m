function status = SetVariant(obj, variant)
%SETVARIANT Activate the model variant defined by the Variant object

status = 1;

switch variant.Type
    case 'DriveSim'
        obj.SetActiveDriveSim(variant.Name);
        status = 0;
    case 'Ems'
        obj.SetActiveEms(variant.Name)
        status = 0;
    case 'HardwareIo'
        obj.SetActiveHardwareIo(variant.Name)
        status = 0;
    case 'VirtuellHardware'
        obj.SetActiveVirtuellHardware(variant.Name)
        status = 0;
    case 'Atm'
        status = obj.SetActiveAtm(variant.Name, variant.SubType, variant.Slot);
    case 'Eq'
        status = obj.SetActiveEq(variant.Name, variant.SubType, variant.Slot);
    case 'Gsq'
        status = obj.SetActiveGsq(variant.Name, variant.SubType);
    case 'Last'
        status = obj.SetActiveLast(variant.Name, variant.SubType);
end

end

