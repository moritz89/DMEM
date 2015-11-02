function SetDriveSim(obj, field)
%VARIANTSETDRIVESIM Activate the selected DriveSim variant

mode = 0;

% If field is not the Null variant, check the 'field' variant for the mode
if(not(strcmp(field, 'Null')))
    mode = obj.Variants.DriveSim.(field);
end

evalString = ['DriveSimMode =' num2str(mode) ';'];
evalin('base', evalString);

end

