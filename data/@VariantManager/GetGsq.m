function [ list, mode ] = GetGsq(obj)
%VariantGetGsq Returns the state (true/false ) of the Gleichstromquelle (Gsq)

modeShift = 1;
mode = modeShift + evalin('base', 'GsqRealBimaqMode;');

list = {'Null'};

% Add real, then virtuell Gsq's
for i = {'Real', 'Virtuell'}
    gsq = obj.Variants.Gsq.(i{:});
    gsqFields = fieldnames(gsq);
    for j = gsqFields'
        list = [list [i{:} j{:}]];
    end
end

end

