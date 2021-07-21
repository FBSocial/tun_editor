class TunEditorValue {
  
  String text;

  TunEditorValue({
    required this.text,
  });

  factory TunEditorValue.fromDocument(String document) {
    return TunEditorValue(
      text: document,
    );
  }

}
