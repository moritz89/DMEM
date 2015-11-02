function [status] = SetActiveAtm(obj, variant, subType, slot)
%SETACTIVEATM Wrapper function for SetAtm

if(strcmp(variant, 'Null'))
    status = obj.SetAtm('Null', slot);
else
    status = obj.SetAtm([subType variant], slot);
end

end

