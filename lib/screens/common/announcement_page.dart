// lib/screens/common/announcement_page.dart

import 'package:flutter/material.dart';
import 'package:edupay_app/models/announcement.dart';
import 'package:edupay_app/services/announcement_service.dart';
import 'package:edupay_app/utils/token_manager.dart'; // To check user role

class AnnouncementPage extends StatefulWidget {
  final bool isAdmin;
  const AnnouncementPage({super.key, this.isAdmin = false});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  final AnnouncementService _announcementService = AnnouncementService();
  late Future<List<Announcement>> _announcementsFuture;

  @override
  void initState() {
    super.initState();
    _announcementsFuture = _fetchAnnouncements();
  }

  Future<List<Announcement>> _fetchAnnouncements() async {
    if (widget.isAdmin) {
      // Admins can view announcements they created
      return _announcementService.getMyAnnouncements();
    } else {
      // Students view general announcements
      return _announcementService.getAnnouncementsForStudents();
    }
  }

  Future<void> _refreshAnnouncements() async {
    setState(() {
      _announcementsFuture = _fetchAnnouncements();
    });
  }

  Future<void> _showAnnouncementForm({Announcement? announcement}) async {
    final bool isEditing = announcement != null;
    final TextEditingController titleController = TextEditingController(text: announcement?.title);
    final TextEditingController contentController = TextEditingController(text: announcement?.content);
    final TextEditingController targetAudienceController = TextEditingController(text: announcement?.targetAudience);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Announcement' : 'New Announcement'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: 'Content'),
                  maxLines: 5,
                ),
                TextField(
                  controller: targetAudienceController,
                  decoration: const InputDecoration(labelText: 'Target Audience (e.g., All Students, Class 10)'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text(isEditing ? 'Update' : 'Post'),
              onPressed: () async {
                try {
                  final newAnnouncement = Announcement(
                    id: announcement?.id,
                    title: titleController.text,
                    content: contentController.text,
                    publishDate: isEditing ? announcement!.publishDate : DateTime.now(),
                    targetAudience: targetAudienceController.text.isEmpty ? null : targetAudienceController.text,
                  );

                  if (isEditing) {
                    await _announcementService.updateAnnouncement(announcement!.id!, newAnnouncement);
                    _showSnackBar('Announcement updated successfully!');
                  } else {
                    await _announcementService.createAnnouncement(newAnnouncement);
                    _showSnackBar('Announcement posted successfully!');
                  }
                  _refreshAnnouncements();
                  Navigator.of(context).pop();
                } catch (e) {
                  _showSnackBar('Error: ${e.toString().replaceFirst('Exception: ', '')}', isError: true);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAnnouncement(int id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this announcement?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _announcementService.deleteAnnouncement(id);
        _showSnackBar('Announcement deleted successfully!');
        _refreshAnnouncements();
      } catch (e) {
        _showSnackBar('Error: ${e.toString().replaceFirst('Exception: ', '')}', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          if (widget.isAdmin)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () => _showAnnouncementForm(),
                icon: const Icon(Icons.add_alert),
                label: const Text('Post New Announcement'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          Expanded(
            child: FutureBuilder<List<Announcement>>(
              future: _announcementsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error.toString().replaceFirst('Exception: ', '')}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No announcements found.'));
                } else {
                  return RefreshIndicator(
                    onRefresh: _refreshAnnouncements,
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final announcement = snapshot.data![index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  announcement.title,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  announcement.content,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    'Published: ${announcement.publishDate.toLocal().toString().split(' ')[0]}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                                  ),
                                ),
                                if (announcement.targetAudience != null && announcement.targetAudience!.isNotEmpty)
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      'Audience: ${announcement.targetAudience}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                if (widget.isAdmin)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _showAnnouncementForm(announcement: announcement),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteAnnouncement(announcement.id!),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          // onTap: () {
                          //   _showSnackBar('Viewing announcement: ${announcement.title}');
                          // },
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
// Note: The AnnouncementPage allows both admins and students to view announcements.
// Admins can create, edit, and delete their own announcements, while students can only view