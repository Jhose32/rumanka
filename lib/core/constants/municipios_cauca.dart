import 'package:latlong2/latlong.dart';

class MunicipiosCauca {
  static const LatLng centroCauca = LatLng(2.4448, -76.6147);

  static const List<Map<String, dynamic>> municipios = [
    {'nombre': 'Popayán',         'lat': 2.4448,  'lng': -76.6147},
    {'nombre': 'Santander de Q.', 'lat': 2.8564,  'lng': -76.4822},
    {'nombre': 'Puerto Tejada',   'lat': 3.2316,  'lng': -76.4156},
    {'nombre': 'Patía',           'lat': 2.0647,  'lng': -77.0497},
    {'nombre': 'Bolívar',         'lat': 1.8611,  'lng': -76.9756},
    {'nombre': 'Timbío',          'lat': 2.3536,  'lng': -76.6814},
    {'nombre': 'Piendamó',        'lat': 2.6397,  'lng': -76.5311},
    {'nombre': 'Caloto',          'lat': 3.0275,  'lng': -76.4194},
    {'nombre': 'Corinto',         'lat': 3.1744,  'lng': -76.2453},
    {'nombre': 'Cajibío',         'lat': 2.5947,  'lng': -76.5908},
    {'nombre': 'El Tambo',        'lat': 2.4536,  'lng': -76.8128},
    {'nombre': 'La Sierra',       'lat': 2.1583,  'lng': -76.8675},
    {'nombre': 'Rosas',           'lat': 2.2586,  'lng': -76.7303},
    {'nombre': 'La Vega',         'lat': 1.9933,  'lng': -76.8911},
    {'nombre': 'Almaguer',        'lat': 1.9192,  'lng': -76.8511},
    {'nombre': 'San Sebastián',   'lat': 1.7758,  'lng': -76.8225},
    {'nombre': 'Santa Rosa',      'lat': 1.6158,  'lng': -76.9706},
    {'nombre': 'Florencia',       'lat': 2.1114,  'lng': -76.6125},
    {'nombre': 'Sucre',           'lat': 2.0411,  'lng': -76.9528},
    {'nombre': 'Timbiquí',        'lat': 2.7711,  'lng': -77.6647},
    {'nombre': 'López de Micay',  'lat': 3.1944,  'lng': -77.2361},
    {'nombre': 'Guapi',           'lat': 2.5664,  'lng': -77.8964},
    {'nombre': 'Toribío',         'lat': 3.0036,  'lng': -76.2764},
    {'nombre': 'Jambaló',         'lat': 2.8597,  'lng': -76.3328},
    {'nombre': 'Caldono',         'lat': 2.7819,  'lng': -76.5000},
    {'nombre': 'Silvia',          'lat': 2.6167,  'lng': -76.3833},
    {'nombre': 'Páez',            'lat': 2.8428,  'lng': -76.0178},
    {'nombre': 'Inzá',            'lat': 2.5583,  'lng': -76.0661},
    {'nombre': 'Totoro',          'lat': 2.5278,  'lng': -76.3917},
    {'nombre': 'Puracé',          'lat': 2.3589,  'lng': -76.4197},
    {'nombre': 'Sotará',          'lat': 2.1939,  'lng': -76.5772},
    {'nombre': 'La Sierra',       'lat': 2.1583,  'lng': -76.8675},
    {'nombre': 'Argelia',         'lat': 1.8203,  'lng': -77.2556},
    {'nombre': 'Balboa',          'lat': 2.0147,  'lng': -77.2128},
    {'nombre': 'Florencia',       'lat': 2.1114,  'lng': -76.6125},
    {'nombre': 'Mercaderes',      'lat': 1.8028,  'lng': -77.1736},
    {'nombre': 'Miranda',         'lat': 3.2456,  'lng': -76.2281},
    {'nombre': 'Morales',         'lat': 2.7536,  'lng': -76.6367},
    {'nombre': 'Padilla',         'lat': 3.2028,  'lng': -76.3328},
    {'nombre': 'Suárez',          'lat': 2.9542,  'lng': -76.6894},
    {'nombre': 'Villa Rica',      'lat': 3.2181,  'lng': -76.4736},
    {'nombre': 'Buenos Aires',    'lat': 3.0131,  'lng': -76.6239},
  ];

  static LatLng? getCoordenadas(String municipio) {
    final found = municipios.firstWhere(
      (m) => m['nombre'] == municipio,
      orElse: () => {},
    );
    if (found.isEmpty) return null;
    return LatLng(found['lat'], found['lng']);
  }
}
