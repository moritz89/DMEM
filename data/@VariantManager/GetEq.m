function [eqList, mode] = GetEq(obj, slot)
%VariantGetEq Return all real and virtuell Eq's listed in Variants
%   The list is ordered as follows: [Null RealHzl RealHtuc VirtuellSimple]
%   This can be generalized to: [Null, Real Eq's, virtuell Eq's]

eqList = {'Null'};
mode = 1;

% Range check. Exit with error status if it fails
if(slot < 1 || slot > obj.VariantsInfo.EqVirtuellAnzahl)
    error('Out-of-bounds slot value in GetEq');
end

% Add real, then virtuell Eq's
for i = {'Real', 'Virtuell'}
    eq = obj.Variants.Eq.(i{:});
    eqFields = fieldnames(eq);
    for j = eqFields'
        eqList = [eqList [i{:} j{:}]];
    end
end

% A virtuell or null Eq is acitve
if(evalin('base', ['EqVirtuell' num2str(slot) 'Mux']) == 1)
    % The null Eq is active
    if(evalin('base', ['EqVirtuell' num2str(slot) 'Mode']) == 0)
        mode = 1;
    % A virtuell Eq is active
    else
        % Refer to the list order. Virtuell variants are last
        modeShift = 1 + numel(fieldnames(obj.Variants.Eq.Real));
        mode = modeShift + evalin('base', ['EqVirtuell' num2str(slot) 'Mode;']);
    end
% A real Atm is active
else
    % The null variant is first in the list, but this is offset by the mux
    % ordering. This can be seen in VirtuellHardwareMuxM2Eq5/EqMux1
    modeShift = 0;
    mode = modeShift + evalin('base', ['EqVirtuell' num2str(slot) 'Mux;']);
end

end