/// Strain data.
class Strain {
  /// Creates a new [Strain].
  Strain({
    this.name,
    this.otherNames,
    this.description,
    this.thc,
    this.averageRating,
    this.imageUrl,
    this.numberOfReviews,
    this.category,
    this.terpenes,
    this.effects,
    this.cannabinoids,
  });

  /// Creates a new [Strain] from JSON.
  Strain.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String?,
        otherNames = (json['otherNames'] as List<dynamic>?)?.cast(),
        description = json['description'] as String?,
        thc = json['thc'] as double?,
        averageRating = json['averageRating'] as double?,
        imageUrl = json['imageUrl'] as String?,
        numberOfReviews = json['numberOfReviews'] as int?,
        category = json['category'] as String?,
        terpenes = (json['terpenes'] as Map<String, dynamic>?)?.cast(),
        effects = (json['effects'] as Map<String, dynamic>?)?.cast(),
        cannabinoids = (json['cannabinoids'] as Map<String, dynamic>?)?.cast();

  /// The name of the strain.
  final String? name;

  /// Other names for this strain.
  final List<String>? otherNames;

  /// The description of the strain.
  final String? description;

  /// The THC content.
  final double? thc;

  /// The average rating of the strain.
  final double? averageRating;

  /// The nug image URL.
  final String? imageUrl;

  /// The number of reviews.
  final int? numberOfReviews;

  /// The strain category.
  final String? category;

  /// The terpene content.
  final Map<String, double?>? terpenes;

  /// The effects.
  final Map<String, double?>? effects;

  /// The cannabinoid content.
  final Map<String, double?>? cannabinoids;

  /// Returns the object in JSON format.
  Map<String, dynamic> toJson() => {
        'name': name,
        'otherNames': otherNames,
        'description': description,
        'thc': thc,
        'averageRating': averageRating,
        'imageUrl': imageUrl,
        'numberOfReviews': numberOfReviews,
        'category': category,
        'terpenes': terpenes,
        'effects': effects,
        'cannabinoids': cannabinoids,
      };
}
