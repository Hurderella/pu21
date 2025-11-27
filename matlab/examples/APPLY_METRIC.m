function APPLY_METRIC%(input)
    % referDir = "/Users/chan_company/Documents/CaveatSIhdr/reference/";
    % reconDir = "/Users/chan_company/Documents/CaveatSIhdr/reconstruction/";
    % pathSplit = "/";
    
    %%%%%%%%%%%% windows %%%%%%%%%%%
    tableSaveDst = "C:\Users\chan\Documents\github\ICIP\TEST_RESULT\";
    hdrBasePath = "C:\\Users\\chan\\Documents\\HDR_DATASET\\CaveatsOfQA\\";
    compareDatas = "C:\\Users\\chan\\Documents\\HDR_DATASET\\CaveatsOfQA\\reconstructions\\";
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%% Ubuntu %%%%%%%%%%%%
    % tableSaveDst = "/home/chan/Documents/github/ICIP/";
    % hdrBasePath = "/home/chan/Documents/HDR_DATASET/CaveatsOfQA/sihdr" + filesep;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    reconPrefixPath = tableSaveDst;
    referencePath = hdrBasePath + "reference" + filesep;
    
    refExt = ".exr";
    NetworkList = ["singlehdr", "hdrcnn", "expandnet", "LFNet", ...
        "TEST_RESULT_2025_11_26__23_43_34", ... 
        "TEST_RESULT_2025_11_27__00_02_26", ... 
        "TEST_RESULT_2025_11_27__00_16_33", ... 
        "TEST_RESULT_2025_11_27__00_38_27", ... 
        "TEST_RESULT_2025_11_27__00_48_17", ... 
        "TEST_RESULT_2025_11_27__01_05_09"];
    % NetworkList = ["singlehdr", "hdrcnn", "expandnet", "LFNet", "LFNet_output"];
    %NetworkList = ["TEST_RESULT/TEST_RESULT_2024_04_12__08_33_47_dummy"];
    %NetworkList = ["TEST_RESULT/TEST_RESULT_2024_05_17__18_40_30_512_color", ...
    %    "TEST_RESULT/TEST_RESULT_2024_05_17__18_34_06_512_gray", ...
    %    "TEST_RESULT/TEST_RESULT_2024_05_17__18_31_55_400_gray", ...
    %    "TEST_RESULT/TEST_RESULT_2024_05_17__17_40_54_09_thres", ...
    %    "TEST_RESULT/TEST_RESULT_2024_05_17__17_39_21_08_thres", ...
    %    "TEST_RESULT/TEST_RESULT_2024_05_17__17_37_35_07_thres"];
    
    % NetworkList =["psnr_test"];
    
    % CRITIC-FREE
    % NetworkList = ["TEST_RESULT_2025_11_26__23_43_34"]; % BRISQUE
    % NetworkList = ["TEST_RESULT_2025_11_27__00_02_26"]; % PIQE
    % NetworkList = ["TEST_RESULT_2025_11_27__00_16_33"]; % hdr-vdp-3
    % ----------------------------------------------------------------
    % CRITIC-FREE-FALSE
    % NetworkList = ["TEST_RESULT_2025_11_27__00_38_27"]; % BRISQUE
    % NetworkList = ["TEST_RESULT_2025_11_27__00_48_17"]; % PIQE
    % NetworkList = ["TEST_RESULT_2025_11_27__01_05_09"]; % hdr-vdp-3
    %NetworkList = [string(input)];
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
                  
            scoreTable = table('Size', [1, 8], ...
                'VariableTypes', ["string", "double", "double", "double", "double", "double", "double", "double"], ...
                'VariableNames',["Name", "PU21-PSNR", "PU21-PSNR-Y", "REF-PU21-PIQE", "REC-PU21-PIQE", "REF-PU21-BRISQUE", "REC-PU21-BRISQUE", "HDR-VDP-3"]);
            reset(gpuDevice(1));
            parfor (idx = 1:length(reconFolderInfo), 12)
            % for idx = 1:length(reconFolderInfo)
                reconFileName = reconFolderInfo(idx).name;
                reconFilePath = string(reconFolderInfo(idx).folder) + filesep + reconFileName;
                
                %referenceFileName = extractBefore(reconFileName, ext) + refExt;
                fileName = split(reconFileName, ["_", "."]);
                tokenLen = size(fileName, 1);
             
                referenceFileName =  fileName(tokenLen - 1)+ refExt;
                referenceFilePath = referencePath + referenceFileName;
                                
                fprintf("%s\n", reconFileName);
                fprintf("%s\n", reconFilePath);
                fprintf("<<--->> %s \n", referenceFileName);
                fprintf("%s\n", referenceFilePath);
                 
                Lpeak = 500.0;
               
                % pu21_metric
                %%%%%%%%%%%%% PSNR %%%%%%%%%%%%%
                pu21_psnr = getPSNR(reconFilePath, referenceFilePath, hdrFileFlag, false, Lpeak);
                pu21_psnr_y = getPSNR(reconFilePath, referenceFilePath, hdrFileFlag, true, Lpeak);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                %%%%%%%% BRISQUE & PIQE %%%%%%%%
                ret = getBRISQUE_PIQE(reconFilePath, referenceFilePath, hdrFileFlag, Lpeak);
                pu21_recon_piqe = ret(1);
                pu21_refer_piqe = ret(2);
                pu21_recon_brisque = ret(3);
                pu21_refer_brisque = ret(4);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                %%%%%%%%%% HDR VDP 3 %%%%%%%%%%%
                hdrvdp3val = getHDRVDP3(reconFilePath, referenceFilePath, hdrFileFlag, Lpeak);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
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
                fprintf("PU21-PSNR : %g, PU21-PSNR-Y : %g... " + ...
                    "REF-PU21-PIQE : %g, REC-PU21-PIQE : %g, REF-PU21-BRISQUE : %g, REC-PU21-BRISQUE : %g, HDRVDP-3 : %g\n", ...
                    pu21_psnr, pu21_psnr_y, ...
                    pu21_refer_piqe, pu21_recon_piqe, pu21_refer_brisque, pu21_recon_brisque, ...
                    hdrvdp3val);
            
                curScore = {reconFileName, pu21_psnr, pu21_psnr_y, ...
                    pu21_refer_piqe, pu21_recon_piqe, pu21_refer_brisque, pu21_recon_brisque, hdrvdp3val};
                scoreTable(idx, :) = curScore;
            end
            currentTime = datetime("now");
            currentTime.Format = "yyyyMMdd_HHmmss";

            saveLogPath = tableSaveDst + NetworkList(netIdx) + "_Lpeak_5" + "_TOTAL_" + string(currentTime) + ".xls";
            disp(saveLogPath);
            writetable(scoreTable, saveLogPath);
        end
    end
end

function ret = getBRISQUE_PIQE(reconFilePath, referenceFilePath, hdrFileFlag, Lpeak)
    pu21 = pu21_encoder();
    epsilon = 0.0001;
    if hdrFileFlag %NetworkList(netIdx) == "LFNet"
        reconFile = hdrread(reconFilePath);
    else
        reconFile = exrread(reconFilePath);
    end
    referenceFile = exrread(referenceFilePath);

    reconFile = reconFile / max(reconFile(:)) * Lpeak;
    referenceFile = referenceFile / max(referenceFile(:)) * Lpeak;

    reconFile_pu21 = pu21.encode(reconFile) ;
    referFile_pu21 = pu21.encode(referenceFile);

    % Normalize
    reconFile_pu21 = get_luminance(reconFile_pu21);
    referFile_pu21 = get_luminance(referFile_pu21);


    % Normalize
    % for k = 1:3
    %     data = reconFile_pu21(:, :, k);
    %     data = data(:);
    %     data_max = max(data);
    %     reconFile_pu21(:, :, k) = reconFile_pu21(:, :, k) / data_max;
    % 
    %     data = referFile_pu21(:, :, k);
    %     data = data(:);
    %     data_max = max(data);
    %     referFile_pu21(:, :, k) = referFile_pu21(:, :, k) / data_max;
    % end
  

    pu21_recon_piqe = piqe(reconFile_pu21);
    pu21_refer_piqe = piqe(referFile_pu21);
    
    pu21_recon_brisque = brisque(reconFile_pu21);
    pu21_refer_brisque = brisque(referFile_pu21);
    
    ret = [pu21_recon_piqe, pu21_refer_piqe, pu21_recon_brisque, pu21_refer_brisque];
end
function ret = getPSNR(reconFilePath, referenceFilePath, hdrFileFlag, grayFlag, Lpeak)
    if hdrFileFlag %NetworkList(netIdx) == "LFNet"
        reconFile = hdrread(reconFilePath);
    else
        reconFile = exrread(reconFilePath);
    end
    
    referenceFile = exrread(referenceFilePath);

    epsilon = 0.0001;
    reconFile = reconFile / max(reconFile(:)) * Lpeak;
    referenceFile = referenceFile / max(referenceFile(:)) * Lpeak;

    % disp(max(reconFile(:)));
    % disp(max(referenceFile(:)));

    if grayFlag == true
        reconFile = im2gray(reconFile);
        referenceFile = im2gray(referenceFile);
    end

    if grayFlag == true
        pu21_psnr = pu21_metric(reconFile, referenceFile, 'PSNRY');
    else
        % pu21_metric
        pu21_psnr = pu21_metric(reconFile, referenceFile, 'PSNR');
    end
    ret = pu21_psnr;
end

function ret = getHDRVDP3(reconFilePath, referenceFilePath, hdrFileFlag, Lpeak)
    if hdrFileFlag
        reconFile = hdrread(reconFilePath);
    else
        reconFile = exrread(reconFilePath);
    end

    referFile = exrread(referenceFilePath);
    
    % contrast = 1000000;
    % 
    % gamma = 2.2;
    % E_ambient = 100;
    ppd = hdrvdp_pix_per_deg( 24, [3840 2160], 0.8 );
    % 
    reconFile = reconFile / max(reconFile(:)) * Lpeak;
    referFile = referFile / max(referFile(:)) * Lpeak;
    % reconFile = clamp(reconFile, 0, Lpeak);
    % referFile = clamp(referFile, 0, Lpeak);
    % 
    % L_recon = hdrvdp_gog_display_model(reconFile, Lpeak, contrast, gamma, E_ambient);
    % L_refer = hdrvdp_gog_display_model(referFile, Lpeak, contrast, gamma, E_ambient);
    
    % ret = hdrvdp3('quality', L_recon, L_refer, 'rgb-native', ppd).Q;
    ret = hdrvdp3('quality', reconFile, referFile, 'rgb-native', ppd).Q;
end

function Y = get_luminance( img )
% Return 2D matrix of luminance values for 3D matrix with an RGB image

    Y = img(:,:,1) * 0.212656 + img(:,:,2) * 0.715158 + img(:,:,3) * 0.072186;
end