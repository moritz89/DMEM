function [list, mode] = GetAtm(obj, slot)
%VariantGetAtm Return all real and virtuell Atm's listed in Variants
%   The list looks as follows: [Null RealBimaq RealBremergy VirtuellSimple]
%   The slot variable is only used for mode, which indicates the active
%   variant. If only the list is of interest, set slot = 1.

list = {'Null'};
mode = 1;

% Range check. Exit with error status if it fails
if(slot < 1 || slot > obj.VariantsInfo.AtmLastVirtuellAnzahl)
    error('Out-of-bounds slot value in GetAtm');
end

% Add real, then virtuell Atm's
for i = {'Real', 'Virtuell'}
    atm = obj.Variants.Atm.(i{:});
    atmFields = fieldnames(atm);
    for j = atmFields'
        list = [list [i{:} j{:}]];
    end
end

% A virtuell or null Atm is acitve
if(evalin('base', ['AtmLastVirtuell' num2str(slot) 'Mux']) == 1)
    % The null Atm is active
    if(evalin('base', ['AtmLastVirtuell' num2str(slot) 'Mode']) == 0)
        mode = 1;
        
    % A virtuell Atm is active
    else
        % First entry is Null and the next are all real Atm variants
        modeShift = 1 + numel(fieldnames(obj.Variants.Atm.Real));
        mode = modeShift + evalin('base', ['AtmLastVirtuell' num2str(slot) 'Mode;']);
    end

% A real Atm is active
else
    % First list entry is the null Variant, but the first mux reserved for 
    % virtuell variants
    modeShift = 1 - 1;
    mode = modeShift + evalin('base', ['AtmLastVirtuell' num2str(slot) 'Mux;']);
end

end