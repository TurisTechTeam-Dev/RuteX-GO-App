/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../domain/entities/home_data.dart';
import '../../domain/entities/home_route.dart';
import '../../domain/entities/home_route_result.dart';
import '../../domain/entities/profile_rank.dart';
import '../../domain/entities/user_profile.dart';

class HomeDataCache {
  const HomeDataCache();

  Future<HomeData?> read(String uid) async {
    try {
      final file = await _cacheFile(uid);
      if (!await file.exists()) return null;

      final content = await file.readAsString();
      final data = jsonDecode(content);
      if (data is! Map<String, dynamic>) return null;

      return _homeDataFromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(String uid, HomeData data) async {
    try {
      final file = await _cacheFile(uid);
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(_homeDataToJson(data)));
    } catch (_) {
      // La caché local es una ayuda de UX; no debe bloquear el home online.
    }
  }

  Future<File> _cacheFile(String uid) async {
    final directory = await getApplicationSupportDirectory();
    final safeUid = uid.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return File('${directory.path}/home_cache_$safeUid.json');
  }

  static Map<String, dynamic> _homeDataToJson(HomeData data) {
    return {
      'user': _userToJson(data.user),
      'routes': data.routes.map(_routeToJson).toList(),
      'ranks': data.ranks.map(_rankToJson).toList(),
    };
  }

  static HomeData _homeDataFromJson(Map<String, dynamic> json) {
    return HomeData(
      user: _userFromJson(_asMap(json['user'])),
      routes: _asList(json['routes']).map((item) {
        return _routeFromJson(_asMap(item));
      }).toList(),
      ranks: _asList(json['ranks']).map((item) {
        return _rankFromJson(_asMap(item));
      }).toList(),
    );
  }

  static Map<String, dynamic> _userToJson(UserProfile user) {
    return {
      'uid': user.uid,
      'name': user.name,
      'username': user.username,
      'email': user.email,
      'avatarUrl': user.avatarUrl,
      'points': user.points,
      'createdAt': user.createdAt?.toIso8601String(),
    };
  }

  static UserProfile _userFromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Sin nombre',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString() ?? '',
      points: _asInt(json['points']),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  static Map<String, dynamic> _rankToJson(ProfileRank rank) {
    return {
      'name': rank.name,
      'logo': rank.logo,
      'neededPoints': rank.neededPoints,
    };
  }

  static ProfileRank _rankFromJson(Map<String, dynamic> json) {
    return ProfileRank(
      name: json['name']?.toString() ?? '',
      logo: json['logo']?.toString() ?? '',
      neededPoints: _asInt(json['neededPoints']),
    );
  }

  static Map<String, dynamic> _routeToJson(HomeRoute route) {
    return {
      'id': route.id,
      'name': route.name,
      'totalPoints': route.totalPoints,
      'pointIds': route.pointIds,
      'totalMissions': route.totalMissions,
      'obtainedPoints': route.obtainedPoints,
      'completedMissions': route.completedMissions,
      'result': route.result == null ? null : _resultToJson(route.result!),
    };
  }

  static HomeRoute _routeFromJson(Map<String, dynamic> json) {
    return HomeRoute(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Ruta',
      totalPoints: _asInt(json['totalPoints']),
      pointIds: _asList(json['pointIds']).map((item) {
        return item.toString();
      }).toList(),
      totalMissions: _asInt(json['totalMissions']),
      obtainedPoints: _asInt(json['obtainedPoints']),
      completedMissions: _asInt(json['completedMissions']),
      result: json['result'] == null ? null : _resultFromJson(
        _asMap(json['result']),
      ),
    );
  }

  static Map<String, dynamic> _resultToJson(HomeRouteResult result) {
    return {
      'routeName': result.routeName,
      'previousBestScore': result.previousBestScore,
      'savedBestScore': result.savedBestScore,
      'attemptScore': result.attemptScore,
      'visitedPois': result.visitedPois,
      'totalPois': result.totalPois,
      'totalPossiblePoints': result.totalPossiblePoints,
      'correctAnswers': result.correctAnswers,
      'totalAnswers': result.totalAnswers,
      'time': result.time,
      'answerResults': result.answerResults.map(_answerToJson).toList(),
      'skippedPois': result.skippedPois,
    };
  }

  static HomeRouteResult _resultFromJson(Map<String, dynamic> json) {
    return HomeRouteResult(
      routeName: json['routeName']?.toString() ?? 'Ruta',
      previousBestScore: _asInt(json['previousBestScore']),
      savedBestScore: _asInt(json['savedBestScore']),
      attemptScore: _asInt(json['attemptScore']),
      visitedPois: _asInt(json['visitedPois']),
      totalPois: _asInt(json['totalPois']),
      totalPossiblePoints: _asInt(json['totalPossiblePoints']),
      correctAnswers: _asInt(json['correctAnswers']),
      totalAnswers: _asInt(json['totalAnswers']),
      time: json['time']?.toString() ?? '--',
      answerResults: _asList(json['answerResults']).map((item) {
        return _answerFromJson(_asMap(item));
      }).toList(),
      skippedPois: _asList(json['skippedPois']).map((item) {
        return item.toString();
      }).toList(),
    );
  }

  static Map<String, dynamic> _answerToJson(HomeAnswerResult answer) {
    return {
      'monumentName': answer.monumentName,
      'question': answer.question,
      'selectedAnswer': answer.selectedAnswer,
      'correctAnswer': answer.correctAnswer,
      'isCorrect': answer.isCorrect,
    };
  }

  static HomeAnswerResult _answerFromJson(Map<String, dynamic> json) {
    return HomeAnswerResult(
      monumentName: json['monumentName']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      selectedAnswer: json['selectedAnswer']?.toString() ?? '',
      correctAnswer: json['correctAnswer']?.toString() ?? '',
      isCorrect: json['isCorrect'] == true,
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);

    return {};
  }

  static List<dynamic> _asList(dynamic value) {
    if (value is List) return value;

    return const [];
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;

    return 0;
  }
}
