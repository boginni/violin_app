import 'package:flutter/material.dart';
import 'package:violin_l10n/violin_l10n.dart';

class HomeHeaderComponent extends StatelessWidget {
  const HomeHeaderComponent({
    super.key,
    required this.formKey,
    required this.urlController,
    required this.onShortenUrl,
    required this.validator,
    this.failureErrorText,
    this.isLoading = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController urlController;
  final VoidCallback onShortenUrl;
  final FormFieldValidator<String?> validator;
  final String? failureErrorText;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(16),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: .stretch,
          spacing: 8,
          children: [
            Row(
              spacing: 8,
              crossAxisAlignment: .start,
              children: [
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: urlController,
                    builder: (context, value, child) {
                      return TextFormField(
                        readOnly: isLoading,
                        enabled: !isLoading,
                        controller: urlController,
                        validator: validator,
                        keyboardType: .multiline,
                        maxLines: null,
                        autovalidateMode: .onUserInteraction,
                        decoration: InputDecoration(
                          contentPadding: const .symmetric(
                            vertical: 0,
                            horizontal: 16,
                          ),
                          prefixIcon: value.text.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () => urlController.text = '',
                                  icon: const Icon(
                                    Icons.close,
                                  ),
                                ),
                          errorText: failureErrorText,
                          hint: const Text('https://'),
                          label: Text(context.l10n.url),
                        ),
                      );
                    },
                  ),
                ),
                IconButton.filled(
                  onPressed: isLoading ? null : onShortenUrl,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
            Visibility(
              visible: isLoading,
              child: const LinearProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}
