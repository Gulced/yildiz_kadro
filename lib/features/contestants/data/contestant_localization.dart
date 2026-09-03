import 'package:flutter/widgets.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';

/// Locale-aware display projection. Stable contestant IDs and gameplay values
/// remain in [Contestant]; no translated string is ever persisted in game state.
class LocalizedContestant {
  const LocalizedContestant._({required this.source, required this.english});

  final Contestant source;
  final EnglishContestantCopy? english;

  EnglishContestantCopy get _copy {
    final value = english;
    if (value == null) {
      throw StateError('Missing English contestant copy for id ${source.id}.');
    }
    return value;
  }

  String get city => english == null ? source.city : _copy.city;
  String get occupation =>
      english == null ? source.occupationOrEducation : _copy.occupation;
  String get shortBackground =>
      english == null ? source.shortBackground : _copy.shortBackground;
  String get fullBackground =>
      english == null ? source.fullBackground : _copy.fullBackground;
  String get archetype => english == null ? source.archetype : _copy.archetype;
  List<String> get personalityTraits =>
      english == null ? source.personalityTraits : _copy.personalityTraits;
  String get primaryRole =>
      english == null ? source.primaryRole : _copy.primaryRole;
  List<String> get secondaryRoles =>
      english == null ? source.secondaryRoles : _copy.secondaryRoles;
  String get specialTraitTitle =>
      english == null ? source.specialTraitTitle : _copy.specialTraitTitle;
  String get specialTraitDescription => english == null
      ? source.specialTraitDescription
      : _copy.specialTraitDescription;
  String get riskTitle => english == null ? source.riskTitle : _copy.riskTitle;
  String get riskDescription =>
      english == null ? source.riskDescription : _copy.riskDescription;
  String get producerNote =>
      english == null ? source.producerNote : _copy.producerNote;
  String get quote => english == null ? source.quote : _copy.quote;
}

extension ContestantLocalization on Contestant {
  LocalizedContestant localized(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    return LocalizedContestant._(
      source: this,
      english: isEnglish ? _englishContestants[id] : null,
    );
  }
}

class EnglishContestantCopy {
  const EnglishContestantCopy({
    required this.city,
    required this.occupation,
    required this.shortBackground,
    required this.fullBackground,
    required this.archetype,
    required this.personalityTraits,
    required this.primaryRole,
    required this.secondaryRoles,
    required this.specialTraitTitle,
    required this.specialTraitDescription,
    required this.riskTitle,
    required this.riskDescription,
    required this.producerNote,
    required this.quote,
  });

  final String city;
  final String occupation;
  final String shortBackground;
  final String fullBackground;
  final String archetype;
  final List<String> personalityTraits;
  final String primaryRole;
  final List<String> secondaryRoles;
  final String specialTraitTitle;
  final String specialTraitDescription;
  final String riskTitle;
  final String riskDescription;
  final String producerNote;
  final String quote;
}

const _englishContestants = <int, EnglishContestantCopy>{
  1: EnglishContestantCopy(
    city: 'Ankara',
    occupation: 'Computer Engineering student',
    shortBackground: 'She codes, dances, and calculates every possibility.',
    fullBackground:
        'Gülce grew up around technology and now studies Computer Engineering. Alongside her classes, she performs with her university dance club and keeps building small apps between rehearsals.\n\nHer friends pushed her to audition. She has limited professional stage experience, but her speed with choreography and calm problem-solving under pressure immediately caught the casting team’s eye.',
    archetype: 'Hidden Gem',
    personalityTraits: ['Smart', 'Ambitious', 'Witty', 'Controlled'],
    primaryRole: 'All-Rounder',
    secondaryRoles: ['Center', 'Lead Vocal'],
    specialTraitTitle: 'Fast Learner',
    specialTraitDescription:
        'She learns new choreography and assignments faster than most contestants.',
    riskTitle: 'Overthinks',
    riskDescription:
        'When pressure rises, she can become overly critical of her own performance.',
    producerNote:
        'One of the rare contestants who can carry vocals, dance, and stage presence at once. Her biggest risk is putting too much pressure on herself as expectations rise.',
    quote: 'I need a plan to relax. Breaking it can be fun sometimes, though.',
  ),
  2: EnglishContestantCopy(
    city: 'Ankara',
    occupation: 'Conservatory vocal student',
    shortBackground:
        'Choir gave her discipline; standing out alone is the real test.',
    fullBackground:
        'Duru began singing in a children’s choir and now studies voice at a conservatory. She has the strongest music-reading and breath technique in the cast, but only started pop choreography two years ago.\n\nShe feels safe inside a choir and tense during solos. She joined to stop hiding her voice and claim her own space onstage.',
    archetype: 'Power Vocal',
    personalityTraits: ['Shy', 'Calm', 'Emotional', 'Hardworking'],
    primaryRole: 'Main Vocal',
    secondaryRoles: ['Lead Vocal'],
    specialTraitTitle: 'Golden Voice',
    specialTraitDescription:
        'She can lift her team significantly in demanding vocal missions.',
    riskTitle: 'Camera Shy',
    riskDescription:
        'Despite her technique, she can pull back during close-ups.',
    producerNote:
        'Her voice is debut-ready. If she stops avoiding attention, she is the strongest main-vocal candidate.',
    quote: 'I’m brave when I sing. Give me a moment when I have to speak.',
  ),
  3: EnglishContestantCopy(
    city: 'Izmir',
    occupation: 'Architecture student',
    shortBackground:
        'She records demos at night, but almost nobody has heard her talent.',
    fullBackground:
        'İdil moved from Denizli to Izmir to study architecture. After late studio deadlines, she records song sketches and vocal demos in her room.\n\nShe submitted her audition on the final night. Her unusual tone and sudden shift in stage energy made the production team want to watch her closely.',
    archetype: 'Diamond in the Rough',
    personalityTraits: ['Observant', 'Skeptical', 'Stubborn', 'Naive'],
    primaryRole: 'Lead Vocal',
    secondaryRoles: ['Center Candidate'],
    specialTraitTitle: 'Hidden Potential',
    specialTraitDescription:
        'With the right feedback, she can make a surprising performance leap.',
    riskTitle: 'Hides Herself',
    riskDescription:
        'When she feels unprepared, she may hand her moment to someone else.',
    producerNote:
        'The cast’s biggest unknown. Managed well, she could change the balance of the entire competition.',
    quote:
        'People think silence means I’m not thinking. It’s usually the opposite.',
  ),
  4: EnglishContestantCopy(
    city: 'Bursa',
    occupation: 'Dance instructor',
    shortBackground:
        'She has prepared others for the stage for years. Now it is her turn.',
    fullBackground:
        'Alara spent high school competing with dance crews, then earned teaching certificates and began coaching young dancers in Bursa.\n\nShe is used to perfecting other people’s choreography. Here, she wants to be judged for her own stage identity.',
    archetype: 'Professional',
    personalityTraits: ['Disciplined', 'Direct', 'Composed', 'Impatient'],
    primaryRole: 'Main Dancer',
    secondaryRoles: ['Dance Leader'],
    specialTraitTitle: 'Rhythm Memory',
    specialTraitDescription:
        'She breaks down complex choreography quickly and makes rehearsal time count.',
    riskTitle: 'Impatient',
    riskDescription:
        'She can become too harsh with teammates who learn at a different pace.',
    producerNote:
        'She will raise the technical standard, but must learn to act like a teammate instead of a teacher.',
    quote:
        'If we do a move a hundred times, the hundredth still has to be clean.',
  ),
  5: EnglishContestantCopy(
    city: 'Antalya',
    occupation: 'Performing Arts student',
    shortBackground:
        'Competition is familiar territory, and she makes no secret of wanting to win.',
    fullBackground:
        'Derin has competed in regional dance contests since childhood. She studies physical theatre and performs with weekend stage crews.\n\nCompetition makes her sharper. She says openly that she did not come here to make friends, though she knows team missions cannot be won alone.',
    archetype: 'The Rival',
    personalityTraits: ['Competitive', 'Bold', 'Sharp-Tongued', 'Stubborn'],
    primaryRole: 'Center',
    secondaryRoles: ['Main Dancer'],
    specialTraitTitle: 'Thrives Under Pressure',
    specialTraitDescription:
        'Strong rivals push her performance to a higher level.',
    riskTitle: 'Consumed by Competition',
    riskDescription:
        'Her drive to win can damage trust and communication inside the team.',
    producerNote:
        'A born fighter onstage. Channeling that ambition is the production’s challenge.',
    quote: 'They say second place isn’t bad. I’d rather not find out.',
  ),
  6: EnglishContestantCopy(
    city: 'Eskisehir',
    occupation: 'Culinary student and part-time barista',
    shortBackground:
        'She always called music a hobby. The casting result changed her mind.',
    fullBackground:
        'Ada studies culinary arts by day and works evenings at a café near campus. During quiet shifts, she records acoustic covers for friends.\n\nHer coworkers filmed her audition. Being selected made her take music seriously for the first time; her warmth often makes up for her technical gaps.',
    archetype: 'Sweetheart',
    personalityTraits: ['Warm', 'Funny', 'Sensitive', 'Helpful'],
    primaryRole: 'Lead Vocal',
    secondaryRoles: ['Face of the Group'],
    specialTraitTitle: 'Team Player',
    specialTraitDescription:
        'She helps teammates relax and work together more naturally.',
    riskTitle: 'Sensitive to Criticism',
    riskDescription:
        'Harsh feedback can feel personal and briefly shake her confidence.',
    producerNote:
        'People feel safe around her. Her technical growth needs to catch up with her audience connection.',
    quote: 'Rush coffee or a song and you lose the flavor.',
  ),
  7: EnglishContestantCopy(
    city: 'Samsun',
    occupation: 'Psychology foundation-year student',
    shortBackground:
        'Almost no experience, but she applies everything she sees at remarkable speed.',
    fullBackground:
        'İpek left home for university and has never trained professionally. She learned dance from slowed-down videos and spent one term in the school choir.\n\nHer dorm friends made her audition tape. She fell behind in the first rehearsal, then caught production’s attention by never repeating the same mistake.',
    archetype: 'Surprise Contender',
    personalityTraits: ['Shy', 'Curious', 'Determined', 'Naive'],
    primaryRole: 'Youngest Member',
    secondaryRoles: ['Growth Candidate'],
    specialTraitTitle: 'Hard Worker',
    specialTraitDescription:
        'Even when tired, she stays focused and improves steadily through repetition.',
    riskTitle: 'Fragile Confidence',
    riskDescription:
        'Comparing herself with experienced contestants can make her withdraw.',
    producerNote:
        'Her current level is not final-ready, but her rate of growth is impossible to ignore.',
    quote:
        'If I’m scared, I’m not in the wrong place. I’m learning something new.',
  ),
  8: EnglishContestantCopy(
    city: 'Istanbul',
    occupation: 'Architecture student',
    shortBackground:
        'She brings an editorial eye shaped by sketches and endless revisions to the stage.',
    fullBackground:
        'Lara studies architecture in Istanbul. Deadlines, sketches, and constant revisions taught her that an idea must work as well as it looks.\n\nShe visualizes stage concepts quickly and notices what others need, but can push her own performance aside while holding everyone else together.',
    archetype: 'Big Sister',
    personalityTraits: ['Protective', 'Patient', 'Warm', 'Realistic'],
    primaryRole: 'Leader',
    secondaryRoles: ['Support Vocal'],
    specialTraitTitle: 'Crisis Manager',
    specialTraitDescription:
        'She calms the team under pressure and brings the focus back to the mission.',
    riskTitle: 'Puts Herself Last',
    riskDescription:
        'Helping everyone else can leave too little time for her own performance.',
    producerNote:
        'She could become the team’s safe space, but must make her own story visible too.',
    quote:
        'Holding everyone together is easy. Sometimes I need to put myself in frame.',
  ),
  9: EnglishContestantCopy(
    city: 'Istanbul',
    occupation: 'Business student',
    shortBackground:
        'She reads the room like a strategy board and rarely moves without a plan.',
    fullBackground:
        'Nehir studies business and approaches rehearsals with the same strategic focus she brings to case competitions. She watches group dynamics before making her move.\n\nHer planning can steady a team, but people sometimes wonder whether every connection is part of a larger calculation.',
    archetype: 'Strategist',
    personalityTraits: ['Strategic', 'Controlled', 'Smart', 'Reserved'],
    primaryRole: 'Leader',
    secondaryRoles: ['All-Rounder'],
    specialTraitTitle: 'Reads the Game',
    specialTraitDescription:
        'She spots shifts in team dynamics early and adapts her plan.',
    riskTitle: 'Too Calculated',
    riskDescription:
        'Her careful choices can make genuine moments feel tactical.',
    producerNote:
        'A sharp observer with leadership potential. She needs to let the audience see beyond the strategy.',
    quote: 'A good plan leaves room for the unexpected.',
  ),
  10: EnglishContestantCopy(
    city: 'Izmir',
    occupation: 'Graphic Design student',
    shortBackground:
        'Instinctive, social, and at her best when the plan leaves room to play.',
    fullBackground:
        'Lalin studies graphic design and moves between illustration, music, and dance projects. Her best ideas tend to arrive in the middle of the mess.\n\nShe brings spontaneity to the stage, but rehearsal structure can slip when a new idea catches her attention.',
    archetype: 'Improviser',
    personalityTraits: ['Impulsive', 'Social', 'Messy', 'Bold'],
    primaryRole: 'All-Rounder',
    secondaryRoles: ['Lead Dancer'],
    specialTraitTitle: 'Improviser',
    specialTraitDescription:
        'She can turn mistakes into fresh, memorable stage moments.',
    riskTitle: 'Easily Distracted',
    riskDescription: 'New ideas can pull her focus away from the plan.',
    producerNote:
        'Her unpredictability can create magic or chaos. The right structure will decide which one.',
    quote: 'The best part is usually the thing nobody planned.',
  ),
  11: EnglishContestantCopy(
    city: 'Istanbul',
    occupation: 'New Media student and content creator',
    shortBackground:
        'She understands the camera—and knows exactly when it is watching.',
    fullBackground:
        'Arya studies new media and has built a small but loyal online audience. She understands framing, timing, and the rhythm of short-form content.\n\nThe camera gives her energy, but protecting her image can keep spontaneous emotion at a distance.',
    archetype: 'Camera Magnet',
    personalityTraits: ['Charismatic', 'Social', 'Skeptical', 'Ambitious'],
    primaryRole: 'Face of the Group',
    secondaryRoles: ['Center', 'Lead Dancer'],
    specialTraitTitle: 'Camera Magnet',
    specialTraitDescription:
        'She finds the lens instantly and makes short moments memorable.',
    riskTitle: 'Image Conscious',
    riskDescription:
        'She can focus so much on presentation that the moment stops feeling natural.',
    producerNote:
        'Already fluent in visibility. The challenge is showing something the audience cannot scroll past.',
    quote: 'The camera notices hesitation before people do.',
  ),
  12: EnglishContestantCopy(
    city: 'Ankara',
    occupation: 'Film and Television student',
    shortBackground:
        'Fast, funny, and impossible to predict once the cameras roll.',
    fullBackground:
        'Mina studies film and television and is usually the loudest energy in the room. She knows how to turn an ordinary backstage moment into a story.\n\nHer spontaneity makes great television, but speaking before thinking can create problems the team then has to solve.',
    archetype: 'Chaos Agent',
    personalityTraits: ['Energetic', 'Funny', 'Impulsive', 'Blunt'],
    primaryRole: 'All-Rounder',
    secondaryRoles: ['Lead Dancer'],
    specialTraitTitle: 'Energy Burst',
    specialTraitDescription:
        'She can instantly lift a flat rehearsal or performance.',
    riskTitle: 'Speaks Before Thinking',
    riskDescription: 'A quick joke or comment can spark unnecessary tension.',
    producerNote:
        'She is natural reality-show gold. Her energy needs direction without losing its spark.',
    quote: 'If everyone is quiet, I assume it’s my turn.',
  ),
  13: EnglishContestantCopy(
    city: 'Sakarya',
    occupation: 'Professional volleyball player',
    shortBackground:
        'Elite-sport discipline gives her stamina, focus, and a fierce competitive edge.',
    fullBackground:
        'Zeynep Ela comes from professional volleyball, where pressure, repetition, and teamwork are everyday realities. She brings that discipline into every rehearsal.\n\nThe stage is a new arena, but she treats each correction like match preparation and refuses to lose intensity.',
    archetype: 'Athlete Discipline',
    personalityTraits: [
      'Competitive',
      'Disciplined',
      'Hardworking',
      'Resilient',
    ],
    primaryRole: 'Performer',
    secondaryRoles: ['Dance', 'Team Leader'],
    specialTraitTitle: 'Match Fitness',
    specialTraitDescription:
        'Her stamina helps her maintain performance quality through demanding schedules.',
    riskTitle: 'Too Calculated',
    riskDescription:
        'She can treat creative choices like problems with only one correct answer.',
    producerNote:
        'Her work ethic is undeniable. She needs to let instinct share the court with discipline.',
    quote: 'Pressure does not scare me. It tells me the match has started.',
  ),
  14: EnglishContestantCopy(
    city: 'Mersin',
    occupation: 'Pilates instructor and amateur songwriter',
    shortBackground:
        'She takes time to open up, then reveals a quietly distinctive voice.',
    fullBackground:
        'Serra teaches Pilates and writes lyrics in her spare time. Her calm exterior hides an observant and emotionally precise creative side.\n\nShe rarely owns the first rehearsal, but becomes more compelling as she understands the room and finds her rhythm.',
    archetype: 'Slow Burn',
    personalityTraits: ['Composed', 'Sensitive', 'Observant', 'Determined'],
    primaryRole: 'Support Vocal',
    secondaryRoles: ['Lead Dancer', 'Songwriter'],
    specialTraitTitle: 'Composed',
    specialTraitDescription:
        'She stays clear-headed when pressure unsettles the rest of the team.',
    riskTitle: 'Slow to Warm Up',
    riskDescription:
        'Short evaluation windows may end before she shows her full range.',
    producerNote:
        'Not the loudest first impression, but she could become the member audiences discover and keep watching.',
    quote: 'I do not need to be first to be remembered.',
  ),
  15: EnglishContestantCopy(
    city: 'Bursa',
    occupation: 'First-year Fashion Design student',
    shortBackground:
        'Young, mischievous, and already building a visual language of her own.',
    fullBackground:
        'Nil is a first-year fashion design student who treats clothes, movement, and attitude as one creative idea. She is the youngest energy in the room.\n\nHer originality stands out immediately, though rules can feel optional when they get in the way of an exciting choice.',
    archetype: 'Mischievous Maknae',
    personalityTraits: ['Mischievous', 'Social', 'Bold', 'Messy'],
    primaryRole: 'Lead Dancer',
    secondaryRoles: ['Youngest Member', 'Visual'],
    specialTraitTitle: 'Original Style',
    specialTraitDescription:
        'She gives styling and stage concepts a distinctive youthful edge.',
    riskTitle: 'Bends the Rules',
    riskDescription:
        'She may ignore structure when a more exciting option appears.',
    producerNote:
        'A clear visual identity at a young age. She needs enough discipline to make that identity reliable.',
    quote:
        'Rules are useful. So is knowing when the look needs something else.',
  ),
};
