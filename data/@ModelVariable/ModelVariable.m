classdef ModelVariable
% MODELVARIABLE(name, value) A single variable in a component
%   A model variable is most commonly used directly by Simulink model
%   variants as a constant by referencing the Value property. Additionally,
%   it can be used to define over- and under-run limits of signals and the
%   response to the violation, as well as add documentation and the unit of
%   the signal. Model variables are managed by Component class objects

%   @author Moritz Ulmer<moritz.ulmer@posteo.de>
%   @created 5.6.2015

properties
    Name = 'UnnamedVariable';
    Value = 0;
    Unit = '';
    Min = 0;
    MinAction = 0;
    Max = 0;
    MaxAction = 0;
    Documentation = '';
end

methods
    function obj = ModelVariable(name, value)
        obj.Value = value;
        obj.Name = name;
    end
end
    
end

