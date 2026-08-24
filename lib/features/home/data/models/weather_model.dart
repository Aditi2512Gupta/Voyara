class WeatherModel {
  final double? temperature;
  final String? condition;
  final String? icon;
  final bool isAvailable;

  const WeatherModel({
    this.temperature,
    this.condition,
    this.icon,
    this.isAvailable = true,
  });

  factory WeatherModel.unavailable() {
    return const WeatherModel(
      temperature: null,
      condition: null,
      icon: null,
      isAvailable: false,
    );
  }

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: (json['main']?['temp'] as num?)?.toDouble(),
      condition: json['weather']?[0]?['main']?.toString(),
      icon: json['weather']?[0]?['icon']?.toString(),
      isAvailable: true,
    );
  }
}