function state = HasSubType(obj, type)
%HASSUBTYPE Returns 1 if the type has a subType, 0 if not. 0 is returned
%   if the type is not found

if(isfield(obj.VariantsInfo.HasSubType, type))
    state = obj.VariantsInfo.HasSubType.(type);
else
    state = 0;
end

end

