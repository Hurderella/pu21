function ret = HDRVDP_GETTER %(inData, refData)
    inpath = "C:\\Users\\chan\\Documents\\github\\ICIP\\TEST_RESULT\\TEST_RESULT_2024_12_22__00_50_06\\TestDumpHdr_4_.hdr";
    %['/Users/chan/Library/CloudStorage/GoogleDrive-hcs3759@gmail.com/내 ', ...
     %   '드라이브/Colab ', ...;
      %  'Notebooks/HDR_DATASET/CaveatsOfQA/reconstructions/LFNet/clip_97/001.hdr'];
    
    referpath = "C:\\Users\\chan\\Documents\\github\\ICIP\\TEST_RESULT\\TEST_RESULT_2024_12_22__00_50_06\\TestDumpHdr_ref_4_.hdr";
    %['/Users/chan/Library/CloudStorage/GoogleDrive-hcs3759@gmail.com/내 ', ...
     %   '드라이브/Colab ', ...;
      %  'Notebooks/HDR_DATASET/CaveatsOfQA/reference/001.exr'];

    inData = hdrread(inpath);
    refData = hdrread(referpath); 
    %exrread(referpath);

    disp(inpath)

    
    Lpeak = 500.0;
    
    contrast = 1000000;

    gamma = 2.2;
    E_ambient = 100;
    ppd = hdrvdp_pix_per_deg( 24, [3840 2160], 0.8 );
    
    m_inData = inData / max(inData(:));
    m_refData = refData / max(refData(:));
    
    L_in = hdrvdp_gog_display_model(m_inData, Lpeak, contrast, gamma, E_ambient);

    L_ref = hdrvdp_gog_display_model(m_refData, Lpeak, contrast, gamma, E_ambient);

    ret = hdrvdp3('quality', L_in, L_ref, 'rgb-native', ppd).Q;
    
    ret = gather(ret);

end