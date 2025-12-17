import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType keyboardType;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onEditingComplete;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.validator,
    this.onChanged,
    this.onEditingComplete,
    this.prefixIcon,
    this.suffixIcon,
    this.textInputAction,
    this.focusNode,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() => _obscureText = !_obscureText);
                },
              )
            : widget.suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      keyboardType: widget.keyboardType,
      obscureText: _obscureText,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onEditingComplete: widget.onEditingComplete,
      textInputAction: widget.textInputAction,
      focusNode: widget.focusNode,
    );
  }
}
