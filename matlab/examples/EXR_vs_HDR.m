referDir = "G:\\내 드라이브\\Colab Notebooks\\HDR_DATASET\\CaveatsOfQA\\reference\\";
reconDir = "G:\\내 드라이브\\Colab Notebooks\\HDR_DATASET\\CaveatsOfQA\\reconstructions\\";
pathSplit = "\\";

% referDir = "/Users/chan_company/Documents/github/pu21/drive_refer/";
% reconDir = "/Users/chan_company/Documents/github/pu21/drive_recon/";
% pathSplit = "/";

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

adjLFReconFile = lfnetFile / max(lfnetFile(:));
peakApplyLFRecon = adjLFReconFile * 10;
exrwrite(peakApplyLFRecon, "peak_a_recon_10_LF.exr");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

adjSingleReconFile = singleHdrFile / max(singleHdrFile(:));
peakApplySingleRecon = adjSingleReconFile * 10;
exrwrite(peakApplySingleRecon, "peak_a_recon_10_Sing.exr");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

adjReferFile = (referFile) / (max(referFile(:)));
peakApplyRefer = adjReferFile * 10;
exrwrite(peakApplyRefer, "peak_a_refer_10.exr");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% tm_refer = tonemap(adjReferFile);
% tm_LF_recon = tonemap(adjLFReconFile);
% tm_Sing_recon = tonemap(adjSingleReconFile);

tm_refer = tonemap(peakApplyRefer);
tm_LF_recon = tonemap(peakApplyLFRecon);
tm_Sing_recon = tonemap(peakApplySingleRecon);

tm_psnr = psnr(tm_LF_recon, tm_refer, 255);
disp(tm_psnr);

tm_psnr = psnr(tm_Sing_recon, tm_refer, 255);
disp(tm_psnr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Lpeak = 10;
adjLFReconFile = adjLFReconFile * Lpeak;
adjSingleReconFile = adjSingleReconFile * Lpeak;
adjReferFile = adjReferFile * Lpeak;

pu21_lf = pu21_metric(adjLFReconFile, adjReferFile, 'PSNR');
pu21_sing = pu21_metric(adjSingleReconFile, adjReferFile, 'PSNR');

pu21_LF_enc = pu21.encode(adjLFReconFile);
pu21_S_enc = pu21.encode(adjSingleReconFile);

disp(piqe(pu21_LF_enc));
disp(piqe(pu21_S_enc));

disp(pu21_lf);
disp(pu21_sing);

disp(piqe(tm_LF_recon));
disp(piqe(tm_Sing_recon));
disp("===")
% pu21_psnr = pu21_metric(reconFile, referenceFile, 'PSNR');
% pu21_fsim = pu21_metric(reconFile, referenceFile, 'FSIM');
% pu21_fsim_crf = pu21_metric(reconFile, referenceFile, 'FSIM', 'crf_correction', true);

