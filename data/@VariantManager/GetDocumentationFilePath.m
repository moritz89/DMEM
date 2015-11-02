function docPath = GetDocumentationFilePath(componentType, subType, variant)
%GETDOCUMENTATIONFILENAME Returns the documentation file name of the requested variant
%   The file name is based on the type, subType and variant names

docSuffixes = {'Doc.pdf', 'Doc.doc', 'Doc.docx', 'Doc.odt', 'Doc.txt'};

switch componentType
    case 'Auto'
        fileName = ['DriveSim' variant];
    case 'Strecke'
        fileName = ['DriveSim' variant];
    case 'Ems'
        fileName = ['Ems' variant];
    case 'Atm'
        fileName = ['Atm' subType variant];
    case 'Last'
        fileName = ['Last' subType variant];
    case 'Eq'
        fileName = ['Eq' subType variant];
    case 'Gsq'
        fileName = ['Gsq' subType variant];
end

docPath = '';
for i = docSuffixes
    filePath = which([fileName i{:}]);
    if(not(isempty(filePath)))
        docPath = filePath;
        return;
    end
end

end
