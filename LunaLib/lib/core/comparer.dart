/// Comparison operators for condition evaluation
enum Comparer {
  equalTo,
  notEqualTo,
  contains,
  doesNotContain,
  greaterThan,
  lessThan,
  startsWith,
  endsWith,
  matches,
  doesNotMatch,
  exists,
  doesNotExist,
}

/// Extension to parse Comparer from string
extension ComparerExtension on Comparer {
  static Comparer fromString(String value) {
    final upperValue = value.toUpperCase();
    switch (upperValue) {
      case 'EQUALTO':
      case 'EQUALS':
      case 'EQ':
        return Comparer.equalTo;
      case 'NOTEQUALTO':
      case 'NOTEQUALS':
      case 'NEQ':
      case 'DOESNOTEQUAL':
        return Comparer.notEqualTo;
      case 'CONTAINS':
      case 'CONTAIN':
        return Comparer.contains;
      case 'DOESNOTCONTAIN':
      case 'NOTCONTAINS':
      case 'NOTCONTAIN':
        return Comparer.doesNotContain;
      case 'GREATERTHAN':
      case 'GT':
        return Comparer.greaterThan;
      case 'LESSTHAN':
      case 'LT':
        return Comparer.lessThan;
      case 'STARTSWITH':
      case 'BEGINSWITH':
        return Comparer.startsWith;
      case 'ENDSWITH':
        return Comparer.endsWith;
      case 'MATCHES':
      case 'MATCHESREGEX':
      case 'REGEX':
        return Comparer.matches;
      case 'DOESNOTMATCH':
      case 'NOTMATCHES':
      case 'NOTMATCH':
        return Comparer.doesNotMatch;
      case 'EXISTS':
        return Comparer.exists;
      case 'DOESNOTEXIST':
      case 'NOTEXISTS':
      case 'NOTEXIST':
        return Comparer.doesNotExist;
      default:
        return Comparer.equalTo;
    }
  }
}
