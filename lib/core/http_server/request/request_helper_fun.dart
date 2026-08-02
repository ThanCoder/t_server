String? getFieldName(String headerText) {
  for (final line in headerText.split('\r\n')) {
    if (!line.toLowerCase().startsWith('content-disposition:')) {
      continue;
    }

    for (final part in line.split(';')) {
      final value = part.trim();

      if (!value.startsWith('name=')) {
        continue;
      }

      return value.substring('name='.length).trim().replaceAll('"', '');
    }
  }

  return null;
}

String? getFilename(String headerText) {
  for (final line in headerText.split('\r\n')) {
    if (!line.toLowerCase().startsWith('content-disposition:')) {
      continue;
    }

    for (final part in line.split(';')) {
      final value = part.trim();

      if (!value.startsWith('filename=')) {
        continue;
      }

      return value.substring('filename='.length).trim().replaceAll('"', '');
    }
  }

  return null;
}

int indexOfBytes(List<int> source, List<int> target) {
  for (var i = 0; i <= source.length - target.length; i++) {
    var found = true;

    for (var j = 0; j < target.length; j++) {
      if (source[i + j] != target[j]) {
        found = false;
        break;
      }
    }

    if (found) {
      return i;
    }
  }

  return -1;
}
