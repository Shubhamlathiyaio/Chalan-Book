import 'package:chalan_book_app/features/chalan/bloc/chalan_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/organization.dart';
import '../bloc/organization_bloc.dart';

class UpdateChalanNumberDialog extends StatefulWidget {
  final Organization organization;

  const UpdateChalanNumberDialog({super.key, required this.organization});

  @override
  State<UpdateChalanNumberDialog> createState() =>
      _UpdateChalanNumberDialogState();
}

class _UpdateChalanNumberDialogState extends State<UpdateChalanNumberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _numberController.text = widget.organization.currentChalanNumber.toString();
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Current Chalan Number'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Organization: ${widget.organization.name}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _numberController,
              decoration: const InputDecoration(
                labelText: 'Current Chalan Number',
                hintText: 'Enter current chalan number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a chalan number';
                }
                final number = int.tryParse(value);
                if (number == null || number < 1) {
                  return 'Please enter a valid number (minimum 1)';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text(
              'This number will be used for the next chalan',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateChalanNumber,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update'),
        ),
      ],
    );
  }

  void _updateChalanNumber() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final newNumber = int.parse(_numberController.text);

    // context.read<ChalanBloc>().add(
    //   UpdateCurrentChalanNumberRequested(
    //     organizationId: widget.organization.id,
    //     newChalanNumber: newNumber,
    //   ),
    // );

    // Close dialog
    Navigator.of(context).pop(true);
  }
}
