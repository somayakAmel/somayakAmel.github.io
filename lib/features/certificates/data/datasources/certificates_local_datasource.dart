import '../../../../core/data/json_reader.dart';
import '../../../../core/data/local_json_datasource.dart';
import '../../../../core/managers/assets_manager.dart';
import '../models/certificate_model.dart';

abstract class CertificatesLocalDatasource {
  Future<List<CertificateModel>> getCertificates();
}

class CertificatesLocalDatasourceImpl implements CertificatesLocalDatasource {
  final LocalJsonDataSource _jsonDataSource;

  CertificatesLocalDatasourceImpl(this._jsonDataSource);

  @override
  Future<List<CertificateModel>> getCertificates() async {
    final Map<String, dynamic> json = await _jsonDataSource.readJson(
      AssetsManager.certificatesData,
    );
    return json
        .objList('certificates')
        .map(CertificateModel.fromJson)
        .toList(growable: false);
  }
}
