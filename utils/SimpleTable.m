classdef SimpleTable < handle
    % SimpleTable 简单数据表
    % 将误差表（或耗时表）存储和输出，输出支持文本格式和latex表格格式，可以输出到控制台或文件中

    properties(SetAccess = private)
        strMat % 显示的数据，以字符串元胞数组的形式存储

        % 仅在使用latex格式输出时有效
        captionStr % 表格标题
        labelStr % 表格标签
    end

    methods(Static)
        function obj = CreateWithOrder(dataMat, headerStrs, descStrs, formatStr, errorNums)
            if size(headerStrs,2) ~= size(dataMat, 2)
                error('rows of headerStrs must match the data rows.');
            end

            if size(descStrs,1) ~= size(dataMat, 1)
                error('columns of descStrs must match the data columns.');
            end

            orderMat = zeros(size(dataMat));
            for w=1:size(orderMat,1)-1
                tmp = log(errorNums(w)/errorNums(w+1));
                orderMat(w,:) = -log(dataMat(w,:)./dataMat(w+1,:))/tmp;
            end

            obj = SimpleTable();
            obj.strMat = cell(size(dataMat, 1)+size(headerStrs,1), size(dataMat, 2)+size(descStrs,2));

            for p=1:size(obj.strMat,1)
                for q=1:size(obj.strMat,2)
                    if p <= size(headerStrs,1) && q <= size(descStrs,2)
                        obj.strMat{p,q} = '';
                    elseif p <= size(headerStrs,1) && q > size(descStrs,2)
                        column = q - size(descStrs,2);
                        obj.strMat{p,q} = char(headerStrs{p,column});
                    elseif p > size(headerStrs,1) && q <= size(descStrs,2)
                        row = p - size(headerStrs,1);
                        obj.strMat{p,q} = char(descStrs{row,q});
                    else
                        row = p - size(headerStrs,1);
                        column = q - size(descStrs,2);

                        if row == 1
                            obj.strMat{p,q} = sprintf(formatStr{1,1}, dataMat(row, column));
                        else
                            obj.strMat{p,q} = sprintf(formatStr{1,2}, dataMat(row, column), orderMat(row-1, column));
                        end
                    end
                end
            end
        end

        function obj = Create(dataMat, headerStrs, descStrs, formatStr)
            if size(headerStrs,2) ~= size(dataMat, 2)
                error('rows of headerStrs must match the err rows.');
            end
            if size(descStrs,1) ~= size(dataMat, 1)
                error('columns of descStrs must match the err columns.');
            end

            obj = SimpleTable();
            obj.strMat = cell(size(dataMat, 1)+size(headerStrs,1), size(dataMat, 2)+size(descStrs,2));

            for p=1:size(obj.strMat,1)
                for q=1:size(obj.strMat,2)
                    if p <= size(headerStrs,1) && q <= size(descStrs,2)
                        obj.strMat{p,q} = '';
                    elseif p <= size(headerStrs,1) && q > size(descStrs,2)
                        column = q - size(descStrs,2);
                        obj.strMat{p,q} = char(headerStrs{p,column});
                    elseif p > size(headerStrs,1) && q <= size(descStrs,2)
                        row = p - size(headerStrs,1);
                        obj.strMat{p,q} = char(descStrs{row,q});
                    else
                        row = p - size(headerStrs,1);
                        column = q - size(descStrs,2);
                        obj.strMat{p,q} = sprintf(formatStr, dataMat(row, column));
                    end
                end
            end
        end
    end

    methods
        function addInfo(obj, captionStr, labelStr)
            obj.captionStr = captionStr;
            obj.labelStr = labelStr;
        end

        function printDetail(obj, transposeFlag, latexFlag, fileName)
            if transposeFlag
                mat = obj.strMat';
            else
                mat = obj.strMat;
            end

            colWidths = zeros(1, size(mat, 2));
            for q = 1:size(mat, 2)
                maxLen = 0;
                for p = 1:size(mat, 1)
                    maxLen = max([maxLen, length(mat{p, q})]);
                end
                colWidths(q) = maxLen;
            end
            colWidths = colWidths + 2; % 2 spaces for padding

            if isempty(fileName)
                fid = 1;
            else
                % 确保目录存在
                [filePath, ~, ~] = fileparts(fileName);
                if ~isempty(filePath) && ~exist(filePath,'dir')
                    mkdir(filePath);
                end

                fid = fopen(fileName, 'w'); % 打开文件
                if fid == -1
                    error('unable to open file %s', fileName);
                end
                cleanup = onCleanup(@() fclose(fid)); % 确保文件在退出时关闭
            end

            % latex列表开头
            if latexFlag
                fprintf(fid, '\\begin{table}[ht]\n    \\centering\n    \\begin{tabular}{l%s}\n        \\hline\n', repmat('|l', 1, size(mat, 2)-1));
            end

            for p = 1:size(mat, 1)
                if latexFlag
                    fprintf(fid, '        ');
                end

                for q = 1:size(mat, 2)
                    formatStr = sprintf('%%-%ds', colWidths(q));
                    fprintf(fid, formatStr, mat{p, q});

                    if latexFlag && q < size(mat, 2)
                        fprintf(fid, ' & ');
                    end
                end

                if latexFlag
                    fprintf(fid, '\\\\\n        \\hline\n');
                else
                    fprintf(fid, '\n');
                end
            end

            % latex列表结束
            if latexFlag
                fprintf(fid, '    \\end{tabular}\n    \\caption{%s}\n    \\label{%s}\n\\end{table}',...
                        obj.captionStr, obj.labelStr);
            end
        end

        function print(obj, varargin)
            % 打印表格
            % 支持参数 -trans -latex -file (支持缩写 -t -l -f，也支持大写 -T -L -F)
            % 使用例如 obj.print('-t', 'yes', '-f', 'table.tex', '-l', 'yes');
            %
            % 这几个选项都是可选的，具体逻辑如下：
            % 1. 缺省-trans参数时，按照行列大小关系自动选择是否转置
            % 2. 缺省-latex参数时，按照是否输出到文件中自动选择是否使用latex：输出到文件中默认yes，输出到控制台默认no
            % 3. 缺省-file参数时，默认输出到控制台

            % 默认参数值
            transposeFlagStr = 'auto';
            latexFlagStr = 'auto';
            fileName = '';

            % 定义允许的选项和验证字符串
            validOptions = {'-trans', '-latex', '-file'};

            % 成对地解析输入的选项和值
            for k = 1:2:length(varargin)
                option = validatestring(varargin{k}, validOptions, mfilename, 'option', k);
                value = varargin{k+1};

                switch option
                    case '-trans'
                        transposeFlagStr = validatestring(value, {'yes', 'no', 'auto'}, mfilename, 'Transpose');
                    case '-latex'
                        latexFlagStr = validatestring(value, {'yes', 'no', 'auto'}, mfilename, 'Latex');
                    case '-file'
                        fileName = value;
                end
            end

            % 缺省-trans参数时，按照行列关系自动选择是否转置
            if strcmp(transposeFlagStr,'auto')
                if size(obj.strMat, 2) > size(obj.strMat, 1) && size(obj.strMat, 2) > 5
                    transposeFlagStr = 'yes';
                else
                    transposeFlagStr = 'no';
                end
            end

            % 缺省-latex参数时，按照是否输出到tex文件中自动选择是否采用latex格式
            if strcmp(latexFlagStr,'auto')
                if ~isempty(fileName) && strcmp(fileName(end-3:end), '.tex')
                    latexFlagStr = 'yes';
                else
                    latexFlagStr = 'no';
                end
            end

            % 调用printDetail完成具体的操作
            obj.printDetail(strcmp(transposeFlagStr,'yes'), strcmp(latexFlagStr,'yes'), fileName);
        end
    end
end
