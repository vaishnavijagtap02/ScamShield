import 'package:flutter/material.dart';
import 'package:scamshield/engine/models.dart';

enum AppLanguage { hiLat, hiDev }

class S {
  const new(this.lang);

  factory of(BuildContext _) {
    return const S(AppLanguage.hiLat);
  }

  final AppLanguage lang;

  bool get isHindi => lang == AppLanguage.hiDev;

  String get appName => 'ScamShield';

  // Home
  String get langToggle => isHindi ? 'Eng' : 'हिं';
  String get homeTitle => 'ScamShield';
  String get guardianLinkedPrefix =>
      isHindi ? 'अलर्ट जाएगा: ' : 'Alert jaayega: ';
  String get linkGuardianCard => isHindi
      ? 'फैमिली को जोड़ें: स्कैम पर उन्हें तुरंत पता चलेगा'
      : 'Family ko jodein: scam pe unhe turant pata chalega';
  String get checkRecordingBtn =>
      isHindi ? 'रिकॉर्डिंग चेक करें' : 'Recording check karein';
  String get checkRecordingSub =>
      isHindi ? 'कॉल रिकॉर्डिंग या वॉइस नोट' : 'Call recording ya voice note';
  String get liveGuardBtn => isHindi ? 'Live Guard' : 'Live Guard';
  String get liveGuardSub =>
      isHindi ? 'स्पीकर पर चल रही कॉल सुनो' : 'Speaker pe chal rahi call suno';
  String get demoBtn => isHindi ? 'Demo' : 'Demo';
  String get demoSub =>
      isHindi ? 'स्कैम के नमूने देखें' : 'Scam ke namoone dekhein';
  String get demoOnlyBanner => isHindi
      ? 'सिर्फ Demo मोड चलेगा (API keys missing)'
      : 'Sirf Demo mode chalega (API keys missing)';

  List<String> get didYouKnowFacts => isHindi
      ? [
          'कोई भी पुलिस या CBI वीडियो कॉल पर अरेस्ट नहीं करती।',
          'डिजिटल अरेस्ट जैसा कोई कानून भारत में नहीं है।',
          'बैंक कभी भी वीडियो कॉल या OTP पर खाता बंद करने की धमकी नहीं देता।',
        ]
      : [
          'Koi bhi police ya CBI video call pe arrest nahi karti.',
          'Digital arrest jaisa koi kanoon nahi hai.',
          'Bank kabhi bhi video call ya OTP pe khata band karne ki dhamki nahi deta.',
        ];

  // Upload
  String get uploadTitle => isHindi ? 'रिकॉर्डिंग चुनें' : 'Recording chunein';
  String get uploadSupportedNote => isHindi
      ? 'WAV (किसी भी लंबाई का), MP3 / M4A / OGG (30 सेकंड तक)'
      : 'WAV (kisi bhi length ka), MP3 / M4A / OGG (30 second tak)';
  String get chooseFileBtn => isHindi ? 'फ़ाइल चुनें' : 'File chunein';
  String get privacyCaption => isHindi
      ? 'ऑडियो सिर्फ लिखने (transcription) के लिए भेजा जाता है। फ़ोन पर या कहीं और सेव नहीं होता।'
      : 'Audio sirf likhne (transcription) ke liye bheja jaata hai. Phone pe ya kahin aur save nahi hota.';
  String get errUnsupportedFile => isHindi
      ? 'यह फ़ाइल फॉर्मेट सपोर्टेड नहीं है। WAV, MP3, M4A या OGG चुनें।'
      : 'Yeh file format supported nahi hai. WAV, MP3, M4A ya OGG chunein.';
  String get errFileTooLong => isHindi
      ? 'MP3/M4A/OGG फ़ाइल 30 सेकंड से छोटी होनी चाहिए। लंबी रिकॉर्डिंग के लिए WAV इस्तेमाल करें।'
      : 'MP3/M4A/OGG file 30 second se choti honi chahiye. Lambi recording ke liye WAV format use karein.';
  String get errPickingFile => isHindi
      ? 'फ़ाइल चुनने में परेशानी हुई।'
      : 'File chunne mein pareshani aayi.';

  // Analysing
  String get analysingTitle =>
      isHindi ? 'जाँच हो रही है' : 'Jaanch ho rahi hai';
  String get listeningStatus => isHindi ? 'सुन रहे हैं…' : 'Sun rahe hain…';
  String piecesProgress(int done, int total) =>
      isHindi ? '$done / $total हिस्से सुने' : '$done / $total hisse sune';
  String get stopBtn => isHindi ? 'रोकें' : 'Rokein';
  String get errNoNetwork => isHindi
      ? 'इंटरनेट नहीं मिल रहा। Wi-Fi चेक करें या Demo चलाएं।'
      : 'Internet nahi mil raha. Wi-Fi check karein ya Demo chalayein.';
  String get notePartialAudio => isHindi
      ? 'कुछ हिस्सा ठीक से सुना नहीं गया, पर बाकी जाँच हो गई है।'
      : 'Kuch hissa theek se suna nahi gaya, par baaki jaanch ho gayi hai.';
  String get runDemoBtn => isHindi ? 'Demo चलाएं' : 'Demo chalayein';

  // Verdict
  String get verdictTitle => isHindi ? 'नतीजा' : 'Nateeja';
  String get levelKhatra => isHindi ? 'ख़तरा' : 'KHATRA';
  String get levelKhatraSub =>
      isHindi ? 'यह कॉल फ़्रॉड लगती है' : 'Ye scam lagta hai';
  String get levelSavdhan => isHindi ? 'सावधान' : 'SAVDHAN';
  String get levelSavdhanSub =>
      isHindi ? 'थोड़ा संदेह लगता है' : 'Thoda sandeh lagta hai';
  String get levelTheek => isHindi ? 'ठीक लगता है' : 'THEEK LAGTA HAI';
  String get levelTheekSub =>
      isHindi ? 'कोई ख़तरा नहीं दिखा' : 'Koi khatra nahi dikha';
  String get labelBasicCheck =>
      isHindi ? 'Basic Check (सिर्फ़ शब्द)' : 'Basic check';
  String get evidenceTitle => isHindi ? 'सबूत (Evidence)' : 'Saboot (Evidence)';
  String get noEvidenceFound => isHindi
      ? 'कोई संदिग्ध चीज़ नहीं मिली।'
      : 'Koi sandeh-janak cheez nahi mili.';
  String get whatNextBtn => isHindi ? 'आगे: क्या करें?' : 'Aage: kya karein?';
  String get sendFamilyBtn => isHindi ? 'फैमिली को भेजो' : 'Family ko bhejo';
  String alertSentSuccess(String name) =>
      isHindi ? '$name को अलर्ट भेज दिया ✓' : '$name ko alert bhej diya ✓';
  String get alertFailed => isHindi
      ? 'भेज नहीं पाए — दोबारा भेजें'
      : 'Bhej nahi paaye — Dobara bhejein';
  String get replayVoice =>
      isHindi ? 'आवाज़ दोबारा सुनें' : 'Awaaz dobara sunein';

  // Questions
  String get questionsTitle => isHindi ? 'कुछ ज़रूरी सवाल' : 'Kuch sawaal';
  String get qPaid =>
      isHindi ? 'क्या आपने पैसे भेजे?' : 'Kya aapne paise bheje?';
  String get qCreds => isHindi
      ? 'क्या OTP, पासवर्ड या बैंक डिटेल दी?'
      : 'Kya OTP ya bank details share ki?';
  String get qRemote => isHindi
      ? 'क्या कोई ऐप डाउनलोड की?'
      : 'Kya koi screen-sharing app download ki?';
  String get yesBtn => isHindi ? 'हाँ' : 'Haan';
  String get noBtn => isHindi ? 'नहीं' : 'Nahi';
  String get showPlanBtn => isHindi ? 'Plan दिखाओ' : 'Plan dikhao';

  // Action plan
  String get planTitle => isHindi ? 'तुरंत क्या करें' : 'Turant kya karein';
  String get call1930Btn =>
      isHindi ? '1930 पर कॉल करें' : '1930 pe call karein';
  String get draftComplaintBtn =>
      isHindi ? 'Complaint draft देखें' : 'Complaint draft dekhein';

  // Complaint
  String get complaintTitle => isHindi ? 'शिकायत का ड्राफ्ट' : 'Shikayat draft';
  String get copyBtn => isHindi ? 'Copy करें' : 'Copy karein';
  String get copySuccess => isHindi ? 'Copy हो गया ✓' : 'Copy ho gaya ✓';
  String get shareBtn => isHindi ? 'Share करें' : 'Share karein';
  String get openPortalBtn =>
      isHindi ? 'cybercrime.gov.in खोलें' : 'cybercrime.gov.in kholein';

  // Live guard
  String get liveInstruction => isHindi
      ? 'कॉल को स्पीकर पर रखें, यह फ़ोन पास रखें।'
      : 'Call ko speaker pe rakhein, ye phone paas rakhein.';
  String get liveListening => isHindi ? 'सुन रहा है' : 'Sun raha hai';
  String get stopAndShowResult =>
      isHindi ? 'रोकें और नतीजा देखें' : 'Rokein aur result dekhein';
  String get errMicPermission => isHindi
      ? 'माइक्रोफ़ोन की अनुमति नहीं मिली। Settings → Apps → ScamShield → Permissions में अनुमति दें।'
      : 'Microphone permission nahi mili. Settings → Apps → ScamShield → Permissions mein mic on karein.';

  // Demo
  String get demoScreenTitle =>
      isHindi ? 'Demo रिकॉर्डिंग्स' : 'Demo Recordings';
  String get demoSubtitle => isHindi
      ? 'असली मामलों और स्कैम के नमूने'
      : 'Asli mamle aur scam ki misalein';
  String get tagScam => isHindi ? 'स्कैम' : 'Scam';
  String get tagReal => isHindi ? 'असली' : 'Asli';
  String get tagSuspicious => isHindi ? 'शक' : 'Shak';

  // Guardians
  String get guardiansTitle => isHindi ? 'Guardians' : 'Guardians';
  String get noGuardians => isHindi
      ? 'अभी कोई guardian नहीं जुड़ा है।'
      : 'Abhi koi guardian nahi juda hai.';
  String get addGuardianBtn =>
      isHindi ? 'नया guardian जोड़ें' : 'Naya guardian jodein';
  String scanInstruction(String botUser) => isHindi
      ? 'Telegram में @$botUser खोलकर Start दबाएं या यह QR स्कैन करें।'
      : 'Telegram mein @$botUser kholkar Start dabayein ya ye QR scan karein.';
  String get waitingCountdown => isHindi ? 'इंतज़ार…' : 'Intezaar…';
  String guardianJoined(String name) =>
      isHindi ? '$name जुड़ गए ✓' : '$name jud gaye ✓';
  String get pairingTimeout => isHindi
      ? 'समय समाप्त हो गया। दोबारा कोशिश करें।'
      : 'Samay samapt ho gaya. Dobara koshish karein.';
  String get autoAlertSwitch => isHindi
      ? 'ख़तरा होने पर अपने-aap अलर्ट भेजो'
      : 'Khatra hone pe apne-aap alert bhejo';
  String get removeBtn => isHindi ? 'हटाएं' : 'Hatayein';
  String get linkCopied =>
      isHindi ? 'Link copy ho gaya ✓' : 'Link copy ho gaya ✓';

  // Settings
  String get settingsTitle => isHindi ? 'Settings' : 'Settings';
  String get languageSetting =>
      isHindi ? 'भाषा / Language' : 'Bhasha / Language';
  String get autoAlertSetting =>
      isHindi ? 'Auto-Alert Telegram' : 'Auto-Alert Telegram';
  String get autoAlertDesc => isHindi
      ? 'KHATRA आने पर parivaar ko turant alert bhejein'
      : 'KHATRA aane pe parivaar ko turant alert bhejein';
  String get userNameSetting =>
      isHindi ? 'आपका नाम (Alert के लिए)' : 'Aapka naam (Alert ke liye)';
  String get userNameHint => 'Jaise: Ramesh ji';
  String get fontNotice => isHindi
      ? 'टेक्स्ट बड़ा करना है? फ़ोन की Settings में जाकर Font Size बढ़ाएं।'
      : 'Text bada karna hai? Phone ki settings mein font size badhayein.';
  String get appVersionText => 'ScamShield v1.0.0 (Beyond Hack 2.0)';

  // Stages
  String stageName(Stage stage) {
    return switch (stage) {
      Stage.authority => isHindi ? 'अधिकारी' : 'Adhikari',
      Stage.fear => isHindi ? 'डर' : 'Darr',
      Stage.urgency => isHindi ? 'जल्दी' : 'Jaldi',
      Stage.secrecy => isHindi ? 'छुपाओ' : 'Chhupao',
      Stage.extraction => isHindi ? 'पैसा / OTP' : 'Paisa / OTP',
    };
  }

  String scamTypeName(ScamType type) {
    return switch (type) {
      ScamType.digitalArrest => isHindi ? 'डिजिटल अरेस्ट' : 'Digital Arrest',
      ScamType.kycBank => isHindi ? 'KYC / बैंक फ़्रॉड' : 'KYC / Bank Fraud',
      ScamType.courierParcel =>
        isHindi ? 'कूरियर पार्सल स्कैम' : 'Courier Parcel Scam',
      ScamType.traiSim =>
        isHindi ? 'TRAI / सिम ब्लॉक स्कैम' : 'TRAI / SIM Block',
      ScamType.investment => isHindi ? 'इन्वेस्टमेंट स्कैम' : 'Investment Scam',
      ScamType.loanApp => isHindi ? 'लोन ऐप फ़्रॉड' : 'Loan App Fraud',
      ScamType.sextortion => isHindi ? 'सेक्सटॉर्शन स्कैम' : 'Sextortion Scam',
      ScamType.familyEmergency =>
        isHindi ? 'फ़ैमिली इमरजेंसी स्कैम' : 'Family Emergency Scam',
      ScamType.none => isHindi ? 'कोई स्कैम नहीं' : 'Koi scam nahi',
      ScamType.unknown => isHindi ? 'अन्जान कॉल' : 'Anjaan call',
    };
  }
}
