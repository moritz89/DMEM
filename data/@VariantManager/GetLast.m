function [list, mode] = GetLast(obj)
%VARIANTGETLAST Returns the state (true/false ) of the Lastmaschine (Last)

list = {'Null'};

% Add real, then virtuell Last's
for i = {'Real', 'Virtuell'}
    last = obj.Variants.Last.(i{:});
    lastFields = fieldnames(last);
    for j = lastFields'
        list = [list [i{:} j{:}]];
    end
end

for i = list
    evalin('base', )

end

