function SaturationCallbackSelection(gcb)
%SATURATIONCALLBACKSELECTION The callback function for the selection
% radiobutton in the SaturationCallback Simulink library

% Get componentManager
global componentManager;

% Get the selected radio button value ('Guided' or 'Manual')
selection = get_param(gcb, 'SelectionRadiobutton');

% Get mask widgets
mask = Simulink.Mask.get(gcb);
type = get_param(gcb, 'TypePopup');
typePopup = mask.getParameter('TypePopup');
subTypePopup = mask.getParameter('SubTypePopup');
variantPopup = mask.getParameter('VariantPopup');
variablePopup = mask.getParameter('VariablePopup');

% In guided mode, show the popup menus, hide them in manual mode
if(strcmp(selection, 'Guided'))
    typePopup.set('Visible', 'on');
    if(componentManager.HasSubType(type))
        subTypePopup.set('Visible', 'on');
    else
        subTypePopup.set('Visible', 'off');
    end
    variantPopup.set('Visible', 'on');
    variablePopup.set('Visible', 'on');
elseif(strcmp(selection, 'Manual'))
    typePopup.set('Visible', 'off');
	subTypePopup.set('Visible', 'off');
    variantPopup.set('Visible', 'off');
    variablePopup.set('Visible', 'off');
else
    % A sign that the GUI has been changed without changing the backend code
    warn(['Undefined radiobutton selection for SaturationCallback library' ...
    'in block ' gcb]);
end

end