
reconFilePath = "C:\\Users\\chan\\Documents\\HDR_DATASET\\CaveatsOfQA\\reconstructions\\hdrcnn\\clip_97\\002.exr";
referenceFilePath = "C:\\Users\\chan\\Documents\\HDR_DATASET\\CaveatsOfQA\\reference\\002.exr";



reconFile = exrread(reconFilePath);

referFile = exrread(referenceFilePath);

contrast = 1000000;

gamma = 2.2;
E_ambient = 100;
ppd = hdrvdp_pix_per_deg( 24, [3840 2160], 0.8 );

reconFile = reconFile / max(reconFile(:));
referFile = referFile / max(referFile(:));
Lpeak = 500.0;

L_recon = hdrvdp_gog_display_model(reconFile, Lpeak, contrast, gamma, E_ambient);
L_refer = hdrvdp_gog_display_model(referFile, Lpeak, contrast, gamma, E_ambient);

ret = hdrvdp3('quality', L_recon, L_refer, 'rgb-native', ppd).Q;
fprintf("%s\n", ret);