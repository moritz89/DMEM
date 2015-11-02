function state = CheckStructure(obj)
%STRUCTURECHECK Check if all types are listed as having or not having
%   subTypes. 0 is no problem, 1 there exists a problem. The problem is
%   returned as an error

state = 0;
brokenTypes = [];

% Check that all types are listed as having or not having a subType
for i = fieldnames(obj.Variants)'
    if(obj.HasSubType(i{:}) == -1)
        if(isempty(brokenTypes))
            brokenTypes = i{:};
        else
            brokenTypes = [brokenTypes ', ' i{:}];
        end
        state = 1;
    end
end

if(not(isempty(brokenTypes)))
    error(['The following types are not defined in VariantManager.VariantsInfo.HasSubType: ' brokenTypes])
end

end
