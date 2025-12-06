import 'dart:math';
import 'package:love_connect/core/models/idea_model.dart';

class QuotesService {
  static final QuotesService _instance = QuotesService._internal();
  factory QuotesService() => _instance;
  QuotesService._internal();

  final List<String> _quotes = [
    'Love is composed of a single soul inhabiting two bodies',
    'The best thing to hold onto in life is each other',
    'Being deeply loved by someone gives you strength, while loving someone deeply gives you courage',
    'Love is not about how many days, months, or years you have been together. It\'s about how much you love each other every single day',
    'A successful marriage requires falling in love many times, always with the same person',
    'The best love is the kind that awakens the soul and makes us reach for more, that plants a fire in our hearts and brings peace to our minds',
    'Love recognizes no barriers. It jumps hurdles, leaps fences, penetrates walls to arrive at its destination full of hope',
    'In all the world, there is no heart for me like yours. In all the world, there is no love for you like mine',
    'Love is when the other person\'s happiness is more important than your own',
    'The greatest thing you\'ll ever learn is just to love and be loved in return',
    'Love is friendship that has caught fire',
    'I saw that you were perfect, and so I loved you. Then I saw that you were not perfect and I loved you even more',
    'Love is not finding someone to live with. It\'s finding someone you can\'t live without',
    'You don\'t love someone for their looks, or their clothes, or for their fancy car, but because they sing a song only you can hear',
    'Love is like the wind, you can\'t see it but you can feel it',
    'The best love is the kind that awakens the soul; that makes us reach for more, that plants the fire in our hearts',
    'Love is not about possession. Love is about appreciation',
    'I love you not only for what you are, but for what I am when I am with you',
    'Love is an untamed force. When we try to control it, it destroys us. When we try to imprison it, it enslaves us',
    'The best and most beautiful things in this world cannot be seen or even heard, but must be felt with the heart',
    'Love is patient, love is kind. It does not envy, it does not boast, it is not proud',
    'To love and be loved is to feel the sun from both sides',
    'Love is the master key that opens the gates of happiness',
    'The heart has its reasons which reason knows nothing of',
    'Love is the answer, and you know that for sure',
    'Love is a canvas furnished by nature and embroidered by imagination',
    'The best love is the kind that awakens the soul and makes us reach for more',
    'Love is not about how much you say "I love you", but how much you prove that it\'s true',
    'In your smile I see something more beautiful than the stars',
    'Love is the greatest refreshment in life',
  ];

  final List<IdeaModel> _ideas = [
    IdeaModel(
      id: '1',
      title: 'Sunrise Walk',
      category: 'Walk',
      location: 'Beachfront',
    ),
    IdeaModel(
      id: '2',
      title: 'Romantic Picnic',
      category: 'Dinner',
      location: 'Riverside Park',
    ),
    IdeaModel(
      id: '3',
      title: 'Movie Marathon',
      category: 'Movie',
      location: 'Home',
    ),
    IdeaModel(
      id: '4',
      title: 'Stargazing Night',
      category: 'Trip',
      location: 'City Rooftop',
    ),
    IdeaModel(
      id: '5',
      title: 'Surprise Dessert',
      category: 'Surprise',
      location: 'Favorite Bakery',
    ),
    IdeaModel(
      id: '6',
      title: 'Cooking Together',
      category: 'Dinner',
      location: 'Home',
    ),
    IdeaModel(
      id: '7',
      title: 'Sunset Beach',
      category: 'Trip',
      location: 'Beach',
    ),
    IdeaModel(
      id: '8',
      title: 'Dance Night',
      category: 'Surprise',
      location: 'Home',
    ),
    IdeaModel(
      id: '9',
      title: 'Wine Tasting',
      category: 'Dinner',
      location: 'Winery',
    ),
    IdeaModel(
      id: '10',
      title: 'Hiking Adventure',
      category: 'Trip',
      location: 'Mountain Trail',
    ),
    IdeaModel(
      id: '11',
      title: 'Spa Day',
      category: 'Surprise',
      location: 'Spa Center',
    ),
    IdeaModel(
      id: '12',
      title: 'Art Gallery Visit',
      category: 'Trip',
      location: 'Art Museum',
    ),
    IdeaModel(
      id: '13',
      title: 'Karaoke Night',
      category: 'Surprise',
      location: 'Home',
    ),
    IdeaModel(
      id: '14',
      title: 'Farmers Market',
      category: 'Walk',
      location: 'Local Market',
    ),
    IdeaModel(
      id: '15',
      title: 'Photography Session',
      category: 'Trip',
      location: 'Scenic Location',
    ),
  ];

  String getRandomQuote() {
    final random = Random();
    return _quotes[random.nextInt(_quotes.length)];
  }

  List<String> getAllQuotes() {
    return List.unmodifiable(_quotes);
  }

  List<IdeaModel> getAllIdeas() {
    return List.unmodifiable(_ideas);
  }

  List<IdeaModel> getRandomIdeas({int count = 5}) {
    final random = Random();
    final shuffled = List<IdeaModel>.from(_ideas)..shuffle(random);
    return shuffled.take(count).toList();
  }
}

