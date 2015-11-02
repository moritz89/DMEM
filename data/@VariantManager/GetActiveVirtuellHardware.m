function name = GetActiveVirtuellHardware(obj)
%GETACTIVEVIRTUELLHARDWARE Wrapper function for GetVirtuellHardware

[list, mode] = obj.GetVirtuellHardware();
name = list(mode);
name = name{:};

end

