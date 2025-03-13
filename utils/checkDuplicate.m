function checkDuplicate(folders,allow_scripts)
    % 检查重复文件

    % 创建容器存储文件名及其路径
    fileMap = containers.Map('KeyType', 'char', 'ValueType', 'any');

    % 遍历每个文件夹
    for i = 1:length(folders)
        folder = folders{i};
        if isfolder(folder)
            % 递归获取所有.m文件（包括子目录），但是排除脚本文件
            getMFiles(folder, fileMap,allow_scripts);
        else
            warning('Folder not found: %s', folder);
        end
    end

    % 检查重复项
    keys = fileMap.keys;
    for i = 1:length(keys)
        fileName = keys{i};
        filePathsList = fileMap(fileName);

        if length(filePathsList) > 1
            % 仅显示路径不同的重复文件
            uniquePaths = unique(filePathsList);
            if length(uniquePaths) > 1
                fprintf('Duplicate file found: %s\n', fileName);
                for j = 1:length(uniquePaths)
                    fprintf('  - %s\n', uniquePaths{j});
                end

                % 比较这些文件的实质内容，如果内容存在差异则触发错误，内容完全一样则触发警告
                compareFileContents(uniquePaths)
            end
        end
    end
end


function getMFiles(folder,fileMap,allow_scripts)
    % 递归查找文件夹中的有效.m文件

    % 获取当前文件夹中的所有文件和子文件夹
    files = dir(folder);

    % 排除隐藏文件和文件夹（如.git）
    files = files(~startsWith({files.name}, '.'));

    for i = 1:length(files)
        if files(i).isdir
            % 如果是子文件夹，递归调用
            subFolder = fullfile(folder, files(i).name);
            getMFiles(subFolder,fileMap,allow_scripts);
        elseif endsWith(files(i).name, '.m')
            % 如果是.m文件，检查是否为有效的类或函数文件
            fileName = files(i).name;  % 获取文件名
            fullPath = fullfile(folder, fileName);  % 获取文件的完整路径

            % 如果不允许脚本文件重复，或者对于非脚本文件
            if ~allow_scripts || isClassOrFunctionFile(fullPath)
                % 如果文件名已存在，添加新的路径
                if isKey(fileMap, fileName)
                    fileMap(fileName) = [fileMap(fileName), {fullPath}];
                else
                    % 否则，创建新条目
                    fileMap(fileName) = {fullPath};
                end
            end
        end
    end
end

function isValid = isClassOrFunctionFile(filePath)
    % 检查给定的.m文件是否为有效的类文件或函数文件
    isValid = false;

    % 打开文件并读取内容
    fid = fopen(filePath, 'rt');

    if fid == -1
        warning('无法打开文件: %s', filePath);
        return;
    end

    % 读取文件内容并去除空行和注释
    lines = {};
    while ~feof(fid)
        line = strtrim(fgetl(fid));
        % 跳过空行和注释行
        if ~isempty(line) && ~startsWith(line, '%')
            lines{end+1} = line; %#ok<*AGROW>
        end
    end
    fclose(fid);

    % 检查文件的第一行是否以'classdef'或'function'开头
    if ~isempty(lines)
        firstLine = lines{1};
        if startsWith(firstLine, 'classdef') || startsWith(firstLine, 'function')
            isValid = true;
        end
    end
end

function compareFileContents(filePaths)
    % 比较文件内容，检测差异或相同
    if length(filePaths) < 2
        return;
    end

    % 计算第一个文件的哈希值
    file1 = filePaths{1};
    hash1 = getFileHash(file1);

    for i = 2:length(filePaths)
        file2 = filePaths{i};
        hash2 = getFileHash(file2);

        if hash1 == hash2
            % 文件内容完全相同，触发警告
            warning('Two files have the same content: \n  - %s\n  - %s', file1, file2);
        else
            % 文件内容不同，触发错误
            error('Two files have the different content! \n  - %s\n  - %s', file1, file2);
        end
    end
end

function hash = getFileHash(filePath)
    % 计算文件的哈希值
    fid = fopen(filePath, 'rt');
    if fid == -1
        error('Failed to open file: %s', filePath);
    end

    % 读取文件内容并生成哈希值
    fileContent = fread(fid, '*uint8');  % 读取文件内容为字节
    fclose(fid);

    hash = keyHash(fileContent);  % 使用 SHA-256 哈希
end
