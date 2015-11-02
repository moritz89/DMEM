function status = SetActiveGsq(obj, variant, subType)
%SETACTIVEGSQ Wrapper function for SetGsq

if(strcmp(variant, 'Null'))
    status = obj.SetGsq('Null');
else
    status = obj.SetGsq([subType variant]);
end

end