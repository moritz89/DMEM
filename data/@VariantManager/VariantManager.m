classdef VariantManager
% VARIANTMANAGER() The manager for all variants
%   The Simulink variant objects and mode variables are saved seperately in
%   the base workspace. The definitions used to create them are stored in
%   the 'Variants' property. Additional parameters such as the number of
%   Atm's and Eq's are stored in the 'VariantsInfo' property. Only the 
%   limited methods can handle Variant objects. Earlier methods used
%   strings in which the type, subType, and name were concatenated.

%   @author Moritz Ulmer<moritz.ulmer@posteo.de>
%   @created 19.3.2015
%   @updated 9.7.2015

properties
    Variants
    VariantsInfo
end

methods (Static)
    function [Variants, VariantsInfo] = Config()
	
    end
end

methods
    function obj = VariantManager()
        [obj.Variants, obj.VariantsInfo] = variant_variables();
        StructureCheck(obj);
    end
    
    Initialize(obj)
    state = StructureCheck(obj)
    SetAllNull(obj)
    
    %----------------------------------------------------------------------
    % Get/Set List of Variants
    %----------------------------------------------------------------------
    
    % Returns a list of all variants of the particular type. The subType is
    % prefixed to the variant name. Used in the GUI since each variant has
    % to be represented by a string
    [list, mode] = GetVariantList(obj, type, slot)
    
    [list, mode] = GetAtm(obj, slot)
    [list, mode] = GetDriveSim(obj)
    [list, mode] = GetEms(obj)
    [list, mode] = GetEq(obj, slot)
    [list, mode] = GetGsq(obj)
    [list, mode] = GetHardwareIo(obj)
    [list, mode] = GetLast(obj)
    [list, mode] = GetVirtuellHardware(obj)
    
    % Sets the selected variant as active. Uses the prefixed subType to
    % filter. All set functions decode the output of the corresponding get
    % functions from above. Used by the GUI where each variant is saved as
    % a string
    SetDriveSim(obj, field)
    SetEms(obj, Field)
    SetHardwareIo(obj, field)
    SetVirtuellHardware(obj, field)
    [status] = SetAtm(obj, field, slot)
    [status] = SetEq(obj, field, slot)
    [status] = SetGsq(obj, field)
    [status] = SetLast(obj, field)
    
	%----------------------------------------------------------------------
    % Get/Set Active Variant
    %----------------------------------------------------------------------
    
    % Returns name and subType of the active variant for the selected type.
    % Not compatible with the above Set functions. Compatible with all
    % SetActive functions
    [name, subType] = GetActiveAtm(obj, slot)
    [name] = GetActiveDriveSim(obj)
    [name] = GetActiveEms(obj)
    [name, subType] = GetActiveEq(obj, slot)
    [name, subType] = GetActiveGsq(obj)
    [name] = GetActiveHardwareIo(obj)
    [name, subType] = GetActiveLast(obj)
    [name] = GetActiveVirtuellHardware(obj)
    [name, subType] = GetActiveVariant(obj, type, slot);
    
    % Sets the selected variant as active. Uses the subType and slot to
    % find the correct subsystem to change the variant to. Compatible with
    % all GetActive functions.
    [status] = SetActiveAtm(obj, name, subType, slot)
    SetActiveDriveSim(obj, name)
    SetActiveEms(obj, name)
    [status] = SetActiveEq(obj, name, subType, slot)
    [status] = SetActiveGsq(obj, name, subType)
    SetActiveHardwareIo(obj, name)
    [status] = SetActiveLast(obj, name, subType)
    SetActiveVirtuellHardware(obj, name)
    
    %----------------------------------------------------------------------
    % Get/Set Variant Objects
    %----------------------------------------------------------------------
    
    % Return and accept Variant objects. The above methods use the variant
    % names (Strings) instead of Variant objects
    variants = GetAllActive(obj)
    state = SetVariant(obj, variant)
	types = GetTypes(obj) % Returns all types as a cell array
    subTypes = GetSubTypes(obj, type) % Returns the subTypes of a type
    state = HasSubType(obj, type) % Returns whether the type has a subType
    variants = GetVariants(obj, type, subType) % Returns the variants
end

methods (Static)
	% Return the variant documentation file path
    filePath = GetDocumentationFilePath(type, subType, variant)
end
methods (Access = private)
    [status] = IsRealAtmSet(obj, field)
    [status] = IsRealLastSet(obj, field)
    [status] = IsRealEqSet(obj, field)
    [status] = IsRealGsqSet(obj, field)
end
methods (Access = private, Static)
    InitModeAndNull(name)
end

end

