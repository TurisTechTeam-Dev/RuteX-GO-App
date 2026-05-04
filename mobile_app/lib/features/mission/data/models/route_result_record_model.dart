import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_contract.dart';
import '../../domain/entities/route_result_record.dart';

class RouteResultRecordModel {
  const RouteResultRecordModel._();

  static Map<String, dynamic> toFirestore({
    required String uid,
    required RouteResultRecord result,
  }) {
    return {
      ResultFields.idUsuario: uid,
      ResultFields.idRuta: result.routeId,
      ResultFields.nombreRuta: result.routeName,
      ResultFields.mejorPuntuacionAnterior: result.previousBestScore,
      ResultFields.mejorPuntuacionGuardada: result.savedBestScore,
      ResultFields.puntuacionIntento: result.attemptScore,
      ResultFields.puntosInteresVisitados: result.visitedPois,
      ResultFields.misionesCompletadas: result.completedMissions,
      ResultFields.totalPuntosInteres: result.totalPois,
      ResultFields.puntosTotalesPosibles: result.totalPossiblePoints,
      ResultFields.tiempoIntento: result.elapsedTimeLabel,
      ResultFields.respuestasCorrectas: result.correctAnswers,
      ResultFields.totalRespuestas: result.totalAnswers,
      ResultFields.respuestas: result.answerResults.map(_answerToFirestore).toList(),
      ResultFields.puntosInteresSaltados: result.skippedPois,
      ResultFields.fechaCreacion: FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> _answerToFirestore(
    RouteAnswerResultRecord answer,
  ) {
    return {
      ResultAnswerFields.nombreMonumento: answer.monumentName,
      ResultAnswerFields.pregunta: answer.question,
      ResultAnswerFields.respuestaSeleccionada: answer.selectedAnswer,
      ResultAnswerFields.respuestaCorrecta: answer.correctAnswer,
      ResultAnswerFields.esCorrecta: answer.isCorrect,
    };
  }
}
