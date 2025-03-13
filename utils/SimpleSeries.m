classdef SimpleSeries < handle
    % SimpleSeries 简单数据表
    % 存储固定容量的二维数据表，支持逐次添加一行数据，按列名查询数据和导出数据

    properties (SetAccess = private)
        cnt % 计数器
        indexNames % 每一列的名称
        dataItems % 存储数据
    end

    methods
        function obj = SimpleSeries(indexNames, len)
            % 创建数据表
            % indexNames: 每一列的名称（要求是一个一维的cell数组）
            % len: 列长度（要求是正整数）

            validateattributes(indexNames, {'cell'}, {'vector', 'nonempty'});
            validateattributes(len, {'numeric'}, {'scalar', 'integer', 'positive'});

            obj.cnt = 0;
            obj.indexNames = indexNames;
            obj.dataItems = zeros(len, length(indexNames));
        end

        function add(obj, newItem)
            % 添加新的数据项，如果容量已满会报错；如果数据项的长度不对，也会报错

            if size(newItem, 2) ~= size(obj.dataItems, 2)
                error('SimpleSeries: Data Column Mismatch');
            end

            if obj.cnt < size(obj.dataItems, 1)
                obj.cnt = obj.cnt + 1;
                obj.dataItems(obj.cnt, :) = newItem;
            else
                error('SimpleSeries: Data Overflow');
            end
        end

        function vecs = export(obj, indexNames)
            % 按列名导出数据，支持处理单个或多个列名，处理多个列名时，要求是一个一维的cell数组

            if ischar(indexNames)
                indexNames = {indexNames};
            end
            validateattributes(indexNames, {'cell'}, {'vector', 'nonempty'});

            % 查找列索引
            idx = zeros(1, length(indexNames));
            for w = 1:length(indexNames)
                idx(w) = obj.getColumnIndex(indexNames{w});
            end

            % 导出列数据
            vecs = obj.dataItems(1:obj.cnt, idx);
        end

        function vecs = exportAll(obj)
            % 导出全部数据
            vecs = obj.dataItems(1:obj.cnt, :);
        end

        function idx = getColumnIndex(obj, indexName)
            % 根据列名查询列索引

            idx = find(strcmp(obj.indexNames, indexName));
            if isempty(idx)
                error('SimpleSeries: Invalid column name');
            end
        end

        function flag = hasColumn(obj, indexNames)
            % 判断是否包含某些列，支持单个或多个列名，对于多个列名查询，只有全部存在时返回true，否则返回false

            if ischar(indexNames)
                indexNames = {indexNames};
            end
            validateattributes(indexNames, {'cell'}, {'vector', 'nonempty'});

            flag = all(ismember(indexNames, obj.indexNames));
        end
    end
end
