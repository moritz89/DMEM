function name = GetActiveHardwareIo(obj)
%GETACTIVEHARDWAREIO Wrapper function for GetHardwareIo

[list, mode] = obj.GetHardwareIo();
name = list(mode);
name = name{:};

end

