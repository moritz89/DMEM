function [list, mode] = GetEms(obj)
%VARIANTGETEMS Return all Ems's listed in Variants
%   The list looks as follows: [Null M2Eq5]

list = {'Null'};

variantFields = fieldnames(obj.Variants.Ems);
for i = variantFields'
    list = [list i{:}];
end

mode = evalin('base', 'EmsMode;') + 1;

end

