function BRISQUE_METRIC
    % PNG()
    EXR()
end

function EXR
    input = "/Users/chan_company/Documents/github/pu21/sample/clip97/";
    infoSavePath = "/Users/chan_company/Documents/github/pu21/sample/";
    query = input + "*" + ".exr";
    savePath = infoSavePath + "exrInfo.xls";
    files = dir(query);
    disp(files)
    disp("----")

    scoreTable = table('Size', [1, 2], ...
        'VariableTypes', ["string", "double"], ...
        'VariableNames',["Name", "BRISQUE"]);

    for idx = 1 : length(files)
        fileName = files(idx).name;
        targetFile = input + fileName;
        disp(targetFile)

        % data = imread(targetFile);
        data = exrread(targetFile);
        std_data = data / max(data(:));
        grayData = im2gray(std_data) * 255;
        score = brisque(grayData);
        disp(score);
        scoreTable(idx, :) = {fileName, score};
    end
    writetable(scoreTable, savePath);
end

function PNG
    input = "/Users/chan_company/Documents/github/pu21/sample/clip97/";
    infoSavePath = "/Users/chan_company/Documents/github/pu21/sample/";
    % disp(input);
    query = input + "*" + ".png";
    savePath = infoSavePath + "pngInfo.xls";
    files = dir(query);
    disp(files)
    disp("----")

    scoreTable = table('Size', [1, 2], ...
        'VariableTypes', ["string", "double"], ...
        'VariableNames',["Name", "BRISQUE"]);

    for idx = 1 : length(files)
        fileName = files(idx).name;
        targetFile = input + fileName;
        disp(targetFile)

        data = imread(targetFile);
        grayData = im2gray(data);
        score = brisque(grayData);
        disp(score);
        scoreTable(idx, :) = {fileName, score};
    end
    writetable(scoreTable, savePath);
end