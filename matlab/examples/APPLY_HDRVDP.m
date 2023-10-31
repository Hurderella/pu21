
% referenceDir = "/Users/chan/Library/CloudStorage/GoogleDrive-hcs3759@gmail.com/내\ 드라이브/Colab\ Notebooks/HDR_DATASET/CaveatsOfQA/reference";
% reconDir = "/Users/chan/Library/CloudStorage/GoogleDrive-hcs3759@gmail.com/내\ 드라이브/Colab\ Notebooks/HDR_DATASET/CaveatsOfQA/reconstructions/singlehdr/clip_97";
referenceDir = "G:\\내 드라이브\\Colab Notebooks\\HDR_DATASET\\CaveatsOfQA\\reference\\";
reconDir = "G:\\내 드라이브\\Colab Notebooks\\HDR_DATASET\\CaveatsOfQA\\reconstructions\\";
% reconDir = "C:\\Users\\chan\\Documents\\HDR_DATASET\\CaveatsOfQA\\sihdr\\reconstructions\\";
                   
ext = ".hdr";
refExt = ".exr";
% referenceFile = referenceDir + "/" + fileName;
% reconFile = reconDir + "/" + fileName;


% NetworkList = ["singlehdr", "maskhdr", "hdrgan", "hdrcnn", "expandnet"]; %, "drtmo"];
NetworkList = ["LFNet"];
ClipItem = ["clip_95", "clip_97"];

for netIdx = 1:length(NetworkList)
    for clipIdx = 1:length(ClipItem)
        
        clipDelim = ClipItem(clipIdx) + "\\";
        reconFullPath = reconDir + NetworkList(netIdx) + "\\" + clipDelim + "*" + ext;
        disp(reconFullPath);

        reconFolderInfo = dir(reconFullPath);

        scoreTable = table('Size', [1, 6], ...
            'VariableTypes', ["string", "double", "double", "double", "double", "double" ], ...
            'VariableNames',["Name", "HDR-VDP-3", "S_max", "P_det", "C_max", "Q_JOD"]);
        for idx = 1:length(reconFolderInfo)
            reconFileName = reconFolderInfo(idx).name;
            reconFilePath = reconDir + NetworkList(netIdx) + "\\" + clipDelim + reconFileName;
            disp(reconFilePath)

            referenceFileName = extractBefore(reconFileName, ext);
            referenceFilePath = referenceDir + referenceFileName + refExt;

            % reconFile = exrread(reconFilePath);
            reconFile = hdrread(reconFilePath);
            referFile = exrread(referenceFilePath);

            Lpeak = 1000;
            contrast = 1000000;
            
            gamma = 2.2;
            E_ambient = 100;
            ppd = hdrvdp_pix_per_deg( 24, [3840 2160], 0.8 ); 

            reconFile = reconFile / max(reconFile(:));
            referFile = referFile / max(referFile(:));

            L_recon = hdrvdp_gog_display_model(reconFile, Lpeak, contrast, gamma, E_ambient);
            L_refer = hdrvdp_gog_display_model(referFile, Lpeak, contrast, gamma, E_ambient);
            
            ret = hdrvdp3('quality', L_recon, L_refer, 'rgb-native', ppd);
            curScore = {reconFileName, ret.Q, ret.S_max, ret.P_det, ret.C_max, ret.Q_JOD};
            scoreTable(idx, :) = curScore;
            % break;
        end
        writetable(scoreTable, NetworkList(netIdx) + "_" + ClipItem(clipIdx) + "_hdrvdp.xls");
        % break;
    end
    % break;
end
