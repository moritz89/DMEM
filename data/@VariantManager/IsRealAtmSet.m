function [status] = IsRealAtmSet(obj, field)
%VariantRealAtmAlreadySet Check if a real Atm is already active for any of the virtuell mux slots.
%   The mux policy is such that only one virtuell mux slot is allowed to input
%   a given real atm, i.e. RealBimaq or RealBremergy. This function checks
%   if any other virtuell mux slot already inputs the given Atm (atmField)

mux = obj.Variants.Atm.Real.(field(5:numel(field)));
status = 0;

for i = 1:obj.VariantsInfo.AtmLastVirtuellAnzahl
    evalString = ['AtmLastVirtuell' num2str(i) 'Mux'];
    if(mux == evalin('base', evalString) - 1)
        status = 1;
    end
end

end

