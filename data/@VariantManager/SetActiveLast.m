function [ output_args ] = SetActiveLast(obj, variant, subType)
%SETACTIVELAST Wrapper function for SetLast

if(strcmp(subType, 'Null'))
    obj.SetLast('Null')
else
    obj.SetLast([subType variant])
end

end

