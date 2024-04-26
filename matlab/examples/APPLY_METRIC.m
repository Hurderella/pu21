function APPLY_METRIC(input)
    % referDir = "/Users/chan_company/Documents/CaveatSIhdr/reference/";
    % reconDir = "/Users/chan_company/Documents/CaveatSIhdr/reconstruction/";
    % pathSplit = "/";
    
    tableSaveDst = "C:\Users\chan\Documents\github\ICIP\TEST_RESULT\";
    hdrBasePath = "C:\\Users\\chan\\Documents\\HDR_DATASET\\CaveatsOfQA\\sihdr" + filesep;
    reconPrefixPath = tableSaveDst;
    referencePath = hdrBasePath + "reference" + filesep;
    
    refExt = ".exr";
    
    %NetworkList = ["singlehdr", "hdrcnn", "expandnet", "LFNet"];
    %NetworkList = ["TEST_RESULT_2024_04_03__14_46_49"];
    NetworkList = [string(input)];
    disp(NetworkList);
    disp("check")
        
    ExrFiles = ["singlehdr", "maskhdr", "hdrgan", ...
                "hdrcnn", "expandnet"];
    ClipItem = ["clip97"]; %["clip_95", "clip_97"];
    
    for netIdx = 1:length(NetworkList)
        for clipIdx = 1:length(ClipItem)
            ext = ".hdr";
            hdrFileFlag = true;
            if ismember(NetworkList(netIdx), ExrFiles)
                ext = ".exr";
                hdrFileFlag = false;
            end
    
            reconPath = reconPrefixPath + NetworkList(netIdx) + filesep;
            clipDelim = ClipItem(clipIdx) + filesep;
    
            reconDirPath = reconPath + clipDelim + "*" + ext;
            
            reconFolderInfo = dir(reconDirPath);
            disp(reconDirPath);
                  
            scoreTable = table('Size', [1, 10], ...
                'VariableTypes', ["string", "double", "double", "double", "double", "double", "double", "double", "double", "double"], ...
                'VariableNames',["Name", "PU21-PSNR", "TMO-PSNR", "REF-TMO-PIQE", "REC-TMO-PIQE", "REF-PU21-PIQE", "REC-PU21-PIQE", "REF-PU21-BRISQUE", "REC-PU21-BRISQUE", "HDR-VDP-3"]);
            %for idx = 1:length(reconFolderInfo)
            reset(gpuDevice(1))
            parfor (idx = 1:length(reconFolderInfo), 8)
            %for idx = 1:length(reconFolderInfo)
                reconFileName = reconFolderInfo(idx).name;
                reconFilePath = string(reconFolderInfo(idx).folder) + filesep + reconFileName;
    
                %referenceFileName = extractBefore(reconFileName, ext) + refExt;
                fileName = split(reconFileName, ["_", "."]);
                tokenLen = size(fileName, 1);
             
                referenceFileName =  fileName(tokenLen - 1)+ refExt;
                referenceFilePath = referencePath + referenceFileName;
                
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
                
                Lpeak = 500;
                reconFile = reconFile / max(reconFile(:));
                reconFile = im2gray(reconFile) * Lpeak;

                referenceFile = referenceFile / max(referenceFile(:));
                referenceFile = im2gray(referenceFile) * Lpeak;

                tm_reconFile = tonemap(reconFile);
                tm_referenceFile = tonemap(referenceFile);
                
                % tone-map => psnr
                % tone-map => piqe
                tone_psnr = psnr(tm_reconFile, tm_referenceFile, 255);
                tm_recon_piqe = piqe(tm_reconFile);
                tm_refer_piqe = piqe(tm_referenceFile);
                
                reconFile_pu21 = pu21.encode( reconFile);
                referFile_pu21 = pu21.encode( referenceFile);
                
                pu21_recon_piqe = piqe(reconFile_pu21);
                pu21_refer_piqe = piqe(referFile_pu21);
                
                pu21_recon_brisque = brisque (reconFile_pu21);
                pu21_refer_brisque = brisque(referFile_pu21);

                % pu21_metric
                pu21_psnr = pu21_metric(reconFile, referenceFile, 'PSNR');
                
                %%%%%%%%%% HDR VDP 3 %%%%%%%%%%%
                if hdrFileFlag 
                    reconFile = hdrread(reconFilePath);
                else
                    reconFile = exrread(reconFilePath);
                end
                
                referFile = exrread(referenceFilePath);
                
                contrast = 1000000;
                
                gamma = 2.2;
                E_ambient = 100;
                Lpeak = 500;
                ppd = hdrvdp_pix_per_deg( 24, [3840 2160], 0.8 ); 
    
                reconFile = reconFile / max(reconFile(:));
                referFile = referFile / max(referFile(:));
    
                L_recon = hdrvdp_gog_display_model(reconFile, Lpeak, contrast, gamma, E_ambient);
                L_refer = hdrvdp_gog_display_model(referFile, Lpeak, contrast, gamma, E_ambient);
                
                ret = hdrvdp3('quality', L_recon, L_refer, 'rgb-native', ppd);
                
                %%%%%%%%%%%%%%%%%%%%%
    
                if isnan(pu21_refer_brisque)
                    pu21_refer_brisque = 100.0;
                end
                if isnan(pu21_recon_brisque)
                    pu21_recon_brisque = 100.0;
                end
                if isnan(pu21_refer_piqe)
                    pu21_refer_piqe = 100.0;
                end
                if isnan(pu21_recon_piqe)
                    pu21_recon_piqe = 100.0;
                end
                fprintf("PU21-PSNR : %g, TMO-PSNR : %g, REF-TMO-PIQE : %g, REC-TMO-PIQE : %g, ... " + ...
                    "REF-PU21-PIQE : %g, REC-PU21-PIQE : %g, REF-PU21-BRISQUE : %g, REC-PU21-BRISQUE : %g, HDRVDP-3 : %g\n", ...
                    pu21_psnr, tone_psnr, tm_refer_piqe, tm_recon_piqe, ...
                    pu21_refer_piqe, pu21_recon_piqe, pu21_refer_brisque, pu21_recon_brisque, ...
                    ret.Q);
                
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
            
                curScore = {reconFileName, pu21_psnr, tone_psnr, tm_refer_piqe, tm_recon_piqe, ...
                    pu21_refer_piqe, pu21_recon_piqe, pu21_refer_brisque, pu21_recon_brisque, ret.Q};
                scoreTable(idx, :) = curScore;
            end
            saveLogPath = tableSaveDst + NetworkList(netIdx) + "_Lpeak_5" + "_TOTAL_" + ".xls";
            disp(saveLogPath);
            writetable(scoreTable, saveLogPath);
        end
    end
end
