function types = GetTypes(obj)
%GETTYPES Returns the variant types as a list.
%   Extracts the type names from the variants struct

types = fieldnames(obj.Variants);

end

