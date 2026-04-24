import 'package:cloud_firestore/cloud_firestore.dart';

import '../datasources/profile_remote_datasource.dart';
import '../home_data_loader.dart';

HomeDataLoader createHomeDataLoader() {
  return HomeDataLoader(ProfileRemoteDatasource(FirebaseFirestore.instance));
}
