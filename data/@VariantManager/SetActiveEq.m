function status = SetActiveEq(obj, variant, subType, slot)
%SETACTIVEEQ Wrapper function for SetEq

if(strcmp(variant, 'Null'))
    status = obj.SetEq('Null', slot);
else
    status = obj.SetEq([subType variant], slot);
end

end

