
import 'codinates.dart';

Coordinates? binarySearch(List<Coordinates> locations, String target) {
  int left = 0;
  int right = locations.length - 1;

  while (left <= right) {
    int mid = (left + right) ~/ 2;
    int comparison = locations[mid].name.compareTo(target);

    if (comparison == 0) {
      return locations[mid];
    } else if (comparison < 0) {
      left = mid + 1;
    } else {
      right = mid - 1;
    }
  }
  return null;
}

Coordinates? realIsFound(List<Coordinates> locations, String target ){

  locations.sort((a, b) => a.name.compareTo(b.name));
  return  binarySearch(locations, target);

}

