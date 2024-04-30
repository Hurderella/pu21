function BRISQUE_METRIC
    PNG()
    %EXR()
end

function EXR
    
    input = "/home/chan/Documents/github/pu21/sample/clip97/";
    
    query = input + "*" + ".exr";
    savePath = input + "exrInfo.xls";
    files = dir(query);
    disp(files)
    disp("----")
    pu21 = pu21_encoder();

    scoreTable = table('Size', [1, 2], ...
        'VariableTypes', ["string", "double"], ...
        'VariableNames',["Name", "BRISQUE"]);
    
    for idx = 1 : length(files)
        fileName = files(idx).name;
        targetFile = input + fileName;
        disp(targetFile);
        
        data = exrread(targetFile);
        score = brisque(data);
        Lpeak = 500.0;
        stddata = data / max(data(:)) * Lpeak;
        %stddata = rgb2gray(stddata);
        max_std = max(stddata(:));
        
        stddata_1 = data / max(data(:));
        %stddata_1 = rgb2gray(stddata_1) * Lpeak;
        max_std_1 = max(stddata_1(:));

        a = [1, 2, 3];
        b = [1, 2, 3];
        if stddata_1 == stddata
        %if a == b
            disp("same");
        end


        pu21_stddata = pu21.encode(stddata);

        std_score = brisque(stddata);
        pu21_score = brisque(pu21_stddata);
        log = sprintf("score : %f, std score : %f, pu21 score : %f", score, std_score, pu21_score);
        disp(log);
        scoreTable(idx, :) = {fileName, pu21_score};
    end
    writetable(scoreTable, savePath);
end

function PNG
    input = "/home/chan/Documents/github/pu21/sample/clip97/";
    
    % disp(input);
    query = input + "*" + ".png";
    savePath = input + "pngInfo.xls";
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