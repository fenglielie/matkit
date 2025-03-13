function writeJson(S, filename)
    % 输入:
    % S - 结构体
    % filename - 要保存的文件名

    % 将结构体转换为 JSON 字符串
    jsonStr = jsonencode(S, 'PrettyPrint', true);

    % 打开文件以写入
    fileID = fopen(filename, 'w');

    % 检查文件是否成功打开
    if fileID == -1
        error('Failed to open file: %s', filename);
    end

    % 将 JSON 字符串写入文件
    fprintf(fileID, '%s', jsonStr);

    % 关闭文件
    fclose(fileID);

    disp(['JSON saved to file: ', filename]);
end
