// lib/screens/admin/admin_add_edit_news_screen.dart
//import 'package:education_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:sud_qollanma/l10n/app_localizations.dart';

import 'package:sud_qollanma/features/news/domain/entities/news_entity.dart';
import 'package:sud_qollanma/features/news/presentation/providers/news_notifier.dart';

class AdminAddEditNewsScreen extends StatefulWidget {
  final NewsEntity? newsItemToEdit;

  const AdminAddEditNewsScreen({super.key, this.newsItemToEdit});

  @override
  State<AdminAddEditNewsScreen> createState() => _AdminAddEditNewsScreenState();
}

class _AdminAddEditNewsScreenState extends State<AdminAddEditNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _sourceController;
  late TextEditingController _urlController;
  late TextEditingController _imageUrlController; // Optional image URL
  DateTime? _selectedPublicationDate;

  bool _isLoading = false;
  bool get _isEditing => widget.newsItemToEdit != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.newsItemToEdit?.title ?? '',
    );
    _sourceController = TextEditingController(
      text: widget.newsItemToEdit?.source ?? '',
    );
    _urlController = TextEditingController(
      text: widget.newsItemToEdit?.url ?? '',
    );
    _imageUrlController = TextEditingController(
      text: widget.newsItemToEdit?.imageUrl ?? '',
    ); // Optional
    _selectedPublicationDate =
        widget.newsItemToEdit?.publicationDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _sourceController.dispose();
    _urlController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickPublicationDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedPublicationDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedPublicationDate) {
      setState(() {
        _selectedPublicationDate = picked;
      });
    }
  }

  Future<void> _saveNews() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedPublicationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.pleaseSelectPublicationDate,
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ), // Add to l10n
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final l10n = AppLocalizations.of(context)!;
    final newsNotifier = Provider.of<NewsNotifier>(context, listen: false);
    // final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    // final adminUserId = authNotifier.currentUser?.uid; // If you want to log who made the change

    final newsData = NewsEntity(
      id: widget.newsItemToEdit?.id ?? '', // ID is empty if creating new
      title: _titleController.text.trim(),
      source: _sourceController.text.trim(),
      url: _urlController.text.trim(),
      imageUrl:
          _imageUrlController.text.trim().isEmpty
              ? null
              : _imageUrlController.text.trim(),
      publicationDate: _selectedPublicationDate,
      // You could add 'createdBy' or 'lastEditedBy' fields here using adminUserId
    );

    try {
      if (_isEditing) {
        await newsNotifier.updateNews(newsData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.newsUpdatedSuccess(newsData.title),
              ), // "'{newsTitle}' updated successfully."
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await newsNotifier.addNews(newsData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.newsAddedSuccess(newsData.title),
              ), // "'{newsTitle}' added successfully."
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      if (mounted) {
        Navigator.of(context).pop(); // Go back to the news list screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.failedToSaveNews(_titleController.text.trim(), e.toString()),
            ), // "Failed to save news: {error}"
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? l10n.editNewsTitle : l10n.addNewsTitle,
        ), // "Edit News" / "Add News"
        centerTitle: true,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save_outlined),
              tooltip: l10n.saveNewsTooltip, // "Save News"
              onPressed: _saveNews,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.newsTitleLabel, // "Title"
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.title_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterNewsTitle; // "Please enter a title."
                  }
                  if (value.trim().length < 5) {
                    return l10n.newsTitleMinLength(
                      5,
                    ); // "Title must be at least 5 characters."
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _sourceController,
                decoration: InputDecoration(
                  labelText: l10n.newsSourceLabel, // "Source (e.g., Blog Name)"
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.source_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n
                        .pleaseEnterNewsSource; // "Please enter a source."
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: l10n.newsUrlLabel, // "URL"
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.link_rounded),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterNewsUrl; // "Please enter a URL."
                  }
                  final uri = Uri.tryParse(value.trim());
                  if (uri == null ||
                      (!uri.isScheme('http') && !uri.isScheme('https'))) {
                    return l10n
                        .pleaseEnterValidNewsUrl; // "Please enter a valid URL (http or https)."
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: l10n.newsImageUrlLabel, // "Image URL (Optional)"
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.image_outlined),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final uri = Uri.tryParse(value.trim());
                    if (uri == null ||
                        (!uri.isScheme('http') && !uri.isScheme('https'))) {
                      return l10n
                          .pleaseEnterValidImageUrl; // "Please enter a valid image URL (http or https)."
                    }
                  }
                  return null; // Optional field
                },
              ),
              const SizedBox(height: 16.0),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text(l10n.publicationDateLabel), // "Publication Date"
                subtitle: Text(
                  _selectedPublicationDate == null
                      ? l10n
                          .noDateSelected // "No date selected"
                      : DateFormat.yMMMMd(
                        l10n.localeName,
                      ).format(_selectedPublicationDate!),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit_calendar_outlined),
                  onPressed: () => _pickPublicationDate(context),
                  tooltip: l10n.selectDateTooltip, // "Select Date"
                ),
                onTap: () => _pickPublicationDate(context),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(
                  _isEditing ? l10n.updateNewsButton : l10n.addNewsButtonForm,
                ), // "Update News" / "Add News Article"
                onPressed: _isLoading ? null : _saveNews,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add these new localization keys to your .arb files:
// "editNewsTitle": "Edit News",
// "addNewsTitle": "Add News Article",
// "saveNewsTooltip": "Save News",
// "newsTitleLabel": "Title",
// "pleaseEnterNewsTitle": "Please enter a news title.",
// "newsTitleMinLength": "News title must be at least {length} characters.",
// "newsSourceLabel": "Source (e.g., Blog Name)",
// "pleaseEnterNewsSource": "Please enter the news source.",
// "newsUrlLabel": "Article URL",
// "pleaseEnterNewsUrl": "Please enter the article URL.",
// "pleaseEnterValidNewsUrl": "Please enter a valid URL (starting with http or https).",
// "newsImageUrlLabel": "Image URL (Optional)",
// "pleaseEnterValidImageUrl": "Please enter a valid image URL (starting with http or https), or leave blank.",
// "publicationDateLabel": "Publication Date",
// "pleaseSelectPublicationDate": "Please select a publication date.",
// "noDateSelected": "No date selected",
// "selectDateTooltip": "Select Date",
// "updateNewsButton": "Update News",
// "addNewsButtonForm": "Add News Article",
// "newsUpdatedSuccess": "\"{newsTitle}\" updated successfully.",
// "newsAddedSuccess": "\"{newsTitle}\" added successfully.",
// "failedToSaveNews": "Failed to save news: {error}"
