import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LinkFormatDialog extends StatefulWidget {

  final String defaultText;
  final String defaultUrl;
  final bool isUrlAutofocus;

  // Primary color.
  final Color? primaryColor;
  final Color defaultPrimaryColor = const Color(0xFF198CFE);

  const LinkFormatDialog({
    Key? key,
    this.defaultText = '',
    this.defaultUrl = '',
    this.isUrlAutofocus = false,
    this.primaryColor,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => LinkFormatDialogState();

  static Future<List<String>?> show(
    BuildContext context, {
      String defaultText = '',
      String defaultUrl = '',
      bool isUrlAutofocus = false,
      Color? primaryColor,
    }
  ) {
    return showDialog<List<String>?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LinkFormatDialog(
        defaultText: defaultText,
        defaultUrl: defaultUrl,
        isUrlAutofocus: isUrlAutofocus,
        primaryColor: primaryColor,
      ),
    );
  }

}

class LinkFormatDialogState extends State<LinkFormatDialog> {

  String get defaultText => widget.defaultText;
  String get defaultUrl => widget.defaultUrl;
  bool get isUrlAutofocus => widget.isUrlAutofocus;

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
      fontSize: 16.w,
    );
    final hintStyle = TextStyle(
      color: Color(0xFF8F959E),
      fontSize: 16.w,
      height: 1.25,
    );
    final fieldStyle = TextStyle(
      color: Color(0xFF363940),
      fontSize: 16.w,
      height: 1.25,
    );
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Color(0x1A8F959E),
      hintStyle: hintStyle,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12.w,
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(4.w),
      ),
    );
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.w),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.w),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 12.w,
          horizontal: 16.w,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10.w),
            // Link text.
            Row(
              children: [
                SizedBox(width: 12.w),
                Text(
                  "文本",
                  style: labelStyle,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: SizedBox(
                    height: 40.w,
                    child: TextField(
                      style: fieldStyle,
                      cursorColor: widget.primaryColor ?? widget.defaultPrimaryColor,
                      textInputAction: TextInputAction.next,
                      decoration: inputDecoration.copyWith(
                        hintText: "输入文本",
                      ),
                      autofocus: !isUrlAutofocus,
                      controller: textCtrl,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.w),
            // Link value.
            Row(
              children: [
                SizedBox(width: 12.w),
                Text(
                  "链接",
                  style: labelStyle,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: SizedBox(
                    height: 40.w,
                    child: TextField(
                      style: fieldStyle,
                      cursorColor: widget.primaryColor ?? widget.defaultPrimaryColor,
                      decoration: inputDecoration.copyWith(
                        hintText: "粘贴或输入一个链接",
                      ),
                      autofocus: isUrlAutofocus,
                      controller: urlCtrl,
                      onSubmitted: (_) => onLinkSubmit(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.w),
            // Button group.
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 65.w,
                  height: 40.w,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Color(0xFF1F2125)),
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      side: MaterialStateProperty.all(BorderSide(
                        width: 0.5.w,
                        color: Color(0xFFDEE0E3),
                      )),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.w),
                        ),
                      ),
                      textStyle: MaterialStateProperty.all(
                        TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16.w,
                        ),
                      ),
                     ),
                    child: Text(
                      '取消',
                      style: TextStyle(
                        fontSize: 16.w,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                SizedBox(
                  width: 65.w,
                  height: 40.w,
                  child: OutlinedButton(
                    onPressed: isFormValid ? onLinkSubmit : null,
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      backgroundColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
                        if (states.contains(MaterialState.disabled)) {
                          return (widget.primaryColor ?? widget.defaultPrimaryColor).withAlpha(128);
                        }
                        return widget.primaryColor ?? widget.defaultPrimaryColor;
                      }),
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      side: MaterialStateProperty.all(BorderSide.none),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.w),
                        ),
                      ),
                      textStyle: MaterialStateProperty.all(
                        TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16.w,
                        ),
                      ),
                     ),
                    child: Text(
                      "确定",
                      style: TextStyle(
                        fontSize: 16.w,
                      ),
                    ),
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
