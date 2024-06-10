function [baseName, processedFolderName]= createProcessedFolder(imageFileName)
    % Extract the file base name without the extension
    [~, baseName, ~] = fileparts(imageFileName);

    % Append '_processed' to create the new folder name
    processedFolderName = [baseName, '_processed'];

    % Create the folder if it doesn't already exist
    if ~exist(processedFolderName, 'dir')
        mkdir(processedFolderName);
        disp(['Folder "', processedFolderName, '" has been created successfully.']);
    else
        disp(['Folder "', processedFolderName, '" already exists.']);
    end
end
