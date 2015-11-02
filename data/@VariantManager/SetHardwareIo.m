function SetHardwareIo(obj, field)
%VARIANTSETHARDWAREIO Activate the selected HardwareIo variant

mode = 0;

% If field is not the Null variant, check the 'field' variant for the mode
if(not(strcmp(field, 'Null')))
    mode = obj.Variants.HardwareIo.(field);
end

evalString = ['HardwareIoMode =' num2str(mode) ';'];
evalin('base', evalString);

end

