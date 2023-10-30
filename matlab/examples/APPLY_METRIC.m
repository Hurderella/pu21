
hdrBasePath = "C:\\Users\\chan\\Documents\\HDR_DATASET\\CaveatsOfQA\\sihdr\\";
reconPath = "reconstructions\\LFNet\\";
referencePath = "reference\\";
clipDelim = "clip_95\\";
ext = "*.png";


reconFullPath = hdrBasePath + reconPath + clipDelim + ext;
referenceFullPath = hdrBasePath + referencePath;

reconFolderInfo = dir(reconFullPath);

for idx = 1:length(reconFolderInfo)
    
    reconFileName = reconFolderInfo(idx).name;
    reconFilePath = hdrBasePath + reconPath + clipDelim + reconFileName;
    % baseFileName = baseFolderInfo(idx).name;
    % baseFilePath = hdrBasePath + referencePath + clipDelim + baseFileName;
    fprintf("%s\n", reconFileName);
    fprintf("%s\n", reconFilePath);
    fprintf("<<--->> %s \n", baseFileName);
    fprintf("%s\n", baseFilePath);

    reconFile = hdrread(reconFilePath);
    baseFile = hdrread(baseFilePath);

    Lpeak = 1000;

    pu21_psnr = pu21_metric(reconFile, baseFile, 'PSNR');
    pu21_fsim = pu21_metric(reconFile, baseFile, 'FSIM');
    pu21_fsim_crf = pu21_metric(reconFile, baseFile, 'FSIM', 'crf_correction', true);
    
    fprintf('PU21-PNSR : %g, PU21-FSIM : %g, PU21-FSIM-CRF : %g', ...
        pu21_psnr, pu21_fsim, pu21_fsim_crf);
    break
end