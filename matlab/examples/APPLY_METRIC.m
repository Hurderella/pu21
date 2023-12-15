% referDir = "/Users/chan_company/Documents/CaveatSIhdr/reference/";
% reconDir = "/Users/chan_company/Documents/CaveatSIhdr/reconstruction/";
% pathSplit = "/";

hdrBasePath = "/Users/chan_company/Documents/CaveatSIhdr/";
reconPrefixPath = "reconstructions/"; 
referencePath = "reference/";
clipDelim = ""; 

refExt = ".exr";


NetworkList = ["LightweightAgent_default_22070522", "LFNet", "singlehdr", "maskhdr", "hdrgan", "hdrcnn", "expandnet"];
ClipItem = ["clip97"]; %["clip_95", "clip_97"];

for netIdx = 1:length(NetworkList)
    for clipIdx = 1:length(ClipItem)
        hdrFileFlag = false;
        ext = ".exr";
        if NetworkList(netIdx) == "LFNet"
            ext = ".hdr";
            hdrFileFlag = true;
        end
        if NetworkList(netIdx) == "LightweightAgent_default_22070522"
            ext = ".hdr";
            hdrFileFlag = true;
        end

        reconPath = reconPrefixPath + NetworkList(netIdx) + "\\";
        clipDelim = ClipItem(clipIdx) + "\\";

        reconFullPath = hdrBasePath + reconPath + clipDelim + "*" + ext;
        referenceFullPath = hdrBasePath + referencePath;
        
        reconFolderInfo = dir(reconFullPath);
        disp(reconFullPath);
              
        scoreTable = table('Size', [1, 5], ...
            'VariableTypes', ["string", "double", "double", "double", "double"], ...
            'VariableNames',["Name", "PU21-PSNR", "TMO-PSNR", "REF-TMO-PIQE", "REC-TMO-PIQE"]);
        for idx = 1:length(reconFolderInfo)
            
            reconFileName = reconFolderInfo(idx).name;
            reconFilePath = hdrBasePath + reconPath + clipDelim + reconFileName;
            
            %referenceFileName = extractBefore(reconFileName, ext) + refExt;
            fileName = split(reconFilePath, ["_", "."]);
            tokenLen = size(fileName, 1);
         
            referenceFileName =  fileName(tokenLen - 1)+ refExt;
            referenceFilePath = hdrBasePath + referencePath + referenceFileName;
            
            pu21 = pu21_encoder();
            
            fprintf("%s\n", reconFileName);
            fprintf("%s\n", reconFilePath);
            fprintf("<<--->> %s \n", referenceFileName);
            fprintf("%s\n", referenceFilePath);
        
            
            if hdrFileFlag %NetworkList(netIdx) == "LFNet"
                reconFile = hdrread(reconFilePath);
            else
                reconFile = exrread(reconFilePath);
            end
            
            referenceFile = exrread(referenceFilePath);
            
            Lpeak = 5;
            reconFile = reconFile / max(reconFile(:)) * Lpeak;
            referenceFile = referenceFile / max(referenceFile(:)) * Lpeak;

            tm_reconFile = tonemap(reconFile);
            tm_referenceFile = tonemap(referenceFile);
            
            % tone-map => psnr
            % tone-map => piqe
            tone_psnr = psnr(tm_reconFile, tm_referenceFile, 255);
            tm_recon_piqe = piqe(tm_reconFile);
            tm_refer_piqe = piqe(tm_referenceFile);
            
            % pu21_metric
            pu21_psnr = pu21_metric(reconFile, referenceFile, 'PSNR');
            
            fprintf("PU21-PSNR : %g, TMO-PSNR : %g, REF-TMO-PIQE : %g, REC-TMO-PIQE : %g\n", ...
                pu21_psnr, tone_psnr, tm_refer_piqe, tm_recon_piqe);
            
            % Lpeak = 1000;
            % reconFile = reconFile / max(reconFile(:)) * Lpeak;
            % referenceFile = referenceFile / max(referenceFile(:)) * Lpeak;
            % 
            % pu21_psnr = pu21_metric(reconFile, referenceFile, 'PSNR');
            % pu21_fsim = pu21_metric(reconFile, referenceFile, 'FSIM');
            % pu21_fsim_crf = pu21_metric(reconFile, referenceFile, 'FSIM', 'crf_correction', true);
            % 
            % fprintf('PU21-PNSR : %g, PU21-FSIM : %g, PU21-FSIM-CRF : %g\n', ...
            %     pu21_psnr, pu21_fsim, pu21_fsim_crf);
            % fprintf("pu21 piqe recon : %g\n", reconPiqeScore);
        
            curScore = {reconFileName, pu21_psnr, tone_psnr, tm_refer_piqe, tm_recon_piqe};
            scoreTable(idx, :) = curScore;
        end
        writetable(scoreTable, NetworkList(netIdx) + "_Lpeak_5" + "_peak10___" + ".xls");
    end
end

