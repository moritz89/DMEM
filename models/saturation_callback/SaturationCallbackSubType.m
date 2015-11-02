function modelVariable = SaturationCallbackSubType(gcb)
%SATURATIONCALLBACKSUBTYPE The callback function for the subType popup in the
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
subType = get_param(gcb, 'SubTypePopup');
variantPopup = mask.getParameter('VariantPopup');
variablePopup = mask.getParameter('VariablePopup');

% Set Widgets -------------------------------------------------------------
% Set variant widget
variants = sort(componentManager.GetVariants(type, subType));
variantPopup.set('TypeOptions', variants);
variant = get_param(gcb, 'VariantPopup');

% Set variable widget
component = componentManager.GetActiveComponent(type, subType, variant);
variables = sort(component.GetVariableNames());
variablePopup.set('TypeOptions', variables);
variable = get_param(gcb, 'VariablePopup');
if(isempty(variables))
    modelVariable = ModelVariable('Null', 0);
else
    modelVariable = component.GetVariable(variable);
end

% Set ModelVariable Edit widget
path = componentManager.GetActiveVariablePath(type, subType, variant, variable);
set_param(gcb, 'ModelVariableEdit', path);

end
