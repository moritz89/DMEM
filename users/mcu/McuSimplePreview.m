function handles = McuSimplePreview(handles)
%SIMPLEPREVIEW A sample implementation of a preview script used by the
% select_results/'Experiment Run Manager' GUI for the preview axes

global experimentRunManager;
% Find required signals
experimentRun = experimentRunManager.GetActiveExperimentRun();
logsOut = experimentRun.SimOut.get('logsout');
fBrems = logsOut.getElement('F_brems in N');
mIstMotor = logsOut.getElement('M_istMotor in Nm');
auto = experimentRun.GetComponent('Auto', '', 'V9');
radradius = auto.GetVariableValue('Radradius');
% Calculate the Motor force from the torque
fIstMotor = mIstMotor;
fIstMotor.Values.Data = fIstMotor.Values.Data / radradius;
% Find prevew axes handle
axesStruct = get(handles.preview_axes);
axes = [];
for i = axesStruct.Parent.Children'
    if(strcmp(i.Tag, 'preview_axes'));
        axes = i;
    end
end
% Setup preview axes, import signals
if(not(isempty(axes)))
    % Set lines
    hold on;
    plot(axes, fBrems.Values.Time, fBrems.Values.Data)
    plot(axes, fIstMotor.Values.Time, fIstMotor.Values.Data)
    % Set Labels
    axes.Title.String = 'Acceleration versus Braking Force';
    axes.Title.FontSize = 12;
    axes.YLabel.String = 'Force (N)';
    axes.YLabel.FontSize = 10;
    axes.XLabel.String = 'Time (seconds)';
    axes.XLabel.FontSize = 10;
else
    warning('Axes not found in select_results GUI (Experiment Run Manager)');
end

end

