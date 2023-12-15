
% referenceDir = "/Users/chan/Library/CloudStorage/GoogleDrive-hcs3759@gmail.com/내\ 드라이브/Colab\ Notebooks/HDR_DATASET/CaveatsOfQA/reference";
% reconDir = "/Users/chan/Library/CloudStorage/GoogleDrive-hcs3759@gmail.com/내\ 드라이브/Colab\ Notebooks/HDR_DATASET/CaveatsOfQA/reconstructions/singlehdr/clip_97";
% referenceDir = "G:\\내 드라이브\\Colab Notebooks\\HDR_DATASET\\CaveatsOfQA\\reference\\";
% reconDir = "G:\\내 드라이브\\Colab Notebooks\\HDR_DATASET\\CaveatsOfQA\\reconstructions\\";
% reconDir = "C:\\Users\\chan\\Documents\\HDR_DATASET\\CaveatsOfQA\\sihdr\\reconstructions\\";
hdrBasePath = "C:\\Users\\chan\\Documents\\HDR_DATASET\\CaveatsOfQA\\sihdr\\";
reconPrefixPath = "reconstructions\\"; % + NetworkList % LFNet\\;
referencePath = "reference\\";
clipDelim = ""; 
reconDir = "C:\\Users\\chan\\Documents\\HDR_DATASET\\CaveatsOfQA\\sihdr\\reconstructions\\";
referenceDir = "C:\\Users\\chan\\Documents\\HDR_DATASET\\CaveatsOfQA\\sihdr\\reference\\";

ext = ".hdr";
% ext = ".exr";
refExt = ".exr";
% referenceFile = referenceDir + "/" + fileName;
% reconFile = reconDir + "/" + fileName;

% NetworkList = ["singlehdr", "maskhdr", "hdrgan", "hdrcnn", "expandnet"]; %, "drtmo"];
% NetworkList = [ ...
%     "LightweightAgent_mn_impl_rwd-score2-clip90", ...
%     "LightweightAgent_mn_impl_rwd-20_10epoch_add_epoch", ...
%     "LightweightAgent_mn_impl_rwd-20-10epoch_Gaussian", ...
%     "LightweightAgent_mn_impl_rwd-20_10epoch_apply_mean_31_pooling", ...
%     "LightweightAgent_mn_impl_rwd-20_10epoch_apply_mean_11_pooling", ...
%     "LightweightAgent_mn_impl_rwd-20_10epoch_apply_mean_5_pooling", ...
%     "LightweightAgent_mn_impl_rwd-20_10epoch_apply_mean_pooling", ...
%     "LightweightAgent_mn_impl_rwd-20_10epoch", ...
%     "LightweightAgent_mn_impl_rwd-score2", ...
%     "LightweightAgent_mn_impl_rwd-20", ...
%     "LightweightAgent_mn_impl_9epoch_900", ...
%     "LightweightAgent_mn_impl_haverange", ...
%     "LightweightAgent_sim_lr001", ...
%     "LightwieghtAgent_mn_impl_1proc"]; 
%["LFNet"];
NetworkList = ["LightweightAgent_default_22070522", "LFNet", "singlehdr", "maskhdr", "hdrgan", "hdrcnn", "expandnet"];
ExrFiles = ["singlehdr", "maskhdr", "hdrgan", "hdrcnn", "expandnet"];
ClipItem = ["clip97"];

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

            fileName = split(reconFilePath, ["_", "."]);
            tokenLen = size(fileName, 1);
         
            referenceFileName =  fileName(tokenLen - 1)+ refExt;
            referenceFilePath = hdrBasePath + referencePath + referenceFileName;
       
            if isemember(NetworkList(netIdx), ExrFiles)
                reconFile = exrread(reconFilePath);
            else
                reconFile = hdrread(reconFilePath);
            end

            referFile = exrread(referenceFilePath);

            Lpeak = 5;
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
        writetable(scoreTable, NetworkList(netIdx) + "_Lpeak_5_" + "_hdrvdp_peak_10.xls");
        % break;
    end
    % break;
end
