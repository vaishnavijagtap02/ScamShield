import 'package:flutter/material.dart';
import 'package:scamshield/engine/models.dart';

enum AppLanguage { hiLat, hiDev, en, mr, gu, bn, ta, te }

extension AppLanguageX on AppLanguage {
  String get code => switch (this) {
    AppLanguage.hiLat => 'hi_lat',
    AppLanguage.hiDev => 'hi_dev',
    AppLanguage.en => 'en',
    AppLanguage.mr => 'mr',
    AppLanguage.gu => 'gu',
    AppLanguage.bn => 'bn',
    AppLanguage.ta => 'ta',
    AppLanguage.te => 'te',
  };

  String get displayName => switch (this) {
    AppLanguage.hiLat => 'Hinglish (English)',
    AppLanguage.hiDev => 'हिन्दी (Devanagari)',
    AppLanguage.en => 'English',
    AppLanguage.mr => 'मराठी (Marathi)',
    AppLanguage.gu => 'ગુજરાતી (Gujarati)',
    AppLanguage.bn => 'বাংলা (Bengali)',
    AppLanguage.ta => 'தமிழ் (Tamil)',
    AppLanguage.te => 'తెలుగు (Telugu)',
  };

  String get nativeName => switch (this) {
    AppLanguage.hiLat => 'Hinglish',
    AppLanguage.hiDev => 'हिन्दी',
    AppLanguage.en => 'English',
    AppLanguage.mr => 'मराठी',
    AppLanguage.gu => 'ગુજરાતી',
    AppLanguage.bn => 'বাংলা',
    AppLanguage.ta => 'தமிழ்',
    AppLanguage.te => 'తెలుగు',
  };

  String get shortLabel => switch (this) {
    AppLanguage.hiLat => 'Eng',
    AppLanguage.hiDev => 'हिं',
    AppLanguage.en => 'EN',
    AppLanguage.mr => 'मरा',
    AppLanguage.gu => 'ગુજ',
    AppLanguage.bn => 'বাং',
    AppLanguage.ta => 'தமி',
    AppLanguage.te => 'తెలు',
  };

  static AppLanguage fromCode(String code) {
    return switch (code) {
      'hi_dev' => AppLanguage.hiDev,
      'en' => AppLanguage.en,
      'mr' => AppLanguage.mr,
      'gu' => AppLanguage.gu,
      'bn' => AppLanguage.bn,
      'ta' => AppLanguage.ta,
      'te' => AppLanguage.te,
      _ => AppLanguage.hiLat,
    };
  }
}

class S {
  const new(this.lang);

  factory of(BuildContext _) {
    return const S(AppLanguage.hiLat);
  }

  final AppLanguage lang;

  bool get isHindi => lang == AppLanguage.hiDev;

  String get appName => 'ScamShield';

  // Home
  String get langToggle => lang.shortLabel;
  String get homeTitle => 'ScamShield';

  String get guardianLinkedPrefix => switch (lang) {
    AppLanguage.hiDev => 'अलर्ट जाएगा: ',
    AppLanguage.en => 'Alert will be sent to: ',
    AppLanguage.mr => 'सूचना पाठवली जाईल: ',
    AppLanguage.gu => 'ચેતવણી મોકલવામાં આવશે: ',
    AppLanguage.bn => 'সতর্কবার্তা যাবে: ',
    AppLanguage.ta => 'எச்சரிக்கை அனுப்பப்படும்: ',
    AppLanguage.te => 'హెచ్చరిక పంపబడుతుంది: ',
    _ => 'Alert jaayega: ',
  };

  String get linkGuardianCard => switch (lang) {
    AppLanguage.hiDev => 'फैमिली को जोड़ें: स्कैम पर उन्हें तुरंत पता चलेगा',
    AppLanguage.en => 'Link Family: Alert them instantly if a scam is detected',
    AppLanguage.mr => 'कुटुंबाला जोडा: स्कॅम झाल्यास त्यांना लगेच समजेल',
    AppLanguage.gu => 'પરિવારને જોડો: છેતરપિંડી પર તેમને તરત જાણ થશે',
    AppLanguage.bn =>
      'পরিবারকে যুক্ত করুন: স্ক্যাম হলে তারা তৎক্ষণাৎ জানতে পারবে',
    AppLanguage.ta => 'குடும்பத்தை இணைக்கவும்: மோசடி நடந்தால் உடனே தெரியவரும்',
    AppLanguage.te =>
      'కుటుంబాన్ని జోడించండి: స్కామ్ జరిగితే వెంటనే తెలుస్తుంది',
    _ => 'Family ko jodein: scam pe unhe turant pata chalega',
  };

  String get checkRecordingBtn => switch (lang) {
    AppLanguage.hiDev => 'रिकॉर्डिंग चेक करें',
    AppLanguage.en => 'Scan Recording',
    AppLanguage.mr => 'रेकॉर्डिंग तपासा',
    AppLanguage.gu => 'રેકોર્ડિંગ તપાસો',
    AppLanguage.bn => 'রেকর্ডিং যাচাই করুন',
    AppLanguage.ta => 'பதிவைச் சரிபார்க்கவும்',
    AppLanguage.te => 'రికార్డింగ్‌ను తనిఖీ చేయండి',
    _ => 'Recording check karein',
  };

  String get checkRecordingSub => switch (lang) {
    AppLanguage.hiDev => 'कॉल रिकॉर्डिंग या वॉइस नोट',
    AppLanguage.en => 'Call recording or audio file',
    AppLanguage.mr => 'कॉल रेकॉर्डिंग किंवा व्हॉइस नोट',
    AppLanguage.gu => 'કૉલ રેકોર્ડિંગ અથવા વૉઇસ નોટ',
    AppLanguage.bn => 'কল রেকর্ডিং বা ভয়েস নোট',
    AppLanguage.ta => 'அழைப்புப் பதிவு அல்லது ஆடியோ',
    AppLanguage.te => 'కాల్ రికార్డింగ్ లేదా వాయిస్ నోట్',
    _ => 'Call recording ya voice note',
  };

  String get liveGuardBtn => 'Live Guard';

  String get liveGuardSub => switch (lang) {
    AppLanguage.hiDev => 'स्पीकर पर चल रही कॉल सुनो',
    AppLanguage.en => 'Monitor live call on speaker',
    AppLanguage.mr => 'स्पीकरवरील चालू कॉल ऐका',
    AppLanguage.gu => 'સ્પીકર પર ચાલી રહેલ કૉલ સાંભળો',
    AppLanguage.bn => 'স্পিকারে চলমান কল শুনুন',
    AppLanguage.ta => 'ஸ்பீக்கரில் பேசும் அழைப்பைக் கேளுங்கள்',
    AppLanguage.te => 'స్పీకర్‌లో జరుగుతున్న కాల్ వినండి',
    _ => 'Speaker pe chal rahi call suno',
  };

  String get demoBtn => 'Demo';

  String get demoSub => switch (lang) {
    AppLanguage.hiDev => 'स्कैम के नमूने देखें',
    AppLanguage.en => 'Explore scam call scenarios',
    AppLanguage.mr => 'स्कॅमची उदाहरणे पहा',
    AppLanguage.gu => 'છેતરપિંડીના નમૂના જુઓ',
    AppLanguage.bn => 'স্ক্যামের নমুনা দেখুন',
    AppLanguage.ta => 'மோசடி மாதிரிகளைப் பார்க்கவும்',
    AppLanguage.te => 'స్కామ్ నమూనాలను చూడండి',
    _ => 'Scam ke namoone dekhein',
  };

  String get demoOnlyBanner => switch (lang) {
    AppLanguage.hiDev => 'सिर्फ Demo मोड चलेगा (API keys missing)',
    AppLanguage.en => 'Running in Demo mode (API keys missing)',
    AppLanguage.mr => 'फक्त Demo मोड चालेल (API keys missing)',
    AppLanguage.gu => 'માત્ર Demo મોડ ચાલશે (API keys missing)',
    AppLanguage.bn => 'শুধু Demo মোড চলবে (API keys missing)',
    AppLanguage.ta => 'Demo பயன்முறை மட்டுமே இயங்கும் (API keys missing)',
    AppLanguage.te => 'కేవలం Demo మోడ్ మాత్రమే పనిచేస్తుంది (API keys missing)',
    _ => 'Sirf Demo mode chalega (API keys missing)',
  };

  List<String> get didYouKnowFacts => switch (lang) {
    AppLanguage.hiDev => [
      'कोई भी पुलिस या CBI वीडियो कॉल पर अरेस्ट नहीं करती।',
      'डिजिटल अरेस्ट जैसा कोई कानून भारत में नहीं है।',
      'बैंक कभी भी वीडियो कॉल या OTP पर खाता बंद करने की धमकी नहीं देता।',
    ],
    AppLanguage.en => [
      'Police, CBI, and ED never place anyone under arrest via video call.',
      'There is no legal provision for "Digital Arrest" under Indian law.',
      'Banks will never demand OTPs or threaten account freezes over a video call.',
    ],
    AppLanguage.mr => [
      'कोणतीही पोलीस किंवा CBI व्हिडिओ कॉलवर कोणालाही अटक करत नाही.',
      'भारतात "डिजिटल अरेस्ट" असा कोणताही कायदा अस्तित्वात नाही.',
      'बँक कधीही व्हिडिओ कॉल किंवा OTP वर खाते बंद करण्याची धमकी देत नाही.',
    ],
    AppLanguage.gu => [
      'કોઈપણ પોલીસ કે CBI વીડિયો કૉલ પર ધરપકડ કરતી નથી.',
      'ભારતમાં "ડિજિટલ અરેસ્ટ" જેવો કોઈ કાયદો નથી.',
      'બેંક ક્યારેય વીડિયો કૉલ અથવા OTP પર ખાતું બંધ કરવાની ધમકી આપતી નથી.',
    ],
    AppLanguage.bn => [
      'কোনো পুলিশ বা CBI ভিডিও কলে কাউকে গ্রেপ্তার করে না।',
      'ভারতীয় আইনে "ডিজিটাল অ্যারেস্ট" বলে কোনো বিধান নেই।',
      'ব্যাংক কখনও ভিডিও কল বা OTP-তে অ্যাকাউন্ট ব্লক করার হুমকি দেয় না।',
    ],
    AppLanguage.ta => [
      'காவல்துறை அல்லது CBI வீடியோ காலில் யாரையும் கைது செய்வதில்லை.',
      'இந்திய சட்டத்தில் "டிஜிட்டல் கைது" என்ற நடைமுறையே இல்லை.',
      'வங்கி ஒருபோதும் வீடியோ காலிலோ OTP கேட்டோ கணக்கை முடக்குவதில்லை.',
    ],
    AppLanguage.te => [
      'పోలీసులు లేదా CBI వీడియో కాల్‌లో ఎవరినీ అరెస్టు చేయరు.',
      'భారతీయ చట్టంలో "డిజిటల్ అరెస్ట్" అనే నిబంధన లేదు.',
      'బ్యాంకులు ఎప్పుడూ వీడియో కాల్ లేదా OTP ద్వారా ఖాతా రద్దు చేస్తామని బెదిరించవు.',
    ],
    _ => [
      'Koi bhi police ya CBI video call pe arrest nahi karti.',
      'Digital arrest jaisa koi kanoon nahi hai.',
      'Bank kabhi bhi video call ya OTP pe khata band karne ki dhamki nahi deta.',
    ],
  };

  // Upload
  String get uploadTitle => switch (lang) {
    AppLanguage.hiDev => 'रिकॉर्डिंग चुनें',
    AppLanguage.en => 'Choose Recording',
    AppLanguage.mr => 'रेकॉर्डिंग निवडा',
    AppLanguage.gu => 'રેકોર્ડિંગ પસંદ કરો',
    AppLanguage.bn => 'রেকর্ডিং নির্বাচন করুন',
    AppLanguage.ta => 'பதிவைத் தேர்ந்தெடுக்கவும்',
    AppLanguage.te => 'రికార్డింగ్‌ను ఎంచుకోండి',
    _ => 'Recording chunein',
  };

  String get uploadSupportedNote => switch (lang) {
    AppLanguage.hiDev =>
      'WAV (किसी भी लंबाई का), MP3 / M4A / OGG (30 सेकंड तक)',
    AppLanguage.en => 'WAV (any length), MP3 / M4A / OGG (up to 30 seconds)',
    AppLanguage.mr =>
      'WAV (कोणत्याही लांबीचा), MP3 / M4A / OGG (30 सेकंदांपर्यंत)',
    AppLanguage.gu => 'WAV (કોઈપણ લંબાઈ), MP3 / M4A / OGG (30 સેકન્ડ સુધી)',
    AppLanguage.bn =>
      'WAV (যেকোনো দৈর্ঘ্যের), MP3 / M4A / OGG (৩০ সেকেন্ড পর্যন্ত)',
    AppLanguage.ta => 'WAV (எந்த நீளமும்), MP3 / M4A / OGG (30 வினாடிகள் வரை)',
    AppLanguage.te => 'WAV (ఏ పొడవు అయినా), MP3 / M4A / OGG (30 సెకన్ల వరకు)',
    _ => 'WAV (kisi bhi length ka), MP3 / M4A / OGG (30 second tak)',
  };

  String get chooseFileBtn => switch (lang) {
    AppLanguage.hiDev => 'फ़ाइल चुनें',
    AppLanguage.en => 'Choose File',
    AppLanguage.mr => 'फाइल निवडा',
    AppLanguage.gu => 'ફાઇલ પસંદ કરો',
    AppLanguage.bn => 'ফাইল বাছুন',
    AppLanguage.ta => 'கோப்பைத் தேர்ந்தெடுக்கவும்',
    AppLanguage.te => 'ఫైల్‌ను ఎంచుకోండి',
    _ => 'File chunein',
  };

  String get privacyCaption => switch (lang) {
    AppLanguage.hiDev => 'ऑडियो सिर्फ लिखने (transcription) के लिए भेजा जाता है। फ़ोन पर या कहीं और सेव नहीं होता।',
    AppLanguage.en => 'Audio is processed purely in-memory for transcription. Never saved or stored anywhere.',
    AppLanguage.mr => 'ऑडिओ फक्त ट्रान्सक्रिप्शनसाठी वापरला जातो. फोनवर किंवा कुठेही सेव्ह केला जात नाही.',
    AppLanguage.gu => 'ઑડિયો ફક્ત ટ્રાન્સક્રિપ્શન માટે ઉપયોગમાં લેવાય છે. ક્યાંય સંગ્રહિત થતો નથી.',
    AppLanguage.bn =>
      'অডিও কেবল ট্রান্সক্রিপশনের জন্য ব্যবহৃত হয়। কোথাও সেভ হয় না।',
    AppLanguage.ta => 'ஆடியோ எழுத்துருவாக்கத்திற்கு மட்டுமே பயன்படுகிறது. எங்கும் சேமிக்கப்படுவதில்லை.',
    AppLanguage.te => 'ఆడియో కేవలం ట్రాన్స్‌క్రిప్షన్ కోసం మాత్రమే ఉపయోగించబడుతుంది. ఎక్కడా సేవ్ చేయబడదు.',
    _ => 'Audio sirf likhne (transcription) ke liye bheja jaata hai. Phone pe ya kahin aur save nahi hota.',
  };

  String get errUnsupportedFile => switch (lang) {
    AppLanguage.hiDev =>
      'यह फ़ाइल फॉर्मेट सपोर्टेड नहीं है। WAV, MP3, M4A या OGG चुनें।',
    AppLanguage.en =>
      'Unsupported file format. Please choose WAV, MP3, M4A or OGG.',
    AppLanguage.mr =>
      'हा फाइल फॉरमॅट सपोर्टेड नाही. WAV, MP3, M4A किंवा OGG निवडा.',
    _ => 'Yeh file format supported nahi hai. WAV, MP3, M4A ya OGG chunein.',
  };

  String get errFileTooLong => switch (lang) {
    AppLanguage.hiDev => 'MP3/M4A/OGG फ़ाइल 30 सेकंड से छोटी होनी चाहिए। लंबी रिकॉर्डिंग के लिए WAV इस्तेमाल करें।',
    AppLanguage.en => 'MP3/M4A/OGG file must be under 30 seconds. For longer recordings, use WAV.',
    _ => 'MP3/M4A/OGG file 30 second se choti honi chahiye. Lambi recording ke liye WAV format use karein.',
  };

  String get errPickingFile => switch (lang) {
    AppLanguage.hiDev => 'फ़ाइल चुनने में परेशानी हुई।',
    AppLanguage.en => 'Failed to pick file.',
    _ => 'File chunne mein pareshani aayi.',
  };

  // Analysing
  String get analysingTitle => switch (lang) {
    AppLanguage.hiDev => 'जाँच हो रही है',
    AppLanguage.en => 'Analyzing Audio',
    AppLanguage.mr => 'तपासणी सुरू आहे',
    AppLanguage.gu => 'તપાસ ચાલુ છે',
    AppLanguage.bn => 'যাচাই করা হচ্ছে',
    AppLanguage.ta => 'ஆய்வு செய்யப்படுகிறது',
    AppLanguage.te => 'విశ్లేషిస్తోంది',
    _ => 'Jaanch ho rahi hai',
  };

  String get listeningStatus => switch (lang) {
    AppLanguage.hiDev => 'सुन रहे हैं…',
    AppLanguage.en => 'Listening…',
    AppLanguage.mr => 'ऐकत आहे…',
    AppLanguage.gu => 'સાંભળી રહ્યા છીએ…',
    AppLanguage.bn => 'শুনছি…',
    AppLanguage.ta => 'கேட்கிறது…',
    AppLanguage.te => 'వింటోంది…',
    _ => 'Sun rahe hain…',
  };

  String piecesProgress(int done, int total) => switch (lang) {
    AppLanguage.hiDev => '$done / $total हिस्से सुने',
    AppLanguage.en => '$done / $total chunks analyzed',
    AppLanguage.mr => '$done / $total भाग तपासले',
    AppLanguage.gu => '$done / $total ભાગો તપાસ્યા',
    AppLanguage.bn => '$done / $total অংশ শোনা হয়েছে',
    AppLanguage.ta => '$done / $total பகுதிகள் பகுப்பாய்வு செய்யப்பட்டன',
    AppLanguage.te => '$done / $total భాగాలు విశ్లేషించబడ్డాయి',
    _ => '$done / $total hisse sune',
  };

  String get stopBtn => switch (lang) {
    AppLanguage.hiDev => 'रोकें',
    AppLanguage.en => 'Stop',
    AppLanguage.mr => 'थांबवा',
    AppLanguage.gu => 'રોકો',
    AppLanguage.bn => 'থামান',
    AppLanguage.ta => 'நிறுத்து',
    AppLanguage.te => 'ఆపండి',
    _ => 'Rokein',
  };

  String get errNoNetwork => switch (lang) {
    AppLanguage.hiDev => 'इंटरनेट नहीं मिल रहा। Wi-Fi चेक करें या Demo चलाएं।',
    AppLanguage.en => 'No internet connection. Check Wi-Fi or run Demo.',
    AppLanguage.mr => 'इंटरनेट कनेक्शन नाही. Wi-Fi तपासा किंवा Demo वापरा.',
    _ => 'Internet nahi mil raha. Wi-Fi check karein ya Demo chalayein.',
  };

  String get notePartialAudio => switch (lang) {
    AppLanguage.hiDev =>
      'कुछ हिस्सा ठीक से सुना नहीं गया, पर बाकी जाँच हो गई है।',
    AppLanguage.en =>
      'Some audio pieces could not be analyzed, remaining check completed.',
    _ => 'Kuch hissa theek se suna nahi gaya, par baaki jaanch ho gayi hai.',
  };

  String get runDemoBtn => switch (lang) {
    AppLanguage.hiDev => 'Demo चलाएं',
    AppLanguage.en => 'Launch Demo',
    AppLanguage.mr => 'Demo सुरू करा',
    _ => 'Demo chalayein',
  };

  // Verdict
  String get verdictTitle => switch (lang) {
    AppLanguage.hiDev => 'नतीजा',
    AppLanguage.en => 'Verdict',
    AppLanguage.mr => 'निकाल',
    AppLanguage.gu => 'પરિણામ',
    AppLanguage.bn => 'ফলাফল',
    AppLanguage.ta => 'முடிவு',
    AppLanguage.te => 'ఫలితం',
    _ => 'Nateeja',
  };

  String get levelKhatra => switch (lang) {
    AppLanguage.hiDev => 'ख़तरा',
    AppLanguage.en => 'HIGH RISK',
    AppLanguage.mr => 'धोका',
    AppLanguage.gu => 'ખતરો',
    AppLanguage.bn => 'বিপদ',
    AppLanguage.ta => 'ஆபத்து',
    AppLanguage.te => 'ప్రమాదం',
    _ => 'KHATRA',
  };

  String get levelKhatraSub => switch (lang) {
    AppLanguage.hiDev => 'यह कॉल फ़्रॉड लगती है',
    AppLanguage.en => 'This call appears to be fraudulent',
    AppLanguage.mr => 'हा कॉल फसवणूक (स्कॅम) वाटतो',
    AppLanguage.gu => 'આ કૉલ છેતરપિંડી લાગે છે',
    AppLanguage.bn => 'এই কলটি প্রতারণামূলক বলে মনে হচ্ছে',
    AppLanguage.ta => 'இந்த அழைப்பு மோசடியாகத் தெரிகிறது',
    AppLanguage.te => 'ఈ కాల్ మోసపూరితమైనదిగా కనిపిస్తోంది',
    _ => 'Ye scam lagta hai',
  };

  String get levelSavdhan => switch (lang) {
    AppLanguage.hiDev => 'सावधान',
    AppLanguage.en => 'CAUTION',
    AppLanguage.mr => 'सावधान',
    AppLanguage.gu => 'સાવધાન',
    AppLanguage.bn => 'সতর্ক',
    AppLanguage.ta => 'எச்சரிக்கை',
    AppLanguage.te => 'జాగ్రత్త',
    _ => 'SAVDHAN',
  };

  String get levelSavdhanSub => switch (lang) {
    AppLanguage.hiDev => 'थोड़ा संदेह लगता है',
    AppLanguage.en => 'Suspicious patterns detected',
    AppLanguage.mr => 'संशयास्पद हालचाली आढळल्या',
    AppLanguage.gu => 'શંકાસ્પદ બાબત જણાય છે',
    AppLanguage.bn => 'সন্দেহজনক কার্যকলাপ ধরা পড়েছে',
    AppLanguage.ta => 'சந்தேகத்திற்கிடமான செயல்பாடு காணப்படுகிறது',
    AppLanguage.te => 'అనుమానాస్పద చర్యలు కనిపించాయి',
    _ => 'Thoda sandeh lagta hai',
  };

  String get levelTheek => switch (lang) {
    AppLanguage.hiDev => 'ठीक लगता है',
    AppLanguage.en => 'SAFE',
    AppLanguage.mr => 'सुरक्षित वाटते',
    AppLanguage.gu => 'સુરક્ષિત લાગે છે',
    AppLanguage.bn => 'নিরাপদ মনে হচ্ছে',
    AppLanguage.ta => 'பாதுகாப்பாகத் தெரிகிறது',
    AppLanguage.te => 'సురక్షితంగా ఉంది',
    _ => 'THEEK LAGTA HAI',
  };

  String get levelTheekSub => switch (lang) {
    AppLanguage.hiDev => 'कोई ख़तरा नहीं दिखा',
    AppLanguage.en => 'No high-risk scam tactics detected',
    AppLanguage.mr => 'कोणताही धोका आढळला नाही',
    AppLanguage.gu => 'કોઈ ખતરો જણાયો નથી',
    AppLanguage.bn => 'কোনো ঝুঁকি দেখা যায়নি',
    AppLanguage.ta => 'எந்த ஆபத்தும் கண்டறியப்படவில்லை',
    AppLanguage.te => 'ఎలాంటి ప్రమాదం కనిపించలేదు',
    _ => 'Koi khatra nahi dikha',
  };

  String get labelBasicCheck => switch (lang) {
    AppLanguage.hiDev => 'Basic Check (सिर्फ़ शब्द)',
    AppLanguage.en => 'Basic Check (Lexicon only)',
    AppLanguage.mr => 'मूलभूत तपासणी (शब्द)',
    _ => 'Basic check',
  };

  String get evidenceTitle => switch (lang) {
    AppLanguage.hiDev => 'सबूत (Evidence)',
    AppLanguage.en => 'Detected Evidence',
    AppLanguage.mr => 'पुरावा (Evidence)',
    AppLanguage.gu => 'પુરાવા (Evidence)',
    AppLanguage.bn => 'প্রমাণ (Evidence)',
    AppLanguage.ta => 'ஆதாரம் (Evidence)',
    AppLanguage.te => 'ఆధారాలు (Evidence)',
    _ => 'Saboot (Evidence)',
  };

  String get noEvidenceFound => switch (lang) {
    AppLanguage.hiDev => 'कोई संदिग्ध चीज़ नहीं मिली।',
    AppLanguage.en => 'No suspicious evidence detected.',
    AppLanguage.mr => 'कोणतीही संशयास्पद गोष्ट आढळली नाही.',
    _ => 'Koi sandeh-janak cheez nahi mili.',
  };

  String get whatNextBtn => switch (lang) {
    AppLanguage.hiDev => 'आगे: क्या करें?',
    AppLanguage.en => 'Next: What to do?',
    AppLanguage.mr => 'पुढे काय करावे?',
    AppLanguage.gu => 'આગળ: શું કરવું?',
    AppLanguage.bn => 'এরপর: কী করবেন?',
    AppLanguage.ta => 'அடுத்து என்ன செய்வது?',
    AppLanguage.te => 'తదుపరి: ఏమి చేయాలి?',
    _ => 'Aage: kya karein?',
  };

  String get sendFamilyBtn => switch (lang) {
    AppLanguage.hiDev => 'फैमिली को भेजो',
    AppLanguage.en => 'Alert Family',
    AppLanguage.mr => 'कुटुंबाला पाठवा',
    AppLanguage.gu => 'પરિવારને મોકલો',
    AppLanguage.bn => 'পরিবারকে পাঠান',
    AppLanguage.ta => 'குடும்பத்திற்கு அனுப்பவும்',
    AppLanguage.te => 'కుటుంబానికి పంపండి',
    _ => 'Family ko bhejo',
  };

  String alertSentSuccess(String name) => switch (lang) {
    AppLanguage.hiDev => '$name को अलर्ट भेज दिया ✓',
    AppLanguage.en => 'Alert sent to $name ✓',
    AppLanguage.mr => '$name यांना सूचना पाठवली ✓',
    AppLanguage.gu => '$name ને ચેતવણી મોકલી દીધી ✓',
    AppLanguage.bn => '$name-কে সতর্কবার্তা পাঠানো হয়েছে ✓',
    AppLanguage.ta => '$name-க்கு எச்சரிக்கை அனுப்பப்பட்டது ✓',
    AppLanguage.te => '$name కి హెచ్చరిక పంపబడింది ✓',
    _ => '$name ko alert bhej diya ✓',
  };

  String get alertFailed => switch (lang) {
    AppLanguage.hiDev => 'भेज नहीं पाए — दोबारा भेजें',
    AppLanguage.en => 'Failed to send — Retry',
    AppLanguage.mr => 'पाठवता आले नाही — पुन्हा प्रयत्न करा',
    _ => 'Bhej nahi paaye — Dobara bhejein',
  };

  String get replayVoice => switch (lang) {
    AppLanguage.hiDev => 'आवाज़ दोबारा सुनें',
    AppLanguage.en => 'Replay voice warning',
    AppLanguage.mr => 'आवाज पुन्हा ऐका',
    _ => 'Awaaz dobara sunein',
  };

  // Questions
  String get questionsTitle => switch (lang) {
    AppLanguage.hiDev => 'कुछ ज़रूरी सवाल',
    AppLanguage.en => 'Security Assessment',
    AppLanguage.mr => 'काही महत्त्वाचे प्रश्न',
    AppLanguage.gu => 'કેટલાક જરૂરી પ્રશ્નો',
    AppLanguage.bn => 'কিছু জরুরি প্রশ্ন',
    AppLanguage.ta => 'முக்கியமான கேள்விகள்',
    AppLanguage.te => 'కొన్ని ముఖ్యమైన ప్రశ్నలు',
    _ => 'Kuch sawaal',
  };

  String get qPaid => switch (lang) {
    AppLanguage.hiDev => 'क्या आपने पैसे भेजे?',
    AppLanguage.en => 'Did you transfer or send any money?',
    AppLanguage.mr => 'तुम्ही पैसे पाठवले का?',
    AppLanguage.gu => 'શું તમે પૈસા મોકલ્યા?',
    AppLanguage.bn => 'আপনি কি টাকা পাঠিয়েছেন?',
    AppLanguage.ta => 'பணம் அனுப்பினீர்களா?',
    AppLanguage.te => 'మీరు డబ్బు పంపారా?',
    _ => 'Kya aapne paise bheje?',
  };

  String get qCreds => switch (lang) {
    AppLanguage.hiDev => 'क्या OTP, पासवर्ड या बैंक डिटेल दी?',
    AppLanguage.en => 'Did you share an OTP, password, or bank details?',
    AppLanguage.mr => 'तुम्ही OTP किंवा बँक तपशील दिले का?',
    AppLanguage.gu => 'શું OTP કે બેંક વિગતો આપી?',
    AppLanguage.bn => 'OTP বা ব্যাংক বিবরণ শেয়ার করেছেন?',
    AppLanguage.ta => 'OTP அல்லது வங்கி விவரங்களைப் பகிர்ந்தீர்களா?',
    AppLanguage.te => 'OTP లేదా బ్యాంక్ వివరాలు ఇచ్చారా?',
    _ => 'Kya OTP ya bank details share ki?',
  };

  String get qRemote => switch (lang) {
    AppLanguage.hiDev => 'क्या कोई ऐप डाउनलोड की?',
    AppLanguage.en => 'Did you install any screen-sharing or unknown app?',
    AppLanguage.mr => 'कोणते ॲप डाउनलोड केले का?',
    AppLanguage.gu => 'શું કોઈ એપ ડાઉનલોડ કરી?',
    AppLanguage.bn => 'কোনো স্ক্রিন-শেয়ারিং অ্যাপ ডাউনলোড করেছেন?',
    AppLanguage.ta => 'ஏதேனும் ஆப் பதிவிறக்கம் செய்தீர்களா?',
    AppLanguage.te => 'ఏదైనా యాప్ డౌన్‌లోడ్ చేశారా?',
    _ => 'Kya koi screen-sharing app download ki?',
  };

  String get yesBtn => switch (lang) {
    AppLanguage.hiDev => 'हाँ',
    AppLanguage.en => 'Yes',
    AppLanguage.mr => 'होय',
    AppLanguage.gu => 'હા',
    AppLanguage.bn => 'হ্যাঁ',
    AppLanguage.ta => 'ஆம்',
    AppLanguage.te => 'అవును',
    _ => 'Haan',
  };

  String get noBtn => switch (lang) {
    AppLanguage.hiDev => 'नहीं',
    AppLanguage.en => 'No',
    AppLanguage.mr => 'नाही',
    AppLanguage.gu => 'ના',
    AppLanguage.bn => 'না',
    AppLanguage.ta => 'இல்லை',
    AppLanguage.te => 'కాదు',
    _ => 'Nahi',
  };

  String get showPlanBtn => switch (lang) {
    AppLanguage.hiDev => 'Plan दिखाओ',
    AppLanguage.en => 'View Action Plan',
    AppLanguage.mr => 'कृती योजना पहा',
    AppLanguage.gu => 'કાર્ય યોજના જુઓ',
    AppLanguage.bn => 'অ্যাকশন প্ল্যান দেখুন',
    AppLanguage.ta => 'செயல்திட்டத்தைக் காண்க',
    AppLanguage.te => 'కార్యాచరణ ప్రణాళికను చూడండి',
    _ => 'Plan dikhao',
  };

  // Action plan
  String get planTitle => switch (lang) {
    AppLanguage.hiDev => 'तुरंत क्या करें',
    AppLanguage.en => 'Immediate Actions',
    AppLanguage.mr => 'त्वरित काय करावे',
    AppLanguage.gu => 'તરત જ શું કરવું',
    AppLanguage.bn => 'তৎক্ষণাৎ কী করবেন',
    AppLanguage.ta => 'உடனடியாக என்ன செய்ய வேண்டும்',
    AppLanguage.te => 'వెంటనే ఏమి చేయాలి',
    _ => 'Turant kya karein',
  };

  String get call1930Btn => switch (lang) {
    AppLanguage.hiDev => '1930 पर कॉल करें',
    AppLanguage.en => 'Call 1930 Helpline',
    AppLanguage.mr => '1930 वर कॉल करा',
    AppLanguage.gu => '1930 પર કૉલ કરો',
    AppLanguage.bn => '1930 নম্বরে কল করুন',
    AppLanguage.ta => '1930 எண்ணை அழைக்கவும்',
    AppLanguage.te => '1930కి కాల్ చేయండి',
    _ => '1930 pe call karein',
  };

  String get draftComplaintBtn => switch (lang) {
    AppLanguage.hiDev => 'Complaint draft देखें',
    AppLanguage.en => 'View Complaint Draft',
    AppLanguage.mr => 'तक्रारीचा मसुदा पहा',
    AppLanguage.gu => 'ફરિયાદ ડ્રાફ્ટ જુઓ',
    AppLanguage.bn => 'অভিযোগের খসড়া দেখুন',
    AppLanguage.ta => 'புகார் வரைவை பார்க்கவும்',
    AppLanguage.te => 'ఫిర్యాదు డ్రాఫ్ట్ చూడండి',
    _ => 'Complaint draft dekhein',
  };

  // Complaint
  String get complaintTitle => switch (lang) {
    AppLanguage.hiDev => 'शिकायत का ड्राफ्ट',
    AppLanguage.en => 'Complaint Draft',
    AppLanguage.mr => 'सायबर तक्रार मसुदा',
    AppLanguage.gu => 'સાયબર ફરિયાદ ડ્રાફ્ટ',
    AppLanguage.bn => 'সাইবার অভিযোগের খসড়া',
    AppLanguage.ta => 'சைபர் புகார் வரைவு',
    AppLanguage.te => 'సైబర్ ఫిర్యాదు డ్రాఫ్ట్',
    _ => 'Shikayat draft',
  };

  String get copyBtn => switch (lang) {
    AppLanguage.hiDev => 'Copy करें',
    AppLanguage.en => 'Copy Draft',
    AppLanguage.mr => 'कॉपी करा',
    AppLanguage.gu => 'કૉપિ કરો',
    AppLanguage.bn => 'কপি করুন',
    AppLanguage.ta => 'நகலெடுக்கவும்',
    AppLanguage.te => 'కాపీ చేయండి',
    _ => 'Copy karein',
  };

  String get copySuccess => switch (lang) {
    AppLanguage.hiDev => 'Copy हो गया ✓',
    AppLanguage.en => 'Copied to clipboard ✓',
    AppLanguage.mr => 'कॉपी झाले ✓',
    AppLanguage.gu => 'કૉપિ થઈ ગયું ✓',
    AppLanguage.bn => 'কপি করা হয়েছে ✓',
    AppLanguage.ta => 'நகலெடுக்கப்பட்டது ✓',
    AppLanguage.te => 'కాపీ చేయబడింది ✓',
    _ => 'Copy ho gaya ✓',
  };

  String get shareBtn => switch (lang) {
    AppLanguage.hiDev => 'Share करें',
    AppLanguage.en => 'Share Draft',
    AppLanguage.mr => 'शेअर करा',
    _ => 'Share karein',
  };

  String get openPortalBtn => 'cybercrime.gov.in kholein';

  // Live guard
  String get liveInstruction => switch (lang) {
    AppLanguage.hiDev => 'कॉल को स्पीकर पर रखें, यह फ़ोन पास रखें।',
    AppLanguage.en =>
      'Put the ongoing call on speaker and place this phone nearby.',
    AppLanguage.mr => 'कॉल स्पीकरवर ठेवा आणि हा फोन जवळ ठेवा.',
    AppLanguage.gu => 'કૉલ સ્પીકર પર રાખો અને આ ફોન નજીક રાખો.',
    AppLanguage.bn => 'কলটি স্পিকারে রাখুন এবং এই ফোনটি কাছে রাখুন।',
    AppLanguage.ta => 'அழைப்பை ஸ்பீக்கரில் வைத்து இந்த போனை அருகில் வைக்கவும்.',
    AppLanguage.te => 'కాల్‌ను స్పీకర్‌లో ఉంచి, ఈ ఫోన్‌ను దగ్గరగా ఉంచండి.',
    _ => 'Call ko speaker pe rakhein, ye phone paas rakhein.',
  };

  String get liveListening => switch (lang) {
    AppLanguage.hiDev => 'सुन रहा है',
    AppLanguage.en => 'Listening Live',
    AppLanguage.mr => 'ऐकत आहे',
    AppLanguage.gu => 'સાંભળી રહ્યું છે',
    AppLanguage.bn => 'শুনছে',
    AppLanguage.ta => 'கேட்கிறது',
    AppLanguage.te => 'వింటోంది',
    _ => 'Sun raha hai',
  };

  String get stopAndShowResult => switch (lang) {
    AppLanguage.hiDev => 'रोकें और नतीजा देखें',
    AppLanguage.en => 'Stop & View Result',
    AppLanguage.mr => 'थांबवा आणि निकाल पहा',
    AppLanguage.gu => 'રોકો અને પરિણામ જુઓ',
    AppLanguage.bn => 'থামান এবং ফলাফল দেখুন',
    AppLanguage.ta => 'நிறுத்தி முடிவைக் காண்க',
    AppLanguage.te => 'ఆపి ఫలితం చూడండి',
    _ => 'Rokein aur result dekhein',
  };

  String get errMicPermission => switch (lang) {
    AppLanguage.hiDev => 'माइक्रोफ़ोन की अनुमति नहीं मिली। Settings → Apps → ScamShield → Permissions में अनुमति दें।',
    AppLanguage.en =>
      'Microphone permission not granted. Please allow in device settings.',
    _ => 'Microphone permission nahi mili. Settings → Apps → ScamShield → Permissions mein mic on karein.',
  };

  // Demo
  String get demoScreenTitle => switch (lang) {
    AppLanguage.hiDev => 'Demo रिकॉर्डिंग्स',
    AppLanguage.en => 'Demo Recordings',
    AppLanguage.mr => 'Demo रेकॉर्डिंग्ज',
    AppLanguage.gu => 'Demo રેકોર્ડિંગ્સ',
    AppLanguage.bn => 'Demo রেকর্ডিং',
    AppLanguage.ta => 'Demo பதிவுகள்',
    AppLanguage.te => 'Demo రికార్డింగ్‌లు',
    _ => 'Demo Recordings',
  };

  String get demoSubtitle => switch (lang) {
    AppLanguage.hiDev => 'असली मामलों और स्कैम के नमूने',
    AppLanguage.en => 'Real cases and simulated scam patterns',
    AppLanguage.mr => 'खऱ्या घटना आणि स्कॅमची उदाहरणे',
    AppLanguage.gu => 'વાસ્તવિક કેસો અને છેતરપિંડીના નમૂના',
    AppLanguage.bn => 'বাস্তব ঘটনা এবং স্ক্যামের উদাহরণ',
    AppLanguage.ta => 'உண்மைச் சம்பவங்கள் மற்றும் மோசடி மாதிரிகள்',
    AppLanguage.te => 'నిజ జీవిత కేసులు మరియు స్కామ్ నమూనాలు',
    _ => 'Asli mamle aur scam ki misalein',
  };

  String get tagScam => switch (lang) {
    AppLanguage.hiDev => 'स्कैम',
    AppLanguage.en => 'Scam',
    AppLanguage.mr => 'स्कॅम',
    AppLanguage.gu => 'છેતરપિંડી',
    AppLanguage.bn => 'স্ক্যাম',
    AppLanguage.ta => 'மோசடி',
    AppLanguage.te => 'స్కామ్',
    _ => 'Scam',
  };

  String get tagReal => switch (lang) {
    AppLanguage.hiDev => 'असली',
    AppLanguage.en => 'Genuine',
    AppLanguage.mr => 'खरे',
    AppLanguage.gu => 'અસલી',
    AppLanguage.bn => 'আসল',
    AppLanguage.ta => 'உண்மை',
    AppLanguage.te => 'నిజమైనది',
    _ => 'Asli',
  };

  String get tagSuspicious => switch (lang) {
    AppLanguage.hiDev => 'शक',
    AppLanguage.en => 'Suspicious',
    AppLanguage.mr => 'संशयास्पद',
    AppLanguage.gu => 'શંકાસ્પદ',
    AppLanguage.bn => 'সন্দেহজনক',
    AppLanguage.ta => 'சந்தேகம்',
    AppLanguage.te => 'అనుమానం',
    _ => 'Shak',
  };

  // Guardians
  String get guardiansTitle => 'Guardians';

  String get noGuardians => switch (lang) {
    AppLanguage.hiDev => 'अभी कोई guardian नहीं जुड़ा है।',
    AppLanguage.en => 'No guardians linked yet.',
    AppLanguage.mr => 'अजून कोणताही guardian जोडलेला नाही.',
    AppLanguage.gu => 'હજુ સુધી કોઈ guardian જોડાયેલ નથી.',
    AppLanguage.bn => 'এখনও কোনো guardian যুক্ত হয়নি।',
    AppLanguage.ta => 'இதுவரை எந்த guardian-உம் இணைக்கப்படவில்லை.',
    AppLanguage.te => 'ఇంకా ఏ guardian జతచేయబడలేదు.',
    _ => 'Abhi koi guardian nahi juda hai.',
  };

  String get addGuardianBtn => switch (lang) {
    AppLanguage.hiDev => 'नया guardian जोड़ें',
    AppLanguage.en => 'Add New Guardian',
    AppLanguage.mr => 'नवीन guardian जोडा',
    AppLanguage.gu => 'નવા guardian જોડો',
    AppLanguage.bn => 'নতুন guardian যুক্ত করুন',
    AppLanguage.ta => 'புதிய guardian சேர்க்கவும்',
    AppLanguage.te => 'కొత్త guardian ని జోడించండి',
    _ => 'Naya guardian jodein',
  };

  String scanInstruction(String botUser) => switch (lang) {
    AppLanguage.hiDev =>
      'Telegram में @$botUser खोलकर Start दबाएं या यह QR स्कैन करें।',
    AppLanguage.en =>
      'Open @$botUser in Telegram and tap Start, or scan this QR code.',
    AppLanguage.mr =>
      'Telegram मध्ये @$botUser उघडून Start दाबा किंवा हा QR स्कॅन करा.',
    _ => 'Telegram mein @$botUser kholkar Start dabayein ya ye QR scan karein.',
  };

  String get waitingCountdown => switch (lang) {
    AppLanguage.hiDev => 'इंतज़ार…',
    AppLanguage.en => 'Waiting…',
    AppLanguage.mr => 'प्रतीक्षा करत आहे…',
    _ => 'Intezaar…',
  };

  String guardianJoined(String name) => switch (lang) {
    AppLanguage.hiDev => '$name जुड़ गए ✓',
    AppLanguage.en => '$name connected successfully ✓',
    AppLanguage.mr => '$name जोडले गेले ✓',
    _ => '$name jud gaye ✓',
  };

  String get pairingTimeout => switch (lang) {
    AppLanguage.hiDev => 'समय समाप्त हो गया। दोबारा कोशिश करें।',
    AppLanguage.en => 'Pairing timed out. Please try again.',
    AppLanguage.mr => 'वेळ संपली. पुन्हा प्रयत्न करा.',
    _ => 'Samay samapt ho gaya. Dobara koshish karein.',
  };

  String get autoAlertSwitch => switch (lang) {
    AppLanguage.hiDev => 'ख़तरा होने पर अपने-aap अलर्ट भेजो',
    AppLanguage.en => 'Auto-alert family if KHATRA is detected',
    AppLanguage.mr => 'धोका असल्यास आपोआप सूचना पाठवा',
    AppLanguage.gu => 'ખતરો હોય ત્યારે આપમેળે ચેતવણી મોકલો',
    AppLanguage.bn => 'বিপদ দেখা দিলে স্বয়ংক্রিয়ভাবে সতর্কবার্তা পাঠান',
    AppLanguage.ta => 'ஆபத்து ஏற்பட்டால் தானாகவே எச்சரிக்கவும்',
    AppLanguage.te => 'ప్రమాదం ఉన్నప్పుడు స్వయంచాలకంగా హెచ్చరిక పంపండి',
    _ => 'Khatra hone pe apne-aap alert bhejo',
  };

  String get removeBtn => switch (lang) {
    AppLanguage.hiDev => 'हटाएं',
    AppLanguage.en => 'Remove',
    AppLanguage.mr => 'काढून टाका',
    _ => 'Hatayein',
  };

  String get linkCopied => 'Link copy ho gaya ✓';

  // Settings
  String get settingsTitle => 'Settings';

  String get languageSetting => switch (lang) {
    AppLanguage.hiDev => 'भाषा / Language',
    AppLanguage.en => 'App Language',
    _ => 'Bhasha / Language',
  };

  String get autoAlertSetting => 'Auto-Alert Telegram';

  String get autoAlertDesc => switch (lang) {
    AppLanguage.hiDev => 'KHATRA आने पर parivaar ko turant alert bhejein',
    AppLanguage.en => 'Alert family instantly via Telegram when fraud is found',
    AppLanguage.mr => 'धोका आढळल्यास कुटुंबाला टेलिग्रामवर लगेच सूचना द्या',
    _ => 'KHATRA aane pe parivaar ko turant alert bhejein',
  };

  String get userNameSetting => switch (lang) {
    AppLanguage.hiDev => 'आपका नाम (Alert के लिए)',
    AppLanguage.en => 'Your Name (for Family Alerts)',
    AppLanguage.mr => 'तुमचे नाव (अलर्टसाठी)',
    _ => 'Aapka naam (Alert ke liye)',
  };

  String get userNameHint => 'Jaise: Ramesh ji';

  String get fontNotice => switch (lang) {
    AppLanguage.hiDev =>
      'टेक्स्ट बड़ा करना है? फ़ोन की Settings में जाकर Font Size बढ़ाएं।',
    AppLanguage.en =>
      'Need larger text? Adjust font size in device display settings.',
    AppLanguage.mr =>
      'अक्षर मोठे करायचे असल्यास फोनच्या Settings मध्ये जाऊन Font Size वाढवा.',
    _ => 'Text bada karna hai? Phone ki settings mein font size badhayein.',
  };

  String get appVersionText => 'ScamShield v1.0.0 (Beyond Hack 2.0)';

  // Stages
  String stageName(Stage stage) {
    return switch (stage) {
      Stage.authority => switch (lang) {
        AppLanguage.hiDev => 'अधिकारी',
        AppLanguage.en => 'Authority',
        AppLanguage.mr => 'अधिकारी',
        AppLanguage.gu => 'અધિકારી',
        AppLanguage.bn => 'কর্তৃপক্ষ',
        AppLanguage.ta => 'அதிகாரி',
        AppLanguage.te => 'అధికారి',
        _ => 'Adhikari',
      },
      Stage.fear => switch (lang) {
        AppLanguage.hiDev => 'डर',
        AppLanguage.en => 'Fear',
        AppLanguage.mr => 'भीती',
        AppLanguage.gu => 'ડર',
        AppLanguage.bn => 'ভয়',
        AppLanguage.ta => 'பயம்',
        AppLanguage.te => 'భయం',
        _ => 'Darr',
      },
      Stage.urgency => switch (lang) {
        AppLanguage.hiDev => 'जल्दी',
        AppLanguage.en => 'Urgency',
        AppLanguage.mr => 'घाई',
        AppLanguage.gu => 'ઉતાવળ',
        AppLanguage.bn => 'জরুরি',
        AppLanguage.ta => 'அவசரம்',
        AppLanguage.te => 'అత్యవసరం',
        _ => 'Jaldi',
      },
      Stage.secrecy => switch (lang) {
        AppLanguage.hiDev => 'छुपाओ',
        AppLanguage.en => 'Secrecy',
        AppLanguage.mr => 'गुप्तता',
        AppLanguage.gu => 'છૂપાવો',
        AppLanguage.bn => 'গোপনীয়তা',
        AppLanguage.ta => 'ரகசியம்',
        AppLanguage.te => 'రహస్యం',
        _ => 'Chhupao',
      },
      Stage.extraction => switch (lang) {
        AppLanguage.hiDev => 'पैसा / OTP',
        AppLanguage.en => 'Money / OTP',
        AppLanguage.mr => 'पैसे / OTP',
        AppLanguage.gu => 'પૈસા / OTP',
        AppLanguage.bn => 'টাকা / OTP',
        AppLanguage.ta => 'பணம் / OTP',
        AppLanguage.te => 'డబ్బు / OTP',
        _ => 'Paisa / OTP',
      },
    };
  }

  String scamTypeName(ScamType type) {
    return switch (type) {
      ScamType.digitalArrest => switch (lang) {
        AppLanguage.hiDev => 'डिजिटल अरेस्ट',
        AppLanguage.en => 'Digital Arrest',
        AppLanguage.mr => 'डिजिटल अरेस्ट',
        AppLanguage.gu => 'ડિજિટલ અરેસ્ટ',
        AppLanguage.bn => 'ডিজিটাল অ্যারেস্ট',
        AppLanguage.ta => 'டிஜிட்டல் கைது',
        AppLanguage.te => 'డిజిటల్ అరెస్ట్',
        _ => 'Digital Arrest',
      },
      ScamType.kycBank => switch (lang) {
        AppLanguage.hiDev => 'KYC / बैंक फ़्रॉड',
        AppLanguage.en => 'KYC / Bank Fraud',
        AppLanguage.mr => 'KYC / बँक फसवणूक',
        AppLanguage.gu => 'KYC / બેંક ફ્રોડ',
        AppLanguage.bn => 'KYC / ব্যাংক জালিয়াতি',
        AppLanguage.ta => 'KYC / வங்கி மோசடி',
        AppLanguage.te => 'KYC / బ్యాంక్ మోసం',
        _ => 'KYC / Bank Fraud',
      },
      ScamType.courierParcel => switch (lang) {
        AppLanguage.hiDev => 'कूरियर पार्सल स्कैम',
        AppLanguage.en => 'Courier Parcel Scam',
        AppLanguage.mr => 'कुरिअर पार्सल स्कॅम',
        AppLanguage.gu => 'કુરિયર પાર્સલ સ્કેમ',
        AppLanguage.bn => 'কুরিয়ার পার্সেল স্ক্যাম',
        AppLanguage.ta => 'கூரியர் பார்சல் மோசடி',
        AppLanguage.te => 'కొరియర్ పార్సెల్ స్కామ్',
        _ => 'Courier Parcel Scam',
      },
      ScamType.traiSim => switch (lang) {
        AppLanguage.hiDev => 'TRAI / सिम ब्लॉक स्कैम',
        AppLanguage.en => 'TRAI / SIM Block',
        AppLanguage.mr => 'TRAI / सिम ब्लॉक स्कॅम',
        AppLanguage.gu => 'TRAI / સિમ બ્લોક',
        AppLanguage.bn => 'TRAI / সিম ব্লক',
        AppLanguage.ta => 'TRAI / சிம் பிளாக்',
        AppLanguage.te => 'TRAI / సిమ్ బ్లాక్',
        _ => 'TRAI / SIM Block',
      },
      ScamType.investment => switch (lang) {
        AppLanguage.hiDev => 'इन्वेस्टमेंट स्कैम',
        AppLanguage.en => 'Investment Scam',
        AppLanguage.mr => 'गुंतवणूक स्कॅम',
        AppLanguage.gu => 'રોકાણ કૌભાંડ',
        AppLanguage.bn => 'বিনিয়োগ স্ক্যাম',
        AppLanguage.ta => 'முதலீட்டு மோசடி',
        AppLanguage.te => 'పెట్టుబడి స్కామ్',
        _ => 'Investment Scam',
      },
      ScamType.loanApp => switch (lang) {
        AppLanguage.hiDev => 'लोन ऐप फ़्रॉड',
        AppLanguage.en => 'Loan App Fraud',
        AppLanguage.mr => 'कर्ज ॲप फसवणूक',
        AppLanguage.gu => 'લોન એપ ફ્રોડ',
        AppLanguage.bn => 'লোন অ্যাপ জালিয়াতি',
        AppLanguage.ta => 'கடன் ஆப் மோசடி',
        AppLanguage.te => 'లోన్ యాప్ మోసం',
        _ => 'Loan App Fraud',
      },
      ScamType.sextortion => switch (lang) {
        AppLanguage.hiDev => 'सेक्सटॉर्शन स्कैम',
        AppLanguage.en => 'Sextortion Scam',
        AppLanguage.mr => 'सेक्सटॉर्शन',
        _ => 'Sextortion Scam',
      },
      ScamType.familyEmergency => switch (lang) {
        AppLanguage.hiDev => 'फ़ैमिली इमरजेंसी स्कैम',
        AppLanguage.en => 'Family Emergency Scam',
        AppLanguage.mr => 'कौटुंबिक आणीबाणी स्कॅम',
        AppLanguage.gu => 'ફેમિલી ઇમરજન્સી સ્કેમ',
        AppLanguage.bn => 'পারিবারিক জরুরি স্ক্যাম',
        AppLanguage.ta => 'குடும்ப அவசர மோசடி',
        AppLanguage.te => 'కుటుంబ అత్యవసర స్కామ్',
        _ => 'Family Emergency Scam',
      },
      ScamType.none => switch (lang) {
        AppLanguage.hiDev => 'कोई स्कैम नहीं',
        AppLanguage.en => 'No Scam Detected',
        AppLanguage.mr => 'कोणताही स्कॅम नाही',
        AppLanguage.gu => 'કોઈ સ્કેમ નથી',
        AppLanguage.bn => 'কোনো স্ক্যাম নেই',
        AppLanguage.ta => 'மோசடி இல்லை',
        AppLanguage.te => 'ఎలాంటి స్కామ్ లేదు',
        _ => 'Koi scam nahi',
      },
      ScamType.unknown => switch (lang) {
        AppLanguage.hiDev => 'अन्जान कॉल',
        AppLanguage.en => 'Unknown Call',
        AppLanguage.mr => 'अनोळखी कॉल',
        AppLanguage.gu => 'અજાણ્યો કૉલ',
        AppLanguage.bn => 'অজানা কল',
        AppLanguage.ta => 'தெரியாத அழைப்பு',
        AppLanguage.te => 'తెలియని కాల్',
        _ => 'Anjaan call',
      },
    };
  }
}
