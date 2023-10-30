
hdrBasePath = "C:\\Users\\chan\\Documents\\HDR_DATASET\\CaveatsOfQA\\sihdr\\";
reconPrefixPath = "reconstructions\\"; % + NetworkList % LFNet\\;
referencePath = "reference\\";
clipDelim = ""; % "clip_97\\";
ext = ".exr";
refExt = ".exr";

NetworkList = ["singlehdr", "maskhdr", "hdrgan", "hdrcnn", "expandnet", "drtmo"];
ClipItem = ["clip_95", "clip_97"];

for netIdx = 1:length(NetworkList)
    for clipIdx = 1:length(ClipItem)
        
        reconPath = reconPrefixPath + NetworkList(netIdx) + "\\";
        clipDelim = ClipItem(clipIdx) + "\\";

        reconFullPath = hdrBasePath + reconPath + clipDelim + "*" + ext;
        referenceFullPath = hdrBasePath + referencePath;
        
        reconFolderInfo = dir(reconFullPath);
        disp(reconFullPath);
        
        scoreTable = table('Size', [1, 5], ...
            'VariableTypes', ["string", "double", "double", "double", "double"], ...
            'VariableNames',["Name", "PU21-PSNR", "PU21-PIQE", "PU21-FSIM", "PU21-FSIM-CRF"]);
        for idx = 1:length(reconFolderInfo)
            
            reconFileName = reconFolderInfo(idx).name;
            reconFilePath = hdrBasePath + reconPath + clipDelim + reconFileName;
            
            referenceFileName = extractBefore(reconFileName, ext) + refExt;
            referenceFilePath = hdrBasePath + referencePath + referenceFileName;
            
            pu21 = pu21_encoder();
            
            fprintf("%s\n", reconFileName);
            fprintf("%s\n", reconFilePath);
            fprintf("<<--->> %s \n", referenceFileName);
            fprintf("%s\n", referenceFilePath);
        
            % reconFile = hdrread(reconFilePath);
            reconFile = exrread(reconFilePath);
            referenceFile = exrread(referenceFilePath);
            % referenceFile = hdrread(referenceFilePath);
            
            reconPiqeScore = piqe(pu21.encode(reconFile));
            disp(reconPiqeScore);
            
            Lpeak = 1000;
            reconFile = reconFile / max(reconFile(:)) * Lpeak;
            referenceFile = referenceFile / max(referenceFile(:)) * Lpeak;
        
            pu21_psnr = pu21_metric(reconFile, referenceFile, 'PSNR');
            pu21_fsim = pu21_metric(reconFile, referenceFile, 'FSIM');
            pu21_fsim_crf = pu21_metric(reconFile, referenceFile, 'FSIM', 'crf_correction', true);
        
            fprintf('PU21-PNSR : %g, PU21-FSIM : %g, PU21-FSIM-CRF : %g\n', ...
                pu21_psnr, pu21_fsim, pu21_fsim_crf);
            fprintf("pu21 piqe recon : %g\n", reconPiqeScore);
        
            curScore = {reconFileName, pu21_psnr, reconPiqeScore, pu21_fsim, pu21_fsim_crf};
            scoreTable(idx, :) = curScore;
        end
        writetable(scoreTable, NetworkList(netIdx) + "_" + ClipItem(clipIdx) + ".xls");

    end
end

