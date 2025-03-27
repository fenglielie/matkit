classdef PathManager < handle
    % PathManager 数据目录管理类

    properties(SetAccess = private)
        dataRoot
    end

    methods
        function obj = PathManager(dataRoot)
            % 构造函数，初始化 dataRoot

            obj.setDataRoot(dataRoot);
        end

        function setDataRoot(obj, dataRoot)
            if exist(dataRoot, 'dir') ~= 7
                mkdir(dataRoot);
            end
            obj.dataRoot = dataRoot;
        end

        function absPath = ensureDirExists(obj, relativeDir, clearContents, backupContents)
            % 确保指定目录存在（相对dataRoot的路径，支持多级目录），然后返回绝对路径
            % 如果指定 backupContents 为 true，则将目录中的现存文件移动到备份文件夹（不会备份备份文件夹本身）
            % 如果指定 clearContents 为 true，则将目录中的现存文件删除（不会影响备份文件夹）

            % 构建绝对路径
            absPath = fullfile(obj.dataRoot, relativeDir);

            % 确保目录存在
            if exist(absPath, 'dir') ~= 7
                mkdir(absPath);
                fprintf('ensureDirExists: create dir %s\n', absPath);
            end

            % 统计一下实际文件数目
            cnt = 0;
            files = dir(fullfile(absPath, '*'));
            for k = 1:length(files)
                % 排除 '.' 和 '..' 目录，以及备份文件夹本身
                if ~strcmp(files(k).name, '.') && ~strcmp(files(k).name, '..') && ~startsWith(files(k).name, '.backup_')
                    cnt = cnt + 1;
                end
            end

            % 备份目录中的现存文件，将其移动到备份文件夹，忽略备份文件夹自身
            if backupContents && cnt > 0
                % 生成备份文件夹名称
                backupFolder = obj.generateBackupFolderName(absPath);

                % 创建备份文件夹
                mkdir(backupFolder);
                fprintf('ensureDirExists: create backup dir %s\n', absPath);

                % 移动文件到备份文件夹
                files = dir(fullfile(absPath, '*'));
                for k = 1:length(files)
                    % 排除 '.' 和 '..' 目录，以及备份文件夹本身
                    if ~strcmp(files(k).name, '.') && ~strcmp(files(k).name, '..') && ~startsWith(files(k).name, '.backup_')
                        movefile(fullfile(absPath, files(k).name), fullfile(backupFolder, files(k).name));
                    end
                end

                fprintf('ensureDirExists: backup to dir %s\n', absPath);
            end

            % 清空目录中的现存文件，忽略备份文件夹自身
            if clearContents && cnt > 0
                files = dir(fullfile(absPath, '*'));
                for k = 1:length(files)
                    % 排除 '.' 和 '..' 目录
                    if ~strcmp(files(k).name, '.') && ~strcmp(files(k).name, '..') && ~startsWith(files(k).name, '.backup_')
                        if ~files(k).isdir % 删除文件
                            delete(fullfile(absPath, files(k).name));
                        else
                            % 删除子目录及其内容
                            rmdir(fullfile(absPath, files(k).name), 's');
                        end
                    end
                end

                fprintf('ensureDirExists: clean dir %s\n', absPath);
            end

            % 统一路径分隔符为 '/'
            absPath = strrep(absPath, '\', '/');
        end

        function fullPath = getPath(obj, relativeFilePath)
            % 将相对路径转换为完整路径

            % 构建完整路径
            fullPath = fullfile(obj.dataRoot, relativeFilePath);

            % 统一路径分隔符为 '/'
            fullPath = strrep(fullPath, '\', '/');
        end
    end

    methods(Access = private)
        function backupFolder = generateBackupFolderName(~, absPath)
            % 生成不重复的备份文件夹名称 .backup_xxx

            idx = 1;
            while true
                backupFolder = fullfile(absPath, ['.backup_' num2str(idx)]);
                if exist(backupFolder, 'dir') ~= 7
                    break;
                end
                idx = idx + 1;
            end
        end
    end
end
