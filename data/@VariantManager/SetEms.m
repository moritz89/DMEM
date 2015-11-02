function SetEms(obj, field)
%VARIANTSETEMS Activate the selected Ems variant

mode = 0;

% If field is not the Null variant, check the 'field' variant for the mode
if(not(strcmp(field, 'Null')))
    mode = obj.Variants.Ems.(field);
end

evalString = ['EmsMode =' num2str(mode) ';'];
evalin('base', evalString);

end

