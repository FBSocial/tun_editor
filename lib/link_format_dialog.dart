import 'package:flutter/material.dart';

class LinkFomratDialog extends StatefulWidget {

  final String defaultText;
  final String defaultUrl;

  const LinkFomratDialog({
    Key? key,
    this.defaultText = '',
    this.defaultUrl = '',
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => LinkFomratDialogState();

  static Future<List<String>?> show(
    BuildContext context, {
      String defaultText = '',
      String defaultUrl = '',
    }
  ) {
    return showDialog<List<String>?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LinkFomratDialog(
        defaultText: defaultText,
        defaultUrl: defaultUrl,
      ),
    );
  }

}

class LinkFomratDialogState extends State<LinkFomratDialog> {

  String get defaultText => widget.defaultText;
  String get defaultUrl => widget.defaultUrl;

  late TextEditingController textCtrl;
  late TextEditingController urlCtrl;

  bool isFormValid = false;

  @override
  void initState() {
    super.initState();
  
    textCtrl = TextEditingController(text: defaultText);
    urlCtrl = TextEditingController(text: defaultUrl);
    textCtrl.addListener(checkForm);
    urlCtrl.addListener(checkForm);
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      color: Color(0xFF363940),
      fontWeight: FontWeight.w500,
      fontSize: 16,
    );
    final hintStyle = TextStyle(
      color: Color(0xFF8F959E),
      fontSize: 16,
      height: 1.25,
    );
    final fieldStyle = TextStyle(
      color: Color(0xFF363940),
      fontSize: 16,
      height: 1.25,
    );
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Color(0x1A8F959E),
      hintStyle: hintStyle,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12,
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(4),
      ),
    );
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10),
            // Link text.
            Row(
              children: [
                SizedBox(width: 12),
                Text(
                  "文本",
                  style: labelStyle,
                ),
                SizedBox(width: 12),
                SizedBox(
                  width: 230,
                  height: 40,
                  child: TextField(
                    style: fieldStyle,
                    cursorColor: Color(0xFF5562F2),
                    textInputAction: TextInputAction.next,
                    decoration: inputDecoration.copyWith(
                      hintText: "输入文本",
                    ),
                    controller: textCtrl,
                    autofocus: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            // Link value.
            Row(
              children: [
                SizedBox(width: 12),
                Text(
                  "链接",
                  style: labelStyle,
                ),
                SizedBox(width: 12),
                SizedBox(
                  width: 230,
                  height: 40,
                  child: TextField(
                    style: fieldStyle,
                    cursorColor: Color(0xFF5562F2),
                    decoration: inputDecoration.copyWith(
                      hintText: "粘贴或输入一个链接",
                    ),
                    controller: urlCtrl,
                    onSubmitted: (_) => onLinkSubmit(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            // Button group.
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 65,
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Color(0xFF1F2125)),
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      side: MaterialStateProperty.all(BorderSide(
                        width: 0.5,
                        color: Color(0xFFDEE0E3),
                      )),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      textStyle: MaterialStateProperty.all(
                        TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                     ),
                    child: Text('取消'),
                  ),
                ),

                SizedBox(width: 12),

                SizedBox(
                  width: 65,
                  height: 40,
                  child: OutlinedButton(
                    onPressed: isFormValid ? onLinkSubmit : null,
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      backgroundColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
                        if (states.contains(MaterialState.disabled)) {
                          return Color(0x806179F2);
                        }
                        return Color(0xFF6179F2);
                      }),
                      side: MaterialStateProperty.all(BorderSide.none),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      textStyle: MaterialStateProperty.all(
                        TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                     ),
                    child: Text("确定"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    textCtrl.dispose();
    urlCtrl.dispose();
  
    super.dispose();
  }

  void checkForm() {
    setState(() {
      isFormValid = textCtrl.text.isNotEmpty && urlCtrl.text.isNotEmpty;
    });
  }

  void onLinkSubmit() {
    if (textCtrl.text.isEmpty || urlCtrl.text.isEmpty) {
      return;
    }
    Navigator.of(context).pop([
      textCtrl.text,
      urlCtrl.text,
    ]);
  }

}
