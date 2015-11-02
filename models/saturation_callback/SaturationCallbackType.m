function modelVariable = SaturationCallbackType(gcb)
%SATURATIONCALLBACKTYPE The callback function for the type popup in the
% SaturationCallback Simulink library. Returns the selected ModelVariable

% Get componentManager and turn off warnings when changing the popup menus
global componentManager;
warning('off', 'Simulink:Masking:ResetMaskParameterValueToDefault');

% Use the given path in the model variable field if Manual mode is selected.
% Do not evaluate the popup menus as they are not visible.
selection = get_param(gcb, 'SelectionRadiobutton');
if(strcmp(selection, 'Manual'))
    path = get_param(gcb, 'ModelVariableEdit');
    modelVariable = eval(path);
    return;
end

% Get mask widgets
mask = Simulink.Mask.get(gcb);
type = get_param(gcb, 'TypePopup');
subTypePopup = mask.getParameter('SubTypePopup');
variantPopup = mask.getParameter('VariantPopup');
variablePopup = mask.getParameter('VariablePopup');

% Set Widgets -------------------------------------------------------------
% Set subType widget
subTypes = sort(componentManager.GetSubTypes(type));
if(isempty(subTypes))
    subTypePopup.set('Visible', 'off');
    subType = '';
else
    subTypePopup.set('TypeOptions', subTypes);
    subType = get_param(gcb, 'SubTypePopup');
    subTypePopup.set('Visible', 'on');
end

% Set variant widget
variants = sort(componentManager.GetVariants(type, subType));
variantPopup.set('TypeOptions', variants);
variant = get_param(gcb, 'VariantPopup');

% Set variable widget
component = componentManager.GetActiveComponent(type, subType, variant);
variables = sort(component.GetVariableNames());
if(isempty(variables))
	variablePopup.set('TypeOptions', {'Null'});
    variable = get_param(gcb, 'VariablePopup');
    modelVariable = ModelVariable(variable, 0);
else
    variablePopup.set('TypeOptions', variables);
    variable = get_param(gcb, 'VariablePopup');
    modelVariable = component.GetVariable(variable);
end

% Set ModelVariable Edit widget
path = componentManager.GetActiveVariablePath(type, subType, variant, variable);
set_param(gcb, 'ModelVariableEdit', path);

end