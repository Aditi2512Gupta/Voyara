import '../datasources/local/voyara_local_datasource.dart';
import '../models/destination_model.dart';

class VoyaraLocalRepository {
  const VoyaraLocalRepository(this.dataSource);

  final VoyaraLocalDataSource dataSource;

  Future<List<DestinationModel>> getDestinations() {
    return dataSource.getDestinations();
  }
}