function [] = InitHardwareVariant(name)
%VariantInitModeAndNull Creates Mode variable and Null variant for 'name' block
%   'name' is used as the prefix to create the mode variable, i.e.
%   AtmBimaqMode and the null variant, i.e. AtmBimaqNullVar. The mode is
%   set to 0 and the null variant is active when its respective mode
%   variable equals 0.

% Create Mode variable
evalString = [name 'Mode = 0;'];
evalin('base', evalString);

% Create Null Variant
evalString = [name 'NullVar = Simulink.Variant(''' name 'Mode == 0'');'];
evalin('base', evalString);

% Create Hardware Interface Variant
evalString = [name 'RealVar = Simulink.Variant(''' name 'Mode == -1'');'];
evalin('base', evalString);
end

