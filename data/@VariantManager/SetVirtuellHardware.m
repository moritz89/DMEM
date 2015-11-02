function SetVirtuellHardware(obj, field)
%VARIANTSETVIRTUELLHARDWARE Activate the selected VirtuellHardware variant

mode = 0;

% If field is not the Null variant, check the 'field' variant for the mode
if(not(strcmp(field, 'Null')))
    mode = obj.Variants.VirtuellHardware.(field);
end

evalString = ['VirtuellHardwareMode =' num2str(mode) ';'];
evalin('base', evalString);

end

