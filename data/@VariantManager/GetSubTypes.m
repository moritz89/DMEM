function subTypes = GetSubTypes(obj, type)
%GETSUBTYPES Returns the subTypes of a type

subTypes = fieldnames(obj.Variants.(type));

end

