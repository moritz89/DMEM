function Initialize(obj)
%INITIALIZE Creates variants and their control variables
%   Die varianten werden anhand der Konfiguration in obj.Variants und
%   obj.VariantsInfo erzeugt. Das erweitern mit Variants in einer bereits
%   definierten Kategorie kann ohne weitere Änderungen erfolgen. Beim
%   Hinzufügen von weiteren Kategorien müssen Änderungen in the Config, so
%   wohl auch hier vorgenommen werden.

%------------------
% Top-Level Blocks
%------------------

% Initialize Hardware Variants
name = 'Hardware';
obj.InitModeAndNull(name);
for i = fieldnames(obj.Variants.Hardware)'
    mode = obj.Variants.Hardware.(i{:});
    evalString = [name i{:} 'Var = Simulink.Variant(''' name 'Mode == ' num2str(mode) ''');'];
    evalin('base', evalString);
end
% Initialize Hardware Control Variants
name = 'HardwareControl';
obj.InitModeAndNull(name);
for i = fieldnames(obj.Variants.HardwareControl)'
    mode = obj.Variants.HardwareControl.(i{:});
    evalString = [name i{:} 'Var = Simulink.Variant(''' name 'Mode == ' num2str(mode) ''');'];
    evalin('base', evalString);
end
% Initialize DriveSim Variants
name = 'DriveSim';
obj.InitModeAndNull(name);
for i = fieldnames(obj.Variants.DriveSim)'
    mode = obj.Variants.DriveSim.(i{:});
    evalString = [name i{:} 'Var = Simulink.Variant(''' name 'Mode == ' num2str(mode) ''');'];
    evalin('base', evalString);
end
% Initialize Ems Variants
name = 'Ems';
obj.InitModeAndNull(name);
for i = fieldnames(obj.Variants.Ems)'
    mode = obj.Variants.Ems.(i{:});
    evalString = [name i{:} 'Var = Simulink.Variant(''' name 'Mode == ' num2str(mode) ''');'];
    evalin('base', evalString);
end

%----------------------
% Real Hardware Blocks
%----------------------

% % Initialize Real GleichStromQuelle (Gsq) Variants
% for i = fieldnames(obj.Variants.Gsq.Real)'
%     obj.InitModeAndNull(['GsqReal' i{:}]);
%     name = ['GsqReal' i{:}];
%     evalString = [name 'TrueVar = Simulink.Variant(''' name 'Mode == 1'');'];
%     evalin('base', evalString);
% end
% % Initialize Real Antriebsmaschine (Atm) Variants
% for i = 1:obj.VariantsInfo.AtmLastAnzahl
%     name = ['AtmLastReal' num2str(i)];
%     obj.InitModeAndNull(name);
%     
%     
% for i = fieldnames(obj.Variants.Atm.Real)'
%     obj.InitModeAndNull(['AtmReal' i{:}]);
%     name = ['AtmReal' i{:}];
%     evalString = [name 'Var = Simulink.Variant(''' name 'Mode == 1'');'];
%     evalin('base', evalString);
% end
% % Initialize Real Lastmaschine (Last) Variants
% for i = fieldnames(obj.Variants.Last.Real)'
%     obj.InitModeAndNull(['LastReal' i{:}]);
%     name = ['LastReal' i{:}];
%     evalString = [name 'TrueVar = Simulink.Variant(''' name 'Mode == 1'');'];
%     evalin('base', evalString);
% end
% % Initialize Real Energiequelle (Eq) Variants
% for i = fieldnames(obj.Variants.Eq.Real)'
%     obj.InitModeAndNull(['EqReal' i{:}]);
%     name = ['EqReal' i{:}];
%     evalString = [name 'TrueVar = Simulink.Variant(''' name 'Mode == 1'');'];
%     evalin('base', evalString);
% end

%--------------------------
% Real Hardware Blocks
%--------------------------

% Initialize Atm (Antriebsmaschine) Variants and Mode
for i = 1:obj.VariantsInfo.AtmLastAnzahl
    % Create Null variants
    name = ['Atm' num2str(i)];
    obj.InitModeAndNull(name);
    % Create Real Hardware Interface variants
    for j = fieldnames(obj.Variants.Atm.Real)'
        mode = obj.Variants.Atm.Real.(j{:});
        evalString = [name 'Real' j{:} 'Var = Simulink.Variant(''' name 'Mode == ' num2str(mode) ''');'];
        evalin('base', evalString);
    end
end

% Initialize Last (Lastmaschine) Variants and Mode
for i = 1:obj.VariantsInfo.AtmLastAnzahl
    % Create Null variants
    name = ['Last' num2str(i)];
    obj.InitModeAndNull(name);
    % Create Real Hardware Interface variants
    for j = fieldnames(obj.Variants.Last.Real)'
        mode = obj.Variants.Last.Real.(j{:});
        evalString = [name 'Real' j{:} 'Var = Simulink.Variant(''' name 'Mode == ' num2str(mode) ''');'];
        evalin('base', evalString);
    end
end

% Initialize Eq (Energiequelle) Variants and Mode
for i = 1:obj.VariantsInfo.EqAnzahl
    % Create Null variants
    name = ['Eq' num2str(i)];
    % Create Real Hardware Interface variants
    for j = fieldnames(obj.Variants.Eq.Real)'
        mode = obj.Variants.Eq.Real.(j{:});
        evalString = [name 'Real' j{:} 'Var = Simulink.Variant(''' name 'Mode == ' num2str(-mode) ''');'];
        evalin('base', evalString);
    end
end

%--------------------------
% Virtuell Hardware Blocks
%--------------------------

% Initialize AtmLast (Antriebs-/Lastmaschine) Variants, Real interface, Mode
for i = 1:obj.VariantsInfo.AtmLastAnzahl
    % Create Null variants
    name = ['AtmLast' num2str(i)];
    obj.InitHardwareVariant(name);
    % Create Hardware Interface variants
    for j = fieldnames(obj.Variants.Atm.Virtuell)'
        mode = obj.Variants.Atm.Virtuell.(j{:});
        evalString = [name 'Virtuell' j{:} 'Var = Simulink.Variant(''' name 'Mode == ' num2str(mode) ''');'];
        evalin('base', evalString);
    end
end

% Initialize Virtuell EnergieQuelle (Eq) Variants, Mode, Mux
for i = 1:obj.VariantsInfo.EqAnzahl
    name = ['Eq' num2str(i)];
    obj.InitHardwareVariant(name);
    for j = fieldnames(obj.Variants.Eq.Virtuell)'
        mode = obj.Variants.Eq.Virtuell.(j{:});
        evalString = [name 'Virtuell' j{:} 'Var = Simulink.Variant(''' name 'Mode == ' num2str(mode) ''');'];
        evalin('base', evalString);
    end 
end

end

