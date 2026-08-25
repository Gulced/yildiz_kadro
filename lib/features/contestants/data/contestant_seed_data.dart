import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';

const contestantSeedData = <Contestant>[
  Contestant(
    id: 1,
    number: '01',
    name: 'Gülce',
    age: 21,
    city: 'İstanbul',
    occupationOrEducation: 'Bilgisayar Mühendisliği öğrencisi',
    shortBackground:
        'Kod yazıyor, dans ediyor ve her ihtimali önceden hesaplıyor.',
    fullBackground:
        'Gülce teknolojiyle iç içe büyüdü ve üniversitede Bilgisayar Mühendisliği okuyor. Derslerinin yanında üniversitenin dans topluluğunda sahneye çıkıyor; prova aralarında küçük uygulamalar geliştirmeyi sürdürüyor.\n\nYarışmaya arkadaşlarının ısrarıyla başvurdu. Profesyonel sahne deneyimi az olsa da koreografileri hızlı öğrenmesi ve baskı altında çözüm üretmesi casting ekibinin dikkatini çekti.',
    archetype: 'Gizli Cevher',
    personalityTraits: ['Zeki', 'Hırslı', 'Esprili', 'Kontrollü'],
    primaryRole: 'Çok Yönlü',
    secondaryRoles: ['Merkez', 'Öncü Vokal'],
    vocal: 74,
    dance: 81,
    stage: 86,
    popularity: 72,
    potential: 92,
    specialTraitTitle: 'Hızlı Öğrenen',
    specialTraitDescription:
        'Yeni koreografileri ve görevleri diğer yarışmacılara göre daha hızlı öğrenebilir.',
    riskTitle: 'Fazla Düşünüyor',
    riskDescription:
        'Baskı yükseldiğinde kendi performansını fazla sorgulayabilir.',
    producerNote:
        'Ham yetenekten çok gelişim potansiyeliyle öne çıkıyor. Doğru eşleşmeyle sezonun sürprizi olabilir.',
    quote:
        'Plan yapmadan rahat edemiyorum. Ama bazen planı bozmak da eğlenceli.',
    portraitAsset: 'assets/contestants/gulce/neutral.png',
  ),
  Contestant(
    id: 2,
    number: '02',
    name: 'Duru',
    age: 20,
    city: 'Ankara',
    occupationOrEducation: 'Konservatuvar şan öğrencisi',
    shortBackground:
        'Koro disiplininden geliyor; asıl sınavı tek başına görünür olmak.',
    fullBackground:
        'Duru çocuk korosunda başladığı müzik eğitimini konservatuvarda sürdürüyor. Nota okuma ve nefes tekniği konusunda kadronun en hazırlıklı isimlerinden, fakat pop koreografisiyle yalnızca son iki yıldır ilgileniyor.\n\nKoro içinde kendini güvende hissederken solo anlarda geriliyor. Yarışmaya, sesini saklamayı bırakmak ve sahnede kendi alanını açmak için katıldı.',
    archetype: 'Güçlü Ses',
    personalityTraits: ['Utangaç', 'Sakin', 'Duygusal', 'Çalışkan'],
    primaryRole: 'Ana Vokal',
    secondaryRoles: ['Öncü Vokal'],
    vocal: 96,
    dance: 58,
    stage: 70,
    popularity: 54,
    potential: 84,
    specialTraitTitle: 'Altın Ses',
    specialTraitDescription:
        'Zorlu vokal görevlerinde takımın performans seviyesini belirgin biçimde yükseltebilir.',
    riskTitle: 'Kamera Önünde Geriliyor',
    riskDescription:
        'Teknik olarak hazır olsa da yakın planlarda kendini geri çekebilir.',
    producerNote:
        'Sesi final grubuna hazır. Görünür olmaktan kaçmayı bırakırsa ana vokal koltuğunun en güçlü adayı.',
    quote: 'Şarkı söylerken cesurum. Konuşmam gerektiğinde biraz zaman verin.',
    portraitAsset: 'assets/contestants/duru/neutral.png',
  ),
  Contestant(
    id: 3,
    number: '03',
    name: 'İdil',
    age: 19,
    city: 'İzmir',
    occupationOrEducation: 'Mimarlık öğrencisi',
    shortBackground:
        'Geceleri demo kaydediyor; yeteneğini şimdiye kadar çok az kişi duydu.',
    fullBackground:
        'İdil mimarlık okumak için Denizli’den İzmir’e taşındı. Stüdyo teslimlerinden kalan gecelerde odasında beste taslakları ve vokal demoları kaydediyor; bunları yakın arkadaşları dışında kimseyle paylaşmadı.\n\nCasting başvurusunu son gece gönderdi. Eğitim almamış olmasına rağmen özgün ses rengi ve sahnede aniden değişen enerjisi, yapım ekibinin onu yakından izlemesine neden oldu.',
    archetype: 'Ham Elmas',
    personalityTraits: ['Gözlemci', 'Şüpheci', 'İnatçı', 'Naif'],
    primaryRole: 'Öncü Vokal',
    secondaryRoles: ['Merkez Adayı'],
    vocal: 82,
    dance: 69,
    stage: 80,
    popularity: 46,
    potential: 97,
    specialTraitTitle: 'Gizli Potansiyel',
    specialTraitDescription:
        'Doğru geri bildirim aldığında kısa sürede beklenmedik bir performans sıçraması yapabilir.',
    riskTitle: 'Kendini Saklıyor',
    riskDescription:
        'Hazır hissetmediğinde öne çıkmak yerine fırsatı başka birine bırakabilir.',
    producerNote:
        'Kadronun en büyük bilinmeyeni. İyi yönetilirse yarışmanın bütün dengesini değiştirebilir.',
    quote:
        'İnsanlar sessizken hiçbir şey düşünmediğimi sanıyor. Genelde tam tersi.',
    portraitAsset: 'assets/contestants/idil/neutral.png',
  ),
  Contestant(
    id: 4,
    number: '04',
    name: 'Alara',
    age: 23,
    city: 'Bursa',
    occupationOrEducation: 'Dans eğitmeni',
    shortBackground:
        'Yıllardır başkalarını sahneye hazırlıyor; şimdi sıra kendisinde.',
    fullBackground:
        'Alara lise yıllarında yarışmalı dans ekiplerinde yer aldı. Üniversiteye başlamasa da eğitim sertifikalarını tamamlayıp Bursa’da küçük bir stüdyoda çocuklara ve gençlere ders vermeye başladı.\n\nBaşkalarının koreografilerini kusursuzlaştırmaya alışkın. Yarışmada ilk kez yalnızca eğitmenliğiyle değil, kendi sahne kimliğiyle değerlendirilmek istiyor.',
    archetype: 'Profesyonel',
    personalityTraits: ['Disiplinli', 'Direkt', 'Soğukkanlı', 'Sabırsız'],
    primaryRole: 'Ana Dansçı',
    secondaryRoles: ['Dans Lideri'],
    vocal: 62,
    dance: 98,
    stage: 91,
    popularity: 67,
    potential: 78,
    specialTraitTitle: 'Ritim Hafızası',
    specialTraitDescription:
        'Karmaşık koreografileri hızlı çözer ve takımın prova süresini verimli kullanmasını sağlar.',
    riskTitle: 'Sabırsız',
    riskDescription:
        'Aynı hızda öğrenemeyen takım arkadaşlarına karşı sertleşebilir.',
    producerNote:
        'Teknik standardı yükseltecek isim. Öğretmen gibi değil takım arkadaşı gibi davranmayı öğrenmeli.',
    quote: 'Bir hareketi yüz kere yapacaksak yüzüncüde de temiz yapmalıyız.',
    portraitAsset: 'assets/contestants/alara/neutral.png',
  ),
  Contestant(
    id: 5,
    number: '05',
    name: 'Derin',
    age: 22,
    city: 'Antalya',
    occupationOrEducation: 'Sahne Sanatları öğrencisi',
    shortBackground:
        'Yarışma ortamına yabancı değil ve kazanmak istediğini saklamıyor.',
    fullBackground:
        'Derin çocukluğundan beri bölgesel dans yarışmalarına katılıyor. Sahne Sanatları bölümünde fiziksel tiyatro eğitimi alırken hafta sonları performans ekiplerinde çalışıyor.\n\nRekabetin kendisini daha iyi yaptığına inanıyor. Yarışmaya arkadaş edinmek için gelmediğini açıkça söylüyor; yine de ekip görevlerinde yalnız kalamayacağını biliyor.',
    archetype: 'Rakip',
    personalityTraits: ['Rekabetçi', 'Cesur', 'Sivri Dilli', 'İnatçı'],
    primaryRole: 'Merkez',
    secondaryRoles: ['Ana Dansçı'],
    vocal: 72,
    dance: 91,
    stage: 94,
    popularity: 70,
    potential: 85,
    specialTraitTitle: 'Baskıyla Besleniyor',
    specialTraitDescription:
        'Güçlü rakiplerle karşılaştığında performans seviyesini yükseltebilir.',
    riskTitle: 'Rekabete Kapılıyor',
    riskDescription:
        'Kazanma isteği takım içindeki güveni ve iletişimi zedeleyebilir.',
    producerNote:
        'Sahne için doğuştan bir mücadeleci. Hırsını doğru yöne çevirmek prodüksiyonun sınavı olacak.',
    quote: 'İkinci olmak kötü değil diyorlar. Ben denemek istemiyorum.',
    portraitAsset: 'assets/contestants/derin/neutral.png',
  ),
  Contestant(
    id: 6,
    number: '06',
    name: 'Ada',
    age: 20,
    city: 'Eskişehir',
    occupationOrEducation: 'Gastronomi öğrencisi ve yarı zamanlı barista',
    shortBackground:
        'Müziği hep hobi sandı; casting sonucu fikrini değiştirdi.',
    fullBackground:
        'Ada gündüzleri gastronomi derslerine giriyor, akşamları kampüse yakın bir kafede çalışıyor. Sessiz vardiyalarda akustik coverlar kaydedip arkadaşlarıyla paylaşıyor.\n\nBaşvuru videosunu iş arkadaşları çekti. Seçilmek, müziğin hayatındaki yerini ilk kez ciddi biçimde sorgulamasına neden oldu; teknik eksiğini sıcak iletişimiyle kapatıyor.',
    archetype: 'Tatlı Kalp',
    personalityTraits: ['Sıcakkanlı', 'Komik', 'Hassas', 'Yardımsever'],
    primaryRole: 'Öncü Vokal',
    secondaryRoles: ['Takım Yüzü'],
    vocal: 81,
    dance: 66,
    stage: 73,
    popularity: 88,
    potential: 82,
    specialTraitTitle: 'Takım Oyuncusu',
    specialTraitDescription:
        'Takım arkadaşlarının rahatlamasına ve birlikte daha uyumlu çalışmasına yardımcı olur.',
    riskTitle: 'Eleştiriye Hassas',
    riskDescription:
        'Sert geri bildirimleri kişisel algılayıp özgüvenini geçici olarak kaybedebilir.',
    producerNote:
        'İnsanların yanında rahat hissettiği nadir karakterlerden. Teknik gelişimi seyirci bağını yakalamalı.',
    quote: 'Kahveyi de şarkıyı da aceleye getirince tadı kaçıyor.',
    portraitAsset: 'assets/contestants/ada/neutral.png',
  ),
  Contestant(
    id: 7,
    number: '07',
    name: 'İpek',
    age: 18,
    city: 'Samsun',
    occupationOrEducation: 'Psikoloji hazırlık öğrencisi',
    shortBackground:
        'Neredeyse deneyimsiz ama gördüğü her şeyi hızla uyguluyor.',
    fullBackground:
        'İpek üniversite için ilk kez ailesinden ayrıldı. Profesyonel ders almadı; dans videolarını yavaşlatarak evde çalıştı ve okul korosunda yalnızca bir dönem yer aldı.\n\nBaşvuru videosunu yurt arkadaşları hazırladı. İlk provada geride kaldı, ikinci provada aynı hataları tekrarlamaması yapım ekibinin dikkatini çekti.',
    archetype: 'Sürpriz Aday',
    personalityTraits: ['Utangaç', 'Meraklı', 'Azimli', 'Naif'],
    primaryRole: 'En Genç Üye',
    secondaryRoles: ['Gelişim Adayı'],
    vocal: 61,
    dance: 68,
    stage: 57,
    popularity: 50,
    potential: 95,
    specialTraitTitle: 'Çalışkan',
    specialTraitDescription:
        'Tekrarlanan provalarda yorulsa bile odağını korur ve düzenli gelişim gösterir.',
    riskTitle: 'Özgüveni Kırılgan',
    riskDescription:
        'Kendisini deneyimli yarışmacılarla kıyasladığında geri çekilebilir.',
    producerNote:
        'Bugünkü seviyesi final için yeterli değil. Fakat gelişim hızı onu görmezden gelmeyi imkânsız kılıyor.',
    quote:
        'Korkuyorsam yanlış yerde değilim; yeni bir şey öğreniyorum demektir.',
    portraitAsset: 'assets/contestants/ipek/neutral.png',
  ),
  Contestant(
    id: 8,
    number: '08',
    name: 'Eylül',
    age: 24,
    city: 'İzmir',
    occupationOrEducation: 'Fizyoterapist',
    shortBackground:
        'Dansçılarla çalışırken ertelediği sahne hayaline geri döndü.',
    fullBackground:
        'Eylül fizyoterapi eğitiminden sonra bir dans stüdyosuyla çalışan klinikte görev aldı. Sakatlanan dansçıların sahneye dönüşüne eşlik ederken kendi performans geçmişini ne kadar özlediğini fark etti.\n\nKadronun en büyüklerinden biri ve bu fırsatı erteleyemeyeceğini düşünüyor. İnsanları gözetme alışkanlığı prova odasında hemen hissediliyor.',
    archetype: 'Büyük Abla',
    personalityTraits: ['Koruyucu', 'Sabırlı', 'Sıcakkanlı', 'Gerçekçi'],
    primaryRole: 'Lider',
    secondaryRoles: ['Destek Vokal'],
    vocal: 76,
    dance: 74,
    stage: 71,
    popularity: 63,
    potential: 76,
    specialTraitTitle: 'Kriz Yöneticisi',
    specialTraitDescription:
        'Gerilim yükseldiğinde takımı sakinleştirip odağı yeniden göreve çevirebilir.',
    riskTitle: 'Kendini Geri Plana Atıyor',
    riskDescription:
        'Başkalarına yardım ederken kendi performansına ayırdığı zamanı azaltabilir.',
    producerNote:
        'Takımın güvenli alanı olabilir. Bu yarışmada kendi hikâyesini de görünür kılması gerekiyor.',
    quote:
        'Herkesi toparlamak kolay. Bazen kendimi de kadraja almam gerekiyor.',
    portraitAsset: 'assets/contestants/eylul/neutral.png',
  ),
  Contestant(
    id: 9,
    number: '09',
    name: 'Nehir',
    age: 22,
    city: 'Ankara',
    occupationOrEducation: 'İşletme öğrencisi',
    shortBackground:
        'Provalarda adımlardan önce insanların birbirini nasıl dinlediğine bakıyor.',
    fullBackground:
        'Nehir işletme okurken öğrenci kulüplerinde etkinlik ve ekip planlaması yaptı. Müziğe ilgisi amatör vokal grubuyla başladı; sahneden çok prova düzenini kurmakta öne çıktı.\n\nİnsanların güçlü ve zayıf yanlarını çabuk okuyor. Yarışmanın yalnızca yetenekle değil doğru eşleşmeler ve zamanlamayla kazanılacağına inanıyor.',
    archetype: 'Stratejist',
    personalityTraits: ['Stratejik', 'Kontrollü', 'Zeki', 'Mesafeli'],
    primaryRole: 'Lider',
    secondaryRoles: ['Çok Yönlü'],
    vocal: 78,
    dance: 80,
    stage: 77,
    popularity: 58,
    potential: 86,
    specialTraitTitle: 'Oyun Okuyucu',
    specialTraitDescription:
        'Takım görevlerinde doğru rol dağılımını ve sorunlu eşleşmeleri erken fark edebilir.',
    riskTitle: 'Fazla Hesaplı',
    riskDescription:
        'Kararlarının stratejik görünmesi diğer yarışmacılarda güvensizlik yaratabilir.',
    producerNote:
        'Takım kurma sezgisi çok güçlü. İnsanları hamle olarak değil ekip arkadaşı olarak gördüğünü kanıtlamalı.',
    quote: 'Şans önemlidir. Ama şans geldiğinde nerede durduğun daha önemli.',
    portraitAsset: 'assets/contestants/nehir/neutral.png',
  ),
  Contestant(
    id: 10,
    number: '10',
    name: 'Lalin',
    age: 19,
    city: 'Mersin',
    occupationOrEducation: 'Grafik Tasarım öğrencisi',
    shortBackground:
        'Kendi posterlerini tasarlıyor, sahnede ise doğaçlamayı seviyor.',
    fullBackground:
        'Lalin grafik tasarım okuyor ve yerel müzik etkinlikleri için afiş hazırlıyor. Küçük sahnelerde arkadaşlarının grubuna geri vokal yaptı; düzenli eğitimden çok deneyerek öğreniyor.\n\nPlanlı işlerde çabuk sıkılsa da beklenmedik aksiliklerde yaratıcı çözümler buluyor. Casting videosundaki doğaçlama bölümü onu ana seçmelere taşıdı.',
    archetype: 'Doğaçlamacı',
    personalityTraits: ['Dürtüsel', 'Sosyal', 'Dağınık', 'Cesur'],
    primaryRole: 'Çok Yönlü',
    secondaryRoles: ['Öncü Dansçı'],
    vocal: 75,
    dance: 82,
    stage: 88,
    popularity: 79,
    potential: 84,
    specialTraitTitle: 'Doğaçlamacı',
    specialTraitDescription:
        'Sahnede beklenmedik bir sorun çıktığında performansı bozmadan yaratıcı biçimde devam edebilir.',
    riskTitle: 'Dikkati Dağılıyor',
    riskDescription: 'Uzun ve tekrarlı provalarda ayrıntıları kaçırabilir.',
    producerNote:
        'Canlı yayında güven veren türden bir refleksi var. Prova disiplinini oturtursa çok değerli olabilir.',
    quote: 'Her şey planlandığı gibi giderse biraz sıkıcı olmaz mı?',
    portraitAsset: 'assets/contestants/lalin/neutral.png',
  ),
  Contestant(
    id: 11,
    number: '11',
    name: 'Arya',
    age: 21,
    city: 'İstanbul',
    occupationOrEducation: 'Yeni medya öğrencisi ve içerik üreticisi',
    shortBackground:
        'Kamerayı iyi tanıyor; insanların bunun arkasındaki emeği görmesini istiyor.',
    fullBackground:
        'Arya lise yıllarının bir bölümünü Berlin’de geçirdi ve İstanbul’a döndüğünde kısa dans videoları üretmeye başladı. Küçük ama sadık bir takipçi kitlesi var; çekim, kurgu ve ışığını çoğunlukla kendisi hazırlıyor.\n\nKamera karşısında rahat olması bazen yalnızca görüntüsüne güvendiği izlenimini yaratıyor. Yarışmada teknik olarak da ciddiye alınmak istiyor.',
    archetype: 'Kamera Dostu',
    personalityTraits: ['Karizmatik', 'Sosyal', 'Şüpheci', 'Hırslı'],
    primaryRole: 'Grup Yüzü',
    secondaryRoles: ['Merkez', 'Öncü Dansçı'],
    vocal: 70,
    dance: 83,
    stage: 95,
    popularity: 91,
    potential: 83,
    specialTraitTitle: 'Kamera Dostu',
    specialTraitDescription:
        'Yakın planlarda ve tanıtım görevlerinde izleyicinin dikkatini doğal biçimde çekebilir.',
    riskTitle: 'İmajına Takılıyor',
    riskDescription:
        'Kontrol edemediği görüntüler ve yorumlar odağını performanstan uzaklaştırabilir.',
    producerNote:
        'Hazır bir yıldız görünümüne sahip. Görüntünün arkasında sürdürülebilir bir performansçı olduğunu göstermeli.',
    quote: 'Kamerayı seviyorum. Kameranın beni tanımlamasını değil.',
    portraitAsset: 'assets/contestants/arya/neutral.png',
  ),
  Contestant(
    id: 12,
    number: '12',
    name: 'Mina',
    age: 20,
    city: 'Adana',
    occupationOrEducation: 'Radyo, Televizyon ve Sinema öğrencisi',
    shortBackground:
        'Kamera arkasını öğrenirken sürekli kadrajın önünde kaldı.',
    fullBackground:
        'Mina üniversiteye kurgu ve kamera arkasında çalışmak için başladı. Okul projelerinde oyuncu bulunamayınca birkaç kez kamera önüne geçti ve ekip arkadaşları enerjisinin oraya daha uygun olduğunu söyledi.\n\nProdüksiyonun nasıl işlediğini bildiği için kameraları çabuk fark ediyor. Filtresiz konuşması hem eğlenceli anlar hem de çözülmesi gereken sorunlar yaratabilir.',
    archetype: 'Kaos',
    personalityTraits: ['Enerjik', 'Komik', 'Dürtüsel', 'Patavatsız'],
    primaryRole: 'Çok Yönlü',
    secondaryRoles: ['Öncü Dansçı'],
    vocal: 79,
    dance: 81,
    stage: 86,
    popularity: 80,
    potential: 81,
    specialTraitTitle: 'Enerji Patlaması',
    specialTraitDescription:
        'Takımın temposu düştüğünde provalara ve sahneye yeniden enerji katabilir.',
    riskTitle: 'Düşünmeden Konuşuyor',
    riskDescription: 'Ani yorumları gereksiz bir tartışmayı büyütebilir.',
    producerNote:
        'Sezonun en izlenebilir karakterlerinden biri. Aynı özellik prodüksiyonun en büyük baş ağrısına dönüşebilir.',
    quote: 'Aklımdan geçeni söylememeye çalışıyorum. Çalışıyorum dedim.',
    portraitAsset: 'assets/contestants/mina/neutral.png',
  ),
  Contestant(
    id: 13,
    number: '13',
    name: 'Naz',
    age: 22,
    city: 'Konya',
    occupationOrEducation: 'Müzik Öğretmenliği son sınıf öğrencisi',
    shortBackground:
        'İnsanları dinlemeye alışkın; kendi hayalini ilk kez öne koyuyor.',
    fullBackground:
        'Naz bağlama çalan bir ailede büyüdü ve okul korolarında yıllarca alto söyledi. Üniversitede müzik öğretmenliği okurken çocuklara özel ders vermeye başladı.\n\nBaşkalarının gelişimini desteklemek ona doğal geliyor. Yarışmaya katılmak, uzun zamandır ilk kez güvenli ve faydalı olduğu rolden çıkıp kendi sesini merkeze alması demek.',
    archetype: 'Doğal Lider',
    personalityTraits: ['Olgun', 'Koruyucu', 'Disiplinli', 'Sakin'],
    primaryRole: 'Lider',
    secondaryRoles: ['Öncü Vokal'],
    vocal: 86,
    dance: 67,
    stage: 76,
    popularity: 69,
    potential: 79,
    specialTraitTitle: 'Doğal Lider',
    specialTraitDescription:
        'Takım arkadaşlarının güçlü yanlarını görür ve görev dağılımını sakin biçimde yönlendirebilir.',
    riskTitle: 'Kendini Unutuyor',
    riskDescription:
        'Takımı korurken kendi görünürlüğünü ve prova ihtiyacını geri plana atabilir.',
    producerNote:
        'Final grubunun omurgası olabilir. Liderlik ederken yarışmacı olduğunu unutmaması gerekiyor.',
    quote: 'Herkesin sesi duyulsun istiyorum. Benimki de dahil.',
    portraitAsset: 'assets/contestants/naz/neutral.png',
  ),
  Contestant(
    id: 14,
    number: '14',
    name: 'Serra',
    age: 23,
    city: 'Muğla',
    occupationOrEducation: 'Pilates eğitmeni ve amatör söz yazarı',
    shortBackground:
        'Sahneye geç başladı; sakinliği ve dayanıklılığıyla açığı kapatıyor.',
    fullBackground:
        'Serra spor bilimleri eğitimini yarıda bırakıp pilates eğitmenliği sertifikası aldı. Akşamları telefonuna kısa melodi ve söz fikirleri kaydediyor, fakat bugüne kadar hiçbirini yayımlamadı.\n\nSahne deneyimi az; buna rağmen bedensel farkındalığı ve uzun provalardaki dayanıklılığı güçlü. Bu yarışmayı yarım bıraktığı şeylere geri dönme fırsatı olarak görüyor.',
    archetype: 'Geç Açılan',
    personalityTraits: ['Soğukkanlı', 'Hassas', 'Gözlemci', 'Kararlı'],
    primaryRole: 'Destek Vokal',
    secondaryRoles: ['Öncü Dansçı', 'Söz Yazarı'],
    vocal: 77,
    dance: 78,
    stage: 68,
    popularity: 57,
    potential: 90,
    specialTraitTitle: 'Soğukkanlı',
    specialTraitDescription:
        'Kritik anlarda heyecanını kontrol ederek görevini istikrarlı biçimde sürdürebilir.',
    riskTitle: 'Geç Isınıyor',
    riskDescription:
        'Kısa hazırlık süresinde karakterini ve sahne enerjisini göstermekte zorlanabilir.',
    producerNote:
        'İlk bakışta sessiz kalıyor, uzun provada değeri ortaya çıkıyor. Zamana karşı yarışacak.',
    quote: 'Geç başladım diye acele etmek zorunda değilim. Ama durmayacağım.',
    portraitAsset: 'assets/contestants/serra/neutral.png',
  ),
  Contestant(
    id: 15,
    number: '15',
    name: 'Nil',
    age: 18,
    city: 'Trabzon',
    occupationOrEducation: 'Moda Tasarımı birinci sınıf öğrencisi',
    shortBackground:
        'Kostümlerini dönüştürüyor, kuralları da aynı rahatlıkla esnetiyor.',
    fullBackground:
        'Nil ikinci el kıyafetleri yeniden tasarlamayı lise yıllarında öğrendi. Üniversite için İstanbul’a taşındıktan sonra dans topluluğuna katıldı ve ilk kez kalabalık bir sahnede performans verdi.\n\nKendi stilini oluşturmakta cesur, prova düzenine uymakta daha isteksiz. Gençliği ve özgün tavrı izleyiciyi hızla çekebilir.',
    archetype: 'Yaramaz En Genç',
    personalityTraits: ['Yaramaz', 'Sosyal', 'Cesur', 'Dağınık'],
    primaryRole: 'Öncü Dansçı',
    secondaryRoles: ['En Genç Üye', 'Görsel'],
    vocal: 67,
    dance: 88,
    stage: 85,
    popularity: 83,
    potential: 89,
    specialTraitTitle: 'Özgün Stil',
    specialTraitDescription:
        'Konsept görevlerinde beklenmedik görsel fikirlerle takımın dikkat çekmesini sağlayabilir.',
    riskTitle: 'Kuralları Esnetiyor',
    riskDescription:
        'Sınırları test etme isteği prova düzeni ve ekip iletişimiyle çatışabilir.',
    producerNote:
        'Doğal bir genç yıldız enerjisi var. Disiplin kazanırsa final için ciddi bir aday olabilir.',
    quote:
        'Kurallar kötü değil. Sadece bazılarının biraz tasarıma ihtiyacı var.',
    portraitAsset: 'assets/contestants/nil/neutral.png',
  ),
];
