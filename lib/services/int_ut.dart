
//static class, cannot use _Fun
class IntUt {

  //int(0/1) to boolean
  static bool toBool(int? value) {
    return (value != null && value > 0);
  }

  static String zeroToEmpty(int? value) {
    return (value == null || value == 0)
      ? '' : value.toString();
  }

} //class
