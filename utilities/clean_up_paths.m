function [files, folders] = clean_up_paths()
% The paths and file signatures to delete when closing the project
%
%   @author Moritz Ulmer<moritz.ulmer@posteo.de>
%   @created 15.12.2015
%   @updated 9.7.2015

% Delete these folders
folders = { ...
    fullfile('work','slprj')
};

% Delete all files the match the expression
files = { ...
    '*.autosave', ...
    '*.mexa64', ...
    '*.mexa32', ...
    '*.m~'
};
end