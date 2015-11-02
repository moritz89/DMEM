function [status] = IsRealEqSet( obj, field )
%IsRealEqSet Check if a real Eq is active in any of the virtuell mux slots.
%   The mux policy is such that only one virtuell mux slot is allowed to input
%   a given real atm, i.e. RealBimaq or RealBremergy. This function checks
%   if any other virtuell mux slot already inputs the given Eq (field)

mux = obj.Variants.Eq.Real.(field(5:numel(field)));
status = 0;

for i = 1:obj.VariantsInfo.EqVirtuellAnzahl
    evalString = ['EqVirtuell' num2str(i) 'Mux'];
    evalMux = evalin('base', evalString) - 1;
    if(mux == evalMux)
        status = 1;
    end
end

end

