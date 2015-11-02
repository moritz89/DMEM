function variants = GetVariants(obj, type, subType)
%GETVARIANTS Returns the list of variants for a given type and subType

if(obj.HasSubType(type))
    variants = fieldnames(obj.Variants.(type).(subType));
else
    variants = fieldnames(obj.Variants.(type));
end

end

