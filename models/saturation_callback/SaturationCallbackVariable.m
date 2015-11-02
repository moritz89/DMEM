function modelVariable = SaturationCallbackVariable(gcb)
%SATURATIONCALLBACKVARIANT The callback function for the type popup in the
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
type = get_param(gcb, 'TypePopup');
if(componentManager.HasSubType(type))
    subType = get_param(gcb, 'SubTypePopup');
else
    subType = '';
end
variant = get_param(gcb, 'VariantPopup');
variable = get_param(gcb, 'VariablePopup');

% Set Widgets -------------------------------------------------------------
% Set variable widget
component = componentManager.GetActiveComponent(type, subType, variant);
variables = component.GetVariableNames();
if(isempty(variables))
    modelVariable = ModelVariable('Null', 0);
else
    modelVariable = component.GetVariable(variable);
end

% Set ModelVariable Edit widget
path = componentManager.GetActiveVariablePath(type, subType, variant, variable);
set_param(gcb, 'ModelVariableEdit', path);

end
