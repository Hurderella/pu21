% referDir = "G:\\내 드라이브\\Colab Notebooks\\HDR_DATASET\\CaveatsOfQA\\reference\\";
% reconDir = "G:\\내 드라이브\\Colab Notebooks\\HDR_DATASET\\CaveatsOfQA\\reconstructions\\";

referDir = "/Users/chan_company/Documents/github/pu21/drive_refer/";
reconDir = "/Users/chan_company/Documents/github/pu21/drive_recon/";
pathSplit = "/";

networkName_LFNet = "LFNet";
networkName_single = "singlehdr";
clipDelim = "clip_97";

LFNetDir = reconDir + networkName_LFNet + pathSplit;
SingleDir = reconDir + networkName_single + pathSplit;

singleHdr_HDR_FilePath = SingleDir + clipDelim + pathSplit+ "001.exr";
disp(singleHdr_HDR_FilePath);

lfnet_EXR_FilePath = LFNetDir + clipDelim + pathSplit + "001.hdr";
disp(lfnet_EXR_FilePath);

refer_EXR_FilePath = referDir + "001.exr";
disp(refer_EXR_FilePath);

% 1280 x 1888
singleHdrFile = exrread(singleHdr_HDR_FilePath);
% imshow((singleHdrFile), [1280 1888]);
% figure

lfnetFile = hdrread(lfnet_EXR_FilePath);
% imshow((lfnetFile), [1280 1888]);
% figure 

referFile = exrread(refer_EXR_FilePath);
% imshow(referFile);
% disp("end");


disp(max(singleHdrFile(:)));
disp(max(referFile(:)));

pu21 = pu21_encoder();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
reconFile = lfnetFile;
adjReconFile = reconFile / max(reconFile(:));
exrwrite(adjReconFile, "std_0_1_recon_LF.exr");
% 
peakApplyRecon = adjReconFile * 10;
exrwrite(peakApplyRecon, "peak_a_recon_10_LF.exr");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% adjReferFile = (referFile) / (max(referFile(:)));
% adjReferFile =

% exrwrite(adjReferFile, "std_0_1_refer.exr");
% hdrwrite(adjReferFile, "std_0_1_refer.hdr");

peakApplyRefer = adjReferFile * 1000 / 100;
exrwrite(peakApplyRefer, "peak_a_refer_150.exr");
% hdrwrite(peakApplyRefer, "peak_a_refer.hdr");

tm_refer = tonemap(adjReferFile);
tm_recon = tonemap(adjReconFile);

tm_psnr = psnr(tm_recon, tm_refer, 255);
disp(tm_psnr);

% peakApplyRefer_2 = adjReferFile * 2;
% exrwrite(peakApplyRefer_2, "peak_b_refer.exr");
% % hdrwrite(peakApplyRefer_2, "peak_b_refer.hdr");
% 
% peakApplyRefer_3 = adjReferFile ;
% exrwrite(peakApplyRefer_3, "peak_c_refer.exr");
% 
% peakApplyRefer_4 = adjReferFile * 1000;
% pu21_referFile = pu21.encode(peakApplyRefer);
% pu21_referFile = pu21_referFile / 1500 * 15;
% exrwrite(pu21_referFile, "pu21_refer.exr");


% hdrwrite(pu21_referFile, "pu21_refer.hdr");

% tonemappedRefer = tonemap(peakApplyRefer_2);
% exrwrite(tonemappedRefer, "tonemap.exr");
% hdrwrite(tonemappedRefer, "tonemap.hdr");

% reconFile = hdrread(singleHdr_HDR_FilePath);
% referFile = exrread(refer_EXR_FilePath);
% 
% Lpeak = 1000;
% contrast = 1000000;
% 
% gamma = 2.2;
% E_ambient = 100;
% ppd = hdrvdp_pix_per_deg( 24, [3840 2160], 0.8 ); 
% 
% reconFile = reconFile / max(reconFile(:));
% referFile = referFile / max(referFile(:));
% 
% L_recon = hdrvdp_gog_display_model(reconFile, Lpeak, contrast, gamma, E_ambient);
% L_refer = hdrvdp_gog_display_model(referFile, Lpeak, contrast, gamma, E_ambient);
% 
% ret = hdrvdp3('quality', L_recon, L_refer, 'rgb-native', ppd);
% disp(ret.Q);
            


